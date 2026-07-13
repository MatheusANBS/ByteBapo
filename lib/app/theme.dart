import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const cyan = Color(0xFF20D9F5);
  const background = Color(0xFF091015);
  const surface = Color(0xFF141D25);
  final scheme = ColorScheme.fromSeed(
    seedColor: cyan,
    brightness: Brightness.dark,
    surface: surface,
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    visualDensity: VisualDensity.compact,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 76,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 27,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    listTileTheme: const ListTileThemeData(
      dense: true,
      minLeadingWidth: 28,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 92,
      backgroundColor: Color(0xFF111B23),
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      iconTheme: WidgetStatePropertyAll(IconThemeData(size: 29)),
    ),
  );
}
