# Distributed under the BSD 2-Clause License - Copyright 2012-2023 Robin Degen

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../")

include(CmakeUnittests)
include(StringUtils)

initialize_tests()

string_repeat("!" 5 REPEAT_TEST_1)
expect_eq(${REPEAT_TEST_1} "!!!!!")

string_repeat("#@" 10 REPEAT_TEST_2)
expect_eq(${REPEAT_TEST_2} "#@#@#@#@#@#@#@#@#@#@")

string_capitalize("teststring" CAPITALIZE_TEST_1)
expect_eq(${CAPITALIZE_TEST_1} "Teststring")

string_capitalize("TESTSTRING" CAPITALIZE_TEST_2)
expect_eq(${CAPITALIZE_TEST_2} "Teststring")

string_expand_width("Test" 10 EXPAND_WIDTH_TEST_1)
expect_eq(${EXPAND_WIDTH_TEST_1} "Test      ")

string_expand_width("LongerText12345" 10 EXPAND_WIDTH_TEST_2)
expect_eq(${EXPAND_WIDTH_TEST_2} "LongerText12345")

string_indent("Test" 4 PREPEND_WIDTH_TEST_1)
expect_eq(${PREPEND_WIDTH_TEST_1} "    Test")

string_indent("LongerText12345" 8 PREPEND_WIDTH_TEST_2)
expect_eq(${PREPEND_WIDTH_TEST_2} "        LongerText12345")

finalize_tests()
