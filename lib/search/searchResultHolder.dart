import 'package:cached_network_image/cached_network_image.dart';
import 'package:fludex/mangaReader/aboutManga.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/models/cover/Cover.dart';

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

  bool hasPressed = false;

  _SearchResultHolder(this.mangaId, this.title, this.baseUrl, this.token,
      this.description, this.tags);
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: lib.getCoverArt(mangaId),
      builder: (context, AsyncSnapshot<Cover?> cover) {
        if (cover.connectionState == ConnectionState.done) {
          if (cover.data != null) {
            var coverFileName = cover.data!.data[0].attributes.fileName;
            List<Widget> tagWidgets = <Widget>[];
            for (int i = 0; i < tags.length; i++) {
              tagWidgets.add(Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                color: Color.fromARGB(150, 18, 18, 18),
                child: Text(
                  tags[i],
                  style: TextStyle(color: Colors.white),
                ),
              ));
            }
            if (hasPressed == false) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 18, 18, 18),
                      boxShadow: [BoxShadow(color: Colors.grey)]),
                  child: InkWell(
                    child: Container(
                      color: Color.fromARGB(255, 18, 18, 18),
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
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      title,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          fontSize: 17, color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5),
                                    child: Container(
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
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        description,
                                        style:
                                            TextStyle(color: Colors.grey[400]),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      setState(() {
                        hasPressed = true;
                      });
                      var chapterData = await lib.getChapters(mangaId);
                      if (chapterData != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AboutManga(mangaId: mangaId, token: token),
                          ),
                        );
                      }
                      setState(() {
                        hasPressed = false;
                      });
                    },
                  ),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
          } else {
            return Container(
              child: Center(
                child: Text(
                  'Couldn\'t load data :(',
                  style: TextStyle(color: Colors.white, fontSize: 18),
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
