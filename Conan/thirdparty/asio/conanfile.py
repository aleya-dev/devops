from conan import ConanFile
from conan.tools.files import copy
import os


required_conan_version = ">=2.0"


class ZlibConan(ConanFile):
    python_requires = "aleya-conan-base/1.2.0"
    python_requires_extend = "aleya-conan-base.AleyaConanBase"

    name = "asio"
    git_repository = "https://github.com/aleya-dev/mirror-package-asio.git"
    git_branch = "1.28.0"
    package_type = "header-library"

    no_copy_source = True

    options = {
        'header_only': [True]
    }
    default_options = {
        'header_only': True
    }

    def package_id(self):
        self.info.clear()

    def package(self):
        include_dir = os.path.join(self.source_folder, "include")
        copy(self, "*.hpp", src=include_dir, dst=os.path.join(self.package_folder, "include"))
        copy(self, "*.ipp", src=include_dir, dst=os.path.join(self.package_folder, "include"))

    def package_info(self):
        self.cpp_info.set_property("pkg_config_name", "asio")
        self.cpp_info.defines.append("ASIO_NO_DEPRECATED")
        self.cpp_info.defines.append("ASIO_STANDALONE")
        self.cpp_info.defines.append("ASIO_HEADER_ONLY")
        self.cpp_info.defines.append("_WINSOCK_DEPRECATED_NO_WARNINGS")

        self.cpp_info.bindirs = []
        self.cpp_info.frameworkdirs = []
        self.cpp_info.libdirs = []
        self.cpp_info.resdirs = []
