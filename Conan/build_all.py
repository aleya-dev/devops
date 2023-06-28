import os
import importlib.util
import uuid
import inspect
import sys
import subprocess
import platform
from conan import ConanFile


class ConanFileMock:
    packages: list[str] = []

    def __init__(self):
        self.packages = []

    def requires(self, package: str):
        self.packages.append(package.split("/")[0])


def get_script_path() -> str:
    """Returns the path of the directory where this script is located"""
    return os.path.dirname(os.path.realpath(__file__))


def get_packages() -> list[str]:
    """Returns a list of all packages in the thirdparty directory"""
    path = os.path.join(get_script_path(), "thirdparty")
    return [o for o in os.listdir(path) if os.path.isdir(os.path.join(path, o))]


def get_profiles(os_name: str) -> list[str]:
    """Returns a list of all profiles in the profiles directory for a given operating system"""
    path = os.path.join(get_script_path(), "profiles", os_name)
    return [os.path.join(path, o) for o in os.listdir(path) if os.path.isfile(os.path.join(path, o))]


def get_package_dependencies(package: str) -> list[str]:
    path = os.path.join(get_script_path(), "thirdparty", package, "conanfile.py")

    # Load the conanfile.py as a module
    module_name = uuid.uuid4().hex[:6].upper()
    spec = importlib.util.spec_from_file_location(module_name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)

    conan_file_class = inspect.getmembers(
        module, predicate=lambda o: not (
                    not inspect.isclass(o) or not issubclass(o, ConanFile) or not (o.__name__ != 'ConanFile')))

    conan_file = ConanFileMock()

    if hasattr(conan_file_class[0][1], "requirements"):
        conan_file_class[0][1].requirements(conan_file)

    return conan_file.packages


def topological_sort(packages: list[str]) -> list[str]:
    visited = set()
    sorted_packages = list()

    def visit(current_package: str):
        if current_package in visited:
            return

        visited.add(current_package)
        dependencies = get_package_dependencies(current_package)

        for dependency in dependencies:
            visit(dependency)

        sorted_packages.append(current_package)

    for package in packages:
        visit(package)

    return sorted_packages


def build_conan_package(package_path: str, profile_path: str):
    command = f"conan create {package_path} -pr {profile_path}"
    return_code = subprocess.call(command, shell=True)

    if return_code != 0:
        print(f"An error occurred while executing the command: {command}")
        print(f"Return code: {return_code}")
        exit(return_code)
    else:
        print("Command executed successfully.")


def build_conan_infra():
    conan_base_path = os.path.join(get_script_path(), "aleya-conan-base")
    os.system(f"conan export {conan_base_path}")


def build_all_thirdparty() -> list[str]:
    packages = get_packages()
    sorted_packages = topological_sort(packages)

    if platform.system() == "Windows":
        profiles = get_profiles("windows")
    elif platform.system() == "Linux":
        profiles = get_profiles("linux")
    elif platform.system() == "Darwin":
        profiles = get_profiles("macos")
    else:
        print(f"Unsupported platform: {platform.system()}")
        exit(1)

    # Call conan create for each package
    for package in sorted_packages:
        package_path = os.path.join(get_script_path(), "thirdparty", package)

        for profile in profiles:
            build_conan_package(package_path, profile)

    return packages


def upload_packages(packages: list[str]):
    for package in packages:
        command = f"conan upload {package} -c --remote aleya-thirdparty-conan"
        return_code = subprocess.call(command, shell=True)

        if return_code != 0:
            print(f"An error occurred while executing the command: {command}")
            print(f"Return code: {return_code}")
            exit(return_code)


def main():
    build_conan_infra()
    packages = build_all_thirdparty()
    upload_packages(packages)


if __name__ == '__main__':
    main()
