# Distributed under the BSD 2-Clause License - Copyright 2012-2023 Robin Degen

include(Architecture)

set(__CONAN_CMAKE_LIST_DIR ${CMAKE_CURRENT_LIST_DIR})

function(__conan_install_internal conan_executable profile_path)
    message(STATUS "Running conan install with profile ${profile_path}...")

    if (profile_path)
        execute_process(
            COMMAND ${conan_executable} install .
                -of "${CMAKE_BINARY_DIR}"
                -pr "${profile_path}"
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            RESULT_VARIABLE CONAN_INSTALL_RESULT
            COMMAND_ERROR_IS_FATAL ANY
        )
    else ()
        execute_process(
            COMMAND ${conan_executable} install .
                -of "${CMAKE_BINARY_DIR}"
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            RESULT_VARIABLE CONAN_INSTALL_RESULT
            COMMAND_ERROR_IS_FATAL ANY
        )
    endif ()

    if (NOT CONAN_INSTALL_RESULT EQUAL 0)
        message(FATAL_ERROR "Could not run conan install for config: ${config}.")
    endif()
endfunction()

# Install conan packages into CMAKE_BINARY_DIR. It is assumed that CMAKE_SOURCE_DIR has a conan file.
function(conan_install)
    find_program(CONAN_EXECUTABLE conan)

    if (NOT CONAN_EXECUTABLE)
        message(FATAL_ERROR "Could not find conan.")
    endif ()

    message(STATUS "Found conan: ${CONAN_EXECUTABLE}")

    set(__conan_profile_path ${__CONAN_CMAKE_LIST_DIR}/../Conan/profiles)

    # Install with the correct profile
    if (MSVC)
        # In Visual Studio we need to use multi-config
        if (AEON_ARCHITECTURE_32_BIT)
            __conan_install_internal("${CONAN_EXECUTABLE}" "${__conan_profile_path}/windows/msvc2022_x86_debug")
            __conan_install_internal("${CONAN_EXECUTABLE}" "${__conan_profile_path}/windows/msvc2022_x86_release")
        else ()
            __conan_install_internal("${CONAN_EXECUTABLE}" "${__conan_profile_path}/windows/msvc2022_x86_64_debug")
            __conan_install_internal("${CONAN_EXECUTABLE}" "${__conan_profile_path}/windows/msvc2022_x86_64_release")
        endif ()
    elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
        string(TOLOWER ${CMAKE_BUILD_TYPE} __config)
        if (AEON_ARCHITECTURE_32_BIT)
            __conan_install_internal("${CONAN_EXECUTABLE}" "${__conan_profile_path}/linux/gcc12_x86_${__config}")
        else ()
            __conan_install_internal("${CONAN_EXECUTABLE}" "${__conan_profile_path}/linux/gcc12_x86_64_${__config}")
        endif ()
    elseif (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        string(TOLOWER ${CMAKE_BUILD_TYPE} __config)
        __conan_install_internal("${CONAN_EXECUTABLE}" "${__conan_profile_path}/macos/appleclang14_x86_64_${__config}")
    else ()
        # Otherwise, assume the default profile
        __conan_install_internal("${CONAN_EXECUTABLE}" "")
    endif ()
endfunction()
