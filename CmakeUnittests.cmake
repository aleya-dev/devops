# Copyright (c) 2012-2019 Robin Degen

function(initialize_tests)
    set(__cmake_unittests_failed 0 PARENT_SCOPE)
endfunction()

function(finalize_tests)
    if (__cmake_unittests_failed EQUAL 1)
        message(FATAL_ERROR "One or more tests failed.")
    endif ()

    message(STATUS "Tests ok.")
endfunction()

function(expect_eq value expected)
    if (NOT value STREQUAL expected)
        message(STATUS "expect_eq failed: Value was '${val1}'. Expected: '${expected}'")
        set(__cmake_unittests_failed 1 PARENT_SCOPE)
    endif ()
endfunction()

function(expect_ne value expected)
    if (value STREQUAL expected)
        message(STATUS "expect_ne failed: Value was equal to '${expected}'")
        set(__cmake_unittests_failed 1 PARENT_SCOPE)
    endif ()
endfunction()
