import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/search/Search.dart';
import 'searchResultHolder.dart';

class SearchReplyScreen extends StatefulWidget {
  final String searchQuery;
  final String token;
  SearchReplyScreen({required this.searchQuery, required this.token});
  _SearchReplyScreen createState() => _SearchReplyScreen(searchQuery, token);
}

class _SearchReplyScreen extends State<SearchReplyScreen> {
  final String searchQuery;
  final String token;
  _SearchReplyScreen(this.searchQuery, this.token);
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: lib.search(searchQuery),
      builder: (context, AsyncSnapshot<Search?> searchData) {
        if (searchData.connectionState == ConnectionState.done) {
          if (searchData.data == null) {
            print(searchData.data);
            return Container(
              child: Center(
                child: Text(
                  'Manga not found :(',
                  style: TextStyle(color: Colors.grey[400], fontSize: 20),
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
                    itemCount: searchData.data!.results.length,
                    itemBuilder: (BuildContext context, index) {
                      for (int i = 0;
                          i <
                              searchData.data!.results[index].data.attributes
                                  .tags.length;
                          i++) {
                        tags.add(searchData.data!.results[index].data.attributes
                            .tags[i].attributes.name.en);
                      }
                      return SearchResultHolder(
                        token: token,
                        description: searchData.data!.results[index].data
                            .attributes.description.en,
                        title: searchData
                            .data!.results[index].data.attributes.title.en,
                        mangaID: searchData.data!.results[index].data.id,
                        baseUrl: 'https://uploads.mangadex.org',
                        tags: tags,
                      );
                    }));
          }
        } else {
          return Container(
            child: LinearProgressIndicator(),
            height: 100,
            width: 100,
          );
        }
      },
    );
  }
}
