# Distributed under the BSD 2-Clause License - Copyright 2012-2020 Robin Degen

if (NOT TARGET PNG::PNG)
    include(Packages/zlib)
    find_package(PNG REQUIRED)
    set_target_properties(PNG::PNG PROPERTIES IMPORTED_LINK_INTERFACE_LIBRARIES ZLIB::ZLIB)
endif ()

