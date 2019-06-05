# Distributed under the BSD 2-Clause License - Copyright 2012-2019 Robin Degen

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
        message(FATAL_ERROR "Could not download url: '${url}'.")
        message(FATAL_ERROR "${__download_status_error_description}.")
    endif ()

    if (NOT EXISTS "${destination_path}")
        file(MAKE_DIRECTORY "${destination_path}")
    endif ()

    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xf "${archive_path}"
        WORKING_DIRECTORY "${destination_path}"
    )
endfunction()
