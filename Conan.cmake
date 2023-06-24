# Distributed under the BSD 2-Clause License - Copyright 2012-2022 Robin Degen

include(Architecture)

function(__conan_install_internal conan_executable config)
    message(STATUS "Running conan install for ${config}...")

    if (AEON_ARCHITECTURE_32_BIT)
        set(__CONAN_ARCH_NAME "x86")
    else ()
        set(__CONAN_ARCH_NAME "x86_64")
    endif ()

    execute_process(
        COMMAND ${conan_executable} install .
            -of "${CMAKE_BINARY_DIR}"
            -s "build_type=${config}"
            -s "arch=${__CONAN_ARCH_NAME}"
            -s "compiler.cppstd=${CMAKE_CXX_STANDARD}"
            -s "compiler.runtime_type=${config}"
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE CONAN_INSTALL_RESULT
        COMMAND_ERROR_IS_FATAL ANY
    )

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

    # If the build type is not set; assume multiconfig
    if (CMAKE_BUILD_TYPE)
        __conan_install_internal("${CONAN_EXECUTABLE}" ${CMAKE_BUILD_TYPE})
    else ()
        __conan_install_internal("${CONAN_EXECUTABLE}" "Debug")
        __conan_install_internal("${CONAN_EXECUTABLE}" "Release")
    endif ()
endfunction()
