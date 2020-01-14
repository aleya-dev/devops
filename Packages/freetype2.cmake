# Distributed under the BSD 2-Clause License - Copyright 2012-2020 Robin Degen

if (NOT TARGET Freetype::Freetype)
    include(Packages/libpng)
    find_package(Freetype REQUIRED)
    set_target_properties(Freetype::Freetype PROPERTIES INTERFACE_LINK_LIBRARIES PNG::PNG)
endif ()

