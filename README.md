# glfw-builder

Build definition for the GLFW dependency used by Mimi Engine.

This repository:
- Pins a specific GLFW revision as a submodule.
- Defines build scripts for generating a Mimi-compatible prebuilt archive.

# Build steps

preset = { macos-arm64-Release, macos-arm64-Debug }

1. Building
./builder.sh build <preset>

2. Bundling
./builder.sh bundle <preset>

3. Deploying
./builder.sh deploy <preset>

or

Full build, bundle, deploy
./builder.sh full <preset>

# Important files

## builder.sh
Helper script for invoking build, bundle, deploy.

## manifest.json
A configuration file that defines how the subproject should be built for various target platforms and configurations. This file is used as an input into prebuild-utils, to configure the build environment (eg. stdlib, rtti, exceptions, ....etc) and towards generating the build's ABI fingerprint for bundling / deployment.

## CMakeLists.txt
CMake build script that configures the build environment, detects the current ABI, reads options from `manifest.json`, and sets up the build for our subproject. This file ensures consistent build settings and proper output directories for prebuilt binaries.
See [CMake documentation](https://cmake.org/cmake/help/latest/index.html) for more details.

## CMakePresets.json
CMake presets are configuration files (CMakePresets.json and optionally CMakeUserPresets.json) that define a set of named build and test configurations for CMake. 
See [CMake documentation on presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html) for more details.
