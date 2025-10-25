cmake_minimum_required(VERSION 3.21)

# Name this meta-project anything; GLFW defines its own project() inside.
project(glfw-builder LANGUAGES C CXX)

# Allow passing shared/common options from presets/CLI:
# (Your presets already set these as cache variables.)
option(BUILD_SHARED_LIBS "Build shared libs" OFF)
option(GLFW_BUILD_EXAMPLES "Build GLFW examples" OFF)
option(GLFW_BUILD_TESTS "Build GLFW tests" OFF)
option(GLFW_BUILD_DOCS "Build GLFW docs" OFF)

# If you want shared CMake helpers from your submodule:
# set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/third_party/prebuild-core/cmake/Modules;${CMAKE_MODULE_PATH}")

set(BUILD_DIR ${CMAKE_SOURCE_DIR}/build)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${BUILD_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${BUILD_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BUILD_DIR}/bin)

# Helpful default for prebuilts
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Where GLFW source lives (submodule path). Allow override via -DGLFW_SOURCE_DIR=...
set(GLFW_SOURCE_DIR "${CMAKE_SOURCE_DIR}/dependencies/glfw" CACHE PATH "Path to GLFW source")

# Nice error if submodule isn't checked out.
if(NOT EXISTS "${GLFW_SOURCE_DIR}/CMakeLists.txt")
    message(FATAL_ERROR
        "GLFW not found at '${GLFW_SOURCE_DIR}'. "
        "Did you init submodules? Try: git submodule update --init --recursive")
endif()

# Forward options to the subproject BEFORE adding it, so its CMake picks them up.
set(GLFW_BUILD_EXAMPLES ${GLFW_BUILD_EXAMPLES} CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS ${GLFW_BUILD_TESTS} CACHE BOOL "" FORCE)
set(GLFW_BUILD_DOCS ${GLFW_BUILD_DOCS} CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS} CACHE BOOL "" FORCE)

# Add GLFW as a subdir; it defines targets like 'glfw'/'glfw3'
add_subdirectory("${GLFW_SOURCE_DIR}" "${CMAKE_BINARY_DIR}/glfw")

# If you want to expose an ALIAS with a stable name for packaging:
# GLFW uses 'glfw' (static) or 'glfw'/'glfw_shared' depending on version/options.
# Create a consistent alias to whatever exists:
# if(TARGET glfw)
#     add_library(mimi_glfw ALIAS glfw)
# elseif(TARGET glfw_shared) # some forks/configs
#     add_library(mimi_glfw ALIAS glfw_shared)
# elseif(TARGET glfw3) # older naming
#     add_library(mimi_glfw ALIAS glfw3)
# endif()

# Nothing else required: `cmake --install` will run GLFW's own install() rules.