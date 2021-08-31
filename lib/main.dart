import 'dart:io';

import 'package:fludex/homepage.dart';
import 'utils.dart';
import 'package:flutter/material.dart';
import 'login/Login.dart';

void main() {
  runApp(MainPage());
}

class MainPage extends StatefulWidget {
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<String> getToken;
  void initState() {
    super.initState();
    getToken = FludexUtils().getTokenIfFileExists();
  }

  FludexUtils utils = FludexUtils();
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getToken,
      builder: (BuildContext context, AsyncSnapshot<String> content) {
        if (content.hasData && content.data != '') {
          return MaterialApp(
            title: "Fludex",
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color.fromARGB(255, 18, 18, 18),
              body: Container(
                child: HomePage(token: content.data ?? ''),
              ),
            ),
          );
        } else if (content.hasError) {
          return MaterialApp(
            title: 'Fludex',
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color.fromARGB(255, 18, 18, 18),
              body: Container(
                child: Login(),
              ),
            ),
          );
        } else {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Color.fromARGB(255, 18, 18, 18),
              body: Container(
                child: Login(),
              ),
            ),
          );
        }
      },
    );
  }
}
