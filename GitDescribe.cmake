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

function(get_git_describe_tag git_describe_tag)
    if (NOT GIT_FOUND)
        find_package(Git REQUIRED)
    endif()

    execute_process(
        COMMAND ${GIT_EXECUTABLE} "describe" "--tags" "--long"
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
