# Distributed under the BSD 2-Clause License - Copyright 2012-2023 Robin Degen

if (NOT TARGET GTest::GTest AND NOT TARGET CONAN_PKG::gtest)
    message(FATAL_ERROR "Unittests.cmake requires Google Test (GTest::GTest or CONAN_PKG::gtest target is missing)")
endif ()

if (NOT TARGET GTest::gmock AND NOT TARGET CONAN_PKG::gtest)
    message(FATAL_ERROR "Unittests.cmake requires Google Mock (GTest::gmock or CONAN_PKG::gtest target is missing)")
endif ()

include(CMakeParseArguments)

function(add_unit_test_suite)
    cmake_parse_arguments(
        UNIT_TEST_PARSED_ARGS
        "NO_GTEST_MAIN;AUTO_GLOB_SOURCES"
        "TARGET;FOLDER"
        "SOURCES;GLOB_SOURCES;LIBRARIES;INCLUDES;LABELS"
        ${ARGN}
    )

    if (NOT UNIT_TEST_PARSED_ARGS_TARGET)
        message(FATAL_ERROR "No target name was given for unit test.")
    endif ()

    if (NOT UNIT_TEST_PARSED_ARGS_AUTO_GLOB_SOURCES AND
        NOT UNIT_TEST_PARSED_ARGS_SOURCES AND
        NOT UNIT_TEST_PARSED_ARGS_GLOB_SOURCES)
        message(FATAL_ERROR "No sources or glob sources were given for unit test.")
    endif ()

    if (UNIT_TEST_PARSED_ARGS_AUTO_GLOB_SOURCES)
        file(GLOB_RECURSE
            AUTO_GLOB_SRCS
            CONFIGURE_DEPENDS
            "${UNIT_TEST_PARSED_ARGS_TARGET}/*"
        )
    endif ()

    if (UNIT_TEST_PARSED_ARGS_SOURCES)
        foreach(_src ${UNIT_TEST_PARSED_ARGS_SOURCES})
            list (APPEND SRCS "${UNIT_TEST_PARSED_ARGS_TARGET}/${_src}")
        endforeach()
    endif ()

    if (UNIT_TEST_PARSED_ARGS_GLOB_SOURCES)
        file(GLOB_RECURSE
            GLOB_SRCS
            CONFIGURE_DEPENDS
            "${UNIT_TEST_PARSED_ARGS_GLOB_SOURCES}"
        )
    endif ()

    add_executable(${UNIT_TEST_PARSED_ARGS_TARGET}
        ${SRCS}
        ${GLOB_SRCS}
        ${AUTO_GLOB_SRCS}
    )

    if (UNIT_TEST_PARSED_ARGS_FOLDER)
        set_target_properties(
            ${UNIT_TEST_PARSED_ARGS_TARGET} PROPERTIES
            FOLDER ${UNIT_TEST_PARSED_ARGS_FOLDER}
        )
    endif ()

    set_target_properties(
        ${UNIT_TEST_PARSED_ARGS_TARGET} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
        VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/bin/$(Configuration)"
    )

    if (UNIT_TEST_PARSED_ARGS_INCLUDES)
        target_include_directories(${UNIT_TEST_PARSED_ARGS_TARGET} PRIVATE ${UNIT_TEST_PARSED_ARGS_INCLUDES})
    endif ()

    if (TARGET GTest::GTest AND TARGET GTest::gmock)
        target_link_libraries(${UNIT_TEST_PARSED_ARGS_TARGET}
            GTest::GTest
            GTest::gmock
        )
    else ()
        target_link_libraries(${UNIT_TEST_PARSED_ARGS_TARGET}
            CONAN_PKG::gtest
        )
    endif ()

    if (NOT ${UNIT_TEST_PARSED_ARGS_NO_GTEST_MAIN})
        if (NOT TARGET GTest::Main AND NOT TARGET CONAN_PKG::gtest)
            message(FATAL_ERROR "Unittests.cmake requires Google Test Main (GTest::Main or CONAN_PKG:: target is missing)")
        endif ()

        if (TARGET GTest::Main)
            target_link_libraries(${UNIT_TEST_PARSED_ARGS_TARGET} GTest::Main)
        endif ()
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
