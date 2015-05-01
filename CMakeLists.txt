###############################################################################
#
# Description       : CMake build script for libLAX
###############################################################################

cmake_minimum_required(VERSION 2.6)
project(liblax)

set(LIBLAX_ROOT_SOURCE_DIR "${CMAKE_SOURCE_DIR}" CACHE PATH
    "Path to the libLAX root source directory")
set(LIBLAX_ROOT_BINARY_DIR "${CMAKE_BINARY_DIR}" CACHE PATH
    "Path to the libLAX root build directory")

include (CMakeTestCCompiler)
include (CheckCSourceCompiles)
include (CheckCXXSourceCompiles)
include (CheckStructHasMember)
include (CheckLibraryExists)
include (CheckFunctionExists)
include (CheckCCompilerFlag)
include (CheckCSourceRuns)
include (CheckSymbolExists)
include (CheckTypeSize)

###############################################################################
#
# Parse VERSION.txt to determine the package version
#

set(LIBLAX_VERSION_MAJOR)
set(LIBLAX_VERSION_MINOR)
set(LIBLAX_VERSION_PATCH)
set(LIBLAX_VERSION_RELEASE)

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")

    file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" VersionString NEWLINE_CONSUME)
    string(STRIP "${VersionString}" VersionString)
    string(REPLACE "." ";" VersionString "${VersionString}" )
    string(REPLACE "-" ";" VersionString "${VersionString}" )
    list(LENGTH VersionString versionLength)
    list(GET VersionString 0 LIBLAX_VERSION_MAJOR )
    list(GET VersionString 1 LIBLAX_VERSION_MINOR )
    list(GET VersionString 2 LIBLAX_VERSION_PATCH )

    if(${versionLength} GREATER 3)
        list(GET VersionString 3 LIBLAX_VERSION_RELEASE )
    endif()

endif()

# version number needs to be calculated correctly
MATH(EXPR LIBLAX_VERSION_NUMERIC "${LIBLAX_VERSION_MAJOR} * 10000 + ${LIBLAX_VERSION_MINOR} * 100 + ${LIBLAX_VERSION_PATCH}" )
set(PACKAGE_VERSION "${LIBLAX_VERSION_MAJOR}.${LIBLAX_VERSION_MINOR}.${LIBLAX_VERSION_PATCH}${LIBLAX_VERSION_RELEASE}")
set(PACKAGE_NAME "libLAX")

# add make dist and make check target as they are already familiar for
# everyone using the gnumake build
add_custom_target(dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)
add_custom_target(check COMMAND ${CMAKE_MAKE_PROGRAM} test)

###############################################################################
#
# The next lines configure the parameters for packaging the binaries.
# They can be invoked with "make package" or "nmake package" or by using
# cpack -G zip|deb|rpm|dmg|nsis
#

include(InstallRequiredSystemLibraries)

set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "An API library for reading/writing XML.")
set(CPACK_PACKAGE_NAME "${PACKAGE_NAME}")
set(CPACK_PACKAGE_VENDOR "The libSBML Team")
set(CPACK_PACKAGE_CONTACT "LibSBML Team <libsbml-team@caltech.edu>")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README.txt")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYING.txt")
set(CPACK_PACKAGE_VERSION_MAJOR "${LIBLAX_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${LIBLAX_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${LIBLAX_VERSION_PATCH}")
set(CPACK_RPM_PACKAGE_LICENSE "LGPL")
set(CPACK_RPM_PACKAGE_GROUP "Libraries/Development")
set(CPACK_DEBIAN_PACKAGE_SECTION "Libraries")

set(CPACK_SOURCE_IGNORE_FILES "${CMAKE_CURRENT_BINARY_DIR};/.svn/;/.libs/;/.deps/;/.bzr/;.*.o$;.*.lo$;.*.la$;${CPACK_SOURCE_IGNORE_FILES};/.DS_Store;/.svnignore;blib;liblax-dist")

if(UNIX)
    set(CPACK_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")
    set(CPACK_SET_DESTDIR "ON")
endif()

if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "i386")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "i386")
else()
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
    set(CPACK_RPM_PACKAGE_ARCHITECTURE "x86_64")
endif()

include(CPack)


###############################################################################
#
# Here we have the main configuration options for liblax.
#


# Build static / shared library
# option(BUILD_SHARED_LIBS  "Build shared library. (Set to OFF to build static libraries.)" OFF)


# Add an option to compile with all warnings shown
option(WITH_WALL     "Compile with -Wall, so that the compiler will display all warnings." OFF)
mark_as_advanced(WITH_WALL)

if(WITH_WALL)
    if(MSVC OR USING_INTEL)
        add_definitions(/W4)
    else()
        add_definitions(-Wall)
    endif()
endif()

