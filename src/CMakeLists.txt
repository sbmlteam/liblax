###############################################################################
# Description       : CMake build script for libLAX
###############################################################################

###############################################################################
#
# Initialize LAX sources
#
set(LIBLAX_SOURCES)

###############################################################################
#
# utility macro for copying files only if they have changed, for this it is
# assumed that the source file is always created. Then the macro is called.
# If the target file will only be overwritten if it does not yet exist, or
# its content is different. At the end the source file will be removed.
#
macro(copy_if_different_and_remove source target)
# message(
# "
# copy_if_different_and_remove called with:
#     source = ${source}
#     target = ${target}
# "
# )
file(READ ${source} CONTENT)

if (EXISTS ${target})
    # message("target exists")
    file(READ ${target} CURRENT_CONTENT)
    string(COMPARE EQUAL ${CURRENT_CONTENT} ${CONTENT} IS_SAME)
    if (NOT ${IS_SAME})
        #message("content is different")
        file(WRITE ${target} ${CONTENT})
    endif()
else()
    #message("target does not exist")
    file(WRITE ${target} ${CONTENT})
endif()

file(REMOVE ${source})

endmacro(copy_if_different_and_remove)

###############################################################################
#
# create liblax-config-common.h
#
include(CheckIncludeFiles)
check_include_files (check.h HAVE_CHECK_H)
check_include_files (expat.h HAVE_EXPAT_H)
check_include_files (errno.h HAVE_ERRNO_H)
check_include_files (ieeefp.h HAVE_IEEEFP_H)
check_include_files (math.h HAVE_MATH_H)
check_include_files (sys/types.h HAVE_SYS_TYPES_H)
check_include_files (float.h STDC_HEADERS)
check_include_files (stdarg.h STDC_HEADERS)
check_include_files (stdlib.h STDC_HEADERS)
check_include_files (string.h STDC_HEADERS)

set(WORDS_BIGENDIAN)
if (UNIX)
  include (TestBigEndian)
  test_big_endian(WORDS_BIGENDIAN)
else()
  # test_big_endian seems to fail with nmake (VS 2010) on windows
  # however, windows is always little endian, so catch this here
  set(WORDS_BIGENDIAN FALSE)
endif()

# for whatever reason some of the values are not correctly picked up
# so we encode these values here
if (MSVC)
  set(HAVE_ERRNO_H TRUE)
  set(HAVE_IEEEFP_H TRUE)
  set(STDC_HEADERS TRUE)
  set(HAVE_MATH_H TRUE)
  set(HAVE_SYS_TYPES_H TRUE)
endif()


include(CheckLibraryExists)
check_library_exists(m sqrt "" HAVE_LIBM)

# generate configuration for this system
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/xml/common/liblax-config-common.h.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/xml/common/liblax-config-common.h
)

# Replace: @PACKAGE_VERSION@ and @LIBLAX_VERSION_NUMERIC@
configure_file (
  "${CMAKE_CURRENT_SOURCE_DIR}/xml/common/liblax-version.h.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/xml/common/liblax-version.h"
)

configure_file (
  "${CMAKE_CURRENT_SOURCE_DIR}/xml/common/liblax-namespace.h.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/xml/common/liblax-namespace.h"
)

configure_file (
  "${CMAKE_CURRENT_SOURCE_DIR}/xml/common/liblax-package.h.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/xml/common/liblax-package.h"
)
  
###############################################################################
#
# mark header files for installation
#

foreach(dir common compress util )

    file(GLOB header_files "${CMAKE_CURRENT_SOURCE_DIR}/xml/${dir}/*.h")
    install(FILES ${header_files} DESTINATION include/xml/${dir})

endforeach(dir)


file(GLOB files "${CMAKE_CURRENT_SOURCE_DIR}/xml/*.h")
install(FILES ${files} DESTINATION include/xml)


###############################################################################
#
# copy build specific header files
#

file(GLOB additional_common "${CMAKE_CURRENT_BINARY_DIR}/xml/common/*.h")

install(FILES ${additional_common} DESTINATION include/xml/common)

###############################################################################
#
# specify include directories
#

include_directories(BEFORE ${LIBLAX_ROOT_SOURCE_DIR}/src/xml)
include_directories(BEFORE ${LIBLAX_ROOT_SOURCE_DIR}/src)
include_directories(BEFORE ${CMAKE_CURRENT_BINARY_DIR})
include_directories(BEFORE ${CMAKE_CURRENT_BINARY_DIR}/src)
include_directories(BEFORE ${CMAKE_CURRENT_BINARY_DIR}/src/xml)
if (EXTRA_INCLUDE_DIRS) 
 include_directories(${EXTRA_INCLUDE_DIRS})
