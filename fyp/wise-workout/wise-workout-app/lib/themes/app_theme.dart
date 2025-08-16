import 'package:flutter/material.dart';

class AppTheme {
  // light theme
  static const Color lightBackground = Color(0xFFF5EFE4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color gold = Color(0xFFFFC62B);
  static const Color navy = Color(0xFF181F48);
  static const Color darkText = Color(0xFF141414);
  static const Color lightSoftPurple = Color(0xFFDED6F9);
  static const Color lavender = Color(0xFFB7B6F7);
  static const Color accentRed = Color(0xFFF83E3E);
  static const Color homeGreen = Color(0xFF87DEB0);
  static const Color gray = Color(0xFFB3B3BE);

  // dark theme
  static const Color darkBackground = Color(0xFF16151B);
  static const Color darkSurface = Color(0xFF23213A);
  static const Color darkSoftPurple = Color(0xFF353351);
  static const Color darkTextColor = Color(0xFFE7E6F6);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: navy,
    cardColor: lightSurface,
    hintColor: gray,
    disabledColor: gray,
    textSelectionTheme: const TextSelectionThemeData(cursorColor: navy),
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: navy,
      onPrimary: Colors.white,
      secondary: gold,
      onSecondary: darkText,
      background: lightBackground,
      onBackground: darkText,
      surface: lightSurface,
      onSurface: darkText,
      error: accentRed,
      onError: Colors.white,
      tertiary: lavender,
      onTertiary: navy,
      surfaceVariant: lightSoftPurple,
      outline: gray,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: darkText,
      elevation: 0,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: darkText),
      iconTheme: IconThemeData(color: darkText),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: darkText),
      bodyMedium: TextStyle(fontSize: 16, color: darkText),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: darkText),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: darkText,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: navy,
        side: const BorderSide(color: navy),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
      hintStyle: const TextStyle(color: gray),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        color: lightSoftPurple,
        borderRadius: BorderRadius.circular(12),
      ),
      labelColor: navy,
      unselectedLabelColor: gray,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: navy,
      unselectedItemColor: gray,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: navy,
    cardColor: darkSurface,
    hintColor: gray.withOpacity(0.7),
    disabledColor: gray.withOpacity(0.5),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: gold),
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: navy,
      onPrimary: Colors.white,
      secondary: gold,
      onSecondary: Colors.black,
      background: darkBackground,
      onBackground: darkTextColor,
      surface: darkSurface,
      onSurface: darkTextColor,
      error: accentRed,
      onError: Colors.white,
      tertiary: lavender,
      onTertiary: navy,
      surfaceVariant: darkSoftPurple,
      outline: gray.withOpacity(0.65),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkTextColor,
      elevation: 0,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: darkTextColor),
      iconTheme: IconThemeData(color: darkTextColor),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: darkTextColor),
      bodyMedium: TextStyle(fontSize: 16, color: darkTextColor),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: darkTextColor),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: darkTextColor,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: navy,
        side: const BorderSide(color: navy),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
      hintStyle: TextStyle(color: gray.withOpacity(0.7)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        color: darkSoftPurple,
        borderRadius: BorderRadius.circular(12),
      ),
      labelColor: gold,
      unselectedLabelColor: gray.withOpacity(0.6),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: gold,
      unselectedItemColor: gray.withOpacity(0.7),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );
}