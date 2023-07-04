import platform
import subprocess
import os
import logging


def __get_script_path() -> str:
    """Returns the path of the directory where this script is located"""
    return os.path.dirname(os.path.realpath(__file__))


def get_profile_root_path() -> str:
    """Returns the path of the Conan profiles directory"""
    return os.path.join(__get_script_path(), "..", "..", "..", "Conan", "profiles")


def get_profile_path(os_name: str) -> str:
    """Returns the path of the Conan profiles directory for a given operating system"""
    return os.path.join(get_profile_root_path(), os_name)


def get_profiles(os_name: str) -> list[str]:
    """Returns a list of all profiles in the profiles directory for a given operating system"""
    path = get_profile_path(os_name)
    return [os.path.join(path, o) for o in os.listdir(path) if os.path.isfile(os.path.join(path, o))]


def get_profiles_for_current_os() -> list[str]:
    """Returns a list of all profiles in the profiles directory for the current operating system"""
    if platform.system() == "Windows":
        return get_profiles("windows")
    elif platform.system() == "Linux":
        return get_profiles("linux")
    elif platform.system() == "Darwin":
        return get_profiles("macos")
    else:
        print(f"Unsupported platform: {platform.system()}")
        exit(1)


def build_package(package_path: str, profile_path: str, options: dict[str, str] = None):
    """Build a conan package with the given arguments"""
    logging.info(f"Building package: {package_path}")
    logging.info(f"Using profile: {profile_path}")
    logging.info(f"Using options: {options}")

    command = f"conan create {package_path} -pr {profile_path}"

    if options is not None:
        for key, value in options.items():
            command += f" -o {key}={value}"

    logging.info(f"Executing command: {command}")

    return_code = subprocess.call(command, shell=True)

    if return_code != 0:
        print(f"An error occurred while executing the command: {command}")
        print(f"Return code: {return_code}")
        exit(return_code)


def upload_package(package_name: str, remote: str):
    """Upload a conan package to the given remote"""
    logging.info(f"Uploading package: {package_name}")

    command = f"conan upload {package_name} -c --remote {remote}"

    logging.info(f"Executing command: {command}")
    return_code = subprocess.call(command, shell=True)

    if return_code != 0:
        print(f"An error occurred while executing the command: {command}")
        print(f"Return code: {return_code}")
        exit(return_code)
