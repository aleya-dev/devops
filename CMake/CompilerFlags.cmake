# Distributed under the BSD 2-Clause License - Copyright 2012-2023 Robin Degen

message(STATUS "Compiler: ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "Version: ${CMAKE_CXX_COMPILER_VERSION}")

include(CppSupport)
include(Architecture)

if (MSVC)
    set(AEON_DISABLE_ITERATOR_DEBUGGING OFF CACHE BOOL "Disable Visual Studio iterator debugging")

    if (${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
        message(STATUS "Clang for Visual Studio detected. Setting flags:")
        # The <experimental/coroutine>, <experimental/generator>, and <experimental/resumable> headers currently do not support Clang.
        # You can define _SILENCE_CLANG_COROUTINE_MESSAGE to silence this message and acknowledge that this is unsupported.
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_SILENCE_CLANG_COROUTINE_MESSAGE")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_SILENCE_CLANG_COROUTINE_MESSAGE")
    else ()
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.20)
            message(FATAL_ERROR "Requires Visual Studio 2019 or higher!")
        endif ()

        message(STATUS "Visual Studio detected. Setting flags:")
        message(STATUS " - Treat warnings as errors (/WX)")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /WX")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /permissive-")
    endif ()

    message(STATUS " - Defining NOMINMAX")
    message(STATUS " - Setting Windows 10 API level (WINVER=_WIN32_WINNT_WIN10, _WIN32_WINNT=_WIN32_WINNT_WIN10)")
    message(STATUS " - Setting Warning Level 4")
    message(STATUS " - Atomic Alignment fix: Instantiated std::atomic<T> with sizeof(T) equal to 2/4/8 and alignof(T) < sizeof(T). (_ENABLE_ATOMIC_ALIGNMENT_FIX)")
    message(STATUS " - Extended Alignment fix: Instantiated std::aligned_storage<Len, Align> with an extended alignment. (_ENABLE_EXTENDED_ALIGNED_STORAGE)")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_ENABLE_ATOMIC_ALIGNMENT_FIX")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_ENABLE_EXTENDED_ALIGNED_STORAGE")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DNOMINMAX")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DWINVER=_WIN32_WINNT_WIN10")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_WIN32_WINNT=_WIN32_WINNT_WIN10")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")

    # 32-bit Visual Studio complains a lot about conversions ("Possible loss of data", "signed/unsigned mismatch").
    # Instead of littering the code with casts, just ignore the warning for now until there is a better solution
    if (AEON_ARCHITECTURE_32_BIT)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4018 /wd4244")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4018 /wd4244")
    endif ()

    if (AEON_DISABLE_ITERATOR_DEBUGGING)
        message(STATUS " - Disable iterator debugging")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_ITERATOR_DEBUG_LEVEL=0")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_ALLOW_ITERATOR_DEBUG_LEVEL_MISMATCH")
    endif ()

    # Make sure the correct C++ version is reported through the __cplusplus macro.
    add_compile_options(/Zc:__cplusplus)

    if (AEON_ENABLE_UNICODE)
        message(STATUS " - Using Unicode")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_UNICODE -DUNICODE")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_UNICODE -DUNICODE")
    endif ()

    # For ClangCL we use -march=native instead
    if (NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        include(Simd)

        if (AEON_CPU_HAS_AVX2)
            # Enabling AVX2 on Visual Studio will also enable SSE optimizations.
            message(STATUS " - Encourage optimizations for AVX2 (/arch:AVX2)")
            set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} /arch:AVX2")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:AVX2")
        else ()
            if (AEON_CPU_HAS_AVX)
                message(STATUS " - Encourage optimizations for AVX (/arch:AVX)")
                set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} /arch:AVX")
                set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:AVX")
            else ()
                message(STATUS " - Encourage optimizations for SSE2 (/arch:SSE2)")
                set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} /arch:SSE2")
                set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:SSE2")
            endif ()
        endif ()
    else ()
        message(STATUS " - Setting -march=native for ClangCL")
        message(STATUS " - Setting showFilenames for ClangCL")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /clang:-march=native /showFilenames")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /clang:-march=native /showFilenames")
    endif ()

    set(AEON_ENABLE_COMPILE_TIME_STATS OFF CACHE BOOL "Enable Visual Studio compiler flags to aid in compile time optimization")

    if (AEON_ENABLE_COMPILE_TIME_STATS)
        message(STATUS " - Enabling compile-time stats")
        add_compile_options(/d1reportTime)
    endif ()

    set(AEON_ENABLE_ADDITIONAL_COMPILE_TIME_STATS OFF CACHE BOOL "Enable additional Visual Studio compiler flags to aid in compile time optimization")

    if (AEON_ENABLE_ADDITIONAL_COMPILE_TIME_STATS)
        message(STATUS " - Enabling additional compile-time stats")
        add_compile_options(/Bt+)
        add_compile_options(/d2cgsummary)
        add_link_options(/time+)
    endif ()

    set(AEON_ENABLE_MSVC_PARALLEL_BUILD ON CACHE BOOL "Enable parallel compilation unit building in Visual Studio")

    # /MP does not play nicely with compile-time stats since the tools require a clean linear build output
    if (AEON_ENABLE_MSVC_PARALLEL_BUILD)
        if (AEON_ENABLE_COMPILE_TIME_STATS OR AEON_ENABLE_ADDITIONAL_COMPILE_TIME_STATS)
            message(STATUS " - Parallel build can not be enabled due to additional compile-time stats being enabled.")
        else ()
            message(STATUS " - Enabling parallel build")
            add_compile_options(/MP)
        endif ()
    endif ()
endif ()

if (NOT CMAKE_CXX_COMPILER_ID)
    set(CMAKE_CXX_COMPILER_ID Unknown)
endif ()

if (APPLE)
    link_libraries(c++fs)
elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" AND NOT CYGWIN)
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 11.0)
        message(FATAL_ERROR "Requires GCC 11.0 or higher!")
    else ()
        message(STATUS "GNU GCC detected. Setting flags:")

        message(STATUS " - Encourage optimizations for the current architecture (-march=native)")
        message(STATUS " - Enable Position Independent Code (-fPIC)")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=native -fPIC")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native -fPIC")

        link_libraries(stdc++fs)
    endif ()
elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND NOT MSVC)
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 12.0)
        message(FATAL_ERROR "Requires Clang 12.0 or higher!")
    else ()
        message(STATUS "Clang detected. Setting flags:")
        message(STATUS " - Disable C++17 extension warnings")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-c++17-extensions")

        # Clang will complain about the usage of a static member variable inside
        # of a templated class if the instantiation is done in another compilation
        # unit. However this seems odd, since this would normally trigger a linker
        # error anyway.
        message(STATUS " - Disable warning for 'undefined' template variables.")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wundefined-var-template")

        message(STATUS " - Encourage optimizations for the current architecture (-march=native)")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=native")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native")

        link_libraries(stdc++fs)
    endif ()
endif ()

# This detection for ARM devices is incomplete.
# I can improve this once I have more devices to test with.
# For certain devices it is likely that additional flags are required (NEON, soft float etc.)
if (UNIX AND NOT APPLE)
    if (CMAKE_SYSTEM_PROCESSOR MATCHES "arm" OR CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
        message(STATUS "Detected ARM CPU. Disabling possible SSE/AVX code (AEON_DISABLE_SSE).")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DAEON_DISABLE_SSE")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DAEON_DISABLE_SSE")
    endif ()
endif ()

# On Visual Studio (not ClangCL), hide the warning that a pdb file could not be found.
if (MSVC AND NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_link_options("/ignore:4099")
endif ()
