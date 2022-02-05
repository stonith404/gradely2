import 'package:flutter/material.dart';

// -----------
//
//Light Theme
//
//------------

final ThemeData lightTheme = ThemeData(
    textTheme: TextTheme(
        headline1: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w900,
            fontSize: 28,
            color: Colors.white)),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    //Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      primary: Colors.black,
      onPrimary: Colors.white,
    )),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
    )),
    iconTheme: IconThemeData(color: Colors.black),
    //Appbar
    appBarTheme: AppBarTheme(
      elevation: 0,
      foregroundColor: Colors.black,
      backgroundColor: Color(0xFFF2F2F7),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        fontFamily: 'PlayfairDisplay',
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    brightness: Brightness.light,

    //Colors
    primaryColorDark: Colors.black,
    primaryColorLight: Colors.white,
    dialogBackgroundColor: Color(0xFFF2F2F7),
    scaffoldBackgroundColor: Color(0xFFF2F2F7),
    backgroundColor: Colors.white);

// -----------
//
//Dark Theme
//
//------------

final ThemeData darkTheme = lightTheme.copyWith(
    textTheme: TextTheme(
        headline1: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w900,
            fontSize: 28,
            color: Colors.black)),
    textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.white),
    //Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      primary: Colors.white,
      onPrimary: Colors.black,
    )),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    )),
    iconTheme: IconThemeData(color: Colors.white),
    //Appbar
    appBarTheme: AppBarTheme(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        fontFamily: 'PlayfairDisplay',
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    brightness: Brightness.light,

    //Colors
    primaryColorDark: Colors.white,
    primaryColorLight: Colors.black,
    dialogBackgroundColor: Color(0xFF1a1a1a),
    scaffoldBackgroundColor: Color(0xFF010001),
    backgroundColor: Color(0xFF1d1c1e));
