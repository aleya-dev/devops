from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain, CMakeDeps
from conan.tools.files import rmdir, rm, collect_libs
import os


required_conan_version = ">=2.0"


class LibPngConan(ConanFile):
    python_requires = "aleya-conan-base/1.0"
    python_requires_extend = "aleya-conan-base.AleyaCmakeBase"

    name = "libpng"
    git_repository = "git://cgit.aeons.dev/conan/mirrors/libpng.git"
    git_branch = "master"

    def requirements(self):
        self.requires("zlib/v1.2.13")

    def on_generate(self, tc: CMakeToolchain):
        tc.variables["PNG_TESTS"] = False
        tc.variables["PNG_SHARED"] = False
        tc.variables["PNG_STATIC"] = True
        tc.generate()
        tc = CMakeDeps(self)

    def on_package(self, cmake: CMake):
        rmdir(self, os.path.join(self.package_folder, "bin"))
        rmdir(self, os.path.join(self.package_folder, "share"))
        rm(self, "*.cmake", os.path.join(self.package_folder, "lib"), recursive=True)

    def package_info(self):
        self.cpp_info.set_property("cmake_find_mode", "both")
        self.cpp_info.set_property("cmake_file_name", "PNG")
        self.cpp_info.set_property("cmake_target_name", "PNG::PNG")
        self.cpp_info.set_property("pkg_config_name", "libpng")

        self.cpp_info.libs = collect_libs(self)
