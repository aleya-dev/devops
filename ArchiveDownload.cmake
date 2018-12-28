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

# Download an arhive (zip, tar.gz etc.) from a URL and extract it
# to the given path.
# \param url The url to the archive to download
# \param archive_path Path where to download the archive to
# \param destination_path The path where to extract the archive
function(archive_download url archive_path destination_path)
    file(DOWNLOAD "${url}" "${archive_path}" STATUS __download_status)

    list(GET __download_status 0 __download_status_error_nr)

    if (NOT __download_status_error_nr EQUAL 0)
        list(GET __download_status 1 __download_status_error_description)
        message(FATAL_ERROR "Error downloading archive: ${__download_status_error_description}.")
    endif ()

    if (NOT EXISTS "${destination_path}")
        file(MAKE_DIRECTORY "${destination_path}")
    endif ()

    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xf "${archive_path}"
        WORKING_DIRECTORY "${destination_path}"
    )
endfunction()
