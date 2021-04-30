import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Color(0xff1f655d),
    accentColor: Color(0xff40bf7a),
    textTheme: TextTheme(
        title: TextStyle(color: Color(0xff40bf7a)),
        subtitle: TextStyle(color: Colors.white),
        subhead: TextStyle(color: Color(0xff40bf7a))),
    appBarTheme: AppBarTheme(color: Color(0xff1f655d)));

    ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: Color(0xfff5f5f5),
    accentColor: Color(0xff40bf7a),
    textTheme: TextTheme(
        title: TextStyle(color: Colors.black54),
        subtitle: TextStyle(color: Colors.grey),
        subhead: TextStyle(color: Colors.white)),
    appBarTheme: AppBarTheme(
        color: Color(0xff1f655d),
        actionsIconTheme: IconThemeData(color: Colors.white)));


enum ThemeType { Light, Dark }

class ThemeModel extends ChangeNotifier {
  ThemeData currentTheme = darkTheme;
  ThemeType _themeType = ThemeType.Dark;

  toggleTheme() {
    if (_themeType == ThemeType.Dark) {
      currentTheme = lightTheme;
      _themeType = ThemeType.Light;
      return notifyListeners();
    }

    if (_themeType == ThemeType.Light) {
      currentTheme = darkTheme;
      _themeType = ThemeType.Dark;
      return notifyListeners();
    }
  }
}