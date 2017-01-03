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

set(AEON_CMAKE_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR})

macro(add_source_path target dir)
    set(source_files "")
    file(
        GLOB source_files
        RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
            ${dir}/*.cpp
            ${dir}/*.c
            ${dir}/*.mm
            ${dir}/*.h
    )
    list(APPEND ${target} "${source_files}")
endmacro()

macro(generate_source_groups sources)
    foreach(f ${sources})
        string(REGEX REPLACE "(.*)(/[^/]*)$" "\\1" source_group_name ${f})
        string(REPLACE / \\ source_group_name ${source_group_name})
        source_group("${source_group_name}" FILES ${f})
    endforeach()
endmacro()

function(set_working_dir target dir)
    message(STATUS "Setting working dir for target ${target} to ${dir}")

    if (MSVC)
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.0 AND NOT ${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
            message(STATUS "set_working_dir requires Visual Studio 2015 or higher. Skipping.")
        else ()
            get_filename_component(absolute_dir "${dir}" ABSOLUTE)
            file(TO_NATIVE_PATH "${absolute_dir}" WORKING_DIR)
            configure_file(${AEON_CMAKE_ROOT_DIR}/VisualStudioWorkingDir.vcxproj.user.in ${target}.vcxproj.user @ONLY)
        endif ()
    endif ()
endfunction()
