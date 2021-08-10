import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'mangaReader/readManga.dart';
import 'package:mangadex_library/cover/Cover.dart';

class SearchResultHolder extends StatefulWidget {
  final String token;
  final String mangaID;
  final String baseUrl;
  final String title;
  final String description;
  final List<String> tags;
  SearchResultHolder(
      {required this.baseUrl,
      required this.mangaID,
      required this.title,
      required this.token,
      required this.description,
      required this.tags});
  _SearchResultHolder createState() =>
      _SearchResultHolder(mangaID, title, baseUrl, token, description, tags);
}

class _SearchResultHolder extends State<SearchResultHolder> {
  final String mangaId;
  final String baseUrl;
  final String title;
  final String token;
  final String description;
  final List<String> tags;

  _SearchResultHolder(this.mangaId, this.title, this.baseUrl, this.token,
      this.description, this.tags);
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: lib.getCoverArt(mangaId),
      builder: (context, AsyncSnapshot<Cover?> cover) {
        if (cover.connectionState == ConnectionState.done) {
          if (cover.data != null) {
            var coverFileName = cover.data!.results[0].data.attributes.fileName;
            List<Widget> tagWidgets = <Widget>[];
            for (int i = 0; i < tags.length; i++) {
              tagWidgets.add(Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                color: Colors.grey[400],
                child: Text(
                  tags[i],
                  style: TextStyle(color: Colors.white),
                ),
              ));
            }
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.grey)]),
                  child: InkWell(
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: CachedNetworkImage(
                              imageUrl:
                                  '$baseUrl/covers/$mangaId/$coverFileName',
                              placeholder: (BuildContext context, url) =>
                                  Center(
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  child: CircularProgressIndicator(
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(fontSize: 17),
                                ),
                                Container(
                                  child: LimitedBox(
                                    maxWidth: 500,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: tagWidgets,
                                      ),
                                    ),
                                  ),
                                ),
                                ClipRect(
                                  child: LimitedBox(
                                    maxWidth: 500,
                                    child: Text(
                                      description,
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      var chapterData = await lib.getChapters(mangaId);
                      if (chapterData != null) {
                        var chapterId = chapterData.result[0].data.id;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MangaReader(
                              token: token,
                              chapterId: chapterId,
                              mangaId: mangaId,
                            ),
                          ),
                        );
                      }
                    },
                  )),
            );
          } else {
            return Container(
              child: Center(
                child: Text(
                  'Couldn\'t load data :(',
                  style: TextStyle(color: Colors.grey[400], fontSize: 18),
                ),
              ),
            );
          }
        } else {
          return Center(
            child: Container(
                height: 100, width: 100, child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
