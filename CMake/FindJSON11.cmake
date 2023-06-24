# Distributed under the BSD 2-Clause License - Copyright 2012-2023 Robin Degen

find_path(JSON11_INCLUDE_DIRS json11.hpp
    DOC
        "Found JSON11 include directory"
    ENV
        JSON11_ROOT
    PATH_SUFFIXES
        include
)

find_library(JSON11_LIBRARIES
    NAMES libjson11.a json11
    DOC "Found JSON11 library path"
    ENV
        JSON11_ROOT
    PATH_SUFFIXES
        lib
        lib64
)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(JSON11
    FOUND_VAR
        JSON11_FOUND
    REQUIRED_VARS
        JSON11_LIBRARIES
        JSON11_INCLUDE_DIRS
)

if (JSON11_FOUND AND NOT TARGET Json11::Json11)
    add_library(Json11::Json11 STATIC IMPORTED)
    set_target_properties(Json11::Json11 PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${JSON11_INCLUDE_DIRS})
    set_target_properties(Json11::Json11 PROPERTIES IMPORTED_LOCATION ${JSON11_LIBRARIES})
endif ()

