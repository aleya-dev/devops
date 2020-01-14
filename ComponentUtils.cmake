# Distributed under the BSD 2-Clause License - Copyright 2012-2020 Robin Degen

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

    if (NOT __AEON_COMPONENT_${name_upper}_ENABLED)
        set(__AEON_COMPONENT_${name_upper}_ENABLED ON CACHE BOOL "" FORCE)

        if (EXISTS ${__AEON_COMPONENT_${name_upper}_PATH}/prerequisites.cmake)
            include(${__AEON_COMPONENT_${name_upper}_PATH}/prerequisites.cmake)
        endif ()
    endif ()
endfunction()

function(list_components)
    set(__column_width 16)
    foreach(__COMPONENT ${__AEON_AVAILABLE_COMPONENTS})
        string(LENGTH ${__COMPONENT} __length)
        if (__column_width LESS __length)
            math(EXPR __column_width "${__length} + 1")
        endif ()
    endforeach()

    math(EXPR __total_width "${__column_width} * 3")

    log_hline(${__total_width})
    message(STATUS " Enabled components")
    log_hline(${__total_width})
    log_columns("Component;| Requested;| Enabled" ${__column_width})

    foreach(__COMPONENT ${__AEON_AVAILABLE_COMPONENTS})
        string(TOUPPER ${__COMPONENT} name_upper)
        log_columns(
            "${__COMPONENT};| ${AEON_COMPONENT_${name_upper}};| ${__AEON_COMPONENT_${name_upper}_ENABLED}"
            ${__column_width}
        )
    endforeach()

    log_hline(${__total_width})
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

function(check_component_enabled name out)
    string(TOUPPER ${name} name_upper)
    set(${out} ${__AEON_COMPONENT_${name_upper}_ENABLED} PARENT_SCOPE)
endfunction()

function(finalize_components)
    __disable_all_components()
    __handle_component_prerequisites()
    __include_enabled_components()

    list_components()
endfunction()
