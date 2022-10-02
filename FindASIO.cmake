# Distributed under the BSD 2-Clause License - Copyright 2012-2022 Robin Degen

find_path(ASIO_INCLUDE_DIRS asio.hpp
    DOC
        "Found ASIO include directory"
    ENV
        ASIO_ROOT
    PATH_SUFFIXES
        include
        include/asio
)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(ASIO
    FOUND_VAR
        ASIO_FOUND
    REQUIRED_VARS
        ASIO_INCLUDE_DIRS
)

if (ASIO_FOUND AND NOT TARGET Asio::Asio)
    add_library(Asio::Asio INTERFACE IMPORTED)
    set_target_properties(Asio::Asio PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${ASIO_INCLUDE_DIRS})

    if (MSVC)
        target_compile_definitions(Asio::Asio INTERFACE
            ASIO_NO_DEPRECATED
            ASIO_STANDALONE
            ASIO_HEADER_ONLY
            # Workaround for VS2017 compiler bug: https://github.com/chriskohlhoff/asio/issues/290
            _SILENCE_CXX17_ALLOCATOR_VOID_DEPRECATION_WARNING
        )
    else ()
        target_compile_definitions(Asio::Asio INTERFACE
            ASIO_NO_DEPRECATED
            ASIO_STANDALONE
            ASIO_HEADER_ONLY
        )
    endif ()

    set(CMAKE_THREAD_PREFER_PTHREAD ON)
    find_package(Threads REQUIRED)
    set_target_properties(Asio::Asio PROPERTIES INTERFACE_LINK_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
endif ()

