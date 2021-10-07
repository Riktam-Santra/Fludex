import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'searchReplyScreen.dart';

class SearchPage extends StatefulWidget {
  final bool lightMode;
  final String token;
  final bool dataSaver;
  SearchPage(
      {required this.token, required this.lightMode, required this.dataSaver});
  _SearchPageState createState() => _SearchPageState(token);
}

class _SearchPageState extends State<SearchPage> {
  final String token;
  _SearchPageState(this.token);
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
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Search for a manga'),
      ),
      backgroundColor:
          widget.lightMode ? Colors.white : Color.fromARGB(255, 18, 18, 18),
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
                        color: widget.lightMode
                            ? Colors.white
                            : Color.fromARGB(200, 18, 18, 18),
                        boxShadow: [
                          BoxShadow(blurRadius: 0.1, spreadRadius: 0.1)
                        ],
                      ),
                      width: 500,
                      height: 50,
                      child: TextField(
                        style: TextStyle(
                            color:
                                widget.lightMode ? Colors.black : Colors.white),
                        cursorColor: Colors.white,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: widget.lightMode
                                        ? Colors.black
                                        : Colors.white)),
                            hintText: 'Search for some manga...',
                            hintStyle: TextStyle(
                                color: widget.lightMode
                                    ? Colors.black
                                    : Colors.white)),
                        onChanged: ((v) async {
                          setState(
                            () {
                              hasTyped = false;
                              _controller.value = TextEditingValue(text: v);
                              searchValue = v;
                              if (v.isEmpty || v == '') {
                                hasTyped = false;
                              } else {
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
                        color: widget.lightMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(20),
                  child: hasTyped
                      ? SearchReplyScreen(
                          lightMode: widget.lightMode,
                          searchQuery: searchValue,
                          token: token,
                          dataSaver: widget.dataSaver,
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
