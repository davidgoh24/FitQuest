import 'package:flutter/material.dart';

final ThemeData christmasTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFB71C1C),    // Christmas Red
    secondary: Color(0xFF388E3C),  // Christmas Green
    background: Color(0xFFF8E1E1), // Soft snow-like pinkish white
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black,
    onSurface: Colors.black,
    error: Colors.red,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Color(0xFFF8E1E1),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFB71C1C),
    foregroundColor: Colors.white,
  ),
  iconTheme: const IconThemeData(color: Color(0xFF388E3C)),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF388E3C),
    foregroundColor: Colors.white,
  ),
  cardColor: Colors.white,
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB71C1C)),
    bodyLarge: TextStyle(color: Colors.black),
  ),
);