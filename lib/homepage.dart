import 'package:flutter/material.dart';
import 'searchReplyScreen.dart';

class HomePage extends StatefulWidget {
  final String token;
  HomePage({required this.token});
  _HomePageState createState() => _HomePageState(token);
}

class _HomePageState extends State<HomePage> {
  final String token;
  _HomePageState(this.token);
  bool hasTyped = false;
  String searchValue = '';
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Container(
              color: Colors.redAccent,
              height: 100,
            ),
            SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    SizedBox(
                      height: 125,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(blurRadius: 0.1, spreadRadius: 0.1)
                              ]),
                          width: 500,
                          height: 50,
                          child: TextField(
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                hintText: 'Search for some manga...'),
                            onChanged: ((v) async {
                              setState(() {
                                searchValue = v;
                                if (v.isEmpty || v == '') {
                                  hasTyped = false;
                                } else {
                                  print(hasTyped);
                                  searchValue = v;
                                }
                              });
                            }),
                          ),
                        ),
                        Container(
                          height: 50,
                          color: Colors.redAccent,
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  hasTyped = true;
                                  print('search value: $searchValue');
                                  print(hasTyped);
                                });
                              },
                              icon: Icon(Icons.search)),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(20),
                      child: hasTyped
                          ? SearchReplyScreen(
                              searchQuery: searchValue,
                              token: token,
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
