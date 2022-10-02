# Distributed under the BSD 2-Clause License - Copyright 2012-2022 Robin Degen

# Currently only detection on Visual Studio is supported (and required).
# For GCC and Clang, use -march=native.
if (MSVC)
    include(CheckCSourceRuns)

    message(STATUS "Detecting CPU SIMD capabilities...")

    # Check for AVX
    set(CMAKE_REQUIRED_FLAGS "/arch:AVX")

    check_c_source_runs("
        #include <immintrin.h>

        int main()
        {
            const float src[8] = { 1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f };
            const __m256 a = _mm256_loadu_ps(src);
            const __m256 b = _mm256_loadu_ps(src);
            const __m256 c = _mm256_add_ps(a, b);

            float dst[8];
            _mm256_storeu_ps(dst, c);

            for(int i = 0; i < 8; ++i)
            {
                if((src[i] + src[i]) != dst[i])
                {
                    return -1;
                }
            }

            return 0;
        }"
    AEON_CPU_HAS_AVX)

    # Check for AVX2
    set(CMAKE_REQUIRED_FLAGS "/arch:AVX2")

    check_c_source_runs("
        #include <immintrin.h>

        int main()
        {
            const int src[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };

            const __m256i a = _mm256_loadu_si256((__m256i*)src);
            const __m256i b = _mm256_loadu_si256((__m256i*)src);
            const __m256i c = _mm256_add_epi32(a, b);

            int dst[8];
            _mm256_storeu_si256((__m256i*)dst, c);

            for(int i = 0; i < 8; ++i)
            {
                if((src[i] + src[i]) != dst[i])
                {
                    return -1;
                }
            }

            return 0;
        }"
    AEON_CPU_HAS_AVX2)
endif ()
