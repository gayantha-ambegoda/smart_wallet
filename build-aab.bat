@echo off
REM ============================================================
REM SmartWallet - Build Signed AAB (Android App Bundle)
REM ============================================================
REM This batch file builds a signed release AAB for the Flutter app
REM without needing to open Android Studio.
REM ============================================================

echo.
echo ============================================================
echo SmartWallet - Build Signed AAB
echo ============================================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    echo.
    pause
    exit /b 1
)

REM Display Flutter version
echo Checking Flutter installation...
flutter --version
echo.

REM Check if key.properties exists
if not exist "android\key.properties" (
    echo WARNING: key.properties file not found!
    echo.
    echo To build a signed release AAB, you need to:
    echo 1. Create a keystore file (if you don't have one)
    echo 2. Copy android\key.properties.example to android\key.properties
    echo 3. Edit android\key.properties with your keystore details
    echo.
    echo The build will continue with DEBUG signing...
    echo.
    pause
)

REM Clean previous builds
echo Cleaning previous builds...
flutter clean
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)
echo.

REM Get dependencies
echo Getting Flutter dependencies...
flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to get Flutter dependencies
    pause
    exit /b 1
)
echo.

REM Run code generation for Floor database
echo Running code generation (build_runner)...
flutter pub run build_runner build --delete-conflicting-outputs
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Code generation failed, but continuing...
)
echo.

REM Build the AAB
echo Building signed release AAB...
echo This may take several minutes...
echo.
flutter build appbundle --release
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Build failed!
    echo Please check the error messages above.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo BUILD SUCCESSFUL!
echo ============================================================
echo.
echo Your signed AAB file is located at:
echo build\app\outputs\bundle\release\app-release.aab
echo.
echo You can now upload this file to Google Play Console.
echo.
echo File size:
for %%A in ("build\app\outputs\bundle\release\app-release.aab") do echo %%~zA bytes
echo.
echo ============================================================
pause
