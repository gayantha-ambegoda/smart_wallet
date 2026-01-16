# Android Build Configuration

## App Signing for Release

This directory contains the configuration for signing the Android release build.

### Quick Setup

1. **Create a keystore** (if you don't have one):
   ```bash
   keytool -genkey -v -keystore smartwallet-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias smartwallet
   ```

2. **Create key.properties** from the example:
   ```bash
   copy key.properties.example key.properties
   ```

3. **Edit key.properties** with your keystore details:
   - `storePassword`: Your keystore password
   - `keyPassword`: Your key password
   - `keyAlias`: Your key alias (e.g., "smartwallet")
   - `storeFile`: Path to your .jks file (use forward slashes)

4. **Build the signed AAB**:
   - Run `build-aab.bat` from the project root
   - Or use: `flutter build appbundle --release`

### Security

**NEVER commit these files:**
- `key.properties` - Contains passwords
- `*.jks` or `*.keystore` - Your signing key

These are already excluded in `.gitignore`.

### More Information

See [BUILD_GUIDE.md](../BUILD_GUIDE.md) in the project root for complete instructions.
