from conan import ConanFile
from conan.tools.scm import Git
from conan.tools.cmake import CMake, CMakeToolchain
from conan.tools.files import rmdir


class AleyaConanBase:
    package_type = "library"
    settings = "os", "arch", "compiler", "build_type"

    options = {
        "shared": [False, True],
        "fPIC": [False]
    }

    default_options = {
        "shared": False,
        "fPIC": False
    }

    """
    The git repository to use as source. If you do wish to use a different source, you must implement the
    source() method yourself.
    """
    git_repository: str

    """
    The git branch to use as source. If unset, master is assumed.
    """
    git_branch: str

    """
    Set to True if libcxx and cppstd can be ignored. This is useful for C libraries.
    """
    ignore_cpp_standard: bool = False

    def config_options(self):
        if not self.git_branch:
            self.git_branch = "master"

        self.output.info("Repository: {}".format(self.git_repository))
        self.output.info("Branch: {}".format(self.git_branch))

        if self.settings.os == "Windows":
            del self.options.fPIC

    def configure(self):
        if self.options.shared:
            self.options.rm_safe("fPIC")

        if self.ignore_cpp_standard:
            self.output.info("Ignoring compiler.libcxx and compiler.cppstd settings.")

            self.settings.rm_safe("compiler.libcxx")
            self.settings.rm_safe("compiler.cppstd")

    def source(self):
        git = Git(self, self.source_folder)
        git.clone(url=self.git_repository, target='.')
        git.checkout(commit=self.version)

    def layout(self):
        self.folders.source = "src"
        self.folders.build = "build"

    def build(self):
        pass

    def generate(self):
        pass

    def set_version(self):
        # Enforce git describe version so that it also works
        # when the provided version was a branch
        self.version = self.version or self.__generate_version()

    def __generate_version(self):
        rmdir(self, "temp-git-dir")
        git = Git(self, "temp-git-dir")
        git.clone(url=self.git_repository, target='.')
        git.checkout(commit=self.git_branch)
        result = self.__get_git_describe(git)
        rmdir(self, "temp-git-dir")
        return result

    @staticmethod
    def __get_git_describe(git: Git):
        return str(git.run("describe --tags")).lower()


class AleyaCmakeBase(AleyaConanBase):
    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["CMAKE_DEBUG_POSTFIX"] = ''
        self.on_generate(tc)
        tc.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()

        self.on_package(cmake)


class AleyaConanBaseConanFile(ConanFile):
    name = "aleya-conan-base"
    version = "1.0.1"
    package_type = "python-require"
