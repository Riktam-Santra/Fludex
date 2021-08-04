import 'package:flutter/material.dart';
import 'login/Login.dart';

void main() {
  runApp(MainPage());
}

class MainPage extends StatefulWidget {
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: Login(),
        ),
      ),
    );
  }
}
