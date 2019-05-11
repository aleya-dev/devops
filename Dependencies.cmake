# Copyright (c) 2012-2019 Robin Degen

include(ArchiveDownload)

if (DEFINED ENV{AEON_EXTERNAL_DEPENDENCIES_DIR})
    file(TO_CMAKE_PATH "$ENV{AEON_EXTERNAL_DEPENDENCIES_DIR}" __EXTERNAL_DEPENDENCIES_DIR)
else ()
    get_filename_component(__EXTERNAL_DEPENDENCIES_DIR ${CMAKE_SOURCE_DIR}/external_dependencies REALPATH)
endif ()

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
else ()
    message(FATAL_ERROR "The current platform is not supported by the package manager.")
endif ()

set(AEON_EXTERNAL_DEPENDENCIES_DIR "${__EXTERNAL_DEPENDENCIES_DIR}" CACHE FILEPATH "The directory where external dependencies will be downloaded to.")

function(handle_dependencies_file dependencies_file)
    if (EXISTS ${dependencies_file})
        file(STRINGS "${dependencies_file}" __dependency_file_lines REGEX "^[^#]")

        foreach (__line ${__dependency_file_lines})
            string(REGEX REPLACE " " ";" __line_split "${__line}")
            list(GET __line_split 0 __dependency_directive)
            list(REMOVE_AT __line_split 0)

            string(COMPARE EQUAL "${__dependency_directive}" "bintray_url" __is_bintray_url)
            string(COMPARE EQUAL "${__dependency_directive}" "bintray" __is_bintray)

            if (__is_bintray_url)
                list(GET __line_split 0 AEON_EXTERNAL_DEPENDENCIES_BINTRAY_URL)
                message(STATUS "Setting Bintray url to ${AEON_EXTERNAL_DEPENDENCIES_BINTRAY_URL}")
            elseif (__is_bintray)
                if (NOT AEON_EXTERNAL_DEPENDENCIES_BINTRAY_URL)
                    message(FATAL_ERROR "Bintray can not be used without setting an url first.")
                endif ()

                list(GET __line_split 0 __bintray_package_name)
                list(GET __line_split 1 __bintray_package_version)

                set(__package_sub_path ${__bintray_package_name}/${AEON_EXTERNAL_DEPENDENCIES_PLATFORM}/${__bintray_package_name}_${__bintray_package_version})

                if (NOT EXISTS ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__package_sub_path})
                    message(STATUS "[bintray] ${__bintray_package_name} (Version: ${AEON_EXTERNAL_DEPENDENCIES_PLATFORM} ${__bintray_package_version}) - Downloading")

                    archive_download(
                        ${AEON_EXTERNAL_DEPENDENCIES_BINTRAY_URL}/${__package_sub_path}.${AEON_EXTERNAL_DEPENDENCIES_EXTENSION}
                        ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__package_sub_path}.${AEON_EXTERNAL_DEPENDENCIES_EXTENSION}
                        ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__bintray_package_name}/${AEON_EXTERNAL_DEPENDENCIES_PLATFORM}
                    )
                else ()
                    message(STATUS "[bintray] ${__bintray_package_name} (Version: ${AEON_EXTERNAL_DEPENDENCIES_PLATFORM} ${__bintray_package_version})")
                endif ()

                # Check for dependencies file
                if (EXISTS ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__package_sub_path}/dependencies.txt)
                    handle_dependencies_file(${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__package_sub_path}/dependencies.txt)
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
