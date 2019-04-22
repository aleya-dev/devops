# Copyright (c) 2012-2019 Robin Degen

message("Compiler: ${CMAKE_CXX_COMPILER_ID}")
message("Version: ${CMAKE_CXX_COMPILER_VERSION}")

include(CppSupport)

if (MSVC)
    if (${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
        message("Clang for Visual Studio detected. Setting flags:")
    else ()
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.20)
            message(FATAL_ERROR "Requires Visual Studio 2019 or higher!")
        endif ()

        message("Visual Studio detected. Setting flags:")
        message(" - Treat warnings as errors (/WX)")
        message(" - Enforce latest C++17 ISO standard.")
        message(" - Disable nodiscard warnings due to build issues with various libraries.")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /WX")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++latest /permissive- /Wv:18")
    endif ()

    message(" - Defining _SCL_SECURE_NO_WARNINGS")
    message(" - Defining _CRT_SECURE_NO_DEPRECATE")
    message(" - Defining NOMINMAX")
    message(" - Setting Windows 7 API level (_WIN32_WINNT=0x0601)")
    message(" - Setting Warning Level 4")
    message(" - Ignore warning C4100 The formal parameter is not referenced in the body of the function.")
    message(" - Ignore warning C4201 Nonstandard extension used: nameless struct/union")
    message(" - Ignore warning C4373 Previous versions of the compiler did not override when parameters only differed by const/volatile qualifiers")
    message(" - Atomic Alignment fix: Instantiated std::atomic<T> with sizeof(T) equal to 2/4/8 and alignof(T) < sizeof(T). (_ENABLE_ATOMIC_ALIGNMENT_FIX)")
    message(" - Extended Alignment fix: Instantiated std::aligned_storage<Len, Align> with an extended alignment. (_ENABLE_EXTENDED_ALIGNED_STORAGE)")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_SCL_SECURE_NO_WARNINGS -D_CRT_SECURE_NO_DEPRECATE -D_ENABLE_ATOMIC_ALIGNMENT_FIX -D_ENABLE_EXTENDED_ALIGNED_STORAGE -DNOMINMAX -D_WIN32_WINNT=0x0601 /W4 /wd4100 /wd4201 /wd4373")

    if (AEON_ENABLE_UNICODE)
        message(" - Using Unicode")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_UNICODE -DUNICODE")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_UNICODE -DUNICODE")
    endif ()

    include(Simd)

    if (AEON_CPU_HAS_AVX2)
        # Enabling AVX2 on Visual Studio will also enable SSE optimizations.
        message(" - Encourage optimizations for AVX2 (/arch:AVX2)")
        set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} /arch:AVX2")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:AVX2")
    else ()
        if (AEON_CPU_HAS_AVX)
            message(" - Encourage optimizations for AVX (/arch:AVX)")
            set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} /arch:AVX")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:AVX")
        else ()
            message(" - Encourage optimizations for SSE2 (/arch:SSE2)")
            set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} /arch:SSE2")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:SSE2")
        endif ()
    endif ()

    set(AEON_ENABLE_COMPILE_TIME_STATS OFF CACHE BOOL "Enable Visual Studio compiler flags to aid in compile time optimization")

    if (AEON_ENABLE_COMPILE_TIME_STATS)
        message(" - Enabling compile-time stats")
        add_compile_options(/d1reportTime)
    endif ()

    set(AEON_ENABLE_ADDITIONAL_COMPILE_TIME_STATS OFF CACHE BOOL "Enable additional Visual Studio compiler flags to aid in compile time optimization")

    if (AEON_ENABLE_ADDITIONAL_COMPILE_TIME_STATS)
        message(" - Enabling additional compile-time stats")
        add_compile_options(/Bt+)
        add_compile_options(/d2cgsummary)
        add_link_options(/time+)
    endif ()

    set(AEON_ENABLE_MSVC_PARALLEL_BUILD ON CACHE BOOL "Enable parallel compilation unit building in Visual Studio")

    # /MP does not play nicely with compile-time stats since the tools require a clean linear build output
    if (AEON_ENABLE_MSVC_PARALLEL_BUILD)
        if (AEON_ENABLE_COMPILE_TIME_STATS OR AEON_ENABLE_ADDITIONAL_COMPILE_TIME_STATS)
            message(" - Parallel build can not be enabled due to additional compile-time stats being enabled.")
        else ()
            message(" - Enabling parallel build")
            add_compile_options(/MP)
        endif ()
    endif ()
endif ()

if (NOT CMAKE_CXX_COMPILER_ID)
    set(CMAKE_CXX_COMPILER_ID Unknown)
endif ()

if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" AND NOT CYGWIN)
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 7.3)
        message(FATAL_ERROR "Requires GCC 7.3.0 or higher!")
    else ()
        message("GNU GCC detected. Setting flags:")

        message(" - CLion Debugger STL Renderer workaround")
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -gdwarf-3")
        set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -gdwarf-3")

        message(" - Suppressing C++ deprecation warnings.")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-declarations")

        message(" - Encourage optimizations for the current architecture (-march=native)")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=native")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native")

        link_libraries(stdc++fs)
    endif ()
endif ()

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 6.0)
        message(FATAL_ERROR "Requires Clang 6.0 or higher!")
    else ()
        message("Clang detected. Setting flags:")
        message(" - Disable C++17 extension warnings")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-c++17-extensions")

        # Clang will complain about the usage of a static member variable inside
        # of a templated class if the instantiation is done in another compilation
        # unit. However this seems odd, since this would normally trigger a linker
        # error anyway.
        message(" - Disable warning for 'undefined' template variables.")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wundefined-var-template")

        message(" - Encourage optimizations for the current architecture (-march=native)")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=native")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=native")

        link_libraries(stdc++fs)
    endif ()
endif ()

