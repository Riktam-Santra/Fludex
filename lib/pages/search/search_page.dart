import 'package:flutter/material.dart';
import 'package:mangadex_library/models/login/Login.dart';
import 'widgets/search_reply_widget.dart';

class SearchPage extends StatefulWidget {
  final Token? token;
  final bool dataSaver;
  SearchPage({required this.token, required this.dataSaver});
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
        title: Text('Search for a manga'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                      ),
                      Container(
                        decoration: BoxDecoration(),
                        width: 500,
                        height: 50,
                        child: TextField(
                          decoration: InputDecoration(
                              hintText: "Search for a manga..."),
                          textAlign: TextAlign.center,
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
                          onEditingComplete: () {
                            setState(
                              () {
                                hasTyped = true;
                              },
                            );
                          },
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
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(20),
                  child: hasTyped
                      ? SearchReplyScreen(
                          searchQuery: searchValue,
                          token: widget.token,
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
