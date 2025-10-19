################################################################################

NAME="glfw"
VERSION="3.3.2"
PLATFORM="osx"

################################################################################
# Parse input parameters.

if [[ "$1" != "Debug" && "$1" != "Release" ]]; then
  echo "Error: First parameter must be 'Debug' or 'Release'."
  exit 1
fi

BUILD_TYPE="$1"

################################################################################
# Setup paths / directories.

ROOT=`pwd`
PROJECT_DIR="$ROOT/project/${PLATFORM}"
BUILD_DIR="$ROOT/build/${PLATFORM}"
OUTPUT_DIR="$ROOT/output"
LIB_DIR="$BUILD_DIR/libs"
BIN_DIR="$BUILD_DIR/bins"

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${PROJECT_DIR}
mkdir -p ${OUTPUT_DIR}

################################################################################
# Generate ABI hash.

# Detect compiler info
C_COMPILER=${C_COMPILER:-$(which clang || which gcc || true)}
CXX_COMPILER=${CXX_COMPILER:-$(which clang++ || which g++ || true)}
C_ID=$($C_COMPILER --version | head -n1)
CXX_ID=$($CXX_COMPILER --version | head -n1)

# Detect OS / target info
ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
OS_VER=$(uname -r | cut -d. -f1-2)

# Detect stdlib / CRT style (best-effort)
CRT=""
if [[ "$OS" == "darwin" ]]; then
  CRT="libc++"
elif [[ "$OS" == "linux" ]]; then
  CRT="libstdc++"
elif [[ "$OS" == "mingw"* || "$OS" == "msys"* ]]; then
  CRT="msvcrt"
fi

# Detect C++ standard and flags (if CXXFLAGS set, use it)
CXXSTD=${CXXSTD:-c++20}

# Compose a fingerprint string
FINGERPRINT="$CXX_ID|$OS|$ARCH|$OS_VER|$CRT|$CXXSTD|$BUILD_TYPE"
# Optionally include custom flags if you have ABI-affecting ones:
# FINGERPRINT="$FINGERPRINT|$CXXFLAGS"

# Hash it to a short token (first 8 hex chars of SHA1)
ABI_HASH=$(echo -n "$FINGERPRINT" | sha1sum | cut -c1-8)

echo "ABI fingerprint: $FINGERPRINT"
echo "ABI hash: $ABI_HASH"

# Optionally write to file for CMake or your manifest
# echo "$ABI_HASH" > abi_hash.txt

################################################################################
# Setup submodules.

git submodule update --init --recursive

BUILD_PATCH="$ROOT/build_osx.patch"
pushd dependencies/glfw
    git checkout tags/${VERSION}

    # Apply patch
    git apply ${BUILD_PATCH}
popd


################################################################################
# Build.

PROJECT_SOURCE_DIR="${ROOT}/dependencies/glfw"
PROJECT_FILE="GLFW.xcodeproj"
PROJECT_SCHEME="ALL_BUILD"

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
    -configuration ${BUILD_TYPE} \
    -arch arm64 \
    -arch x86_64 \
    -quiet
popd

################################################################################
# Package to output directory.

pushd ${OUTPUT_DIR}
    PREBUILT_DIR="${NAME}-${VERSION}-${ABI_HASH}"
    mkdir -p "${PREBUILT_DIR}"

    cp -rf ${ROOT}/dependencies/glfw/LICENSE.md ${PREBUILT_DIR}/LICENSE.md
    cp -rf ${ROOT}/dependencies/glfw/include/* ${PREBUILT_DIR}/include
    cp -rf ${LIB_DIR}/${BUILD_TYPE} ${PREBUILT_DIR}/libs

    zip -r ${PREBUILT_DIR}.zip ${PREBUILT_DIR}
popd

################################################################################