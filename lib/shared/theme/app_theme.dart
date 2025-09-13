import 'package:flutter/material.dart';

/// Application theme constants and styling
///
/// Centralizes all colors, text styles, and design tokens used throughout the app.
/// This ensures consistent branding and easier maintenance.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Ibis Styles brand colors
  static const Color ibisRed = Color(0xFFE63946);
  static const Color ibisBlue = Color(0xFF1E3A8A);
  static const Color ibisGray = Color(0xFFF8FAFC);
  static const Color ibisWhite = Colors.white;
  static const Color ibisGreen = Color(0xFF10B981);

  /// Additional semantic colors
  static const Color primaryColor = ibisBlue;
  static const Color accentColor = ibisRed;
  static const Color backgroundColor = ibisGray;
  static const Color surfaceColor = ibisWhite;
  static const Color successColor = ibisGreen;
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = ibisRed;

  /// Text colors
  static const Color primaryTextColor = Color(0xFF1F2937);
  static const Color secondaryTextColor = Color(0xFF6B7280);
  static const Color onPrimaryTextColor = ibisWhite;

  /// Common design tokens
  static const double borderRadius = 15.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 20.0;

  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;

  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;

  /// Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);

  /// Text styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: primaryTextColor,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: primaryTextColor,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: secondaryTextColor,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: secondaryTextColor,
  );

  /// Button styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: onPrimaryTextColor,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    elevation: 3,
  );

  static ButtonStyle get accentButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: accentColor,
    foregroundColor: onPrimaryTextColor,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    elevation: 3,
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: Colors.grey.shade100,
    foregroundColor: primaryTextColor,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    elevation: 1,
  );

  /// Card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );

  /// Gradient decorations
  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ibisBlue, ibisRed],
    ),
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: ibisBlue.withOpacity(0.3),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static BoxDecoration get successGradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        successColor.withOpacity(0.1),
        successColor.withOpacity(0.2),
      ],
    ),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: successColor.withOpacity(0.3)),
  );

  /// Input decoration theme
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: surfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: const BorderSide(color: errorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: const BorderSide(color: errorColor, width: 2),
    ),
  );

  /// App bar theme
  static AppBarTheme get appBarTheme => const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: onPrimaryTextColor,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: onPrimaryTextColor,
    ),
  );

  /// Complete theme data
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    appBarTheme: appBarTheme,
    inputDecorationTheme: inputDecorationTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 2,
    ),
    fontFamily: 'Roboto', // Can be customized based on brand requirements
  );
}

/// Helper class for creating consistent spacing
class AppSpacing {
  static const SizedBox xs = SizedBox(height: 4, width: 4);
  static const SizedBox sm = SizedBox(height: 8, width: 8);
  static const SizedBox md = SizedBox(height: 16, width: 16);
  static const SizedBox lg = SizedBox(height: 24, width: 24);
  static const SizedBox xl = SizedBox(height: 32, width: 32);

  static const EdgeInsets paddingXs = EdgeInsets.all(4);
  static const EdgeInsets paddingSm = EdgeInsets.all(8);
  static const EdgeInsets paddingMd = EdgeInsets.all(16);
  static const EdgeInsets paddingLg = EdgeInsets.all(24);
  static const EdgeInsets paddingXl = EdgeInsets.all(32);

  static const EdgeInsets horizontalPaddingSm = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets horizontalPaddingMd = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets horizontalPaddingLg = EdgeInsets.symmetric(horizontal: 24);

  static const EdgeInsets verticalPaddingSm = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets verticalPaddingMd = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets verticalPaddingLg = EdgeInsets.symmetric(vertical: 24);
}