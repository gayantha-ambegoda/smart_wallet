/// Application-wide constants
class AppConstants {
  /// Maximum length for account name display before truncation
  static const int maxAccountNameLength = 15;
}

/// Helper class for string utilities
class StringUtils {
  /// Truncates a string to a maximum length and adds ellipsis if truncated
  static String truncateAccountName(String name) {
    if (name.length > AppConstants.maxAccountNameLength) {
      return '${name.substring(0, AppConstants.maxAccountNameLength)}...';
    }
    return name;
  }
}
