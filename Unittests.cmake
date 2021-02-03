# Distributed under the BSD 2-Clause License - Copyright 2012-2021 Robin Degen

if (NOT TARGET GTest::GTest)
    message(FATAL_ERROR "Unittests.cmake requires Google Test (GTest::GTest target is missing)")
endif ()

if (NOT TARGET GTest::GMock)
    message(FATAL_ERROR "Unittests.cmake requires Google Mock (GTest::GMock target is missing)")
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

    target_link_libraries(${UNIT_TEST_PARSED_ARGS_TARGET}
        GTest::GTest
        GTest::GMock
    )

    if (NOT ${UNIT_TEST_PARSED_ARGS_NO_GTEST_MAIN})
        if (NOT TARGET GTest::Main)
            message(FATAL_ERROR "Unittests.cmake requires Google Test Main (GTest::Main target is missing)")
        endif ()
        target_link_libraries(${UNIT_TEST_PARSED_ARGS_TARGET} GTest::Main)
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
        COMMAND $<TARGET_FILE:${UNIT_TEST_PARSED_ARGS_TARGET}> "--gtest_output=xml:${UNIT_TEST_PARSED_ARGS_TARGET}.xml"
    )

    if (UNIX AND NOT APPLE)
        set_tests_properties(${UNIT_TEST_PARSED_ARGS_TARGET} PROPERTIES
            ENVIRONMENT LD_LIBRARY_PATH=$<TARGET_FILE_DIR:${UNIT_TEST_PARSED_ARGS_TARGET}>:$ENV{LD_LIBRARY_PATH})
    endif ()

    list(APPEND UNIT_TEST_PARSED_ARGS_LABELS "unittest")
    set_tests_properties(${UNIT_TEST_PARSED_ARGS_TARGET} PROPERTIES LABELS "${UNIT_TEST_PARSED_ARGS_LABELS}")
endfunction()
