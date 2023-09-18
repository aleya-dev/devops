from conan import ConanFile
from conan.tools.cmake import CMakeToolchain
from conan.tools.files import rmdir, rm, collect_libs
import os


required_conan_version = ">=2.0"


class ZlibConan(ConanFile):
    python_requires = "aleya-conan-base/[>=1.2.0 <1.3.0]"
    python_requires_extend = "aleya-conan-base.AleyaCmakeBase"

    name = "zlib"
    git_repository = "https://github.com/aleya-dev/mirror-package-zlib.git"
    git_branch = "1.2.13"
    ignore_cpp_standard = True

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
        tc.variables["CMAKE_DEBUG_POSTFIX"] = ''
        tc.variables["BUILD_SHARED_LIBS"] = self.options.shared
        tc.variables["INSTALL_LIB_DIR"] = "lib"
        tc.variables["INSTALL_INC_DIR"] = "include"
        tc.generate()

    def package(self):
        super().package()

        rmdir(self, os.path.join(self.package_folder, "share"))

        if self.options.shared:
            rm(self, "*.a", os.path.join(self.package_folder, "lib"), recursive=True)
            rm(self, "zlibstatic.lib", os.path.join(self.package_folder, "lib"), recursive=True)
            rm(self, "zlibstaticd.lib", os.path.join(self.package_folder, "lib"), recursive=True)
        else:
            rmdir(self, os.path.join(self.package_folder, "bin"))
            rm(self, "*.so", os.path.join(self.package_folder, "lib"), recursive=True)
            rm(self, "zlib.lib", os.path.join(self.package_folder, "lib"), recursive=True)
            rm(self, "zlibd.lib", os.path.join(self.package_folder, "lib"), recursive=True)

    def package_info(self):
        self.cpp_info.set_property("cmake_find_mode", "both")
        self.cpp_info.set_property("cmake_file_name", "ZLIB")
        self.cpp_info.set_property("cmake_target_name", "ZLIB::ZLIB")
        self.cpp_info.set_property("pkg_config_name", "zlib")

        self.cpp_info.libs = collect_libs(self)
