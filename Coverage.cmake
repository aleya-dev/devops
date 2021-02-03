# Distributed under the BSD 2-Clause License - Copyright 2012-2021 Robin Degen

macro(enable_coverage)
    message("Enabling code coverage.")

    if (NOT ${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
        message(FATAL_ERROR "Can not enable coverage. Coverage reporting requires linux.")
    endif ()

    if(NOT ${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
        message(FATAL_ERROR "Can not enable coverage. Coverage reporting requires GCC.")
    endif ()

    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.1)
        message(FATAL_ERROR "Can not enable coverage. Coverage reporting requires GCC 5.1.0 or higher!")
    endif ()

    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage")

    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --coverage")
    set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} --coverage")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} --coverage")
endmacro()
