# Distributed under the BSD 2-Clause License - Copyright 2012-2021 Robin Degen

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
