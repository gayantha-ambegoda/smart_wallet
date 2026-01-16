# Build Guide - Building Signed AAB from Command Line

This guide explains how to build a signed Android App Bundle (AAB) for SmartWallet directly from the command prompt, without needing to open Android Studio.

## Prerequisites

Before you can build a signed AAB, you need:

1. **Flutter SDK** installed and added to your PATH
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter --version`

2. **Java Development Kit (JDK)** 11 or higher
   - Required by Android build tools

3. **Android SDK** (automatically installed with Flutter)

## Quick Start

### Option 1: Using the Batch File (Easiest - Command Prompt)

Simply double-click the `build-aab.bat` file in the project root, or run it from command prompt:

```cmd
build-aab.bat
```

### Option 2: Using PowerShell Script

If you prefer PowerShell, run:

```powershell
.\build-aab.ps1
```

Both scripts will:
- Check if Flutter is installed
- Clean previous builds
- Get dependencies
- Run code generation (for Floor database)
- Build the signed release AAB
- Display the output file location

### Option 3: Manual Command

If you prefer to run the build command manually:

```cmd
flutter build appbundle --release
```

The output AAB will be located at:
```
build\app\outputs\bundle\release\app-release.aab
```

## Setting Up App Signing

To properly sign your release AAB (required for Google Play Store), follow these steps:

### Step 1: Create a Keystore (One-time setup)

If you don't already have a keystore file, create one using the Java keytool:

```cmd
keytool -genkey -v -keystore smartwallet-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias smartwallet
```

You will be prompted to enter:
- Keystore password (remember this!)
- Key password (remember this!)
- Your name, organization, city, state, and country

**IMPORTANT:** 
- Store the keystore file in a safe location (e.g., `C:\keys\smartwallet-release-key.jks`)
- Keep the passwords safe - you'll need them for every release
- NEVER commit the keystore file or passwords to version control
- Make backups of your keystore file - if you lose it, you cannot update your app on Google Play

### Step 2: Configure Signing

1. Copy the example properties file:
   ```cmd
   copy android\key.properties.example android\key.properties
   ```

2. Edit `android\key.properties` with your keystore information:
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=smartwallet
   storeFile=C:/keys/smartwallet-release-key.jks
   ```

   **Note:** Use forward slashes (/) or double backslashes (\\) for the path on Windows.

3. The `key.properties` file is already in `.gitignore` and will not be committed to the repository.

### Step 3: Build the Signed AAB

Once the `key.properties` file is configured, run the batch file:

```cmd
build-aab.bat
```

Or use the manual command:

```cmd
flutter build appbundle --release
```

The AAB will be signed with your keystore and ready for upload to Google Play Console.

## Build Configuration Details

### What the Build Does

The build process includes:

1. **Clean**: Removes previous build artifacts
2. **Dependencies**: Fetches all Flutter packages via `flutter pub get`
3. **Code Generation**: Runs `build_runner` to generate Floor database code
4. **Compilation**: Compiles the Flutter app for Android in release mode
5. **Bundling**: Creates the AAB file with all necessary resources
6. **Signing**: Signs the AAB with your keystore (if configured)

### Build Variants

The app is built in **release** mode, which:
- Enables optimizations
- Removes debug code
- Minifies the app size
- Makes it ready for production

### Version Management

The version is managed in `pubspec.yaml`:

```yaml
version: 2.0.1+37
```

- `2.0.1` is the version name (displayed to users)
- `37` is the version code (must increment for each release)

Update this before building a new release.

## Troubleshooting

### "Flutter is not installed or not in PATH"

**Solution:** Install Flutter and add it to your system PATH. See: https://flutter.dev/docs/get-started/install

### "key.properties file not found"

**Solution:** The build will continue with debug signing. To use release signing, create the `key.properties` file as described in "Setting Up App Signing" above.

### Build fails with dependency errors

**Solution:** Try these commands:

```cmd
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build appbundle --release
```

### "Execution failed for task ':app:signReleaseBundle'"

**Solution:** Check your `key.properties` file:
- Verify the keystore file path is correct
- Ensure passwords are correct
- Make sure the key alias matches

### Build is very slow

**Solution:** The first build is always slower. Subsequent builds will be faster. You can also:
- Close other applications to free up system resources
- Use `flutter build appbundle --release --no-tree-shake-icons` to skip icon tree-shaking

### Code generation errors

**Solution:** Run code generation separately:

```cmd
flutter pub run build_runner build --delete-conflicting-outputs
```

## Uploading to Google Play Console

Once you have the signed AAB:

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Go to "Release" → "Production" (or "Testing" for beta releases)
4. Create a new release
5. Upload the AAB file from `build\app\outputs\bundle\release\app-release.aab`
6. Fill in release notes
7. Review and roll out

## Additional Resources

- [Flutter Build Documentation](https://flutter.dev/docs/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)

## Security Notes

**NEVER commit these files to version control:**
- `android/key.properties` - Contains sensitive passwords
- `*.jks` or `*.keystore` - Your signing key
- Any file containing passwords or secrets

These files are already excluded in `.gitignore`, but be careful when sharing your project.

**Always:**
- Keep backups of your keystore file
- Store passwords securely (consider using a password manager)
- Use different keystores for different apps
- Never share your keystore or passwords with anyone
