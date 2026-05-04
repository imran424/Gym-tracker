import 'package:flutter/material.dart';

const kBg          = Color(0xFF0C0C0C);
const kSurface     = Color(0xFF181818);
const kSurface2    = Color(0xFF222222);
const kBorder      = Color(0xFF2E2E2E);
const kGreen       = Color(0xFF4ADE80);
const kGreenDim    = Color(0xFF0D2E1A);
const kTextPrimary = Color(0xFFE8E8E8);
const kTextMuted   = Color(0xFF555555);

class AppTheme {
  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(
          primary: kGreen,
          surface: kSurface,
          onSurface: kTextPrimary,
        ),
        cardColor: kSurface,
        dividerColor: kBorder,
        fontFamily: 'sans-serif',
        appBarTheme: const AppBarTheme(
          backgroundColor: kSurface,
          foregroundColor: kTextPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: kTextPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: kSurface,
          selectedItemColor: kGreen,
          unselectedItemColor: kTextMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurface2,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kGreen),
          ),
          hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kGreen,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kGreen),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kGreen,
          foregroundColor: Colors.black,
          elevation: 2,
        ),
        listTileTheme: const ListTileThemeData(
          textColor: kTextPrimary,
          iconColor: kTextMuted,
        ),
        iconTheme: const IconThemeData(color: kTextMuted),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: kTextPrimary),
          bodyMedium: TextStyle(color: kTextPrimary),
          bodySmall: TextStyle(color: kTextMuted),
        ),
        useMaterial3: true,
      );
}
