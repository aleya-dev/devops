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

if (NOT AEON_ARCHITECTURE_SUFFIX_SET)
    if (CMAKE_SIZEOF_VOID_P EQUAL 8)
        message(STATUS "Detected 64-bit compilation.")
        set(AEON_ARCHITECTURE_SUFFIX "64")
        set(AEON_ARCHITECTURE_SUFFIX_SET 1)
        set(AEON_ARCHITECTURE_32_BIT 0)
        set(AEON_ARCHITECTURE_64_BIT 1)
    else ()
        message(STATUS "Detected 32-bit compilation.")
        set(AEON_ARCHITECTURE_SUFFIX "")
        set(AEON_ARCHITECTURE_SUFFIX_SET 1)
        set(AEON_ARCHITECTURE_32_BIT 1)
        set(AEON_ARCHITECTURE_64_BIT 0)
    endif ()
endif ()
