import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/models/search/Search.dart';
import 'searchResultHolder.dart';

class SearchReplyScreen extends StatefulWidget {
  final bool dataSaver;
  final String searchQuery;
  final String token;
  SearchReplyScreen(
      {required this.searchQuery,
      required this.token,
      required this.dataSaver});
  _SearchReplyScreen createState() => _SearchReplyScreen(searchQuery, token);
}

class _SearchReplyScreen extends State<SearchReplyScreen> {
  final String searchQuery;
  final String token;
  _SearchReplyScreen(this.searchQuery, this.token);
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: lib.search(query: searchQuery),
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
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: 300,
                  crossAxisCount: 2,
                ),
                itemCount: searchData.data!.data.length,
                itemBuilder: (BuildContext context, index) {
                  tags = [];
                  for (int i = 0;
                      i < searchData.data!.data[index].attributes.tags.length;
                      i++) {
                    tags.add(searchData.data!.data[index].attributes.tags[i]
                        .attributes.name.en);
                  }
                  return SearchResultHolder(
                    token: token,
                    mangaData: searchData.data!.data[index],
                    dataSaver: widget.dataSaver,
                  );
                },
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
