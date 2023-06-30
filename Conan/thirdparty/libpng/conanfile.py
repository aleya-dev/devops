from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain, CMakeDeps
from conan.tools.files import rmdir, rm, collect_libs
import os


required_conan_version = ">=2.0"


class LibPngConan(ConanFile):
    python_requires = "aleya-conan-base/1.0.1"
    python_requires_extend = "aleya-conan-base.AleyaCmakeBase"

    name = "libpng"
    git_repository = "https://github.com/aleya-dev/mirror-package-libpng.git"
    git_branch = "master"
    ignore_cpp_standard = True

    def configure(self):
        super(LibPngConan, self).configure()

        self.options["zlib"].shared = self.options.shared

    def requirements(self):
        self.requires("zlib/1.2.13")

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["CMAKE_DEBUG_POSTFIX"] = ''
        tc.variables["PNG_TESTS"] = False
        tc.variables["PNG_EXECUTABLES"] = False
        tc.variables["PNG_SHARED"] = self.options.shared
        tc.variables["PNG_STATIC"] = not self.options.shared
        tc.generate()
        tc = CMakeDeps(self)
        tc.generate()

    def on_package(self, cmake: CMake):
        rmdir(self, os.path.join(self.package_folder, "share"))
        rmdir(self, os.path.join(self.package_folder, "lib", "pkgconfig"))

        if self.options.shared:
            rm(self, "*.a", os.path.join(self.package_folder, "lib"), recursive=True)
        else:
            rm(self, "*.so", os.path.join(self.package_folder, "lib"), recursive=True)
            rmdir(self, os.path.join(self.package_folder, "bin"))

        rm(self, "*.cmake", os.path.join(self.package_folder, "lib"), recursive=True)

    def package_info(self):
        self.cpp_info.set_property("cmake_find_mode", "both")
        self.cpp_info.set_property("cmake_file_name", "PNG")
        self.cpp_info.set_property("cmake_target_name", "PNG::PNG")
        self.cpp_info.set_property("pkg_config_name", "libpng")

        self.cpp_info.libs = collect_libs(self)
