# ROBIN DEGEN; CONFIDENTIAL
#
# 2012 - 2016 Robin Degen
# All Rights Reserved.
#
# NOTICE:  All information contained herein is, and remains the property of
# Robin Degen and its suppliers, if any. The intellectual and technical
# concepts contained herein are proprietary to Robin Degen and its suppliers
# and may be covered by U.S. and Foreign Patents, patents in process, and are
# protected by trade secret or copyright law. Dissemination of this
# information or reproduction of this material is strictly forbidden unless
# prior written permission is obtained from Robin Degen.

find_program(
    MONO_EXECUTABLE mono
    PATH $ENV{MONO_DEPENDENCIES_PREFIX}/bin
)

find_program(
    MONO_MCS_EXECUTABLE mcs
    PATH $ENV{MONO_DEPENDENCIES_PREFIX}/bin
)

find_library(
    MONO_MAIN_LIBRARY mono-2.0
    PATH $ENV{MONO_DEPENDENCIES_PREFIX}/lib
)

set(MONO_FOUND FALSE CACHE INTERNAL "")

if(MONO_EXECUTABLE AND MONO_MCS_EXECUTABLE AND MONO_MAIN_LIBRARY)
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
        find_file(MONO_DLL_PATH mono-2.0.dll PATH ${MONO_BINARY_PATH})
        copy_files_to_runtime_path(FILES ${MONO_DLL_PATH})
    endif ()

    execute_process(COMMAND ${MONO_MCS_EXECUTABLE} --version OUTPUT_VARIABLE MONO_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
    string(REGEX REPLACE ".*version ([^ ]+)" "\\1" MONO_VERSION "${MONO_VERSION}")
    message(STATUS "Found Mono version: ${MONO_MAIN_LIBRARY} (found version \"${MONO_VERSION}\")")
endif()

