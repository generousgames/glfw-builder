::===============================================================
@echo off

set NAME=glfw
set REPOSITORY_TAG="3.3.2"
set PLATFORM=win32
set ARCHS=x86 x64

set ROOT=%cd%
set SUB_MODULE_DIR=%ROOT%/dependencies/%NAME%
set PROJECT_DIR=%ROOT%/project/%PLATFORM%
set BUILD_DIR=%ROOT%/build/%PLATFORM%
set LIB_DIR=%BUILD_DIR%/libs
set BIN_DIR=%BUILD_DIR%/bins

echo "PROJECT_DIR: %PROJECT_DIR%"
echo "BUILD_DIR: %BUILD_DIR%"
echo "LIB_DIR: %LIB_DIR%"
echo "BIN_DIR: %BIN_DIR%"

::===============================================================

pushd "%SUB_MODULE_DIR%"
    echo %cd%
    git checkout tags/%REPOSITORY_TAG%
popd

::===============================================================
:: Configure.

set PROJECT_GENERATOR="Visual Studio 16 2019"
set PROJECT_SOURCE_DIR="%ROOT%"
set PROJECT_TARGET="ALL_BUILD"

::===============================================================
:: Build.

:: Allows us to late resolve !XYZ! variables that are expressed in a loop.
setlocal enableextensions enabledelayedexpansion

rmdir /s /q "%BUILD_DIR%"
rmdir /s /q "%PROJECT_DIR%"
mkdir "%BUILD_DIR%"

(for %%a in (%ARCHS%) do (
    set TARGET_ARCH=%%a
    if "%%a"=="x86" (
        set TARGET_ARCH=win32
    )

    mkdir "%PROJECT_DIR%/%%a"

    pushd "%PROJECT_DIR%/%%a"
        cmake -G %PROJECT_GENERATOR% ^
        -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%LIB_DIR%/%%a" ^
        -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="%LIB_DIR%/%%a" ^
        -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="%BIN_DIR%/%%a" ^
        -DCMAKE_CXX_FLAGS_DEBUG="/Zi /nologo /W3 /WX- /diagnostics:classic /Od /Ob0 /Oy- /D WIN32 /D _WINDOWS /D _MBCS /Gm- /EHsc /MTd /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /GR" ^
        -DCMAKE_CXX_FLAGS_RELEASE="/nologo /W3 /WX- /diagnostics:classic /O2 /Ob2 /Oy- /D WIN32 /D _WINDOWS /D NDEBUG /D _MBCS /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /GR" ^
        ^
        -DGLFW_BUILD_EXAMPLES=OFF ^
        -DGLFW_BUILD_TESTS=OFF ^
        -DGLFW_BUILD_DOCS=OFF ^
        -DGLFW_INSTALL=OFF ^
        ^
        -A !TARGET_ARCH! ^
        "%SUB_MODULE_DIR%"

        cmake --build . --target %PROJECT_TARGET% --config Debug
        cmake --build . --target %PROJECT_TARGET% --config Release
    popd
))

::===============================================================
:: Package.

pushd "%BUILD_DIR%"
    mkdir "prebuilt/include"
    mkdir "prebuilt/libs"

    xcopy /s /q "%ROOT%/dependencies/%NAME%/include" "prebuilt/include"
    xcopy /s /q "%LIB_DIR%" "prebuilt/libs"

    tar -a -c -f prebuilt.zip prebuilt
popd

::===============================================================