# ROBIN DEGEN; CONFIDENTIAL
#
# 2012 - 2016 Robin Degen
# All Rights Reserved.
#
# NOTICE:  All information contained herein is, and remains the property of
# Robin Degen and its suppliers, if any. The intellectual and technical
# concepts contained herein are proprietary to Robin Degen and its suppliers
# and may be covered by U.S. and Foreign Patents, patents in process, and are
# protected by trade secret or copyright law. Dissemination of this
# information or reproduction of this material is strictly forbidden unless
# prior written permission is obtained from Robin Degen.

message(STATUS "Running Find Raspberry Pi SDK.")

find_path(RASPBERRY_PI_INCLUDE_PATH "bcm_host.h"
    PATHS $ENV{RASPBERRY_PI_SDK_ROOT}/include
)

if (NOT RASPBERRY_PI_INCLUDE_PATH)
    message(FATAL "Could not find bcm_host.h. Please set the environment variable RASPBERRY_PI_SDK_ROOT.")
endif ()

set(RASPBERRY_PI_INCLUDE_PATHS ${RASPBERRY_PI_INCLUDE_PATH})
list(APPEND RASPBERRY_PI_INCLUDE_PATHS ${RASPBERRY_PI_INCLUDE_PATH}/interface/vcos/pthreads)
list(APPEND RASPBERRY_PI_INCLUDE_PATHS ${RASPBERRY_PI_INCLUDE_PATH}/interface/vmcs_host/linux)

set(RASPBERRY_PI_LIBRARIES "")
foreach(component ${RaspberryPiSDK_FIND_COMPONENTS})
    find_library(
        RASPBERRY_PI_COMPONENT_${component}_LIBRARIES NAMES ${component}
        PATHS $ENV{RASPBERRY_PI_SDK_ROOT}/lib
    )

    if (NOT RASPBERRY_PI_COMPONENT_${component}_LIBRARIES)
        message(FATAL_ERROR "Could not find Raspberry Pi component: ${component}.")
    endif ()

    set(_COMPONENT_PATH ${RASPBERRY_PI_COMPONENT_${component}_LIBRARIES})
    message(STATUS "  Found ${component}: ${_COMPONENT_PATH}")

    set(RASPBERRY_PI_LIBRARIES "${_COMPONENT_PATH};${RASPBERRY_PI_LIBRARIES}")
endforeach()

add_library(RaspberryPiSdk INTERFACE IMPORTED)

set_target_properties(RaspberryPiSdk PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${RASPBERRY_PI_INCLUDE_PATHS}"
    INTERFACE_LINK_LIBRARIES "${RASPBERRY_PI_LIBRARIES}"
)
