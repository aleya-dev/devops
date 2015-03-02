function(get_git_describe_tag git_describe_tag)
    if (NOT GIT_FOUND)
        find_package(Git REQUIRED)
    endif()

    execute_process(
        COMMAND ${GIT_EXECUTABLE} "describe" "--tags"
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_DESCRIBE_OUTPUT
        ERROR_VARIABLE GIT_DESCRIBE_ERROR_OUTPUT
        RESULT_VARIABLE GIT_DESCRIBE_RESULT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if (NOT GIT_DESCRIBE_RESULT EQUAL 0)
        message(FATAL_ERROR "Could not parse git describe version.\nOutput was ${GIT_DESCRIBE_ERROR_OUTPUT}")
    endif()

    set(${git_describe_tag} ${GIT_DESCRIBE_OUTPUT} PARENT_SCOPE)
endfunction()
