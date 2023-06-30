from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain
from conan.tools.files import rmdir, rm
import os


required_conan_version = ">=2.0"


class SDL2Conan(ConanFile):
    python_requires = "aleya-conan-base/1.0.1"
    python_requires_extend = "aleya-conan-base.AleyaCmakeBase"

    name = "sdl"
    git_repository = "https://github.com/aleya-dev/mirror-package-sdl.git"
    git_branch = "2.28.0"

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["SDL_SHARED"] = self.options.shared
        tc.variables["SDL_STATIC"] = not self.options.shared
        tc.variables["SDL_TEST"] = False
        tc.variables["SDL_TESTS"] = False
        tc.generate()

    def on_package(self, cmake: CMake):
        rmdir(self, os.path.join(self.package_folder, "share"))
        rmdir(self, os.path.join(self.package_folder, "lib", "cmake"))
        rmdir(self, os.path.join(self.package_folder, "lib", "pkgconfig"))
        rmdir(self, os.path.join(self.package_folder, "lib", "aclocal"))
        rmdir(self, os.path.join(self.package_folder, "licenses"))
        rm(self, "sdl2-config", os.path.join(self.package_folder, "bin"), recursive=False)

    def package_info(self):
        postfix = "d" if self.settings.os != "Android" and self.settings.build_type == "Debug" else ""
        static_postfix = "-static" if not self.options.shared else ""

        self.cpp_info.set_property("cmake_file_name", "SDL2")

        self.cpp_info.components["libsdl2"].libs = ["SDL2" + static_postfix + postfix]
        self.cpp_info.components["libsdl2"].set_property("cmake_target_name", "SDL2::SDL2")

        self.cpp_info.components["sdl2main"].libs = ["SDL2main" + postfix]
        self.cpp_info.components["sdl2main"].set_property("cmake_target_name", "SDL2::SDL2main")
        self.cpp_info.components["sdl2main"].requires = ["libsdl2"]
