include(GitDescribe)

set(AEON_CMAKE_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR})

function(generate_build_info_header destination)
    get_git_describe_tag(git_describe_tag)

    set(AEON_CMAKE_FULL_VERSION ${git_describe_tag})
    string(TIMESTAMP AEON_CMAKE_BUILD_DATE "%Y-%m-%d")

    configure_file(
        ${AEON_CMAKE_ROOT_DIR}/buildinfo.h.in
        ${destination}
        @ONLY
    )
endfunction()
