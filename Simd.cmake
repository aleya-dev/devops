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

# Currently only detection on Visual Studio is supported (and required).
# For GCC and Clang, use -march=native.
if (MSVC)
    include(CheckCSourceRuns)

    message("Detecting CPU SIMD capabilities...")

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
