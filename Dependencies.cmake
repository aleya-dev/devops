# Distributed under the BSD 2-Clause License - Copyright 2012-2022 Robin Degen

include(ArchiveDownload)
include(Logging)

if (DEFINED ENV{AEON_EXTERNAL_DEPENDENCIES_DIR})
    file(TO_CMAKE_PATH "$ENV{AEON_EXTERNAL_DEPENDENCIES_DIR}" __EXTERNAL_DEPENDENCIES_DIR)
else ()
    get_filename_component(__EXTERNAL_DEPENDENCIES_DIR ${CMAKE_SOURCE_DIR}/external_dependencies REALPATH)
endif ()

set(AEON_EXTERNAL_DEPENDENCIES_URL "https://packages.aeons.dev/legacy/"
    CACHE STRING "The remote url for downloading external packages.")

option(AEON_EXTERNAL_DEPENDENCIES_LOCAL "Enable local dependencies" OFF)

if (AEON_EXTERNAL_DEPENDENCIES_LOCAL)
    message(STATUS "Local external dependencies enabled. Downloading stubs.")
    set(AEON_EXTERNAL_DEPENDENCIES_PLATFORM "local")
    set(AEON_EXTERNAL_DEPENDENCIES_EXTENSION "tar.gz")
elseif (MSVC)
    set(AEON_EXTERNAL_DEPENDENCIES_PLATFORM "windows_vc2019")
    set(AEON_EXTERNAL_DEPENDENCIES_EXTENSION "zip")
elseif (UNIX AND NOT APPLE)
    set(AEON_EXTERNAL_DEPENDENCIES_PLATFORM "linux_gcc8")
    set(AEON_EXTERNAL_DEPENDENCIES_EXTENSION "tar.gz")
elseif (APPLE)
    set(AEON_EXTERNAL_DEPENDENCIES_PLATFORM "macos_clang8")
    set(AEON_EXTERNAL_DEPENDENCIES_EXTENSION "tar.gz")
else ()
    message(FATAL_ERROR "The current platform is not supported by the package manager.")
endif ()

set(AEON_EXTERNAL_DEPENDENCIES_DIR "${__EXTERNAL_DEPENDENCIES_DIR}" CACHE FILEPATH "The directory where external dependencies will be downloaded to.")

function(__handle_dependencies_file_internal dependencies_file indent)
    if (EXISTS ${dependencies_file})
        file(STRINGS "${dependencies_file}" __dependency_file_lines REGEX "^[^#]")

        foreach (__line ${__dependency_file_lines})
            string(REGEX REPLACE " " ";" __line_split "${__line}")
            list(GET __line_split 0 __dependency_directive)

            string(COMPARE EQUAL "${__dependency_directive}" "url" __url)

            if (AEON_EXTERNAL_DEPENDENCIES_LOCAL)
                list(GET __line_split 0 __package_name)

                message(STATUS "${__package_name} (local)")
                include(Packages/${__package_name})
            else ()
                list(GET __line_split 0 __package_name)
                list(GET __line_split 1 __package_version)

                set(__package_sub_path ${__package_name}/${AEON_EXTERNAL_DEPENDENCIES_PLATFORM}/${__package_name}_${__package_version})

                if (NOT EXISTS ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__package_sub_path})
                    log_indent("${__package_name} (Version: ${AEON_EXTERNAL_DEPENDENCIES_PLATFORM} ${__package_version}) - Downloading" ${indent})

                    archive_download(
                        ${AEON_EXTERNAL_DEPENDENCIES_URL}/${__package_sub_path}.${AEON_EXTERNAL_DEPENDENCIES_EXTENSION}
                        ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__package_sub_path}.${AEON_EXTERNAL_DEPENDENCIES_EXTENSION}
                        ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__package_name}/${AEON_EXTERNAL_DEPENDENCIES_PLATFORM}
                    )
                else ()
                    log_indent("${__package_name} (Version: ${AEON_EXTERNAL_DEPENDENCIES_PLATFORM} ${__package_version})" ${indent})
                endif ()

                # Check for dependencies file
                if (EXISTS ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__package_sub_path}/dependencies.txt)
                    math(EXPR __recurse_indent "${indent}+1")
                    __handle_dependencies_file_internal(${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__package_sub_path}/dependencies.txt ${__recurse_indent})
                endif ()

                # Check for package cmake file
                if (EXISTS ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__package_sub_path}/package.cmake)
                    include(${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__package_sub_path}/package.cmake)
                endif ()
            endif ()
        endforeach ()
    else ()
        message(STATUS "Dependency file does not exist. Skipping.")
    endif ()
endfunction()

function(handle_dependencies_file dependencies_file)
    __handle_dependencies_file_internal(${dependencies_file} 0)
endfunction()

function(handle_local_dependencies_file)
    handle_dependencies_file(${CMAKE_CURRENT_SOURCE_DIR}/dependencies.txt)
endfunction()
