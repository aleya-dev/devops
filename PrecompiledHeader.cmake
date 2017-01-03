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

macro(use_precompiled_header TARGET HEADER_FILE SRC_FILE)
    if (MSVC)
        get_filename_component(HEADER ${HEADER_FILE} NAME)
        add_definitions(/Yu"${HEADER}")
        set_source_files_properties(${SRC_FILE} PROPERTIES COMPILE_FLAGS /Yc"${HEADER}")
    endif ()
endmacro(use_precompiled_header)
