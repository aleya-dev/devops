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
