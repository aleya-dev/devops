# Copyright (c) 2012-2019 Robin Degen

include(StringUtils)

function(log_indent msg indent_depth)
    math(EXPR indent "${indent_depth}*4")
    string_indent("${msg}" ${indent} __msg)
    message(STATUS "${__msg}")
endfunction()
