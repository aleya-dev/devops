from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain, CMakeDeps
from conan.tools.files import rmdir, collect_libs
import os


required_conan_version = ">=2.0"


class FreeTypeConan(ConanFile):
    python_requires = "aleya-conan-base/1.0"
    python_requires_extend = "aleya-conan-base.AleyaCmakeBase"

    name = "freetype"
    git_repository = "https://github.com/aleya-dev/mirror-package-freetype.git"
    git_branch = "2.13.0"

    def requirements(self):
        self.requires("zlib/1.2.13")
        self.requires("libpng/1.6.40")

    def on_generate(self, tc: CMakeToolchain):
        tc.variables["BUILD_SHARED_LIBS"] = False
        tc.variables["FT_REQUIRE_ZLIB"] = True
        tc.variables["FT_REQUIRE_PNG"] = True
        tc.variables["FT_DISABLE_HARFBUZZ"] = True
        tc.variables["FT_DISABLE_BZIP2"] = True
        tc.variables["FT_DISABLE_BROTLI"] = True
        tc.generate()
        tc = CMakeDeps(self)

    def on_package(self, cmake: CMake):
        rmdir(self, os.path.join(self.package_folder, "bin"))
        rmdir(self, os.path.join(self.package_folder, "lib", "pkgconfig"))
        rmdir(self, os.path.join(self.package_folder, "lib", "cmake"))

    def package_info(self):
        self.cpp_info.set_property("cmake_find_mode", "both")
        self.cpp_info.set_property("cmake_module_file_name", "Freetype")
        self.cpp_info.set_property("cmake_file_name", "freetype")
        self.cpp_info.set_property("cmake_target_name", "Freetype::Freetype")
        self.cpp_info.set_property("cmake_target_aliases", ["freetype"])
        self.cpp_info.set_property("pkg_config_name", "freetype2")
        self.cpp_info.includedirs.append(os.path.join("include", "freetype2"))

        self.cpp_info.libs = collect_libs(self)
