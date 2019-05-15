# Copyright (c) 2012-2019 Robin Degen

function(string_repeat str count output)
    set(__output_str "")
    while(NOT ${count} STREQUAL "0")
        math(EXPR count "${count}-1")
        string(APPEND __output_str "${str}")
    endwhile()

    set(${output} "${__output_str}" PARENT_SCOPE)
endfunction()

function(string_capitalize str output)
    string(SUBSTRING "${str}" 0 1 __str_first_char)
    string(TOUPPER "${__str_first_char}" __str_first_char)

    string(SUBSTRING "${str}" 1 -1 __str_remainder)
    string(TOLOWER "${__str_remainder}" __str_remainder)

    set(${output} "${__str_first_char}${__str_remainder}" PARENT_SCOPE)
endfunction()

# Expand a given string with spaces up to a certain length. This can be useful
# for generating a table-like column view.
# For example:
# string_expand_width("test" 10 output) would result in "test      "
#
# If the given length is shorter than the given string, nothing will be added.
function(string_expand_width str len output)
    string(LENGTH "${str}" strlen)

    set(__output_str "")
    if (strlen LESS len)
        math(EXPR count "${len}-${strlen}")
        string_repeat(" " ${count} __output_str)
    endif ()

    set(${output} "${str}${__output_str}" PARENT_SCOPE)
endfunction()

function(string_indent str depth output)
    string_repeat(" " ${depth} __output_str)
    set(${output} "${__output_str}${str}" PARENT_SCOPE)
endfunction()
