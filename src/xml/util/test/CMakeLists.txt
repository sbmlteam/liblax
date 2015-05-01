## @file    CMakeLists.txt
## @brief   CMake build script
## @author  Frank T. Bergmann
## ------------------------------------------------------------------------ -->

file(GLOB TEST_FILES_UTIL ${CMAKE_CURRENT_SOURCE_DIR}/*.c)
include_directories(${LIBCHECK_INCLUDE_DIR})
include_directories(BEFORE ${LIBLAX_ROOT_BINARY_DIR}/src)

if (EXTRA_INCLUDE_DIRS) 
 include_directories(${EXTRA_INCLUDE_DIRS})
endif(EXTRA_INCLUDE_DIRS)

add_executable(test_xml_util ${TEST_FILES_UTIL})

if (NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/TestUtil.c)
# the test checks for the present of a file so lets create it if necessary
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/TestUtil.c "// test")

endif()

target_link_libraries(test_xml_util ${LIBLAX_LIBRARY}-static ${LIBCHECK_LIBRARY})
add_test(test_xml_util_run ${CMAKE_CURRENT_BINARY_DIR}/test_xml_util )

