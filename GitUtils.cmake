# Distributed under the BSD 2-Clause License - Copyright 2012-2019 Robin Degen

if (NOT GIT_FOUND)
    find_package(Git REQUIRED)

    if (NOT GIT_FOUND)
        message(FATAL_ERROR "Could not find git which is required for the Git Utilities.")
    endif ()
endif()

# Initialize a Git repository at the given path. If there is already a git
# repository at this path it will be reinitialized. The directory in the given
# path will be created if it doesn't already exist.
# \param path The path to the repository
function(git_init path)
    if (NOT EXISTS "${path}")
        file(MAKE_DIRECTORY "${path}")
    endif ()

    execute_process(
        COMMAND ${GIT_EXECUTABLE} "init"
        WORKING_DIRECTORY ${path}
        OUTPUT_VARIABLE __output
        ERROR_VARIABLE __error_output
        RESULT_VARIABLE __result
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if (NOT __result EQUAL 0)
        message(FATAL_ERROR "Could not init git.\nOutput was ${__error_output}")
    endif()
endfunction()

# Get the url of a remote if available in the given repository path.
# \param path The path to the repository
# \param name The name of the remote
# \param url_output Output variable. Contains the url if the remote exists.
#                   Empty if it doesn't.
function(git_get_remote_url path name url_output)
    if (NOT EXISTS ${path})
        message(FATAL_ERROR "Repository path does not exist.")
    endif ()

    execute_process(
        COMMAND ${GIT_EXECUTABLE} "config" "remote.${name}.url"
        WORKING_DIRECTORY ${path}
        OUTPUT_VARIABLE __output
        ERROR_VARIABLE __error_output
        RESULT_VARIABLE __result
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    set(${url_output} "${__output}" PARENT_SCOPE)
endfunction()

# Set the URL of a remote. If the given remote does not yet exist,
# it is created.
# \param path The path to the repository
# \param name The name of the remote
# \param url The url of the remote
function(git_set_remote_url path name url)
    if (NOT EXISTS ${path})
        message(FATAL_ERROR "Repository path does not exist.")
    endif ()

    git_get_remote_url("${path}" "${name}" __url)

    # Remote does not exist yet. Create it.
    if (NOT __url)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} "remote" "add" "${name}" "${url}"
            WORKING_DIRECTORY ${path}
            OUTPUT_VARIABLE __output
            ERROR_VARIABLE __error_output
            RESULT_VARIABLE __result
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if (NOT __result EQUAL 0)
            message(FATAL_ERROR "Could not add remote.\nOutput was ${__error_output}")
        endif()
    else () # Remote exists; update the url
        execute_process(
            COMMAND ${GIT_EXECUTABLE} "remote" "set-url" "${name}" "${url}"
            WORKING_DIRECTORY ${path}
            OUTPUT_VARIABLE __output
            ERROR_VARIABLE __error_output
            RESULT_VARIABLE __result
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if (NOT __result EQUAL 0)
            message(FATAL_ERROR "Could not set remote url.\nOutput was ${__error_output}")
        endif()
    endif ()
endfunction()

# Fetch from a given remote name. Raises error if the remote does not exist.
# \param path The path to the repository
# \param name The name of the remote
function(git_fetch path name)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} "fetch" "${name}"
        WORKING_DIRECTORY ${path}
        OUTPUT_VARIABLE __output
        ERROR_VARIABLE __error_output
        RESULT_VARIABLE __result
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if (NOT __result EQUAL 0)
        message(FATAL_ERROR "Could not fetch.\nOutput was ${__error_output}")
    endif()
endfunction()

# Check out a treeish (branch, tag, hash, etc.). Raises error if the treeish
# does not exist.
# \param path The path to the repository
# \param treeish A "treeish" (branch, tag, hash, etc.)
function(git_checkout path treeish)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} "checkout" "${treeish}"
        WORKING_DIRECTORY ${path}
        OUTPUT_VARIABLE __output
        ERROR_VARIABLE __error_output
        RESULT_VARIABLE __result
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if (NOT __result EQUAL 0)
        message(FATAL_ERROR "Could not checkout '${treeish}'.\nOutput was ${__error_output}")
    endif()
endfunction()

# Get the git describe tag for the current repository. Raises error if the source
# dir is not a git repository or if it does not contain a usable describe tag.
# \param git_describe_tag Output variable containing the git describe tag
function(git_get_describe_tag git_describe_tag)
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


# Utility function to clone, fetch and checkout a branch. This can be used to
# ensure that the repository at a given path is up to date.
# \param path The path to the repository
# \param url The url of the remote
# \param treeish A "treeish" (branch, tag, hash, etc.)
function(git_clone_and_checkout path url treeish)
    set(__remote_name "aeon_cmake_remote")

    git_init("${path}")
    git_set_remote_url("${path}" "${__remote_name}" "${url}")
    git_fetch("${path}" "${__remote_name}")
    git_checkout("${path}" "${treeish}")
endfunction()
