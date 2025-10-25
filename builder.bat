@REM ::===============================================================
@REM @echo off

@REM set NAME=glfw
@REM set REPOSITORY_TAG="3.3.2"
@REM set PLATFORM=win32
@REM set ARCHS=x86 x64

@REM set ROOT=%cd%
@REM set SUB_MODULE_DIR=%ROOT%/dependencies/%NAME%
@REM set PROJECT_DIR=%ROOT%/project/%PLATFORM%
@REM set BUILD_DIR=%ROOT%/build/%PLATFORM%
@REM set LIB_DIR=%BUILD_DIR%/libs
@REM set BIN_DIR=%BUILD_DIR%/bins

@REM echo "PROJECT_DIR: %PROJECT_DIR%"
@REM echo "BUILD_DIR: %BUILD_DIR%"
@REM echo "LIB_DIR: %LIB_DIR%"
@REM echo "BIN_DIR: %BIN_DIR%"

@REM ::===============================================================

@REM pushd "%SUB_MODULE_DIR%"
@REM     echo %cd%
@REM     git checkout tags/%REPOSITORY_TAG%
@REM popd

@REM ::===============================================================
@REM :: Configure.

@REM set PROJECT_GENERATOR="Visual Studio 16 2019"
@REM set PROJECT_SOURCE_DIR="%ROOT%"
@REM set PROJECT_TARGET="ALL_BUILD"

@REM ::===============================================================
@REM :: Build.

@REM :: Allows us to late resolve !XYZ! variables that are expressed in a loop.
@REM setlocal enableextensions enabledelayedexpansion

@REM rmdir /s /q "%BUILD_DIR%"
@REM rmdir /s /q "%PROJECT_DIR%"
@REM mkdir "%BUILD_DIR%"

@REM (for %%a in (%ARCHS%) do (
@REM     set TARGET_ARCH=%%a
@REM     if "%%a"=="x86" (
@REM         set TARGET_ARCH=win32
@REM     )

@REM     mkdir "%PROJECT_DIR%/%%a"

@REM     pushd "%PROJECT_DIR%/%%a"
@REM         cmake -G %PROJECT_GENERATOR% ^
@REM         -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="%LIB_DIR%/%%a" ^
@REM         -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="%LIB_DIR%/%%a" ^
@REM         -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="%BIN_DIR%/%%a" ^
@REM         -DCMAKE_CXX_FLAGS_DEBUG="/Zi /nologo /W3 /WX- /diagnostics:classic /Od /Ob0 /Oy- /D WIN32 /D _WINDOWS /D _MBCS /Gm- /EHsc /MTd /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /GR" ^
@REM         -DCMAKE_CXX_FLAGS_RELEASE="/nologo /W3 /WX- /diagnostics:classic /O2 /Ob2 /Oy- /D WIN32 /D _WINDOWS /D NDEBUG /D _MBCS /Gm- /EHsc /MT /GS /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /GR" ^
@REM         ^
@REM         -DGLFW_BUILD_EXAMPLES=OFF ^
@REM         -DGLFW_BUILD_TESTS=OFF ^
@REM         -DGLFW_BUILD_DOCS=OFF ^
@REM         -DGLFW_INSTALL=OFF ^
@REM         ^
@REM         -A !TARGET_ARCH! ^
@REM         "%SUB_MODULE_DIR%"

@REM         cmake --build . --target %PROJECT_TARGET% --config Debug
@REM         cmake --build . --target %PROJECT_TARGET% --config Release
@REM     popd
@REM ))

@REM ::===============================================================
@REM :: Package.

@REM pushd "%BUILD_DIR%"
@REM     mkdir "prebuilt/include"
@REM     mkdir "prebuilt/libs"

@REM     xcopy /s /q "%ROOT%/dependencies/%NAME%/include" "prebuilt/include"
@REM     xcopy /s /q "%LIB_DIR%" "prebuilt/libs"

@REM     tar -a -c -f prebuilt.zip prebuilt
@REM popd

@REM ::===============================================================