# Distributed under the BSD 2-Clause License - Copyright 2012-2019 Robin Degen

if (NOT VULKAN_FOUND OR NOT VULKAN_GLSLANG_VALIDATOR)
    message(FATAL_ERROR "The Lunar-G vulkan SDK is required to compile Vulkan GLSL code.")
endif ()

function(add_vulkan_glsl_program)
    cmake_parse_arguments(
        VULKAN_GLSL_PARSED_ARGS
        ""
        "TARGET;DESTINATION"
        "SOURCES"
        ${ARGN}
    )

    set(FULL_PATH_SOURCES "")
    foreach(_SOURCE ${VULKAN_GLSL_PARSED_ARGS_SOURCES})
        get_filename_component(_FULL_PATH "${SOURCE}" ABSOLUTE)
        list(APPEND FULL_PATH_SOURCES "${_FULL_PATH}/${_SOURCE}")
    endforeach()

    if (NOT VULKAN_GLSL_PARSED_ARGS_DESTINATION)
        set(VULKAN_GLSL_PARSED_ARGS_DESTINATION ${CMAKE_BINARY_DIR}/bin)
    else ()
        file(MAKE_DIRECTORY ${VULKAN_GLSL_PARSED_ARGS_DESTINATION})
    endif ()

    add_custom_target(
        ${VULKAN_GLSL_PARSED_ARGS_TARGET} ALL
        ${VULKAN_GLSLANG_VALIDATOR} "-V" ${FULL_PATH_SOURCES}
        WORKING_DIRECTORY "${VULKAN_GLSL_PARSED_ARGS_DESTINATION}"
        COMMENT "Building Vulkan Shaders ${VULKAN_GLSL_PARSED_ARGS_TARGET}"
        SOURCES ${FULL_PATH_SOURCES}
    )

    # In Visual Studio and Xcode, the Bin folder is appended with Debug or Release.
    if (MSVC OR CMAKE_GENERATOR STREQUAL Xcode)
        file(MAKE_DIRECTORY ${VULKAN_GLSL_PARSED_ARGS_DESTINATION}/Debug)
        file(MAKE_DIRECTORY ${VULKAN_GLSL_PARSED_ARGS_DESTINATION}/Release)
        add_custom_command(TARGET ${VULKAN_GLSL_PARSED_ARGS_TARGET} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${VULKAN_GLSL_PARSED_ARGS_DESTINATION}/vert.spv ${VULKAN_GLSL_PARSED_ARGS_DESTINATION}/Debug/vert.spv
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${VULKAN_GLSL_PARSED_ARGS_DESTINATION}/frag.spv ${VULKAN_GLSL_PARSED_ARGS_DESTINATION}/Debug/frag.spv
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${VULKAN_GLSL_PARSED_ARGS_DESTINATION}/vert.spv ${VULKAN_GLSL_PARSED_ARGS_DESTINATION}/Release/vert.spv
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${VULKAN_GLSL_PARSED_ARGS_DESTINATION}/frag.spv ${VULKAN_GLSL_PARSED_ARGS_DESTINATION}/Release/frag.spv
            WORKING_DIRECTORY "${VULKAN_GLSL_PARSED_ARGS_DESTINATION}"
            COMMENT "Duplicating SPIR-V shader binaries to the Debug and Release folders."
            VERBATIM
        )
    endif ()
endfunction()
