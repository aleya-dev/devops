from tempfile import TemporaryDirectory

from conan import ConanFile
from conan.tools.scm import Git
from conan.tools.cmake import CMake
import importlib.util, sys
import inspect
import uuid


def inherit_conanfile_requirements(conanfile : ConanFile, path : str):
    conanfile.output.info('Inheriting conanfile requirements from {}'.format(path))
    module_name = uuid.uuid4().hex[:6].upper()
    spec = importlib.util.spec_from_file_location(module_name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)

    conan_file_class = inspect.getmembers(
        module, predicate=lambda o: inspect.isclass(o) \
            and issubclass(o, ConanFile) \
            and o.__name__ is not 'ConanFile')

    if len(conan_file_class) == 0:
        conanfile.output.error('Did not find any ConanFile in given python script. Aborting')
        return

    if len(conan_file_class) > 1:
        conanfile.output.error('Found more than 1 possible conan file in given python script. Aborting')
        return

    conan_file_class[0][1].requirements(conanfile)


class AleyaConanBase:
    package_type = "library"
    settings = "os", "arch", "compiler", "build_type"

    """
    Set to True if libcxx and cppstd can be ignored. This is useful for C libraries.
    """
    ignore_cpp_standard: bool = False

    def config_options(self):
        if self.settings.os == "Windows":
            self.options.rm_safe("fPIC")

    def configure(self):
        if self.options.get_safe("shared", False):
            self.options.rm_safe("fPIC")

        if self.ignore_cpp_standard:
            self.output.info("Ignoring compiler.libcxx and compiler.cppstd settings.")

            self.settings.rm_safe("compiler.libcxx")
            self.settings.rm_safe("compiler.cppstd")

    def layout(self):
        self.folders.source = "source"
        self.folders.build = "build"

    def build(self):
        pass

    def generate(self):
        pass


class AleyaCmakeBase(AleyaConanBase):
    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()


class AleyaConanBaseConanFile(ConanFile):
    name = "aleya-conan-base"
    version = "1.3.0"
    package_type = "python-require"
