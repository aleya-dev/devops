# Distributed under the BSD 2-Clause License - Copyright 2012-2022 Robin Degen

include(CMakeParseArguments)

set(AEON_DOTNET_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR})

set(AEON_DOTNET_DEFAULT_TARGET_FRAMEWORK "net6.0" CACHE STRING "The default .NET target framework if unset for the specific project.")
option(AEON_DOTNET_DEFAULT_IMPLICIT_USINGS "The default setting for Implicit Usings if unset for the specific project." ON)
option(AEON_DOTNET_DEFAULT_NULLABE "The default setting for Nullable if unset for the specific project." ON)
option(AEON_DOTNET_DEFAULT_ALLOW_UNSAFE_BLOCKS "The default setting for allow unsafe blocks if unset for the specific project." OFF)

find_program(AEON_DOTNET_EXECUTABLE dotnet REQUIRED)

function(add_dotnet_class_library)
    cmake_parse_arguments(
        PARSE_ARGV 1
        DOTNET_ASSEMBLY_PARSED_ARGS
        ""
        "BASE_OUTPUT_PATH"
        "SOURCES"
    )

    set(__AEON_DOTNET_SOURCES "")
    set(__AEON_DOTNET_SOURCES_LIST "")
    foreach(_SOURCE ${DOTNET_ASSEMBLY_PARSED_ARGS_SOURCES})
        get_filename_component(_FULL_PATH "${SOURCE}" ABSOLUTE)
        set(__AEON_DOTNET_SOURCES "${__AEON_DOTNET_SOURCES}<Compile Include=\"${_FULL_PATH}/${_SOURCE}\"/>")
        list(APPEND __AEON_DOTNET_SOURCES_LIST "${_FULL_PATH}/${_SOURCE}")
    endforeach()
    
    set(__AEON_DOTNET_TARGET_FRAMEWORK ${AEON_DOTNET_DEFAULT_TARGET_FRAMEWORK})
    set(__AEON_DOTNET_IMPLICIT_USINGS "enable")
    set(__AEON_DOTNET_NULLABLE "enable")
    set(__AEON_DOTNET_ALLOW_UNSAFE_BLOCKS "true")

    if (DOTNET_ASSEMBLY_PARSED_ARGS_BASE_OUTPUT_PATH)
        set(__AEON_DOTNET_BASE_OUTPUT_PATH ${DOTNET_ASSEMBLY_PARSED_ARGS_BASE_OUTPUT_PATH})
    else ()
        set(__AEON_DOTNET_BASE_OUTPUT_PATH ${CMAKE_BINARY_DIR})
    endif ()

    set(__AEON_DOTNET_BASE_INTERMEDIATE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

    configure_file(${AEON_DOTNET_ROOT_DIR}/DotnetSdkProject.csproj.in ${CMAKE_CURRENT_BINARY_DIR}/${ARGV0}.csproj)

    add_custom_target(
        ${ARGV0} ALL
        ${AEON_DOTNET_EXECUTABLE} build "${CMAKE_CURRENT_BINARY_DIR}/${ARGV0}.csproj"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Building .NET Class library: ${ARGV0}"
        SOURCES ${__AEON_DOTNET_SOURCES_LIST}
    )
endfunction()
