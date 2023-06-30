from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain
from conan.tools.files import rmdir, collect_libs
import os


required_conan_version = ">=2.0"


class LibJpegTurboConan(ConanFile):
    python_requires = "aleya-conan-base/1.0.1"
    python_requires_extend = "aleya-conan-base.AleyaCmakeBase"

    name = "libjpeg-turbo"
    git_repository = "https://github.com/aleya-dev/mirror-package-libjpeg-turbo.git"
    git_branch = "2.1.91"
    ignore_cpp_standard = True

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["BUILD_SHARED_LIBS"] = self.options.shared
        tc.variables["ENABLE_SHARED"] = self.options.shared
        tc.variables["ENABLE_STATIC"] = not self.options.shared
        tc.generate()

    def on_package(self, cmake: CMake):
        rmdir(self, os.path.join(self.package_folder, "bin"))
        rmdir(self, os.path.join(self.package_folder, "share"))
        rmdir(self, os.path.join(self.package_folder, "lib", "cmake"))
        rmdir(self, os.path.join(self.package_folder, "lib", "pkgconfig"))

    def package_info(self):
        self.cpp_info.set_property("cmake_find_mode", "both")
        self.cpp_info.set_property("cmake_module_file_name", "JPEG")
        self.cpp_info.set_property("cmake_file_name", "libjpeg-turbo")

        self.cpp_info.components["turbojpeg"].libs = collect_libs(self)
        self.cpp_info.components["turbojpeg"].set_property("cmake_target_name", "libjpeg-turbo::turbojpeg-static")
