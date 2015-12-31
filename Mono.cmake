include(CMakeParseArguments)

function(add_mono_assembly)
    cmake_parse_arguments(
        MONO_ASSEMBLY_PARSED_ARGS
        ""
        "TARGET;DESTINATION;TYPE"
        "SOURCES"
        ${ARGN}
    )

    find_program(MONO_COMPILER_EXECUTABLE gmcs)

    if (NOT MONO_COMPILER_EXECUTABLE)
        message(FATAL_ERROR "Could not find mono.")
    endif ()

    message("Usinig mono: ${MONO_COMPILER_EXECUTABLE}")

    if (NOT MONO_ASSEMBLY_PARSED_ARGS_TYPE)
        set(MONO_ASSEMBLY_PARSED_ARGS_TYPE "library")
        message("No type provided for ${MONO_ASSEMBLY_PARSED_ARGS_TARGET}. Assuming library.")
    endif ()

    set(_FILE_EXTENSION "")
    if (MONO_ASSEMBLY_PARSED_ARGS_TYPE STREQUAL "library")
        set(_FILE_EXTENSION ".dll")
    elseif (MONO_ASSEMBLY_PARSED_ARGS_TYPE STREQUAL "exe")
        set(_FILE_EXTENSION ".exe")
    else ()
        message(FATAL_ERROR "Type must be either exe or library.")
    endif ()


    set(FULL_PATH_SOURCES "")
    foreach(_SOURCE ${MONO_ASSEMBLY_PARSED_ARGS_SOURCES})
        get_filename_component(_FULL_PATH "${SOURCE}" ABSOLUTE)
        list(APPEND FULL_PATH_SOURCES "${_FULL_PATH}/${_SOURCE}")
    endforeach()

    if (NOT MONO_ASSEMBLY_PARSED_ARGS_DESTINATION)
        set(MONO_ASSEMBLY_PARSED_ARGS_DESTINATION ${CMAKE_BINARY_DIR})
    endif ()

    add_custom_target(
        ${MONO_ASSEMBLY_PARSED_ARGS_TARGET} ALL
        ${MONO_COMPILER_EXECUTABLE} -t:${MONO_ASSEMBLY_PARSED_ARGS_TYPE} ${FULL_PATH_SOURCES} -out:${MONO_ASSEMBLY_PARSED_ARGS_TARGET}${_FILE_EXTENSION}
        WORKING_DIRECTORY "${MONO_ASSEMBLY_PARSED_ARGS_DESTINATION}"
        COMMENT "Building Mono Library ${MONO_ASSEMBLY_PARSED_ARGS_TARGET}"
        SOURCES ${FULL_PATH_SOURCES}
    )
endfunction()

