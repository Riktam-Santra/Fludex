import 'package:cached_network_image/cached_network_image.dart';
import 'package:fludex/mangaReader/aboutManga.dart';
import 'package:fludex/utils.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/models/cover/Cover.dart';

class SearchResultHolder extends StatefulWidget {
  final bool dataSaver;
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
      {required this.baseUrl,
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
  late bool lightMode;
  Widget build(BuildContext context) {
    lightMode = Theme.of(context).brightness == Brightness.light;
    return LayoutBuilder(builder: (context, constraints) {
      return FutureBuilder(
        future: lib.getCoverArtUrl(widget.mangaId, res: 256),
        builder: (context, AsyncSnapshot<String?> coverUrl) {
          if (coverUrl.connectionState == ConnectionState.done) {
            if (coverUrl.data != null) {
              List<Widget> tagWidgets = <Widget>[];
              var requiredTagList = widget.tags.take(4);
              for (int i = 0; i < requiredTagList.length; i++) {
                tagWidgets.add(
                  Container(
                    decoration: BoxDecoration(
                      color: lightMode
                          ? Colors.white
                          : Color.fromARGB(150, 18, 18, 18),
                      border:
                          lightMode ? Border.all(color: Colors.black) : null,
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
                        color: lightMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              }
              if (hasPressed == false) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    child: InkWell(
                      child: Card(
                        elevation: 1,
                        child: (constraints.maxWidth < 427)
                            ? Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(coverUrl.data!),
                                  ),
                                ),
                                height: 200,
                                //alignment: Alignment.centerLeft,
                                // CachedNetworkImage(
                                //   imageUrl: coverUrl.data!,
                                //   fit: BoxFit.contain,
                                //   placeholder:
                                //       (BuildContext context, url) => Center(
                                //     child: Container(
                                //       height: 100,
                                //       width: 100,
                                //       child: CircularProgressIndicator(),
                                //     ),
                                //   ),
                                // ),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                Colors.black,
                                                Colors.transparent
                                              ],
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter)),
                                          height: 40,
                                          child: Center(
                                            child: Text(
                                              widget.title,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: CachedNetworkImage(
                                      imageUrl: coverUrl.data!,
                                      placeholder:
                                          (BuildContext context, url) => Center(
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              widget.title,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                fontSize: 21,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Container(
                                              child: LimitedBox(
                                                maxWidth: 500,
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
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
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 4,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                FludexUtils.statusContainer(
                                                    widget.status, lightMode),
                                                FludexUtils
                                                    .demographicContainer(
                                                        widget.demographic,
                                                        lightMode),
                                                FludexUtils.ratingContainer(
                                                    widget.rating, lightMode),
                                              ],
                                            ),
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
                        try {
                          if (chapterData != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AboutManga(
                                  mangaId: widget.mangaId,
                                  token: widget.token,
                                  dataSaver: widget.dataSaver,
                                  totalChapters: chapterData.total,
                                  lightMode: lightMode,
                                ),
                              ),
                            );
                          }
                          setState(() {
                            hasPressed = false;
                          });
                        } catch (e) {
                          print(e.toString());
                          setState(() {
                            hasPressed = false;
                          });
                          showBanner();
                        }
                      },
                    ),
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            } else {
              return Container(
                child: Center(
                  child: Text(
                    'Couldn\'t load data :(',
                    style: TextStyle(fontSize: 18),
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
    });
  }

  void showBanner() => ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
              'Something went wrong, make sure you are connected to the internet.'),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: Text('Dismiss'),
              style: TextButton.styleFrom(),
            )
          ],
        ),
      );
}
