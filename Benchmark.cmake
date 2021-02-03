# Distributed under the BSD 2-Clause License - Copyright 2012-2021 Robin Degen

if (NOT TARGET GoogleBenchmark::GoogleBenchmark)
    message(FATAL_ERROR "Benchmark.cmake requires Google Benchmark (GoogleBenchmark::GoogleBenchmark target is missing)")
endif ()

include(CMakeParseArguments)

function(add_benchmark_suite)
    cmake_parse_arguments(
        BENCHMARK_PARSED_ARGS
        "NO_BENCHMARK_MAIN"
        "TARGET;FOLDER"
        "SOURCES;LIBRARIES;INCLUDES;LABELS"
        ${ARGN}
    )

    if (NOT BENCHMARK_PARSED_ARGS_TARGET)
        message(FATAL_ERROR "No target name was given for benchmark.")
    endif ()

    if (NOT BENCHMARK_PARSED_ARGS_SOURCES)
        message(FATAL_ERROR "No sources were given for benchmark.")
    endif ()

    foreach(_src ${BENCHMARK_PARSED_ARGS_SOURCES})
        list (APPEND SRCS "${BENCHMARK_PARSED_ARGS_TARGET}/${_src}")
    endforeach()

    add_executable(${BENCHMARK_PARSED_ARGS_TARGET} ${SRCS})

    if (BENCHMARK_PARSED_ARGS_FOLDER)
        set_target_properties(
            ${BENCHMARK_PARSED_ARGS_TARGET} PROPERTIES
            FOLDER ${BENCHMARK_PARSED_ARGS_FOLDER}
            RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
        )
    endif ()

    if (BENCHMARK_PARSED_ARGS_INCLUDES)
        target_include_directories(${BENCHMARK_PARSED_ARGS_TARGET} PRIVATE ${BENCHMARK_PARSED_ARGS_INCLUDES})
    endif ()

    target_link_libraries(
        ${BENCHMARK_PARSED_ARGS_TARGET}
        GoogleBenchmark::GoogleBenchmark
    )

    if (NOT ${BENCHMARK_PARSED_ARGS_NO_BENCHMARK_MAIN})
        if (NOT TARGET GoogleBenchmark::Main)
            message(FATAL_ERROR "Benchmark.cmake requires Google Benchmark Main (GoogleBenchmark::Main target is missing)")
        endif ()
        target_link_libraries(${BENCHMARK_PARSED_ARGS_TARGET} benchmark_main)
    endif ()

    if (BENCHMARK_PARSED_ARGS_LIBRARIES)
        target_link_libraries(
            ${BENCHMARK_PARSED_ARGS_TARGET}
            ${BENCHMARK_PARSED_ARGS_LIBRARIES}
        )
    endif ()
endfunction()