set(LIBLAX_BUILD_TYPE "native")
if (CMAKE_SIZEOF_VOID_P EQUAL 4)
  set(LIBLAX_BUILD_TYPE "32bit")
else()
  set(LIBLAX_BUILD_TYPE "64bit")
endif()
if (APPLE AND ENABLE_UNIVERSAL)
  set(LIBLAX_BUILD_TYPE "universal")
endif()

# When allocation of memory fails or the libLAX C API is unable to open
# a file, libLAX can exit the current process. By default this behavior
# is disabled.
#
option (EXIT_ON_ERROR "Call exit(-1) in case of allocation or file error." OFF)
mark_as_advanced(EXIT_ON_ERROR)

# Use the version number in the shared library.
#
option (LIBLAX_SHARED_VERSION
"Include version information into the compiled libLAX shared library." ON)
mark_as_advanced(LIBLAX_SHARED_VERSION)

# Enable the generation of unit tests. If enabled, all test runners
# will be created and can be run with "make test" or ctest.
# This won't work in Visual Studio 2003, so we disable this option there.
#
if(NOT ${CMAKE_GENERATOR} MATCHES "Visual Studio 6" AND NOT ${CMAKE_GENERATOR} MATCHES "Visual Studio 7")
    option(WITH_CHECK
"Compile the libLAX unit tests. (You can then run the tests with the
command 'make test' or 'ctest'.)" OFF)
endif()

# Choose the xml parsing library to be used.
option(WITH_EXPAT    "Use the Expat XML parser library."     OFF)
option(WITH_LIBXML   "Use the libxml2 XML parser library."   ON )
option(WITH_XERCES   "Use the Xerces XML parser library."    OFF)

# Use C++ namespace.
option(WITH_CPP_NAMESPACE "Use a C++ namespace for libLAX."   OFF)


# Set build type default.
set(CMAKE_BUILD_TYPE "Release" CACHE STRING
  "Choose the type of build to perform. The options are: None (CMAKE_CXX_FLAGS
or CMAKE_C_FLAGS are used), Debug, Release, RelWithDebInfo, MinSizeRel.")
if("${CMAKE_BUILD_TYPE}" STREQUAL "")
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING
    "Choose the type of build to perform. The options are: None (CMAKE_CXX_FLAGS
or CMAKE_C_FLAGS are used), Debug, Release, RelWithDebInfo, MinSizeRel." FORCE)
endif()

