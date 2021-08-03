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
        builder: (context, AsyncSnapshot<Search> searchData) {
          if (searchData.connectionState == ConnectionState.done) {
            return Container(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 256 / 375,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: searchData.data!.results.length,
                itemBuilder: (BuildContext context, index) {
                  return SearchResultHolder(
                    token: token,
                    title: searchData
                        .data!.results[index].data.attributes.title.en,
                    mangaID: searchData.data!.results[index].data.id,
                    baseUrl: 'https://uploads.mangadex.org',
                  );
                },
              ),
            );
          } else {
            return Container(
              child: LinearProgressIndicator(),
              height: 100,
              width: 100,
            );
          }
        });
  }
}
