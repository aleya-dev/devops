# Distributed under the BSD 2-Clause License - Copyright 2012-2019 Robin Degen

include(CMakeParseArguments)

macro(generic_find_script)
    cmake_parse_arguments(
        FIND_AEON_PACKAGE_PARSED_ARGS
        ""
        "NAME;HEADER;LIBRARY_WIN_DEBUG;LIBRARY_WIN_RELEASE;LIBRARY"
        ""
        ${ARGN}
    )

    find_path(
        ${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_INCLUDE_DIRS "${FIND_AEON_PACKAGE_PARSED_ARGS_HEADER}"
        PATH_SUFFIXES include
    )

    if (${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_INCLUDE_DIRS)
        set(${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_FOUND "YES")

        get_filename_component(
            ${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_ROOT_DIR
            "${${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_INCLUDE_DIRS}/../" ABSOLUTE
        )

        set(${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_DIR ${${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_ROOT_DIR}/lib/)

        if (MSVC)
            find_library(
                ${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_DEBUG "${FIND_AEON_PACKAGE_PARSED_ARGS_LIBRARY_WIN_DEBUG}"
                PATHS ${${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_DIR}
            )

            find_library(
                ${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_RELEASE "${FIND_AEON_PACKAGE_PARSED_ARGS_LIBRARY_WIN_RELEASE}"
                PATHS ${${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_DIR}
            )
        else ()
            find_library(
                ${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_DEBUG "${FIND_AEON_PACKAGE_PARSED_ARGS_LIBRARY}"
                PATHS ${${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_DIR}
            )

            find_library(
                ${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_RELEASE "${FIND_AEON_PACKAGE_PARSED_ARGS_LIBRARY}"
                PATHS ${${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_DIR}
            )
        endif ()

        if (NOT ${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_DEBUG)
            message(FATAL_ERROR "${FIND_AEON_PACKAGE_PARSED_ARGS_NAME} not found!")
        endif ()

        if (NOT ${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_RELEASE)
            message(FATAL_ERROR "${FIND_AEON_PACKAGE_PARSED_ARGS_NAME} not found!")
        endif ()

        set(${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARIES
            debug ${${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_DEBUG}
            optimized ${${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_LIBRARY_RELEASE}
        )

        message(STATUS "Found ${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}: ${${FIND_AEON_PACKAGE_PARSED_ARGS_NAME}_ROOT_DIR}")
    else ()
        message(FATAL_ERROR "${FIND_AEON_PACKAGE_PARSED_ARGS_NAME} not found!")
    endif ()
endmacro()
