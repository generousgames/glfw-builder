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

# Build (local host) app target.
build_dep() {
    BUILD_TARGET=${1:-}
    BUILD_TYPE=${2:-}

    pushd dependencies/prebuild-utils
        source ./setup.sh
        npm run dev build_dep "$BUILD_TARGET" "$BUILD_TYPE"
    popd
}

# Build (local host) app target.
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
    build_dep)
        build_dep "${@:2}"
        ;;
    clean)
        clean
        ;;
    *)
        usage
        ;;
esac