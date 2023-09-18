from conan import ConanFile
from conan.tools.cmake import CMakeToolchain
from conan.tools.files import rmdir, collect_libs
import os

required_conan_version = ">=2.0"


class GlfwConan(ConanFile):
    python_requires = "aleya-conan-base/[>=1.1.0 <1.2.0]"
    python_requires_extend = "aleya-conan-base.AleyaCmakeBase"

    name = "glfw"
    git_repository = "https://github.com/aleya-dev/mirror-package-glfw.git"
    git_branch = "3.3.8"

    options = {
        "shared": [False, True],
        "fPIC": [False, True]
    }

    default_options = {
        "shared": False,
        "fPIC": True
    }

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["BUILD_SHARED_LIBS"] = self.options.shared
        tc.variables["GLFW_BUILD_DOCS"] = False
        tc.variables["GLFW_BUILD_EXAMPLES"] = False
        tc.variables["GLFW_BUILD_TESTS"] = False
        tc.variables["GLFW_INSTALL"] = True

        if self.settings.os == "Windows":
            tc.variables["USE_MSVC_RUNTIME_LIBRARY_DLL"] = True

        tc.generate()

    def package(self):
        super().package()

        rmdir(self, os.path.join(self.package_folder, "lib", "cmake"))
        rmdir(self, os.path.join(self.package_folder, "lib", "pkgconfig"))

    def package_info(self):
        self.cpp_info.set_property("cmake_file_name", "glfw3")
        self.cpp_info.set_property("cmake_target_name", "glfw")
        self.cpp_info.set_property("cmake_target_aliases", ["glfw::glfw"])
        self.cpp_info.set_property("pkg_config_name", "glfw3")

        if self.settings.os == "Macos":
            self.cpp_info.frameworks = ["AppKit", "IOKit", "Foundation", "CoreFoundation", "CoreGraphics", "CoreAudio"]

        self.cpp_info.libs = collect_libs(self)
