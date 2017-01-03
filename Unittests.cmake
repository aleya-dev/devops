# ROBIN DEGEN; CONFIDENTIAL
#
# 2012 - 2017 Robin Degen
# All Rights Reserved.
#
# NOTICE:  All information contained herein is, and remains the property of
# Robin Degen and its suppliers, if any. The intellectual and technical
# concepts contained herein are proprietary to Robin Degen and its suppliers
# and may be covered by U.S. and Foreign Patents, patents in process, and are
# protected by trade secret or copyright law. Dissemination of this
# information or reproduction of this material is strictly forbidden unless
# prior written permission is obtained from Robin Degen.

if (NOT TARGET gtest)
    message(FATAL_ERROR "Unittests.cmake requires google test included as submodule.")
endif ()

include(CMakeParseArguments)

function(add_unit_test_suite)
    cmake_parse_arguments(
        UNIT_TEST_PARSED_ARGS
        "NO_GTEST_MAIN"
        "TARGET;FOLDER"
        "SOURCES;LIBRARIES;INCLUDES;LABELS"
        ${ARGN}
    )

    if (NOT UNIT_TEST_PARSED_ARGS_TARGET)
        message(FATAL_ERROR "No target name was given for unit test.")
    endif ()

    if (NOT UNIT_TEST_PARSED_ARGS_SOURCES)
        message(FATAL_ERROR "No sources were given for unit test.")
    endif ()

    foreach(_src ${UNIT_TEST_PARSED_ARGS_SOURCES})
        list (APPEND SRCS "${UNIT_TEST_PARSED_ARGS_TARGET}/${_src}")
    endforeach()

    add_executable(${UNIT_TEST_PARSED_ARGS_TARGET} ${SRCS})

    if (UNIT_TEST_PARSED_ARGS_FOLDER)
        set_target_properties(
            ${UNIT_TEST_PARSED_ARGS_TARGET} PROPERTIES
            FOLDER ${UNIT_TEST_PARSED_ARGS_FOLDER}
            RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
        )
    endif ()

    if (UNIT_TEST_PARSED_ARGS_INCLUDES)
        target_include_directories(${UNIT_TEST_PARSED_ARGS_TARGET} PRIVATE ${UNIT_TEST_PARSED_ARGS_INCLUDES})
    endif ()

    target_link_libraries(
        ${UNIT_TEST_PARSED_ARGS_TARGET}
        gtest
        gmock
    )

    if (NOT ${UNIT_TEST_PARSED_ARGS_NO_GTEST_MAIN})
        target_link_libraries(${UNIT_TEST_PARSED_ARGS_TARGET} gtest_main)
    endif ()

    if (UNIT_TEST_PARSED_ARGS_LIBRARIES)
        target_link_libraries(
            ${UNIT_TEST_PARSED_ARGS_TARGET}
            ${UNIT_TEST_PARSED_ARGS_LIBRARIES}
        )
    endif ()

    add_test(
        NAME ${UNIT_TEST_PARSED_ARGS_TARGET}
        WORKING_DIRECTORY $<TARGET_FILE_DIR:${UNIT_TEST_PARSED_ARGS_TARGET}>
        COMMAND $<TARGET_FILE:${UNIT_TEST_PARSED_ARGS_TARGET}>
    )

    list(APPEND UNIT_TEST_PARSED_ARGS_LABELS "unittest")
    set_tests_properties(${UNIT_TEST_PARSED_ARGS_TARGET} PROPERTIES LABELS "${UNIT_TEST_PARSED_ARGS_LABELS}")
endfunction()
