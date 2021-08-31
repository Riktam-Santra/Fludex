import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'search/searchReplyScreen.dart';

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
  bool dataPresent = false;

  TextEditingController _controller = TextEditingController();

  void initState() {
    super.initState();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      body: Container(
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(200, 18, 18, 18),
                        boxShadow: [
                          BoxShadow(blurRadius: 0.1, spreadRadius: 0.1)
                        ],
                      ),
                      width: 500,
                      height: 50,
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            hintText: 'Search for some manga...',
                            hintStyle: TextStyle(color: Colors.white)),
                        onChanged: ((v) async {
                          setState(
                            () {
                              hasTyped = false;
                              _controller.value = TextEditingValue(text: v);
                              searchValue = v;
                              if (v.isEmpty || v == '') {
                                hasTyped = false;
                              } else {
                                print(hasTyped);
                                searchValue = v;
                              }
                            },
                          );
                        }),
                      ),
                    ),
                    Container(
                      height: 50,
                      child: IconButton(
                        onPressed: () {
                          setState(
                            () {
                              hasTyped = true;
                            },
                          );
                        },
                        icon: Icon(Icons.search),
                        color: Colors.white,
                      ),
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
      ),
    );
  }
}
