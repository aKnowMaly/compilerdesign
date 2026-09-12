cmake_minimum_required(VERSION 3.20)

project(AdaptiveWidthMemoryPass LANGUAGES CXX)

find_package(LLVM REQUIRED CONFIG)

if (NOT LLVM_VERSION_MAJOR EQUAL 18)
  message(FATAL_ERROR "LLVM 18 is required, found LLVM ${LLVM_PACKAGE_VERSION}")
endif()

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in ${LLVM_DIR}")

list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
include(AddLLVM)

add_definitions(${LLVM_DEFINITIONS})
include_directories(SYSTEM ${LLVM_INCLUDE_DIRS})

add_llvm_pass_plugin(AdaptiveWidthMemoryPass
  src/AdaptiveWidthMemoryPass.cpp
)

target_compile_features(AdaptiveWidthMemoryPass PRIVATE cxx_std_17)
