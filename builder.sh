#!/bin/bash

# (1) Exit on error
# (2) Fail on unset variables
# (3) Fail on pipe failure
set -euo pipefail

################################################################################

NAME="glfw"
VERSION="3.3.2"

################################################################################
# Commands

# Setup.
setup() {
    git submodule update --init --recursive

    pushd dependencies/glfw
        git checkout tags/${VERSION}
    popd
}

# Builds the dependency given a CMake preset name.
build() {
    PRESET_NAME=${1:-}

    pushd dependencies/prebuild-utils
        source ./setup.sh
        npm run dev build "$PRESET_NAME"
    popd
}

# Bundles the dependency given a build type.
bundle() {
    PRESET_NAME=${1:-}

    pushd dependencies/prebuild-utils
        source ./setup.sh
        npm run dev bundle "$PRESET_NAME"
    popd
}

# Deploys the dependency given a CMake preset name.
deploy() {
    PRESET_NAME=${1:-}

    pushd dependencies/prebuild-utils
        source ./setup.sh
        npm run dev deploy "$PRESET_NAME"
    popd
}

# Clean temporary directories.
clean() {
    pushd dependencies/prebuild-utils
        source ./setup.sh
        npm run dev clean
    popd
}

################################################################################
# Command processing.

COMMAND=$1

case "$COMMAND" in
    setup)
        setup
        ;;
    build)
        build "${@:2}"
        ;;
    bundle)
        bundle "${@:2}"
        ;;
    deploy)
        deploy "${@:2}"
        ;;
    clean)
        clean
        ;;
    *)
        usage
        ;;
esac