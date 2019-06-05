# Distributed under the BSD 2-Clause License - Copyright 2012-2019 Robin Degen

find_program(LLVM_CONFIG_EXECUTABLE llvm-config)

if (NOT LLVM_CONFIG_EXECUTABLE)
    message(FATAL_ERROR "Could not find llvm-config.")
endif ()

execute_process(
    COMMAND ${LLVM_CONFIG_EXECUTABLE} --includedir
    OUTPUT_VARIABLE __CLANG_INCLUDE_DIRS
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(CLANG_INCLUDE_DIRS ${__CLANG_INCLUDE_DIRS} CACHE PATH "Include directory for libClang")

execute_process(
    COMMAND ${LLVM_CONFIG_EXECUTABLE} --libdir
    OUTPUT_VARIABLE __CLANG_LIBDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

find_library(CLANG_LIBRARIES
    NAMES libclang clang
    DOC "Found libClang library path"
    PATHS
        ${__CLANG_LIBDIR}
)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Clang
    FOUND_VAR
        CLANG_FOUND
    REQUIRED_VARS
        CLANG_LIBRARIES
        CLANG_INCLUDE_DIRS
)

if (CLANG_FOUND AND NOT TARGET Clang::Clang)
    add_library(Clang::Clang SHARED IMPORTED)
    set_target_properties(Clang::Clang PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${CLANG_INCLUDE_DIRS})
    set_target_properties(Clang::Clang PROPERTIES IMPORTED_LOCATION ${CLANG_LIBRARIES})
endif ()
