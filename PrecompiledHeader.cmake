# Copyright (c) 2012-2019 Robin Degen

macro(use_precompiled_header TARGET HEADER_FILE SRC_FILE)
    if (MSVC)
        get_filename_component(HEADER ${HEADER_FILE} NAME)
        add_definitions(/Yu"${HEADER}")
        set_source_files_properties(${SRC_FILE} PROPERTIES COMPILE_FLAGS /Yc"${HEADER}")
    endif ()
endmacro(use_precompiled_header)
