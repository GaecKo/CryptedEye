import 'package:flutter/material.dart';
import '../../controller.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _themeData;
  late String mode;
  final Controller ctr;

  ThemeProvider({required this.ctr}) {
    if (ctr.getSettingTheme() == "Light") {
      mode = "Light";
      setLightMode();
    } else {
      mode = "Dark";
      setDarkMode();
    }
  }

  /// ----- DARK MODE -----
  void setDarkMode() {
    const primaryColor = Colors.blue;
    _themeData = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        surface: Color(0xFF121212),
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.blue.withOpacity(0.2),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: primaryColor.withOpacity(0.3),
        selectionHandleColor: primaryColor,
      ),
    );

    mode = "Dark";
    notifyListeners();
    if (ctr.initialized) ctr.setSettingTheme(mode);
  }

  /// ----- LIGHT MODE -----
  void setLightMode() {
    const primaryColor = Colors.blue;
    _themeData = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shadowColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.blue.withOpacity(0.1),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: primaryColor.withOpacity(0.3),
        selectionHandleColor: primaryColor,
      ),
    );

    mode = "Light";
    notifyListeners();
    if (ctr.initialized) ctr.setSettingTheme(mode);
  }

  ThemeData get themeData => _themeData;

  void setThemeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}
