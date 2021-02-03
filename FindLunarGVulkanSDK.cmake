# Distributed under the BSD 2-Clause License - Copyright 2012-2021 Robin Degen

if (DEFINED ENV{VULKAN_SDK})
    file(TO_CMAKE_PATH $ENV{VULKAN_SDK} VULKAN_SDK)
endif ()

find_path(VULKAN_INCLUDE_DIR
    NAMES vulkan/vulkan.h
    PATHS
        "${VULKAN_SDK}/Include"
)

find_library(VULKAN_LIBRARY
    NAMES vulkan vulkan-1
    PATHS
        "${VULKAN_SDK}/lib"
)

find_program(VULKAN_GLSLANG_VALIDATOR
    NAMES glslangValidator
    PATHS
        "${VULKAN_SDK}/bin"
)

# On windows, also search the default install location
if (WIN32 AND NOT VULKAN_INCLUDE_DIR OR NOT VULKAN_LIBRARY OR NOT VULKAN_GLSLANG_VALIDATOR)
    set(__VULKAN_WINDOWS_PREFIX "C:/VulkanSDK/")

    if (EXISTS "${__VULKAN_WINDOWS_PREFIX}")
        file(GLOB __VULKAN_WINDOWS_VERSIONS RELATIVE "${__VULKAN_WINDOWS_PREFIX}" "${__VULKAN_WINDOWS_PREFIX}/*")
        # Sorting versions alphabetically isn't perfect, but good enough. It's not typical to install multiple versions anyway.
        list(SORT __VULKAN_WINDOWS_VERSIONS)
        list(REVERSE __VULKAN_WINDOWS_VERSIONS)

        foreach(__VULKAN_WINDOWS_VERSION ${__VULKAN_WINDOWS_VERSIONS})
            find_path(VULKAN_INCLUDE_DIR
                NAMES vulkan/vulkan.h
                PATHS "${__VULKAN_WINDOWS_PREFIX}${__VULKAN_WINDOWS_VERSION}/Include"
            )

            find_library(VULKAN_LIBRARY
                NAMES vulkan vulkan-1
                PATHS "${__VULKAN_WINDOWS_PREFIX}${__VULKAN_WINDOWS_VERSION}/lib"
            )

            find_program(VULKAN_GLSLANG_VALIDATOR
                NAMES glslangValidator
                PATHS "${__VULKAN_WINDOWS_PREFIX}${__VULKAN_WINDOWS_VERSION}/bin"
            )

            if (VULKAN_INCLUDE_DIR AND VULKAN_LIBRARY AND VULKAN_GLSLANG_VALIDATOR)
                message("Vulkan version: ${__VULKAN_WINDOWS_VERSION}")
                break()
            endif ()

            # Unset all variables to make sure that versions are not mixed.
            unset(VULKAN_INCLUDE_DIR)
            unset(VULKAN_LIBRARY)
            unset(VULKAN_GLSLANG_VALIDATOR)
        endforeach()
    endif ()
endif ()

set(VULKAN_LIBRARIES ${VULKAN_LIBRARY})
set(VULKAN_INCLUDE_DIRS ${VULKAN_INCLUDE_DIR})

if (VULKAN_LIBRARIES AND VULKAN_INCLUDE_DIRS)
    set(VULKAN_FOUND 1)
    message(STATUS "Found the Lunar-G Vulkan SDK.")
    if (NOT TARGET LunarGVulkanSDK)
        add_library(LunarGVulkanSDK UNKNOWN IMPORTED)
        set_target_properties(LunarGVulkanSDK PROPERTIES
            IMPORTED_LOCATION "${VULKAN_LIBRARIES}"
            INTERFACE_INCLUDE_DIRECTORIES "${VULKAN_INCLUDE_DIRS}")
    endif ()
else ()
    message(STATUS "Couldn't find the Lunar-G Vulkan SDK.")
endif ()
