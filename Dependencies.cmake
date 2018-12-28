# Copyright (c) 2012-2018 Robin Degen
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

find_package(Git)

include(GitUtils)
include(ArchiveDownload)

if (DEFINED ENV{AEON_EXTERNAL_DEPENDENCIES_DIR})
    file(TO_CMAKE_PATH "$ENV{AEON_EXTERNAL_DEPENDENCIES_DIR}" __EXTERNAL_DEPENDENCIES_DIR)
else ()
    get_filename_component(__EXTERNAL_DEPENDENCIES_DIR ${CMAKE_SOURCE_DIR}/external_dependencies REALPATH)
endif ()

if (MSVC)
    set(AEON_EXTERNAL_DEPENDENCIES_PLATFORM "vc2017")
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
            string(COMPARE EQUAL "${__dependency_directive}" "git" __is_git)

            if (__is_bintray_url)
                list(GET __line_split 0 AEON_EXTERNAL_DEPENDENCIES_BINTRAY_URL)
                message(STATUS "Setting Bintray url to ${AEON_EXTERNAL_DEPENDENCIES_BINTRAY_URL}")
            elseif (__is_bintray)
                if (NOT AEON_EXTERNAL_DEPENDENCIES_BINTRAY_URL)
                    message(FATAL_ERROR "Bintray can not be used without setting an url first.")
                endif ()

                list(GET __line_split 0 __bintray_package_name)
                list(GET __line_split 1 __bintray_package_version)

                message(STATUS "[bintray] ${__bintray_package_name} (Version: ${__bintray_package_version})")

                if (NOT EXISTS ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__bintray_package_name}/${__bintray_package_name}_${__bintray_package_version})
                    archive_download(
                        ${AEON_EXTERNAL_DEPENDENCIES_BINTRAY_URL}/${__bintray_package_name}/${AEON_EXTERNAL_DEPENDENCIES_PLATFORM}/${__bintray_package_name}_${__bintray_package_version}.zip
                        ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__bintray_package_name}/${__bintray_package_name}_${__bintray_package_version}.zip
                        ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__bintray_package_name}
                    )
                endif ()

                # Check for dependencies file
                if (EXISTS ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__bintray_package_name}/${__bintray_package_name}_${__bintray_package_version}/dependencies.txt)
                    handle_dependencies_file(${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__bintray_package_name}/${__bintray_package_name}_${__bintray_package_version}/dependencies.txt)
                endif ()

                # Check for package cmake file
                if (EXISTS ${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__bintray_package_name}/${__bintray_package_name}_${__bintray_package_version}/package.cmake)
                    include(${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__bintray_package_name}/${__bintray_package_name}_${__bintray_package_version}/package.cmake)
                endif ()
            elseif (__is_git)
                if (NOT Git_FOUND)
                    message(FATAL_ERROR "Git can not be used since the executable could not be found.")
                endif ()

                list(GET __line_split 0 __git_package_name)
                list(GET __line_split 1 __git_package_url)
                list(GET __line_split 2 __git_package_treeish)

                message(STATUS "[git] ${__git_package_url} (Version: ${__git_package_treeish})")
                git_clone_and_checkout("${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__git_package_name}" ${__git_package_url} ${__git_package_treeish})

                # Check for dependencies file
                if (EXISTS "${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__git_package_name}/dependencies.txt")
                    handle_dependencies_file("${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__git_package_name}/dependencies.txt")
                endif ()

                # Check for package cmake file
                if (EXISTS "${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__git_package_name}/package.cmake")
                    include("${AEON_EXTERNAL_DEPENDENCIES_DIR}/${__git_package_name}/package.cmake")
                endif ()
            endif ()
        endforeach ()
    else ()
        message(STATUS "Dependency file does not exist. Skipping.")
    endif ()
endfunction()
