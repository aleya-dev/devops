# Copyright (c) 2012-2018 Robin Degen
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

if (DEFINED ENV{VULKAN_SDK})
    file(TO_CMAKE_PATH $ENV{VULKAN_SDK} VULKAN_SDK)
endif ()

find_path(Vulkan_INCLUDE_DIR
    NAMES vulkan/vulkan.h
    PATHS
        "${VULKAN_SDK}/Include"
)

if (WIN32)
    include(Architecture)

    if (AEON_ARCHITECTURE_64_BIT)
        find_library(Vulkan_LIBRARY
            NAMES vulkan-1
            PATHS
                "${VULKAN_SDK}/Lib"
                "${VULKAN_SDK}/Bin"
        )
    else ()
        find_library(Vulkan_LIBRARY
            NAMES vulkan-1
            PATHS
                "${VULKAN_SDK}/Lib32"
                "${VULKAN_SDK}/Bin32"
        )
    endif ()
else ()
    find_library(Vulkan_LIBRARY
        NAMES vulkan
        PATHS "${VULKAN_SDK}/lib"
    )
endif ()

set(Vulkan_LIBRARIES ${Vulkan_LIBRARY})
set(Vulkan_INCLUDE_DIRS ${Vulkan_INCLUDE_DIR})

if (Vulkan_LIBRARIES AND Vulkan_INCLUDE_DIRS)
    set(Vulkan_FOUND 1)
    message(STATUS "Found the Lunar-G Vulkan SDK.")
    if (NOT TARGET LunarGVulkanSDK)
        add_library(LunarGVulkanSDK UNKNOWN IMPORTED)
        set_target_properties(LunarGVulkanSDK PROPERTIES
            IMPORTED_LOCATION "${Vulkan_LIBRARIES}"
            INTERFACE_INCLUDE_DIRECTORIES "${Vulkan_INCLUDE_DIRS}")
    endif ()
else ()
    message(STATUS "Couldn't find the Lunar-G Vulkan SDK.")
endif ()
