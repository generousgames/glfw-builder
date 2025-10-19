################################################################################

REPOSITORY_TAG="3.3.2"
PLATFORM="osx"

ROOT=`pwd`
PROJECT_DIR="$ROOT/project/${PLATFORM}"
BUILD_DIR="$ROOT/build/${PLATFORM}"
LIB_DIR="$BUILD_DIR/libs"
BIN_DIR="$BUILD_DIR/bins"

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${PROJECT_DIR}

################################################################################

################################################################################

BUILD_PATCH="$ROOT/build_osx.patch"
pushd dependencies/glfw
    git checkout tags/${REPOSITORY_TAG}

    # Apply patch
    git apply ${BUILD_PATCH}
popd


################################################################################
# Configure.

PROJECT_SOURCE_DIR="${ROOT}/dependencies/glfw"
PROJECT_FILE="GLFW.xcodeproj"
PROJECT_SCHEME="ALL_BUILD"

################################################################################
# Build.

pushd ${PROJECT_DIR}
    cmake -G "Xcode" \
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="${LIB_DIR}" \
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="${LIB_DIR}" \
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="${BIN_DIR}" \
    -DCMAKE_OSX_ARCHITECTURES="arm64,x86_64" \
    \
    -DGLFW_BUILD_EXAMPLES=OFF \
    -DGLFW_BUILD_TESTS=OFF \
    -DGLFW_BUILD_DOCS=OFF \
    -DGLFW_INSTALL=OFF \
    \
    ${PROJECT_SOURCE_DIR}

    xcodebuild \
    -project ${PROJECT_FILE} \
    -scheme ${PROJECT_SCHEME} \
    -configuration Release \
    -arch arm64 \
    -arch x86_64 \
    -quiet

    xcodebuild \
    -project ${PROJECT_FILE} \
    -scheme ${PROJECT_SCHEME} \
    -configuration Debug \
    -arch arm64 \
    -arch x86_64 \
    -quiet
popd

################################################################################
# Package.

pushd ${BUILD_DIR}
    mkdir -p "prebuilt/include"

    cp -rf ${ROOT}/dependencies/glfw/include/* prebuilt/include
    cp -rf ${LIB_DIR} prebuilt

    zip -r prebuilt.zip prebuilt
popd

################################################################################