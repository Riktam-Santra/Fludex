import 'package:flutter/material.dart';

class Constants {
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
}
