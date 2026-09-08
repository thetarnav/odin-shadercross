@echo off
setlocal EnableExtensions

set "ROOT_DIR=%~dp0"
set "ENV_FILE=%ROOT_DIR%.env"

if not exist "%ENV_FILE%" (
	echo ERROR: %ENV_FILE% does not exist.
	exit /b 1
)

rem Load defaults from .env without overriding existing environment variables.
for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%ENV_FILE%") do (
	if not defined %%A set "%%A=%%B"
)

if not defined SHADERCROSS_URL (
	echo ERROR: SHADERCROSS_URL is not set.
	exit /b 1
)

if not defined SHADERCROSS_REF (
	echo ERROR: SHADERCROSS_REF is not set.
	exit /b 1
)

if not defined SHADERCROSS_FLAGS (
	echo ERROR: SHADERCROSS_FLAGS is not set.
	exit /b 1
)

if not defined SHADERCROSS_PREFIX (
	echo ERROR: SHADERCROSS_PREFIX is not set.
	exit /b 1
)

if not defined SHADERCROSS_CLONE_DIR (
	echo ERROR: SHADERCROSS_CLONE_DIR is not set.
	exit /b 1
)

if not defined SHADERCROSS_BUILD_DIR (
	echo ERROR: SHADERCROSS_BUILD_DIR is not set.
	exit /b 1
)

rem Resolve relative paths against the repository containing this script.
set "INSTALL_PREFIX=%SHADERCROSS_PREFIX%"
set "CLONE_DIR=%SHADERCROSS_CLONE_DIR%"
set "BUILD_DIR=%SHADERCROSS_BUILD_DIR%"

if not "%INSTALL_PREFIX:~1,1%"==":" set "INSTALL_PREFIX=%ROOT_DIR%%INSTALL_PREFIX%"
if not "%CLONE_DIR:~1,1%"==":" set "CLONE_DIR=%ROOT_DIR%%CLONE_DIR%"
if not "%BUILD_DIR:~1,1%"==":" set "BUILD_DIR=%ROOT_DIR%%BUILD_DIR%"

rem Check whether Shadercross is already installed.
set "LIBRARY_PRESENT="

if exist "%INSTALL_PREFIX%\lib\SDL3_shadercross.lib" set "LIBRARY_PRESENT=1"
if exist "%INSTALL_PREFIX%\bin\SDL3_shadercross.dll" set "LIBRARY_PRESENT=1"

if defined LIBRARY_PRESENT (
	echo WARNING: SDL_shadercross is already installed at:
	echo          %INSTALL_PREFIX%
	echo Skipping clone and build.
	echo Remove the installed library if this was unintentional.
	exit /b 0
)

if exist "%CLONE_DIR%\.git" (
	echo Source repository already exists:
	echo   %CLONE_DIR%
	echo Checking out %SHADERCROSS_REF%...

	git -C "%CLONE_DIR%" fetch --depth 1 origin "%SHADERCROSS_REF%"
	if errorlevel 1 exit /b %errorlevel%

	git -C "%CLONE_DIR%" checkout "%SHADERCROSS_REF%"
	if errorlevel 1 exit /b %errorlevel%

	git -C "%CLONE_DIR%" submodule update --init --recursive
	if errorlevel 1 exit /b %errorlevel%
) else (
	echo Cloning SDL_shadercross %SHADERCROSS_REF%...
	echo   %SHADERCROSS_URL%
	echo   -^> %CLONE_DIR%

	for %%I in ("%CLONE_DIR%") do if not exist "%%~dpI" mkdir "%%~dpI"

	git clone ^
		--depth 1 ^
		--branch "%SHADERCROSS_REF%" ^
		--recurse-submodules ^
		"%SHADERCROSS_URL%" ^
		"%CLONE_DIR%"

	if errorlevel 1 exit /b %errorlevel%
)

echo Configuring SDL_shadercross...

cmake ^
	-S "%CLONE_DIR%" ^
	-B "%BUILD_DIR%" ^
	-A x64 ^
	-DCMAKE_BUILD_TYPE=Release ^
	"-DCMAKE_INSTALL_PREFIX=%INSTALL_PREFIX%" ^
	%SHADERCROSS_FLAGS%

if errorlevel 1 exit /b %errorlevel%

echo Building SDL_shadercross...

cmake ^
	--build "%BUILD_DIR%" ^
	--config Release

if errorlevel 1 exit /b %errorlevel%

echo Installing SDL_shadercross...

cmake ^
	--install "%BUILD_DIR%" ^
	--config Release

if errorlevel 1 exit /b %errorlevel%

echo SDL_shadercross build complete.
echo Installed to: %INSTALL_PREFIX%
