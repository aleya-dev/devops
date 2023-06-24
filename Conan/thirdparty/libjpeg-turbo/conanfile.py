from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain
from conan.tools.files import rmdir
import os


required_conan_version = ">=2.0"


class LibJpegTurboConan(ConanFile):
    python_requires = "aleya-conan-base/1.0"
    python_requires_extend = "aleya-conan-base.AleyaCmakeBase"

    name = "libjpeg-turbo"
    git_repository = "git://cgit.aeons.dev/conan/mirrors/libjpeg-turbo.git"
    git_branch = "main"

    def on_generate(self, tc: CMakeToolchain):
        tc.variables["BUILD_SHARED_LIBS"] = False
        tc.variables["ENABLE_SHARED"] = False
        tc.variables["ENABLE_STATIC"] = True

    def on_package(self, cmake: CMake):
        rmdir(self, os.path.join(self.package_folder, "bin"))
        rmdir(self, os.path.join(self.package_folder, "share"))
        rmdir(self, os.path.join(self.package_folder, "lib", "cmake"))
        rmdir(self, os.path.join(self.package_folder, "lib", "pkgconfig"))

    def package_info(self):
        self.cpp_info.set_property("cmake_find_mode", "both")
        self.cpp_info.set_property("cmake_module_file_name", "JPEG")
        self.cpp_info.set_property("cmake_file_name", "libjpeg-turbo")

        postfix = "-static" if self.settings.os == "Windows" and not self._is_mingw else ""

        self.cpp_info.components["turbojpeg"].libs = ["turbojpeg" + postfix]
        self.cpp_info.components["turbojpeg"].set_property("cmake_target_name", "libjpeg-turbo::turbojpeg-static")
