# Copyright (c) 2012-2019 Robin Degen

find_path(TurboJPEG_INCLUDE_DIRS turbojpeg.h
    DOC
        "Found TurboJPEG include directory"
    PATHS
        "/opt/libjpeg-turbo"
        "/opt/local"
        "/usr/local/opt/jpeg-turbo"
    ENV
        TurboJPEG_ROOT
    PATH_SUFFIXES
        include
)

find_library(TurboJPEG_LIBRARIES
    NAMES libturbojpeg.so.1 libturbojpeg.so.0 turbojpeg
    DOC "Found TurboJPEG library path"
    PATHS
        "/opt/libjpeg-turbo"
        "/usr/local/opt/jpeg-turbo"
        "/opt/local"
    ENV
        TurboJPEG_ROOT
    PATH_SUFFIXES
        lib
        lib64
)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(TurboJPEG
    FOUND_VAR
        TurboJPEG_FOUND
    REQUIRED_VARS
        TurboJPEG_LIBRARIES
        TurboJPEG_INCLUDE_DIRS
)

if (TurboJPEG_FOUND AND NOT TARGET JPEG::JPEGTURBO)
    add_library(JPEG::JPEGTURBO SHARED IMPORTED)
    set_target_properties(JPEG::JPEGTURBO PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${TurboJPEG_INCLUDE_DIRS})
    set_target_properties(JPEG::JPEGTURBO PROPERTIES IMPORTED_LOCATION ${TurboJPEG_LIBRARIES})
endif ()

