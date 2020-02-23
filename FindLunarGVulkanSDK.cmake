# Distributed under the BSD 2-Clause License - Copyright 2012-2020 Robin Degen

if (DEFINED ENV{VULKAN_SDK})
    file(TO_CMAKE_PATH $ENV{VULKAN_SDK} VULKAN_SDK)
endif ()

find_path(VULKAN_INCLUDE_DIR
    NAMES vulkan/vulkan.h
    PATHS
        "${VULKAN_SDK}/Include"
        "C:/VulkanSDK/1.1.106.0/Include"
        "C:/VulkanSDK/1.2.131.2/Include"
)

find_library(VULKAN_LIBRARY
    NAMES vulkan vulkan-1
    PATHS
        "${VULKAN_SDK}/lib"
        "C:/VulkanSDK/1.1.106.0/lib"
        "C:/VulkanSDK/1.2.131.2/lib"
)

find_program(VULKAN_GLSLANG_VALIDATOR
    NAMES glslangValidator
    PATHS
        "${VULKAN_SDK}/bin"
        "C:/VulkanSDK/1.1.106.0/bin"
        "C:/VulkanSDK/1.2.131.2/bin"
)

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