endif(EXTRA_INCLUDE_DIRS)


###############################################################################
#
# Find all sources
#

macro(ADD_FUNCTION directory)

    set(prefix "xml/")

    if ("${directory}" STREQUAL "xml")
        set(prefix "")
    endif()


    file(GLOB temp
            ${prefix}${directory}/*.cpp
            ${prefix}${directory}/*.cxx
            ${prefix}${directory}/*.c
            ${prefix}${directory}/*.h)

    # create source group for IDEs
    source_group(${directory} FILES ${temp})

    # add to liblax sources
    set(LIBLAX_SOURCES ${LIBLAX_SOURCES} ${temp})

endmacro(ADD_FUNCTION)

foreach (directory common util)

	ADD_FUNCTION(${directory})
				       
endforeach()

###############################################################################
#
# Find compression sources and adjust include and lib directory
#
set (COMPRESS_SOURCES)
set(COMPRESS_SOURCES ${COMPRESS_SOURCES}
    xml/compress/CompressCommon.h
    xml/compress/CompressCommon.cpp
    xml/compress/InputDecompressor.cpp
    xml/compress/InputDecompressor.h
    xml/compress/OutputCompressor.cpp
    xml/compress/OutputCompressor.h
    )

if(WITH_BZIP2)

  set(COMPRESS_SOURCES ${COMPRESS_SOURCES}
        xml/compress/bzfstream.h
        xml/compress/bzfstream.cpp
        )
  include_directories(${LIBBZ_INCLUDE_DIR})
  set(LIBLAX_LIBS ${LIBLAX_LIBS} ${LIBBZ_LIBRARY})

endif()

if(WITH_ZLIB)

set(COMPRESS_SOURCES ${COMPRESS_SOURCES}
        xml/compress/zip.c
        xml/compress/zip.h
        xml/compress/unzip.h
        xml/compress/unzip.c
        xml/compress/ioapi.h
        xml/compress/ioapi.c
        xml/compress/zfstream.h
        xml/compress/zfstream.cpp
        xml/compress/zipfstream.cpp
        xml/compress/zipfstream.h
    )

    if (WIN32)
        #
        # compress/iowin32.c contains only symbols on WIN32 if we include
        # it on other platforms a warning is issued by ranlib about
        # no symbols. So it will only be included on windows.
        #
        set(COMPRESS_SOURCES ${COMPRESS_SOURCES}
            xml/compress/iowin32.c
            xml/compress/iowin32.h
        )
    endif()

    include_directories(${LIBZ_INCLUDE_DIR})
    set(LIBLAX_LIBS ${LIBLAX_LIBS} ${LIBZ_LIBRARY})

endif()

source_group(compress FILES ${COMPRESS_SOURCES})
set(LIBLAX_SOURCES ${LIBLAX_SOURCES} ${COMPRESS_SOURCES})

###############################################################################
#
# Find xml sources and adjust include and lib directory
#

set(XML_SOURCES)
set(XML_SOURCES ${XML_SOURCES}

  xml/XMLAttributes.cpp
  xml/XMLBuffer.cpp
  xml/XMLConstructorException.cpp
  xml/XMLError.cpp
  xml/XMLErrorLog.cpp
  xml/XMLLogOverride.cpp
  xml/XMLFileBuffer.cpp
  xml/XMLHandler.cpp
  xml/XMLInputStream.cpp
  xml/XMLMemoryBuffer.cpp
  xml/XMLNamespaces.cpp
  xml/XMLNode.cpp
  xml/XMLOutputStream.cpp
  xml/XMLParser.cpp
  xml/XMLToken.cpp
  xml/XMLTokenizer.cpp
  xml/XMLTriple.cpp
  xml/XMLAttributes.h
  xml/XMLBuffer.h
  xml/XMLConstructorException.h
  xml/XMLError.h
  xml/XMLErrorLog.h
  xml/XMLLogOverride.h
  xml/XMLFileBuffer.h
  xml/XMLHandler.h
  xml/XMLInputStream.h
  xml/XMLMemoryBuffer.h
  xml/XMLNamespaces.h
  xml/XMLNode.h
  xml/XMLOutputStream.h
  xml/XMLParser.h
  xml/XMLToken.h
  xml/XMLTokenizer.h
  xml/XMLTriple.h
)

if(WITH_EXPAT)

    set(XML_SOURCES ${XML_SOURCES}
        xml/ExpatAttributes.cpp
        xml/ExpatHandler.cpp
        xml/ExpatParser.cpp
        xml/ExpatAttributes.h
        xml/ExpatHandler.h
        xml/ExpatParser.h
    )
    set(LIBLAX_LIBS ${LIBLAX_LIBS} ${LIBEXPAT_LIBRARY})
    include_directories(${LIBEXPAT_INCLUDE_DIR})

endif(WITH_EXPAT)

if(WITH_LIBXML)

    set(XML_SOURCES ${XML_SOURCES}
        xml/LibXMLAttributes.cpp
        xml/LibXMLHandler.cpp
        xml/LibXMLNamespaces.cpp
        xml/LibXMLParser.cpp
        xml/LibXMLTranscode.cpp
        xml/LibXMLAttributes.h
        xml/LibXMLHandler.h
        xml/LibXMLNamespaces.h
        xml/LibXMLParser.h
        xml/LibXMLTranscode.h
    )
    set(LIBLAX_LIBS ${LIBLAX_LIBS} ${LIBXML_LIBRARY})
    include_directories(${LIBXML_INCLUDE_DIR})

endif(WITH_LIBXML)

if(WITH_XERCES)

    set(XML_SOURCES ${XML_SOURCES}
        xml/XercesAttributes.cpp
        xml/XercesHandler.cpp
        xml/XercesNamespaces.cpp
        xml/XercesParser.cpp
        xml/XercesTranscode.cpp
        xml/XercesAttributes.h
        xml/XercesHandler.h
        xml/XercesNamespaces.h
        xml/XercesParser.h
        xml/XercesTranscode.h
    )

    set(LIBLAX_LIBS ${LIBLAX_LIBS} ${XERCES_LIBRARY})
    include_directories(${XERCES_INCLUDE_DIR})


endif(WITH_XERCES)

source_group(xml FILES ${XML_SOURCES})
set(LIBLAX_SOURCES ${LIBLAX_SOURCES} ${XML_SOURCES})

###############################################################################
#
# this is a directory level operation!
#
if (MSVC)
if (WITH_STATIC_RUNTIME)
    foreach(flag_var
        CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
        CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO
        CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO)

        if(${flag_var} MATCHES "/MD")
            string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
        endif(${flag_var} MATCHES "/MD")


    endforeach(flag_var)
    add_definitions( -D_MT)
endif(WITH_STATIC_RUNTIME)
endif(MSVC)

###############################################################################
#
# Build library
#

if (NOT LIBLAX_SKIP_SHARED_LIBRARY)

add_library (${LIBLAX_LIBRARY} SHARED ${LIBLAX_SOURCES} )

if (LIBLAX_SHARED_VERSION)
  SET_TARGET_PROPERTIES(${LIBLAX_LIBRARY} PROPERTIES
                        SOVERSION ${LIBLAX_VERSION_MAJOR}
                        VERSION ${LIBLAX_VERSION_MAJOR}.${LIBLAX_VERSION_MINOR}.${LIBLAX_VERSION_PATCH})
endif()

target_link_libraries(${LIBLAX_LIBRARY} ${LIBLAX_LIBS} ${EXTRA_LIBS})

INSTALL(TARGETS ${LIBLAX_LIBRARY}
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )

endif()

add_library (${LIBLAX_LIBRARY}-static STATIC ${LIBLAX_SOURCES} )

if (WIN32 AND NOT CYGWIN)
    # don't decorate static library 
    set_target_properties(${LIBLAX_LIBRARY}-static PROPERTIES COMPILE_DEFINITIONS "LIBLAX_STATIC=1;LIBLAX_STATIC=1")
endif(WIN32 AND NOT CYGWIN)

target_link_libraries(${LIBLAX_LIBRARY}-static ${LIBLAX_LIBS} ${EXTRA_LIBS})

INSTALL(TARGETS ${LIBLAX_LIBRARY}-static
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

##############################################################################
#
# add native tests
#
add_subdirectory(xml)

##############################################################################
#
# construct list of all header files to create dependency list for 
# language bindings
#

file(GLOB LIBLAX_HEADER_FILES "${CMAKE_CURRENT_BINARY_DIR}/xml/common/*.h")    
foreach(file ${LIBLAX_SOURCES})
   
   if ("${file}" MATCHES "h$" )
     get_filename_component(full_path ${file} ABSOLUTE)
     list(APPEND LIBLAX_HEADER_FILES ${full_path})     
   endif()

endforeach()

