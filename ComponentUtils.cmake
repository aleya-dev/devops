# Copyright (c) 2012-2019 Robin Degen

include(Logging)

function(initialize_components)
    set(__AEON_AVAILABLE_COMPONENTS "" CACHE STRING "" FORCE)
endfunction()

function(register_component name path)
    string(TOUPPER ${name} name_upper)
    option(AEON_COMPONENT_${name_upper} "Enable the '${name}' component." OFF)

    set(__AEON_AVAILABLE_COMPONENTS "${__AEON_AVAILABLE_COMPONENTS};${name}" CACHE STRING "" FORCE)
    mark_as_advanced(FORCE __AEON_AVAILABLE_COMPONENTS)

    set(__AEON_COMPONENT_${name_upper}_ENABLED OFF CACHE BOOL "" FORCE)
    mark_as_advanced(FORCE __AEON_COMPONENT_${name_upper}_ENABLED)

    set(__AEON_COMPONENT_${name_upper}_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${path}" CACHE STRING "" FORCE)
    mark_as_advanced(FORCE __AEON_COMPONENT_${name_upper}_PATH)
endfunction()

function(register_component_auto name)
    register_component(${name} ${name})
endfunction()

function(enable_component name)
    string(TOUPPER ${name} name_upper)
    set(AEON_COMPONENT_${name_upper} ON CACHE BOOL "")
endfunction()

function(depend_on name)
    string(TOUPPER ${name} name_upper)
    set(__AEON_COMPONENT_${name_upper}_ENABLED ON CACHE BOOL "" FORCE)

    if (EXISTS ${__AEON_COMPONENT_${name_upper}_PATH}/prerequisites.cmake)
        include(${__AEON_COMPONENT_${name_upper}_PATH}/prerequisites.cmake)
    endif ()
endfunction()

function(list_components)
    message(STATUS "-----------------------------------------")
    message(STATUS " Enabled components")
    message(STATUS "-----------------------------------------")
    log_columns("Component;| Requested;| Enabled" 16)

    foreach(__COMPONENT ${__AEON_AVAILABLE_COMPONENTS})
        string(TOUPPER ${__COMPONENT} name_upper)
        log_columns("${__COMPONENT};| ${AEON_COMPONENT_${name_upper}};| ${__AEON_COMPONENT_${name_upper}_ENABLED}" 16)
    endforeach()

    message(STATUS "-----------------------------------------")
endfunction()

function(__disable_all_components)
    foreach(__COMPONENT ${__AEON_AVAILABLE_COMPONENTS})
        string(TOUPPER ${__COMPONENT} name_upper)
        set(__AEON_COMPONENT_${name_upper}_ENABLED OFF CACHE BOOL "" FORCE)
    endforeach()
endfunction()

function(__handle_component_prerequisites)
    foreach(__COMPONENT ${__AEON_AVAILABLE_COMPONENTS})
        string(TOUPPER ${__COMPONENT} name_upper)

        if (${AEON_COMPONENT_${name_upper}})
            set(__AEON_COMPONENT_${name_upper}_ENABLED ON CACHE BOOL "" FORCE)

            if (EXISTS ${__AEON_COMPONENT_${name_upper}_PATH}/prerequisites.cmake)
                include(${__AEON_COMPONENT_${name_upper}_PATH}/prerequisites.cmake)
            endif ()
        endif ()
    endforeach()
endfunction()

function(__include_enabled_components)
    foreach(__COMPONENT ${__AEON_AVAILABLE_COMPONENTS})
        string(TOUPPER ${__COMPONENT} name_upper)

        if (${__AEON_COMPONENT_${name_upper}_ENABLED})
            add_subdirectory(${__AEON_COMPONENT_${name_upper}_PATH})
        endif ()
    endforeach()
endfunction()

function(finalize_components)
    __disable_all_components()
    __handle_component_prerequisites()
    __include_enabled_components()

    list_components()
endfunction()
