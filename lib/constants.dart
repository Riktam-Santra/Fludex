import 'package:flutter/material.dart';

class Constants {
  final TextStyle normalTextStyle = TextStyle(color: Colors.white);
  InputDecoration loginInputDecoration(String hintText) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: Colors.white),
      ),
      hintText: "$hintText",
      hintStyle: TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }

  ThemeData _appThemeData(bool dartMode) {
    return ThemeData(
      // Define the default brightness and colors.
      brightness: Brightness.dark,
      primaryColor: Colors.lightBlue[800],

      // Define the default font family.
      fontFamily: 'Georgia',

      // Define the default `TextTheme`. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      textTheme: const TextTheme(
        headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
        bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
      ),
    );
  }
}
