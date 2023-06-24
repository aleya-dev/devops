# Distributed under the BSD 2-Clause License - Copyright 2012-2023 Robin Degen

find_path(GoogleBenchmark_INCLUDE_DIRS benchmark/benchmark.h
    DOC
        "Found google benchmark include directory"
    ENV
        GOOGLE_BENCHMARK_ROOT
    PATH_SUFFIXES
        include
)

find_library(GoogleBenchmark_LIBRARIES
    NAMES libbenchmark.a benchmark
    DOC "Found google benchmark library path"
    ENV
        GOOGLE_BENCHMARK_ROOT
    PATH_SUFFIXES
        lib
        lib64
)

find_library(GoogleBenchmark_MAIN_LIBRARIES
    NAMES libbenchmark_main.so benchmark_main
    DOC "Found google benchmark main library path"
    ENV
        GOOGLE_BENCHMARK_ROOT
    PATH_SUFFIXES
        lib
        lib64
)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GoogleBenchmark
    FOUND_VAR
        GoogleBenchmark_FOUND
    REQUIRED_VARS
        GoogleBenchmark_INCLUDE_DIRS
        GoogleBenchmark_LIBRARIES
        GoogleBenchmark_MAIN_LIBRARIES
)

if (GoogleBenchmark_FOUND)
    if (NOT TARGET GoogleBenchmark::GoogleBenchmark)
        add_library(GoogleBenchmark::GoogleBenchmark STATIC IMPORTED)
        set_target_properties(GoogleBenchmark::GoogleBenchmark PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${GoogleBenchmark_INCLUDE_DIRS})
        set_target_properties(GoogleBenchmark::GoogleBenchmark PROPERTIES IMPORTED_LOCATION ${GoogleBenchmark_LIBRARIES})

        set(CMAKE_THREAD_PREFER_PTHREAD ON)
        find_package(Threads REQUIRED)
        set_target_properties(GoogleBenchmark::GoogleBenchmark PROPERTIES INTERFACE_LINK_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
    endif ()

    if (NOT TARGET GoogleBenchmark::Main)
        add_library(GoogleBenchmark::Main STATIC IMPORTED)
        set_target_properties(GoogleBenchmark::Main PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${GoogleBenchmark_INCLUDE_DIRS})
        set_target_properties(GoogleBenchmark::Main PROPERTIES IMPORTED_LOCATION ${GoogleBenchmark_MAIN_LIBRARIES})
        set_target_properties(GoogleBenchmark::Main PROPERTIES INTERFACE_LINK_LIBRARIES GoogleBenchmark::GoogleBenchmark)
    endif ()
endif ()

