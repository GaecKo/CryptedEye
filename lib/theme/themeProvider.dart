import 'package:flutter/material.dart';

import '../controller.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _themeData; // Default theme
  late String mode;
  Controller ctr;

  ThemeProvider({required this.ctr}) {
    if (ctr.getSettingTheme() == "Light") {
      mode = "Light";
      setLightMode();
    } else {
      mode = "Dark";
      setDarkMode();
    }
  }

  void setDarkMode() {
    _themeData = ThemeData(
      colorScheme: const ColorScheme.dark().copyWith(
        primary: Colors.blue,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.black,
        selectionHandleColor:
            Colors.black, // Couleur de la poignée de sélection
        selectionColor:
            Colors.black.withValues(alpha: 0.3), // Couleur de la sélection
      ),
    );
    notifyListeners();
    mode = "Dark";
    if (ctr.initialized) {
      ctr.setSettingTheme(mode);
    }
  }

  void setLightMode() {
    _themeData = ThemeData(
      colorScheme: const ColorScheme.light().copyWith(
        primary: Colors.blue,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.black,
        selectionHandleColor:
            Colors.black, // Couleur de la poignée de sélection
        selectionColor:
            Colors.black.withOpacity(0.3), // Couleur de la sélection
      ),
    );
    notifyListeners();
    mode = "Light";
    if (ctr.initialized) {
      ctr.setSettingTheme(mode);
    }
  }

  ThemeData get themeData => _themeData;

  void setThemeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}
