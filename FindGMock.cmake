# Distributed under the BSD 2-Clause License - Copyright 2012-2021 Robin Degen

find_path(GMock_INCLUDE_DIRS gmock/gmock.h
    DOC
        "Found gmock include directory"
    ENV
        GMOCK_ROOT
    PATH_SUFFIXES
        include
)

find_library(GMock_LIBRARIES
    NAMES libgmock.so gmock
    DOC "Found gmock library path"
    ENV
        GMOCK_ROOT
    PATH_SUFFIXES
        lib
        lib64
)

find_library(GMock_MAIN_LIBRARIES
    NAMES libgmock_main.so gmock_main
    DOC "Found gmock main library path"
    ENV
        GMOCK_ROOT
    PATH_SUFFIXES
        lib
        lib64
)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GMock
    FOUND_VAR
        GMock_FOUND
    REQUIRED_VARS
        GMock_INCLUDE_DIRS
        GMock_LIBRARIES
        GMock_MAIN_LIBRARIES
)

if (GMock_FOUND)
    if (NOT TARGET GTest::GMock)
        add_library(GTest::GMock STATIC IMPORTED)
        set_target_properties(GTest::GMock PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${GMock_INCLUDE_DIRS})
        set_target_properties(GTest::GMock PROPERTIES IMPORTED_LOCATION ${GMock_LIBRARIES})
    endif ()

    if (NOT TARGET GTest::GmockMain)
        add_library(GTest::GmockMain STATIC IMPORTED)
        set_target_properties(GTest::GmockMain PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${GMock_INCLUDE_DIRS})
        set_target_properties(GTest::GmockMain PROPERTIES IMPORTED_LOCATION ${GMock_MAIN_LIBRARIES})
        set_target_properties(GTest::GmockMain PROPERTIES INTERFACE_LINK_LIBRARIES GTest::GMock)
    endif ()
endif ()

