# Distributed under the BSD 2-Clause License - Copyright 2012-2023 Robin Degen

include(StringUtils)

function(log_indent msg indent_depth)
    math(EXPR indent "${indent_depth}*4")
    string_indent("${msg}" ${indent} __msg)
    message(STATUS "${__msg}")
endfunction()

function(log_columns columns width)
    set(__msg "")

    foreach(column ${columns})
        string_expand_width("${column}" ${width} __indented_column)
        string(APPEND __msg "${__indented_column}")
    endforeach()

    string(STRIP "${__msg}" __msg)
    message(STATUS "${__msg}")
endfunction()

function(log_hline width)
    string_repeat("-" ${width} __hline)
    message(STATUS ${__hline})
endfunction()