# Set the default dependency directory.
set(LIBLAX_DEPENDENCY_DIR ${LIBLAX_ROOT_SOURCE_DIR}/dependencies/ CACHE PATH
  "Directory containing libraries that libLAX depends upon.
(Particularly important on Windows.)")
if("${LIBLAX_DEPENDENCY_DIR}" STREQUAL "")
  set(LIBLAX_DEPENDENCY_DIR ${LIBLAX_ROOT_SOURCE_DIR}/dependencies/ CACHE PATH
    "Directory containing libraries that libLAX depends upon.
(Particularly important on Windows.)" FORCE)
endif()


###############################################################################
#
# If WITH_SWIG is selected, we need to find swig
#
set(LIBLAX_USE_CPP_NAMESPACE OFF)
if(WITH_CPP_NAMESPACE)
    add_definitions(-DLIBLAX_USE_CPP_NAMESPACE)
    set(LIBLAX_USE_CPP_NAMESPACE ON)	
endif()

# Locate expat if needed
#

set(LIBLAX_XML_LIBRARY)
set(LIBLAX_XML_LIBRARY_INCLUDE)
set(LIBLAX_XML_LIBRARY_LIBS)

if(WITH_EXPAT)
  if (NOT LIBEXPAT_LIBRARY)  
    find_library(LIBEXPAT_LIBRARY
        NAMES libexpat.lib expat
        PATHS ${LIBLAX_DEPENDENCY_DIR}/lib
              /usr/lib /usr/local/lib
              /usr/lib/i386-linux-gnu
        DOC "The file name of the Expat library."
                )

  endif()
  
  if (NOT LIBEXPAT_INCLUDE_DIR)
    find_path(LIBEXPAT_INCLUDE_DIR
        NAMES expat.h
        PATHS ${LIBLAX_DEPENDENCY_DIR}/include
              /usr/include /usr/local/include
              ${CMAKE_OSX_SYSROOT}/usr/include              
        DOC "The directory containing the Expat include files."
              )
  endif()
  
    add_definitions( -DUSE_EXPAT )
    list(APPEND SWIG_EXTRA_ARGS -DUSE_EXPAT)	

    set(LIBLAX_XML_LIBRARY "expat")
    set(LIBLAX_XML_LIBRARY_INCLUDE ${LIBEXPAT_INCLUDE_DIR})
    set(LIBLAX_XML_LIBRARY_LIBS ${LIBEXPAT_LIBRARY})

    if(NOT EXISTS "${LIBEXPAT_INCLUDE_DIR}/expat.h")
        message(FATAL_ERROR
"The include directory specified for Expat appears to be invalid.
It should contain the file expat.h, but it does not.")
    endif()
endif(WITH_EXPAT)


###############################################################################
#
# Locate Libxml2 if needed
#
set(USE_LIBXML OFF)
if(WITH_LIBXML)
  if (NOT LIBXML_LIBRARY)
    find_library(LIBXML_LIBRARY
        NAMES libxml2.lib xml2
        PATHS /usr/lib /usr/local/lib
              ${LIBLAX_DEPENDENCY_DIR}/lib
        DOC "The file name of the libxml2 library."
                )
  endif()
  
  if (NOT LIBXML_INCLUDE_DIR)
    find_path(LIBXML_INCLUDE_DIR
        NAMES libxml/parser.h
        PATHS ${LIBLAX_DEPENDENCY_DIR}/include
              /usr/include /usr/local/include
              /usr/include/libxml2
              ${CMAKE_OSX_SYSROOT}/usr/include/libxml2
              /usr/local/include/libxml2

        DOC "The directory containing the libxml2 include files."
              )
  endif()
    
  add_definitions( -DUSE_LIBXML )
  list(APPEND SWIG_EXTRA_ARGS -DUSE_LIBXML)	
  set(USE_LIBXML ON)

  set(LIBLAX_XML_LIBRARY "libxml2")
  set(LIBLAX_XML_LIBRARY_INCLUDE ${LIBXML_INCLUDE_DIR})
  set(LIBLAX_XML_LIBRARY_LIBS ${LIBXML_LIBRARY})

  if(NOT EXISTS "${LIBXML_INCLUDE_DIR}/libxml/parser.h")
        message(FATAL_ERROR
"The include directory specified for libxml appears to be invalid.
It should contain the file libxml/parser.h, but it does not.")
  endif()
endif(WITH_LIBXML)


###############################################################################
#
# Locate xerces
#

if(WITH_XERCES)
    add_definitions( -DUSE_XERCES )
    list(APPEND SWIG_EXTRA_ARGS -DUSE_XERCES)

    find_library(XERCES_LIBRARY
        NAMES xerces-c_3.lib xerces-c
        PATHS /usr/lib /usr/local/lib
              ${LIBLAX_DEPENDENCY_DIR}/lib
        DOC "The file name of the Xerces library."
                )

    find_path(XERCES_INCLUDE_DIR
        NAMES xercesc/parsers/XercesDOMParser.hpp
        PATHS /usr/include /usr/local/include
              ${CMAKE_OSX_SYSROOT}/usr/include/xercesc
              /usr/include/xercesc
              /usr/local/include/xercesc
              ${LIBLAX_DEPENDENCY_DIR}/include
        DOC "The directory containing the Xerces include files."
              )

    set(LIBLAX_XML_LIBRARY "xerces-c")
    set(LIBLAX_XML_LIBRARY_INCLUDE ${XERCES_INCLUDE_DIR})
    set(LIBLAX_XML_LIBRARY_LIBS ${XERCES_LIBRARY})

    if(NOT EXISTS "${XERCES_INCLUDE_DIR}/xercesc/parsers/XercesDOMParser.hpp")
        message(FATAL_ERROR
"The include directory specified for Xerces appears to be invalid.
It should contain the file xercesc/parsers/XercesDOMParser.hpp, but
it does not.")
    endif()

endif(WITH_XERCES)


###############################################################################
#
# Locate bz2
#

set(BZIP_INITIAL_VALUE)
if (NOT LIBBZ_LIBRARY)
find_library(LIBBZ_LIBRARY
    NAMES bzip2.lib bz2 libbz2.lib
    PATHS /usr/lib /usr/local/lib
          ${CMAKE_OSX_SYSROOT}/usr/lib
          ${LIBLAX_DEPENDENCY_DIR}/lib
    DOC "The file name of the bzip2 library."
)
endif()

if(EXISTS ${LIBBZ_LIBRARY})
    set(BZIP_INITIAL_VALUE ON)
else()
    set(BZIP_INITIAL_VALUE OFF)
endif()

option(WITH_BZIP2    "Enable the use of bzip2 compression."  ${BZIP_INITIAL_VALUE})
set(USE_BZ2 OFF)
if(WITH_BZIP2)

  if (NOT LIBBZ_INCLUDE_DIR)
    find_path(LIBBZ_INCLUDE_DIR
        NAMES bzlib.h bzip2/bzlib.h
        PATHS ${CMAKE_OSX_SYSROOT}/usr/include
              /usr/include /usr/local/include
              ${LIBLAX_DEPENDENCY_DIR}/include
              NO_DEFAULT_PATH
        DOC "The directory containing the bzip2 include files."
        )
  endif()

  if (NOT LIBBZ_INCLUDE_DIR)
      find_path(LIBBZ_INCLUDE_DIR
        NAMES bzlib.h bzip2/bzlib.h
        PATHS ${CMAKE_OSX_SYSROOT}/usr/include
              /usr/include /usr/local/include
              ${LIBLAX_DEPENDENCY_DIR}/include
        DOC "The directory containing the bzip2 include files."
              )
  endif()

    set(USE_BZ2 ON)
    add_definitions( -DUSE_BZ2 )
	list(APPEND SWIG_EXTRA_ARGS -DUSE_BZ2)

    # make sure that we have a valid bzip2 library
    check_library_exists("${LIBBZ_LIBRARY}" "BZ2_bzCompressInit" "" LIBBZ_FOUND_SYMBOL)
    if(NOT LIBBZ_FOUND_SYMBOL)
        # this is odd, but on windows this check always fails! must be a
        # bug in the current cmake version so for now only issue this
        # warning on linux
        if(UNIX)
            message(WARNING 
"The chosen bz2 library does not appear to be valid because it is
missing some required symbols. Please check that ${LIBBZ_LIBRARY}
is the bzip2 library. For details about the error, please see
${LIBLAX_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log")
        endif()
    endif()
    if(NOT EXISTS "${LIBBZ_INCLUDE_DIR}/bzlib.h")
        message(FATAL_ERROR
"The include directory specified for the bz2 library does not
appear to be valid.  It should contain the file bzlib.h, but
it does not.")
    endif()


endif(WITH_BZIP2)


###############################################################################
#
# list of additional files to link against.
#

set(EXTRA_LIBS "" CACHE STRING
"List of additional libraries to link against.  Separate multiple
names using semicolons." )
set(EXTRA_INCLUDE_DIRS "" CACHE STRING
"List of additional include directories to use during compilation.
Separate multiple directories using semicolons." )


###############################################################################
#
# Locate zlib
#

set(ZLIB_INITIAL_VALUE)
if (NOT LIBZ_LIBRARY)
find_library(LIBZ_LIBRARY
    NAMES zdll.lib z zlib.lib
    PATHS /usr/lib /usr/local/lib
          ${CMAKE_OSX_SYSROOT}/usr/lib
          ${LIBLAX_DEPENDENCY_DIR}/lib
    DOC "The file name of the zip compression library."
    )
endif()

if(EXISTS ${LIBZ_LIBRARY})
    set(ZLIB_INITIAL_VALUE ON)
else()
    set(ZLIB_INITIAL_VALUE OFF)
endif()
option(WITH_ZLIB     "Enable the use of zip compression."    ${ZLIB_INITIAL_VALUE} )

set(USE_ZLIB OFF)
if(WITH_ZLIB)

  if (NOT LIBZ_INCLUDE_DIR)
    find_path(LIBZ_INCLUDE_DIR
        NAMES zlib.h zlib/zlib.h
        PATHS ${CMAKE_OSX_SYSROOT}/usr/include
              /usr/include /usr/local/include
              ${LIBLAX_DEPENDENCY_DIR}/include
              NO_DEFAULT_PATH
        DOC "The directory containing the zlib include files."
              )
  endif()
    if (NOT LIBZ_INCLUDE_DIR)
        find_path(LIBZ_INCLUDE_DIR
        NAMES zlib.h zlib/zlib.h
        PATHS ${CMAKE_OSX_SYSROOT}/usr/include
              /usr/include /usr/local/include
              ${LIBLAX_DEPENDENCY_DIR}/include
        DOC "The directory containing the zlib include files."
              )
    endif()
    set(USE_ZLIB ON)
    add_definitions( -DUSE_ZLIB )
	list(APPEND SWIG_EXTRA_ARGS -DUSE_ZLIB)	

    # make sure that we have a valid zip library
    check_library_exists("${LIBZ_LIBRARY}" "gzopen" "" LIBZ_FOUND_SYMBOL)
    if(NOT LIBZ_FOUND_SYMBOL)
        # this is odd, but on windows this check always fails! must be a
        # bug in the current cmake version so for now only issue this
        # warning on linux
        if(UNIX)
            message(WARNING
"The chosen zlib library does not appear to be valid because it is
missing certain required symbols. Please check that ${LIBZ_LIBRARY} is
the correct zlib library. For details about the error, please see
${LIBLAX_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log")
        endif()
    endif()

    if(NOT EXISTS "${LIBZ_INCLUDE_DIR}/zlib.h")
        message(FATAL_ERROR
"The include directory specified for zlib does not appear to be
valid. It should contain the file zlib.h, but it does not.")
    endif()

endif(WITH_ZLIB)


###############################################################################
#
# Enable support for testing ... can be invoked by running ctest
# or make test
#

if(WITH_CHECK)

    # we do use tests, that require 2.8.4
    cmake_minimum_required(VERSION 2.8.4)

    # set test timeout to 3000 as the normal time limit is not sufficient
    # for the comp tests
    SET(DART_TESTING_TIMEOUT "3000" CACHE STRING "" FORCE)
    
    enable_testing()

    find_library(LIBCHECK_LIBRARY
        NAMES check libcheck
        PATHS /usr/lib /usr/local/lib ${LIBLAX_DEPENDENCY_DIR}/lib
        DOC "The file name of the libcheck library."
    )

    find_path(LIBCHECK_INCLUDE_DIR
        NAMES check.h
        PATHS /usr/include /usr/local/include  ${LIBLAX_DEPENDENCY_DIR}/include
        DOC "The directory containing the libcheck include files."
              )

    if(NOT EXISTS "${LIBCHECK_INCLUDE_DIR}/check.h")
        message(FATAL_ERROR
"The include directory specified for the 'check' library appears to be
invalid. It should contain the file check.h, but it does not.")
    endif()

    if(${CMAKE_GENERATOR} MATCHES "Visual Studio 6" OR ${CMAKE_GENERATOR} MATCHES "Visual Studio 7")
        message(WARNING "Libcheck is not compatible with Visual Studio 2003 (or earlier versions).")
    endif()

	if (UNIX)
      # setup valgrind
      set(CMAKE_MEMORYCHECK_COMMAND valgrind)
      set(CMAKE_MEMORYCHECK_COMMAND_OPTIONS
         "--error-exitcode=1 --trace-children=yes --leak-check=full --show-reachable=yes --leak-resolution=high --track-origins=yes --error-limit=no ")

      set(MEMCHECK_COMMAND
         "${CMAKE_MEMORYCHECK_COMMAND} ${CMAKE_MEMORYCHECK_COMMAND_OPTIONS}")
      separate_arguments(MEMCHECK_COMMAND)
	endif()

    include(CTest)

endif(WITH_CHECK)


###############################################################################
#
# Need some variables set up, such as the name for the libLAX
# library and the Path and file separator characters. The
# MISC_PREFIX variable will cause libsbml bindings, examples and
# documentation to be installed in PREFIX/${MISC_PREFIX}.
#

set( MISC_PREFIX )
if(UNIX OR CYGWIN)
    set(PATH_SEP "/")
    set(FILE_SEP ":")
    set( MISC_PREFIX "share/liblax/" )
    set(LIBLAX_LIBRARY lax)
else()
    set( MISC_PREFIX "" )
    set(PATH_SEP "\\")
    set(FILE_SEP ";")
    if(MINGW)
        set(LIBLAX_LIBRARY lax)
    else()
        set(LIBLAX_LIBRARY liblax)
    endif()
endif()

# On some Linux  (64bit) systems (64bit) the libraries should be installed into lib64 rather
# than lib. It will default to 'lib' but can be overwritten.

set(CMAKE_INSTALL_LIBDIR lib CACHE PATH "Full path to the library output directory")
mark_as_advanced(CMAKE_INSTALL_LIBDIR)

###############################################################################
#
# Set up remaining variables, add option for universal binaries
#

set(USING_INTEL)
if (WIN32 AND CMAKE_C_COMPILER AND ${CMAKE_C_COMPILER} MATCHES ".*icl.*$")
  message(STATUS "Detected Intel Compiler")
  set(USING_INTEL TRUE)
endif ()


set(BUILD_DEFINITIONS)
if(UNIX)
    if(APPLE)
        # on osx starting with xcode 4.3 the system root is in
        # the app bundle, however cmake (up to 2.8.8) does not seem
        # to update the path, so lets try it here
        if (CMAKE_OSX_SYSROOT AND NOT EXISTS ${CMAKE_OSX_SYSROOT})
          if (EXISTS "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/${CMAKE_OSX_SYSROOT}")
            set(CMAKE_OSX_SYSROOT "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/${CMAKE_OSX_SYSROOT}" CACHE STRING "The SDK root to be used" FORCE)
          endif()
        endif()
        add_definitions(-DMACOSX)
        set(BUILD_DEFINITIONS "${BUILD_DEFINITIONS} -DMACOSX")

        # Since we are encountering errors with the use of libc++ on OSX
        # this option allows to override which stdlib to use
        if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
          option(CLANG_USE_STDLIB "Use libstdc++ rather than libc++" OFF)
          if (CLANG_USE_STDLIB)
            SET( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libstdc++" )
          endif()
        endif()
        
        # On OSX it is common to build universal binaries to support multiple
        # processor architectures. The default behavior is not to build
        # multiple architectures, as most users might not need that.
        option(ENABLE_UNIVERSAL
          "Create 'universal' binaries on Mac OS X. (Not available on
other operating systems.)" OFF)

        set(CMAKE_OSX_ARCHITECTURES "${CMAKE_OSX_ARCHITECTURES}" CACHE STRING
           "A semicolon-separated list of architectures for which libLAX should be built.")
        if(ENABLE_UNIVERSAL)
            
            # if universal binaries are requested and none defined so far
            # overwrite them with all three common architectures. If the user
            # specified their own list of architectures do not touch!
            if(CMAKE_OSX_ARCHITECTURES STREQUAL "")

                STRING(REGEX REPLACE "^.*MacOSX([0-9]*\\.[0-9]*)\\.sdk$" "\\1"
                       OSX_SDK_VERSION "${CMAKE_OSX_SYSROOT}")

                if(OSX_SDK_VERSION  VERSION_EQUAL "10.7" OR
                   OSX_SDK_VERSION  VERSION_GREATER "10.7" OR
                   OSX_SDK_VERSION  VERSION_EQUAL "10.8" OR
                   OSX_SDK_VERSION  VERSION_GREATER "10.8")

                   # OSX Lion no longer supports ppc architecture
                   set(CMAKE_OSX_ARCHITECTURES "i386;x86_64" CACHE STRING
                      "A semicolon-separated list of architectures for which libLAX should be built." FORCE)

                elseif(OSX_SDK_VERSION AND OSX_SDK_VERSION  VERSION_LESS "10.7" )

                   set(CMAKE_OSX_ARCHITECTURES "i386;ppc;x86_64" CACHE STRING
                       "A semicolon-separated list of architectures for which libLAX should be built." FORCE)

                else()

                   set(CMAKE_OSX_ARCHITECTURES "i386;x86_64" CACHE STRING
                       "A semicolon-separated list of architectures for which libLAX should be built." FORCE)

                endif()
            endif()
        endif(ENABLE_UNIVERSAL)
    else(APPLE)
        add_definitions(-DLINUX)
		
        if(NOT CYGWIN)
            # on cygwin all code is position independent so -fPIC is not needed
            set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-strict-aliasing -fPIC")
            set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-strict-aliasing -fPIC")
        endif()

        set(BUILD_DEFINITIONS "${BUILD_DEFINITIONS} -DLINUX")
    endif(APPLE)

    # not needing these defines, and they do cause warnings
    # add_definitions( -DPACKAGE_VERSION=\"${PACKAGE_VERSION}\"  -DPACKAGE_NAME=\"${PROJECT_NAME}\")
    # set(BUILD_DEFINITIONS "${BUILD_DEFINITIONS} -DPACKAGE_VERSION=\"${PACKAGE_VERSION}\"  -DPACKAGE_NAME=\"${PROJECT_NAME}\"")

else(UNIX)
    # not needing these defines, and they do cause warnings
    # add_definitions(-DPACKAGE_VERSION=\"${PACKAGE_VERSION}\"  -DPACKAGE_NAME=\"${PROJECT_NAME}\")
    add_definitions(-DWIN32 -DLIBLAX_EXPORTS)
    set(BUILD_DEFINITIONS "${BUILD_DEFINITIONS} -DWIN32 -DLIBLAX_EXPORTS")
    if(MSVC OR USING_INTEL)
        add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE)
        set(BUILD_DEFINITIONS "${BUILD_DEFINITIONS} -D_CRT_SECURE_NO_WARNINGS")
        option(WITH_STATIC_RUNTIME "Compile using the static MSVC Runtime." OFF)
        if(WITH_STATIC_RUNTIME)
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

 		# CMake no longer creates PDB files for static libraries after 2.8.11
		# so we store debug information in the object files instead
		if (${CMAKE_VERSION} VERSION_GREATER "2.8.11")
            foreach(flag_var
                CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
                CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO
                CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
                CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO)

                if(${flag_var} MATCHES "/Zi")
				    STRING(REPLACE "/Zi"  "/Z7" "${flag_var}" "${${flag_var}}")
                endif(${flag_var} MATCHES "/Zi")

            endforeach(flag_var)		  
		endif()
		
        file(GLOB WIN32_BINARIES ${LIBLAX_DEPENDENCY_DIR}/bin/*.dll)
        INSTALL(FILES ${WIN32_BINARIES} DESTINATION bin)
        file(GLOB WIN32_DEPENDENCIES ${LIBLAX_DEPENDENCY_DIR}/lib/*.lib)
        install(FILES ${WIN32_DEPENDENCIES} DESTINATION lib)
        if(WITH_LIBXML)
		  if (EXTRA_LIBS STREQUAL "")
		    # populate EXTRA_LIBS variable
              find_library(LIBICONV_LIBRARY
                NAMES libiconv.lib iconv.lib iconv
                PATHS /usr/lib /usr/local/lib
                      ${CMAKE_OSX_SYSROOT}/usr/lib
                      ${LIBLAX_DEPENDENCY_DIR}/lib
                DOC "The file name of the libiconv library."
              )
		    
		    set(ADDITIONAL_LIBS)
		    if (EXISTS ${LIBICONV_LIBRARY})
		 	 set(ADDITIONAL_LIBS "${ADDITIONAL_LIBS}${LIBICONV_LIBRARY};")
		    endif()
		    if (EXISTS ${LIBZ_LIBRARY})
		    set(ADDITIONAL_LIBS "${ADDITIONAL_LIBS}${LIBZ_LIBRARY};")
		    endif()
		    set(EXTRA_LIBS "WS2_32.lib;${ADDITIONAL_LIBS}" CACHE STRING "List of additional libraries to link against." FORCE)
		  endif()
		endif()
    elseif(CYGWIN)
        add_definitions(-DCYGWIN)
        set(BUILD_DEFINITIONS "${BUILD_DEFINITIONS} -DCYGWIN")
    elseif(MINGW)
        if(WITH_LIBXML)
            # this is necessary to build with libxml2 on mingw
            add_definitions(-DLIBXML_STATIC)
        endif(WITH_LIBXML)
    endif(MSVC OR USING_INTEL)

endif(UNIX)


###############################################################################
#
# Disable in-source build
#

if("${LIBLAX_ROOT_SOURCE_DIR}" STREQUAL "${LIBLAX_ROOT_BINARY_DIR}" )
    message(FATAL_ERROR "In-source builds of libLAX are disabled. 
Please create a separate build directory.")
endif()


###############################################################################
#
# Add check that only one XML library was selection
#

set(LIBRARY_COUNT 0)
if(WITH_EXPAT)
    math(EXPR LIBRARY_COUNT "${LIBRARY_COUNT} + 1")
endif()
if(WITH_LIBXML)
    math(EXPR LIBRARY_COUNT "${LIBRARY_COUNT} + 1")
endif()
if(WITH_XERCES)
    math(EXPR LIBRARY_COUNT "${LIBRARY_COUNT} + 1")
endif()

if(LIBRARY_COUNT GREATER 1)
    message(FATAL_ERROR
"Only one XML library should be chosen. Please select only one of the
following options: WITH_LIBXML, WITH_EXPAT or WITH_XERCES.")
endif()


###############################################################################
#
# Add check that at least one XML library was selection
#

if(LIBRARY_COUNT EQUAL 0)
    message(FATAL_ERROR
"A XML library must be selected. Please select one of the following
options: WITH_LIBXML, WITH_EXPAT or WITH_XERCES.")
endif()

###############################################################################
#
# Include options for all libLAX packages
#
set(LIBLAX_PACKAGE_INCLUDES)
set(LIBLAX_PACKAGE_SUMMARY)
file(GLOB PACKAGE_OPTIONS "*package.cmake")
foreach(package ${PACKAGE_OPTIONS})
    include(${package})
endforeach()

if (LIBLAX_PACKAGE_INCLUDES)
  list(REMOVE_DUPLICATES LIBLAX_PACKAGE_INCLUDES)
endif()

###############################################################################
#
# Build the actual libLAX library
#

add_subdirectory(src)



###############################################################################
#
# Install documentation
#

set(DOCUMENTATION_FILES
        COPYING.txt
        FUNDING.txt
        LICENSE.txt
        NEWS.txt
        README.txt
        VERSION.txt
)

install(FILES ${DOCUMENTATION_FILES} DESTINATION ${MISC_PREFIX}.)

###############################################################################
#
# Write liblax.pc
#

set (PRIVATE_LIBS "-lstdc++ -lm")
if (WITH_ZLIB)
set (PRIVATE_LIBS "${LIBZ_LIBRARY} ${PRIVATE_LIBS}")
endif()
if (WITH_BZIP2)
set (PRIVATE_LIBS "${LIBBZ_LIBRARY} ${PRIVATE_LIBS}")
endif()
if (WITH_LIBXML)
set (PRIVATE_LIBS "${LIBXML_LIBRARY} ${PRIVATE_LIBS}")
endif()
if (WITH_EXPAT)
set (PRIVATE_LIBS "${LIBEXPAT_LIBRARY} ${PRIVATE_LIBS}")
endif()
if (WITH_XERCES)
set (PRIVATE_LIBS "${XERCES_LIBRARY} ${PRIVATE_LIBS}")
endif()

SET (PC_LIBDIR ${CMAKE_INSTALL_LIBDIR})
if (${CMAKE_INSTALL_LIBDIR} STREQUAL "lib")
SET (PC_LIBDIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
endif()

file(WRITE  "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "Name: ${PACKAGE_NAME}\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "Description: A library for reading/writing XML\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "URL:\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "Version: ${PACKAGE_VERSION}\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "prefix=${CMAKE_INSTALL_PREFIX}\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "libdir=${PC_LIBDIR}\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "includedir=${CMAKE_INSTALL_PREFIX}/include\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "Libs: -L\${libdir} -llax\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "Libs.private:        ${PRIVATE_LIBS}\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "Cflags: -I\${includedir}\n")
if (WITH_XERCES)
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "Conflicts: xerces-c = 2.6.0\n")
endif()

if (WITH_LIBXML)
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" "Requires.private: libxml-2.0 >= 2.6.22\n")
endif()

if (UNIX)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/liblax.pc" 
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)
endif()

###############################################################################
#
# Print Summary
#
if (NOT HOSTNAME)
 site_name(HOSTNAME)
endif()

message(STATUS "
----------------------------------------------------------------------
libLAX version ${PACKAGE_VERSION}
----------------------------------------------------------------------

   More information and the latest version are available online at


   Please report problems using the issue tracker at


   To contact the developers directly, email libsbml-team@caltech.edu

   Configured on host '${HOSTNAME}'
     host type                       = ${CMAKE_SYSTEM_NAME}
     host operating system           = ${CMAKE_SYSTEM_NAME} ${CMAKE_SYSTEM_VERSION}
     host CPU architecture           = ${CMAKE_SYSTEM_PROCESSOR}

   General build flags:
     CC                              = ${CMAKE_C_COMPILER}
     CXX                             = ${CMAKE_CXX_COMPILER}
     CPPFLAGS                        = ${BUILD_DEFINITIONS}
     CFLAGS                          = ${CMAKE_C_FLAGS}
     CXXFLAGS                        = ${CMAKE_CXX_FLAGS}
     LDFLAGS                         = ${CMAKE_EXE_LINKER_FLAGS}

   XML parser library configuration:
     XML library                     = ${LIBLAX_XML_LIBRARY}
     CPPFLAGS for XML                = -I${LIBLAX_XML_LIBRARY_INCLUDE}
     LIBS for XML                    = ${LIBLAX_XML_LIBRARY_LIBS}

   Other libLAX configuration settings:
     Installation $prefix            = ${CMAKE_INSTALL_PREFIX}")

if(UNIX)
    if(APPLE)
        message(STATUS "     Value of $DYLD_LIBRARY_PATH     = $ENV{DYLD_LIBRARY_PATH}")
    else()
        message(STATUS "     Value of $LD_LIBRARY_PATH       = $ENV{LD_LIBRARY_PATH}")
    endif()
endif()

if(WITH_CHECK)
    message(STATUS "     Using libcheck                  = ${LIBCHECK_LIBRARY}")
endif()

if(APPLE)
    if(CMAKE_OSX_ARCHITECTURES STREQUAL "")
        message(STATUS "     Building 'universal' binaries   = no (using native arch)")
    else()
        list(REMOVE_DUPLICATES CMAKE_OSX_ARCHITECTURES)
        list(REMOVE_ITEM CMAKE_OSX_ARCHITECTURES "")
        list(SORT CMAKE_OSX_ARCHITECTURES)
        list(LENGTH CMAKE_OSX_ARCHITECTURES NUM_ARCHS)
        if(NUMARCHS EQUAL 1)
            message(STATUS "     Building 'universal' binaries   = no (using ${CMAKE_OSX_ARCHITECTURES})")
        else()
            message(STATUS "     Building 'universal' binaries   = yes (using ${CMAKE_OSX_ARCHITECTURES})")
        endif()
    endif()
endif()

message(STATUS "
")
message(STATUS "Other potentially important settings:")
if(WITH_ZLIB)
    message(STATUS "  Compression support is enabled for .zip and .gz files")
else()
    message(STATUS "
Warning: reading/writing compressed XML in .zip or .gz format in
this copy of libLAX is not supported or has been disabled.
If this was not your intention, please check the WITH_ZLIB
option.")
endif()

if(WITH_BZIP2)
    message(STATUS "  Compression support is enabled for .bz2 files")
else()
    message(STATUS "
Warning: reading/writing compressed XML in .bz2 format in
this copy of libLAX is not supported or has been disabled.
If this was not your intention, please check the WITH_BZIP2
option.")
endif()

message(STATUS "
----------------------------------------------------------------------")


## Add uninstall target
## as available from http://www.cmake.org/Wiki/RecipeAddUninstallTarget
CONFIGURE_FILE(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
  IMMEDIATE @ONLY)
ADD_CUSTOM_TARGET(uninstall
  "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake") 

## To compile a test program simply comment out the lines below ...
#
#OPTION(WITH_TEST_PROGRAM " COMPILE SMALL TEST PROGRAM " ON)
#
#if(WITH_TEST_PROGRAM)
#
#include_directories(${CMAKE_CURRENT_SOURCE_DIR})
#
#add_executable(libsbml_test test.cpp)
#target_link_libraries(libsbml_test ${LIBLAX_LIBRARY}-static)
#
#endif()
#
