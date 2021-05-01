import 'package:flutter/material.dart';
import '../main.dart';

List<ThemeData> getThemes() {
  return [
    ThemeData(
          appBarTheme: AppBarTheme(centerTitle: true),
          fontFamily: 'Nunito',
          brightness: Brightness.light,
          primaryColor: defaultColor,
          scaffoldBackgroundColor: Colors.grey[300],
          backgroundColor: Colors.grey[300],
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(defaultColor)),
          ),
        ),
   ThemeData(
          appBarTheme: AppBarTheme(centerTitle: true),
          backgroundColor: Colors.grey[900],
          scaffoldBackgroundColor: Colors.grey[900],
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(defaultColor)),
          ),
          brightness: Brightness.dark,
          primaryColor: defaultColor,
          floatingActionButtonTheme:
              FloatingActionButtonThemeData(backgroundColor: defaultColor),
        ),
    ThemeData(backgroundColor: Colors.purple, accentColor: Colors.green),
    ThemeData(backgroundColor: Colors.black, accentColor: Colors.red),
    ThemeData(backgroundColor: Colors.red, accentColor: Colors.blue),
  ];
}