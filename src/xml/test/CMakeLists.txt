## @file    CMakeLists.txt
## ------------------------------------------------------------------------ -->

include(${LIBLAX_ROOT_SOURCE_DIR}/common.cmake)

file(GLOB C_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.c)

foreach(c_file ${C_FILES})
	set_source_files_properties(${c_file} PROPERTIES LANGUAGE CXX)
endforeach()

file(GLOB CPP_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp )
file(GLOB H_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.h )

set(TEST_FILES ${CPP_FILES} ${C_FILES} ${H_FILES})

include_directories(${LIBLAX_ROOT_SOURCE_DIR}/include/xml)
include_directories(BEFORE ${LIBLAX_ROOT_BINARY_DIR}/src)

if (EXTRA_INCLUDE_DIRS) 
 include_directories(${EXTRA_INCLUDE_DIRS})
endif(EXTRA_INCLUDE_DIRS)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
include_directories(${LIBCHECK_INCLUDE_DIR})
add_executable(test_xml_xml ${TEST_FILES})
target_link_libraries(test_xml_xml ${LIBLAX_LIBRARY}-static ${LIBCHECK_LIBRARY})
add_test(test_xml_xml_run ${CMAKE_CURRENT_BINARY_DIR}/test_xml_xml )
