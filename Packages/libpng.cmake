# Copyright (c) 2012-2019 Robin Degen

if (NOT TARGET PNG::PNG)
    include(Packages/zlib)
    find_package(PNG REQUIRED)
    set_target_properties(PNG::PNG PROPERTIES IMPORTED_LINK_INTERFACE_LIBRARIES ZLIB::ZLIB)
endif ()

