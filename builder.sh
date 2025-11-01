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

# Builds, bundles, and deploys the dependency given a CMake preset name.
build_bundle_deploy() {
    PRESET_NAME=${1:-}

    pushd dependencies/prebuild-utils
        source ./setup.sh
        npm run dev build "$PRESET_NAME"
        npm run dev bundle "$PRESET_NAME"
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

usage() {
    echo "Usage: $0 <command>"
    echo "Commands:"
    echo "  setup               Setup the builder"
    echo "  build <preset>      Build the dependency"
    echo "  bundle <preset>     Bundle the dependency"
    echo "  deploy <preset>     Deploy the dependency"
    echo "  full <preset>       Build, bundle, and deploy the dependency"
    echo "  clean               Clean the builder"
}

################################################################################
# Command processing.

if [ $# -eq 0 ]; then
    usage
    exit 1
fi
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
    full)
        build_bundle_deploy "${@:2}"
        ;;
    *)
        usage
        exit 1
        ;;
esac