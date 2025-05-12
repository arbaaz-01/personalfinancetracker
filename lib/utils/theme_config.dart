import 'package:flutter/material.dart';

class ThemeConfig {
  // Primary color palette
  static const Color primaryColor = Color(0xFF536DFE);
  static const Color secondaryColor = Color(0xFF42A5F5);
  static const Color accentColor = Color(0xFF03A9F4);

  // Background colors
  static const Color scaffoldLightColor = Color(0xFFF8F9FA);
  static const Color scaffoldDarkColor = Color(0xFF121212);

  // Card colors
  static const Color cardLightColor = Colors.white;
  static const Color cardDarkColor = Color(0xFF1E1E1E);

  // Text colors
  static const Color textLightColor = Color(0xFF212121);
  static const Color textDarkColor = Color(0xFFF5F5F5);
  static const Color textSecondaryLightColor = Color(0xFF757575);
  static const Color textSecondaryDarkColor = Color(0xFFBDBDBD);

  // Category colors
  static const List<Color> categoryColors = [
    Color(0xFF536DFE), // Primary blue
    Color(0xFF00C853), // Green
    Color(0xFFFF6D00), // Orange
    Color(0xFFD500F9), // Purple
    Color(0xFFFFD600), // Yellow
    Color(0xFFFF1744), // Red
    Color(0xFF00B0FF), // Light blue
    Color(0xFF76FF03), // Light green
  ];

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF536DFE), // Primary blue
    Color(0xFF00C853), // Green
    Color(0xFFFF6D00), // Orange
    Color(0xFFD500F9), // Purple
    Color(0xFFFFD600), // Yellow
    Color(0xFFFF1744), // Red
    Color(0xFF00B0FF), // Light blue
    Color(0xFF76FF03), // Light green
  ];

  // Transaction colors
  static const Color incomeColor = Color(0xFF00C853);
  static const Color expenseColor = Color(0xFFFF1744);

  // Budget status colors
  static const Color budgetGoodColor = Color(0xFF00C853);
  static const Color budgetWarningColor = Color(0xFFFFD600);
  static const Color budgetDangerColor = Color(0xFFFF1744);

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardLightColor,
      background: scaffoldLightColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textLightColor,
      onBackground: textLightColor,
    ),
    scaffoldBackgroundColor: scaffoldLightColor,
    cardColor: cardLightColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryLightColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: 1,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: textLightColor),
      displayMedium: TextStyle(color: textLightColor),
      displaySmall: TextStyle(color: textLightColor),
      headlineLarge: TextStyle(color: textLightColor),
      headlineMedium: TextStyle(color: textLightColor),
      headlineSmall: TextStyle(color: textLightColor),
      titleLarge: TextStyle(color: textLightColor),
      titleMedium: TextStyle(color: textLightColor),
      titleSmall: TextStyle(color: textLightColor),
      bodyLarge: TextStyle(color: textLightColor),
      bodyMedium: TextStyle(color: textLightColor),
      bodySmall: TextStyle(color: textSecondaryLightColor),
      labelLarge: TextStyle(color: textLightColor),
      labelMedium: TextStyle(color: textLightColor),
      labelSmall: TextStyle(color: textSecondaryLightColor),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardDarkColor,
      background: scaffoldDarkColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDarkColor,
      onBackground: textDarkColor,
    ),
    scaffoldBackgroundColor: scaffoldDarkColor,
    cardColor: cardDarkColor,
    appBarTheme: AppBarTheme(
      backgroundColor: cardDarkColor,
      elevation: 0,
      iconTheme: IconThemeData(color: textDarkColor),
      titleTextStyle: TextStyle(
        color: textDarkColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardDarkColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryDarkColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade800,
      thickness: 1,
      space: 1,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: textDarkColor),
      displayMedium: TextStyle(color: textDarkColor),
      displaySmall: TextStyle(color: textDarkColor),
      headlineLarge: TextStyle(color: textDarkColor),
      headlineMedium: TextStyle(color: textDarkColor),
      headlineSmall: TextStyle(color: textDarkColor),
      titleLarge: TextStyle(color: textDarkColor),
      titleMedium: TextStyle(color: textDarkColor),
      titleSmall: TextStyle(color: textDarkColor),
      bodyLarge: TextStyle(color: textDarkColor),
      bodyMedium: TextStyle(color: textDarkColor),
      bodySmall: TextStyle(color: textSecondaryDarkColor),
      labelLarge: TextStyle(color: textDarkColor),
      labelMedium: TextStyle(color: textDarkColor),
      labelSmall: TextStyle(color: textSecondaryDarkColor),
    ),
  );
}
