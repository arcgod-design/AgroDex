import 'package:flutter/material.dart';

/// Clean extensions on [BuildContext] for easy access to theme, color scheme,
/// typography, and MediaQuery properties.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  bool get isDark => theme.brightness == Brightness.dark;

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  bool get isMobile => screenWidth < 768.0;
  bool get isTablet => screenWidth >= 768.0 && screenWidth < 1024.0;
  bool get isDesktop => screenWidth >= 1024.0;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
