from conan import ConanFile
from conan.tools.cmake import CMake, CMakeToolchain
from conan.tools.files import rmdir, collect_libs
import os


required_conan_version = ">=2.0"


class VulkanMemoryAllocatorConan(ConanFile):
    python_requires = "aleya-conan-base/1.0.1"
    python_requires_extend = "aleya-conan-base.AleyaCmakeBase"

    name = "vulkan-memory-allocator"
    git_repository = "https://github.com/aleya-dev/mirror-package-vulkan-memory-allocator.git"
    git_branch = "3.0.1"

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["BUILD_SHARED_LIBS"] = self.options.shared
        tc.variables["BUILD_DOCUMENTATION"] = False
        tc.variables["VMA_BUILD_SAMPLE"] = False
        tc.variables["VMA_BUILD_SAMPLE_SHADERS"] = False
        tc.variables["VMA_DEBUG_ALWAYS_DEDICATED_MEMORY"] = False
        tc.variables["VMA_DEBUG_DONT_EXCEED_MAX_MEMORY_ALLOCATION_COUNT"] = False
        tc.variables["VMA_DEBUG_GLOBAL_MUTEX"] = False
        tc.variables["VMA_DEBUG_INITIALIZE_ALLOCATIONS"] = False
        tc.variables["VMA_DYNAMIC_VULKAN_FUNCTIONS"] = False
        tc.variables["VMA_STATIC_VULKAN_FUNCTIONS"] = True
        tc.generate()

    def on_package(self, cmake: CMake):
        rmdir(self, os.path.join(self.package_folder, "lib", "cmake"))

    def package_info(self):
        self.cpp_info.set_property("cmake_find_mode", "both")
        self.cpp_info.set_property("cmake_file_name", "vulkan-memory-allocator")
        self.cpp_info.set_property("cmake_target_name", "vulkan-memory-allocator::vulkan-memory-allocator")
        self.cpp_info.set_property("pkg_config_name", "vulkan-memory-allocator")

        self.cpp_info.libs = collect_libs(self)
