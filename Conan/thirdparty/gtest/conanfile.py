from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain
from conan.tools.files import rmdir
import os


required_conan_version = ">=2.0"


class GTestConan(ConanFile):
    python_requires = "aleya-conan-base/1.2.0"
    python_requires_extend = "aleya-conan-base.AleyaCmakeBase"

    name = "gtest"
    git_repository = "https://github.com/aleya-dev/mirror-package-googletest.git"
    git_branch = "1.13.0"

    options = {
        "shared": [False],
        "fPIC": [False, True]
    }

    default_options = {
        "shared": False,
        "fPIC": True
    }

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["BUILD_SHARED_LIBS"] = False
        tc.variables["GTEST_HAS_ABSL"] = False
        tc.variables["gmock_build_tests"] = False
        tc.variables["gtest_build_samples"] = False
        tc.variables["gtest_build_tests"] = False
        tc.variables["gtest_force_shared_crt"] = self.settings.os == "Windows"
        tc.generate()

    def package(self):
        super().package()

        rmdir(self, os.path.join(self.package_folder, "bin"))
        rmdir(self, os.path.join(self.package_folder, "lib", "cmake"))
        rmdir(self, os.path.join(self.package_folder, "lib", "pkgconfig"))

    def package_info(self):
        self.cpp_info.set_property("cmake_file_name", "GTest")

        self.cpp_info.components["libgtest"].libs = ["gtest"]
        self.cpp_info.components["libgtest"].set_property("cmake_target_name", "GTest::gtest")
        self.cpp_info.components["libgtest"].set_property("cmake_target_aliases", ["GTest::GTest"])

        self.cpp_info.components["gtest_main"].set_property("cmake_target_name", "GTest::gtest_main")
        self.cpp_info.components["gtest_main"].set_property("cmake_target_aliases", ["GTest::Main"])
        self.cpp_info.components["gtest_main"].libs = ["gtest_main"]
        self.cpp_info.components["gtest_main"].requires = ["libgtest"]

        self.cpp_info.components["gmock"].set_property("cmake_target_name", "GTest::gmock")
        self.cpp_info.components["gmock"].libs = ["gmock"]
        self.cpp_info.components["gmock"].requires = ["libgtest"]

        self.cpp_info.components["gmock_main"].set_property("cmake_target_name", "GTest::gmock_main")
        self.cpp_info.components["gmock_main"].libs = [f"gmock_main"]
        self.cpp_info.components["gmock_main"].requires = ["gmock"]
