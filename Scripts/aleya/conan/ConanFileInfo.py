import json
import subprocess
import logging
import os
from .ConanUtils import build_package, upload_package


class ConanDependency:
    name: str = ""
    version: str = ""

    def __init__(self, version_string: str):
        name_version_part = version_string.split("@")[0]
        name_version = name_version_part.split("/")
        self.name = name_version[0]
        self.version = name_version[1]


class ConanFileInfo:
    name: str = ""
    version: str = ""
    conan_file_base_path: str = ""
    options: dict[dict[str]] = {}
    requires: list[ConanDependency] = []

    def __init__(self, conan_file_base_path: str):
        self.conan_file_base_path = conan_file_base_path
        self.__parse_inspect_info()

    def __parse_inspect_info(self):
        inspect_info = subprocess.run(
            ["conan", "inspect", self.conan_file_base_path, "-f", "json", "-vnotice"], capture_output=True)
        inspect_info.check_returncode()

        inspect_json = json.loads(inspect_info.stdout)

        self.name = inspect_json["name"]
        self.version = inspect_json["version"]
        self.options = inspect_json["options_definitions"]

        for require in inspect_json["requires"]:
            self.requires.append(ConanDependency(require["ref"]))

    @staticmethod
    def enumerate(base_path: str):
        """
        Enumerate all conan packages in the given base path, and return a list of ConanFileInfo objects containing
        information about each package.
        """
        packages: list[ConanFileInfo] = []

        dirs = os.listdir(base_path)

        logging.info('Enumerating Conan packages in: {}'.format(base_path))
        logging.info('Found {} potential packages...'.format(len(dirs)))

        for package in dirs:
            logging.info('Processing Conan package: {}'.format(package))

            package_path = os.path.join(base_path, package)

            if os.path.isdir(package_path):
                conan_file_path = os.path.join(package_path, "conanfile.py")

                if os.path.isfile(conan_file_path):
                    packages.append(ConanFileInfo(conan_file_path))

        logging.info('Found {} Conan packages'.format(len(packages)))

        return packages

    def build(self, profile_path: str, shared: bool|None, additional_options: dict[str, str] = None):
        """Build this conan package"""
        options = {'shared': shared} if shared else {}

        if additional_options is not None:
            options.update(additional_options)

        build_package(self.conan_file_base_path, profile_path, options)

    def upload(self, remote: str):
        """Upload all profile and options variations of this conan package available locally to the given remote"""
        upload_package(f"{self.name}/{self.version}", remote)
