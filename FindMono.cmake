# Distributed under the BSD 2-Clause License - Copyright 2012-2021 Robin Degen

if (DEFINED ENV{MONO_DEPENDENCIES_PREFIX})
    file(TO_CMAKE_PATH $ENV{MONO_DEPENDENCIES_PREFIX} MONO_DEPENDENCIES_PREFIX)
endif ()

set (MONO_DEFAULT_INSTALL_PATH
    "C:/Program Files/Mono"
)

find_program(
    MONO_EXECUTABLE mono
    PATHS
        ${MONO_DEPENDENCIES_PREFIX}/bin
        ${MONO_DEFAULT_INSTALL_PATH}/bin
)

if (MSVC)
    find_program(
        MONO_MCS_EXECUTABLE mcs.bat
        PATHS
            ${MONO_DEPENDENCIES_PREFIX}/bin
            ${MONO_DEFAULT_INSTALL_PATH}/bin
    )
else ()
    find_program(
        MONO_MCS_EXECUTABLE mcs
        PATHS
            ${MONO_DEPENDENCIES_PREFIX}/bin
            ${MONO_DEFAULT_INSTALL_PATH}/bin
    )
endif ()

find_program(
    MONO_PKG_CONFIG_EXECUTABLE pkg-config
    PATHS
        ${MONO_DEPENDENCIES_PREFIX}/bin
        ${MONO_DEFAULT_INSTALL_PATH}/bin
)

find_library(
    MONO_MAIN_LIBRARY NAMES mono-2.0 mono-2.0-sgen
    PATHS
        ${MONO_DEPENDENCIES_PREFIX}/lib
        ${MONO_DEFAULT_INSTALL_PATH}/lib
)

set(MONO_FOUND FALSE CACHE INTERNAL "")

if(MONO_EXECUTABLE AND MONO_MCS_EXECUTABLE AND MONO_PKG_CONFIG_EXECUTABLE AND MONO_MAIN_LIBRARY)
    set(MONO_FOUND TRUE CACHE INTERNAL "")

    get_filename_component(MONO_LIBRARY_PATH "${MONO_MAIN_LIBRARY}" DIRECTORY)
    set(MONO_LIBRARY_PATH "${MONO_LIBRARY_PATH}" CACHE PATH "")

    get_filename_component(MONO_INCLUDE_PATH "${MONO_LIBRARY_PATH}/../include/mono-2.0" ABSOLUTE)
    set(MONO_INCLUDE_PATH "${MONO_INCLUDE_PATH}" CACHE PATH "")
    set(MONO_ASSEMBLY_PATH "${MONO_LIBRARY_PATH}" CACHE PATH "")

    get_filename_component(MONO_CONFIG_PATH "${MONO_LIBRARY_PATH}/../etc" ABSOLUTE)
    set(MONO_CONFIG_PATH "${MONO_CONFIG_PATH}" CACHE PATH "")

    get_filename_component(MONO_BINARY_PATH "${MONO_LIBRARY_PATH}/../bin" ABSOLUTE)
    set(MONO_BINARY_PATH "${MONO_BINARY_PATH}" CACHE PATH "")

    set(MONO_LIBRARIES "${MONO_MAIN_LIBRARY}" CACHE STRING "")

    if (APPLE)
        find_library(CORE_FOUNDATION_LIBRARY CoreFoundation)
        set(MONO_LIBRARIES "${MONO_LIBRARIES};${CORE_FOUNDATION_LIBRARY}")
    endif ()

    if (MSVC)
        include(CopyToRuntimePath)
        find_file(MONO_DLL_PATH NAMES mono-2.0.dll mono-2.0-sgen.dll PATHS ${MONO_BINARY_PATH})
        copy_files_to_runtime_path(FILES ${MONO_DLL_PATH})
    endif ()

    execute_process(COMMAND "${MONO_MCS_EXECUTABLE}" "--version" OUTPUT_VARIABLE MONO_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
    string(REGEX REPLACE ".*version ([^ ]+)" "\\1" MONO_VERSION "${MONO_VERSION}")
    message(STATUS "Found Mono version: ${MONO_MAIN_LIBRARY} (found version \"${MONO_VERSION}\")")
endif()

