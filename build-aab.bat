
flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to get Flutter dependencies
    pause
    exit /b 1
)
echo.

REM Run code generation for Floor database
echo Running code generation (build_runner)...
dart run build_runner build --delete-conflicting-outputs
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Code generation failed, but continuing...
)
echo.

REM Build the AAB
echo Building signed release AAB...
echo This may take several minutes...
echo.
flutter build appbundle --release
