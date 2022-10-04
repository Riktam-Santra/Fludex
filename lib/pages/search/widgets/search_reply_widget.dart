import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadexServerException.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/models/login/Login.dart';
import 'package:mangadex_library/models/search/Search.dart';
import 'search_result_holder_widget.dart';

class SearchReplyScreen extends StatefulWidget {
  final bool dataSaver;
  final String searchQuery;
  SearchReplyScreen({required this.searchQuery, required this.dataSaver});
  _SearchReplyScreen createState() => _SearchReplyScreen();
}

class _SearchReplyScreen extends State<SearchReplyScreen> {
  late Future<Search> searchData;

  @override
  void initState() {
    searchData = _search(query: widget.searchQuery);
    super.initState();
  }

  Future<Search> _search({required String query}) async {
    try {
      var data = await lib.search(query: query);
      return data;
    } on MangadexServerException catch (e) {
      return Future.error(
          "Mangadex server exception: ${e.info.errors.toString()}");
    } on SocketException {
      return Future.error("Unable to connect to the internet");
    }
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: searchData,
      builder: (context, AsyncSnapshot<Search> searchData) {
        if (searchData.connectionState == ConnectionState.done) {
          if (searchData.hasError) {
            return Container(
              child: Center(
                child: Text(
                  'Something went wrong :\'(',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            );
          } else if (searchData.data == null) {
            return Container(
              child: Center(
                child: Text(
                  'Manga not found :(',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            );
          } else {
            var tags = <String>[];
            return Container(
              child: searchData.data!.data.length != 0
                  ? GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisExtent: 300,
                        crossAxisCount: 2,
                      ),
                      itemCount: searchData.data!.data.length,
                      itemBuilder: (BuildContext context, index) {
                        tags = [];
                        for (int i = 0;
                            i <
                                searchData
                                    .data!.data[index].attributes.tags.length;
                            i++) {
                          tags.add(searchData.data!.data[index].attributes
                              .tags[i].attributes.name.en);
                        }
                        return SearchResultHolder(
                          mangaData: searchData.data!.data[index],
                          dataSaver: widget.dataSaver,
                        );
                      },
                    )
                  : Center(
                      child: Text("Nothing found :D"),
                    ),
            );
          }
        } else {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
                height: 30,
              ),
            ),
          );
        }
      },
    );
  }
}
