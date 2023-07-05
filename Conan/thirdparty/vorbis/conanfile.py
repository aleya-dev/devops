from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMakeDeps
from conan.tools.files import rmdir
import os


required_conan_version = ">=2.0"


class VorbisConan(ConanFile):
    python_requires = "aleya-conan-base/[>=1.1.0 <1.2.0]"
    python_requires_extend = "aleya-conan-base.AleyaCmakeBase"

    name = "vorbis"
    git_repository = "git@github.com:aleya-dev/mirror-package-vorbis.git"
    git_branch = "1.3.7"
    ignore_cpp_standard = True

    requires = "ogg/1.3.5"

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
        tc.cache_variables["CMAKE_POLICY_DEFAULT_CMP0042"] = "NEW"
        tc.cache_variables["CMAKE_POLICY_DEFAULT_CMP0077"] = "NEW"
        tc.generate()
        tc = CMakeDeps(self)
        tc.generate()

    def package(self):
        super().package()

        rmdir(self, os.path.join(self.package_folder, "lib", "cmake"))
        rmdir(self, os.path.join(self.package_folder, "lib", "pkgconfig"))

    def package_info(self):
        self.cpp_info.set_property("cmake_file_name", "Vorbis")
        self.cpp_info.set_property("pkg_config_name", "vorbis")

        self.cpp_info.components["vorbismain"].set_property("cmake_target_name", "Vorbis::vorbis")
        self.cpp_info.components["vorbismain"].set_property("pkg_config_name", "vorbis")
        self.cpp_info.components["vorbismain"].libs = ["vorbis"]

        if self.settings.os in ["Linux", "FreeBSD"]:
            self.cpp_info.components["vorbismain"].system_libs.append("m")

        self.cpp_info.components["vorbismain"].requires = ["ogg::ogg"]

        self.cpp_info.components["vorbisenc"].set_property("cmake_target_name", "Vorbis::vorbisenc")
        self.cpp_info.components["vorbisenc"].set_property("pkg_config_name", "vorbisenc")
        self.cpp_info.components["vorbisenc"].libs = ["vorbisenc"]
        self.cpp_info.components["vorbisenc"].requires = ["vorbismain"]

        self.cpp_info.components["vorbisfile"].set_property("cmake_target_name", "Vorbis::vorbisfile")
        self.cpp_info.components["vorbisfile"].set_property("pkg_config_name", "vorbisfile")
        self.cpp_info.components["vorbisfile"].libs = ["vorbisfile"]
        self.cpp_info.components["vorbisfile"].requires = ["vorbismain"]
