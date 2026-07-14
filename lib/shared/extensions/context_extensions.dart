import 'package:flutter/material.dart';
import '../../config/themes/colors.dart';

extension ContextExtensions on BuildContext {
  /// Get the theme
  ThemeData get theme => Theme.of(this);

  /// Get the text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get the color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if device is tablet
  bool get isTablet => screenWidth >= 600;

  /// Check if device is phone
  bool get isPhone => screenWidth < 600;

  /// Get padding from MediaQuery
  EdgeInsets get padding => MediaQuery.of(this).padding;

  /// Get safe area insets
  EdgeInsets get safeAreaInsets => MediaQuery.of(this).padding;

  /// Show a snackbar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? AppColors.textLight),
        ),
        backgroundColor: backgroundColor ?? AppColors.primary,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Show an error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: AppColors.error,
      textColor: AppColors.textLight,
    );
  }

  /// Show a success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: AppColors.success,
      textColor: AppColors.textLight,
    );
  }

  /// Navigate to a route
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(
      this,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and replace current route
  Future<T?> navigateToReplacement<T>(String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, Object?>(
      this,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and remove all previous routes
  Future<T?> navigateToAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      this,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Go back
  void goBack<T>([T? result]) {
    Navigator.pop(this, result);
  }

  /// Check if can go back
  bool canGoBack() {
    return Navigator.canPop(this);
  }
}

