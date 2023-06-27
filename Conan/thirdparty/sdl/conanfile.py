from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain
from conan.tools.files import rmdir
import os


required_conan_version = ">=2.0"


class SDL2Conan(ConanFile):
    python_requires = "aleya-conan-base/1.0"
    python_requires_extend = "aleya-conan-base.AleyaCmakeBase"

    name = "sdl"
    git_repository = "https://github.com/aleya-dev/mirror-package-sdl.git"
    git_branch = "2.28.0"

    def on_generate(self, tc: CMakeToolchain):
        tc.variables["SDL_SHARED"] = False
        tc.variables["SDL_STATIC"] = True

    def on_package(self, cmake: CMake):
        rmdir(self, os.path.join(self.package_folder, "cmake"))
        rmdir(self, os.path.join(self.package_folder, "lib", "pkgconfig"))
        rmdir(self, os.path.join(self.package_folder, "licenses"))

    def package_info(self):
        postfix = "d" if self.settings.os != "Android" and self.settings.build_type == "Debug" else ""

        self.cpp_info.set_property("cmake_file_name", "SDL2")

        self.cpp_info.components["libsdl2"].libs = ["SDL2-static" + postfix]
        self.cpp_info.components["libsdl2"].set_property("cmake_target_name", "SDL2::SDL2")

        self.cpp_info.components["sdl2main"].libs = ["SDL2main" + postfix]
        self.cpp_info.components["sdl2main"].set_property("cmake_target_name", "SDL2::SDL2main")
        self.cpp_info.components["sdl2main"].requires = ["libsdl2"]
