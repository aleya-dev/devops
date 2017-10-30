# Copyright (c) 2012-2017 Robin Degen
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

message("Compiler: ${CMAKE_CXX_COMPILER_ID}")
message("Version: ${CMAKE_CXX_COMPILER_VERSION}")

if (MSVC)
    if (${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
        message("Clang for Visual Studio detected. Setting flags:")
    else ()
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.10)
            message(FATAL_ERROR "Requires Visual Studio 2017 or higher!")
        endif ()

        message("Visual Studio detected. Setting flags:")
        message(" - Treat warnings as errors (/WX)")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /WX")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++latest")
    endif ()

    message(" - Defining _SCL_SECURE_NO_WARNINGS")
    message(" - Defining _CRT_SECURE_NO_DEPRECATE")
    message(" - Defining NOMINMAX")
    message(" - Setting Windows 7 API level (_WIN32_WINNT=0x0601)")
    message(" - Setting Warning Level 4")
    message(" - Ignore warning C4100 The formal parameter is not referenced in the body of the function.")
    message(" - Ignore warning C4201 Nonstandard extension used: nameless struct/union")
    message(" - Ignore warning C4373 Previous versions of the compiler did not override when parameters only differed by const/volatile qualifiers")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_SCL_SECURE_NO_WARNINGS -D_CRT_SECURE_NO_DEPRECATE -DNOMINMAX -D_WIN32_WINNT=0x0601 /W4 /wd4100 /wd4201 /wd4373")
endif ()

if (NOT CMAKE_CXX_COMPILER_ID)
    set(CMAKE_CXX_COMPILER_ID Unknown)
endif ()

if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" AND NOT CYGWIN)
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.1)
        message(FATAL_ERROR "Requires GCC 5.1.0 or higher!")
    else ()
        message("GNU GCC detected. Setting flags:")

        message(" - CLion Debugger STL Renderer workaround")
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -gdwarf-3")
        set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -gdwarf-3")

        message(" - Suppressing C++ deprecation warnings.")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-declarations")
    endif ()
endif ()

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    message("Clang detected. Setting flags:")
    message(" - Disable C++17 extension warnings")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-c++17-extensions")

    message(" - Link with c++experimental")
    get_filename_component(AEON_CLANG_PREFIX_PATH $ENV{CXX} DIRECTORY)
    link_directories("${AEON_CLANG_PREFIX_PATH}/../lib")
    link_libraries(c++experimental)
endif ()

