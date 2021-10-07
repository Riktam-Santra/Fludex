import 'utils.dart';
import 'package:flutter/material.dart';
import 'login/login.dart';

void main() {
  runApp(MainPage());
}

class MainPage extends StatefulWidget {
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void initState() {
    super.initState();
  }

  FludexUtils utils = FludexUtils();
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fludex",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 18, 18, 18),
        body: Container(child: UserLogin()),
      ),
    );
  }
}
