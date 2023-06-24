# Distributed under the BSD 2-Clause License - Copyright 2012-2023 Robin Degen

include(CheckCXXSourceCompiles)

message(STATUS "Detecting support for integer std::from_chars")

if (MSVC)
    set(CMAKE_REQUIRED_FLAGS "/std:c++17")
else ()
    set(CMAKE_REQUIRED_FLAGS "-std=c++17")
endif ()

check_cxx_source_compiles("
        #include <charconv>
        #include <string>

        int main(int argc, char *argv[])
        {
            std::string str;

            auto value = 0;
            const auto [ptr, ec] = std::from_chars(std::data(str), std::data(str) + std::size(str), value);

            if (ec != std::errc{})
                return 1;

            return 0;
        }"
    AEON_COMPILER_HAS_FROM_CHARS_INTEGER)

message(STATUS "Detecting support for float std::from_chars")

check_cxx_source_compiles("
        #include <charconv>
        #include <string>

        int main(int argc, char *argv[])
        {
            std::string str;

            auto value = 0.0f;
            const auto [ptr, ec] = std::from_chars(std::data(str), std::data(str) + std::size(str), value);

            if (ec != std::errc{})
                return 1;

            return 0;
        }"
    AEON_COMPILER_HAS_FROM_CHARS_FLOAT)

message(STATUS "Detecting support for double std::from_chars")

check_cxx_source_compiles("
        #include <charconv>
        #include <string>

        int main(int argc, char *argv[])
        {
            std::string str;

            auto value = 0.0;
            const auto [ptr, ec] = std::from_chars(std::data(str), std::data(str) + std::size(str), value);

            if (ec != std::errc{})
                return 1;

            return 0;
        }"
    AEON_COMPILER_HAS_FROM_CHARS_DOUBLE)

message(STATUS "Detecting support for long double std::from_chars")

check_cxx_source_compiles("
        #include <charconv>
        #include <string>

        int main(int argc, char *argv[])
        {
            std::string str;

            long double value = 0.0;
            const auto [ptr, ec] = std::from_chars(std::data(str), std::data(str) + std::size(str), value);

            if (ec != std::errc{})
                return 1;

            return 0;
        }"
    AEON_COMPILER_HAS_FROM_CHARS_LONG_DOUBLE)


configure_file(${CMAKE_CURRENT_LIST_DIR}/aeon_cpp_support.h.in aeon_cpp_support.h @ONLY)
