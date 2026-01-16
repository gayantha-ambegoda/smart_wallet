# ============================================================
# SmartWallet - Build Signed AAB (Android App Bundle)
# ============================================================
# This PowerShell script builds a signed release AAB for the Flutter app
# without needing to open Android Studio.
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "SmartWallet - Build Signed AAB" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from https://flutter.dev/docs/get-started/install"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Display Flutter version
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
flutter --version
Write-Host ""

# Check if key.properties exists
if (-not (Test-Path "android\key.properties")) {
    Write-Host "WARNING: key.properties file not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To build a signed release AAB, you need to:"
    Write-Host "1. Create a keystore file (if you don't have one)"
    Write-Host "2. Copy android\key.properties.example to android\key.properties"
    Write-Host "3. Edit android\key.properties with your keystore details"
    Write-Host ""
    Write-Host "The build will continue with DEBUG signing..." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter clean failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Get dependencies
Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to get Flutter dependencies" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Run code generation for Floor database
Write-Host "Running code generation (build_runner)..." -ForegroundColor Yellow
dart run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Code generation failed, but continuing..." -ForegroundColor Yellow
}
Write-Host ""

# Build the AAB
Write-Host "Building signed release AAB..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Yellow
Write-Host ""
flutter build appbundle --release
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    Write-Host "Please check the error messages above."
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your signed AAB file is located at:" -ForegroundColor Green
Write-Host "build\app\outputs\bundle\release\app-release.aab"
Write-Host ""
Write-Host "You can now upload this file to Google Play Console."
Write-Host ""

# Display file size
if (Test-Path "build\app\outputs\bundle\release\app-release.aab") {
    $fileSize = (Get-Item "build\app\outputs\bundle\release\app-release.aab").Length
    Write-Host "File size: $fileSize bytes"
    Write-Host ""
}

Write-Host "============================================================" -ForegroundColor Cyan
Read-Host "Press Enter to exit"
