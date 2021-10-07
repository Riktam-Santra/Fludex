import 'package:cached_network_image/cached_network_image.dart';
import 'package:fludex/mangaReader/aboutManga.dart';
import 'package:fludex/utils.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/models/cover/Cover.dart';

class SearchResultHolder extends StatefulWidget {
  final bool dataSaver;
  final bool lightMode;
  final String token;
  final String mangaId;
  final String baseUrl;
  final String title;
  final String status;
  final String description;
  final List<String> tags;
  final String demographic;
  final String rating;
  SearchResultHolder(
      {required this.lightMode,
      required this.baseUrl,
      required this.mangaId,
      required this.title,
      required this.status,
      required this.token,
      required this.description,
      required this.tags,
      required this.demographic,
      required this.rating,
      required this.dataSaver});
  _SearchResultHolder createState() => _SearchResultHolder();
}

class _SearchResultHolder extends State<SearchResultHolder> {
  bool hasPressed = false;

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: lib.getCoverArt(widget.mangaId),
      builder: (context, AsyncSnapshot<Cover?> cover) {
        if (cover.connectionState == ConnectionState.done) {
          if (cover.data != null) {
            var coverFileName = cover.data!.data[0].attributes.fileName;
            List<Widget> tagWidgets = <Widget>[];
            var requiredTagList = widget.tags.take(4);
            for (int i = 0; i < requiredTagList.length; i++) {
              tagWidgets.add(
                Container(
                  decoration: widget.lightMode
                      ? BoxDecoration(
                          color: Colors.white,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(5))
                      : BoxDecoration(
                          color: Color.fromARGB(150, 18, 18, 18),
                          borderRadius: BorderRadius.circular(5),
                        ),
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Text(
                    widget.tags[i],
                    style: TextStyle(
                      color: widget.lightMode ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              );
            }
            if (hasPressed == false) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: widget.lightMode
                      ? BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5,
                              spreadRadius: 0.2,
                              offset: Offset(1, 1),
                            )
                          ],
                        )
                      : BoxDecoration(
                          color: Color.fromARGB(255, 18, 18, 18),
                          boxShadow: [BoxShadow(color: Colors.grey)]),
                  child: InkWell(
                    child: Container(
                      color: Color.fromARGB(18, 255, 255, 255),
                      child: Row(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${widget.baseUrl}/covers/${widget.mangaId}/$coverFileName',
                              placeholder: (BuildContext context, url) =>
                                  Center(
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  child: CircularProgressIndicator(
                                    color: widget.lightMode
                                        ? Color.fromARGB(255, 255, 103, 64)
                                        : Colors.white,
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
                                      widget.title,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: widget.lightMode
                                              ? Colors.black
                                              : Colors.white),
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
                                  Container(
                                    child: Text(
                                      widget.description,
                                      style: TextStyle(color: Colors.grey[400]),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      FludexUtils.statusContainer(
                                          widget.status, widget.lightMode),
                                      FludexUtils.demographicContainer(
                                          widget.demographic, widget.lightMode),
                                      FludexUtils.ratingContainer(
                                          widget.rating, widget.lightMode),
                                    ],
                                  )
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
                      var chapterData = await lib.getChapters(widget.mangaId);
                      if (chapterData != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutManga(
                              mangaId: widget.mangaId,
                              token: widget.token,
                              lightMode: widget.lightMode,
                              dataSaver: widget.dataSaver,
                            ),
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
                  color: widget.lightMode
                      ? Color.fromARGB(255, 255, 103, 64)
                      : Colors.white,
                ),
              );
            }
          } else {
            return Container(
              child: Center(
                child: Text(
                  'Couldn\'t load data :(',
                  style: TextStyle(
                      color: widget.lightMode ? Colors.black : Colors.white,
                      fontSize: 18),
                ),
              ),
            );
          }
        } else {
          return Center(
            child: Container(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  color: widget.lightMode
                      ? Color.fromARGB(255, 255, 103, 64)
                      : Colors.white,
                )),
          );
        }
      },
    );
  }
}
