import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:fludex/mangaReader/readManga.dart';
import 'package:fludex/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mangadex_library/src/models/chapter/ChapterData.dart' as ch;
import 'package:mangadex_library/jsonSearchCommands.dart';
import 'package:mangadex_library/mangadex_library.dart';
import 'package:mangadex_library/src/models/chapter/readChapters.dart';
import 'package:mangadex_library/src/models/common/singleMangaData.dart';
import 'package:mangadex_library/src/models/common/tags.dart';
import 'package:mangadex_library/src/models/user/user_followed_manga/manga_check.dart';

class AboutManga extends StatefulWidget {
  final bool dataSaver;
  final String token;
  final String mangaId;
  AboutManga(
      {required this.mangaId, required this.token, required this.dataSaver});
  @override
  _AboutMangaState createState() =>
      _AboutMangaState(mangaId: mangaId, token: token);
}

class _AboutMangaState extends State<AboutManga> {
  late String token;
  final String mangaId;
  _AboutMangaState({required this.mangaId, required this.token});
  int _chapterPageOffset = 0;
  int _totalChapters = 0;
  int _desiredInputChapterNumber = 0;

  Future<SingleMangaData> _getMangaData(String mangaId) async {
    try {
      var _data = await JsonUtils.getMangaDataByMangaId(mangaId);
      return _data;
    } catch (e) {
      print(e.toString());
      return await JsonUtils.getMangaDataByMangaId(mangaId);
    }
  }

  Future<String> _getCoverData(String mangaId) async {
    return await getCoverArtUrl(mangaId);
  }

  Future<ch.ChapterData?> _getChapterData(String mangaId, {int? offset}) async {
    var _offset = offset ?? 0;
    var chapters = await getChapters(mangaId, offset: _offset);
    return chapters;
  }

  String getYear(int year) {
    if (year == 0) {
      return 'N/A';
    } else {
      return year.toString();
    }
  }

  Future<bool> _mangaFollowCheck(_token, _mangaId) async {
    var data = await checkIfUserFollowsManga(_token, _mangaId);
    return data;
  }

  bool isFollowed = false;
  bool hasPressed = false;
  String buttonText = 'Add to library';
  static Container _tagContainer(String _tag, bool lightMode) {
    return Container(
      decoration: BoxDecoration(
        color: lightMode ? Colors.white : Color.fromARGB(150, 18, 18, 18),
        border: lightMode ? Border.all(color: Colors.black) : null,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Text(
        _tag,
        style: TextStyle(
          color: lightMode ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  List<Widget> tagWidgets(List<Tags> _tags, bool lightMode) {
    List<Widget> _widgets = [];
    if (_tags.length > 10) {
      for (int i = 0; i < 10; i++) {
        _widgets.add(_tagContainer(_tags[i].attributes.name.en, lightMode));
      }
    } else {
      for (int i = 0; i < _tags.length; i++) {
        _widgets.add(_tagContainer(_tags[i].attributes.name.en, lightMode));
      }
    }

    return _widgets;
  }

  @override
  Widget build(BuildContext context) {
    var brightness = Theme.of(context).brightness;
    bool appLightMode = brightness == Brightness.light;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var _mangaData = await _getMangaData(mangaId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MangaReader(
                mangaTitle: _mangaData.data.attributes.title.en,
                token: token,
                mangaId: mangaId,
                chapterNumber: 1,
                dataSaver: widget.dataSaver,
              ),
            ),
          );
        },
        label: Text(
          "Read now",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        icon: Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => DownloadManager(
        //             mangaId: mangaId,
        //           ),
        //         ),
        //       );
        //     },
        //     icon: Icon(Icons.download),
        //   ),
        // ],
      ),
      body: hasPressed
          ? Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: _getMangaData(mangaId),
              builder: (context, AsyncSnapshot<SingleMangaData> mangaData) {
                if (mangaData.connectionState == ConnectionState.done) {
                  return SingleChildScrollView(
                      child: FutureBuilder(
                          future: _getCoverData(mangaId),
                          builder: (context, AsyncSnapshot<String> data) {
                            if (data.connectionState == ConnectionState.done) {
                              return Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      data.data!,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: FutureBuilder(
                                                  future:
                                                      _getCoverData(mangaId),
                                                  builder: (context,
                                                      AsyncSnapshot<String>
                                                          cover) {
                                                    if (cover.connectionState ==
                                                        ConnectionState.done) {
                                                      return SizedBox(
                                                        height: 500,
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: cover.data!,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      );
                                                    } else {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: SizedBox(
                                                          height: 500,
                                                          width: 400,
                                                          child: Center(
                                                              child:
                                                                  CircularProgressIndicator()),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              Container(
                                                child: Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          mangaData
                                                              .data!
                                                              .data
                                                              .attributes
                                                              .title
                                                              .en,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 30),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Row(
                                                            children: tagWidgets(
                                                                mangaData
                                                                    .data!
                                                                    .data
                                                                    .attributes
                                                                    .tags,
                                                                appLightMode)),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          mangaData
                                                              .data!
                                                              .data
                                                              .attributes
                                                              .description
                                                              .en,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 10,
                                                          style: TextStyle(),
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          FludexUtils
                                                              .ratingContainer(
                                                                  mangaData
                                                                      .data!
                                                                      .data
                                                                      .attributes
                                                                      .contentRating,
                                                                  appLightMode),
                                                          FludexUtils
                                                              .statusContainer(
                                                                  mangaData
                                                                      .data!
                                                                      .data
                                                                      .attributes
                                                                      .status,
                                                                  appLightMode),
                                                          FludexUtils
                                                              .demographicContainer(
                                                                  mangaData
                                                                      .data!
                                                                      .data
                                                                      .attributes
                                                                      .publicationDemographic,
                                                                  appLightMode),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 40,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          'Year of Release: ' +
                                                              getYear(mangaData
                                                                  .data!
                                                                  .data
                                                                  .attributes
                                                                  .year),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          'No. of Chapters: $_totalChapters',
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 20),
                                                        child: FutureBuilder(
                                                          future:
                                                              _mangaFollowCheck(
                                                                  token,
                                                                  mangaId),
                                                          builder: (context,
                                                              AsyncSnapshot<
                                                                      bool>
                                                                  data) {
                                                            if (data.connectionState ==
                                                                ConnectionState
                                                                    .done) {
                                                              print(data.data!);
                                                              if (data.data! ==
                                                                  true) {
                                                                return ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await _unFollowManga(
                                                                        token,
                                                                        mangaId);
                                                                    print(
                                                                        'Unfollowed manga $mangaId');
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 222,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          'Added to library!',
                                                                          style:
                                                                              TextStyle(fontSize: 25),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Icon(Icons
                                                                            .favorite),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              } else {
                                                                return ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await _followManga(
                                                                        token,
                                                                        mangaId);
                                                                    print(
                                                                        'Followed manga $mangaId');
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 222,
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            'Add to library!',
                                                                            style:
                                                                                TextStyle(fontSize: 25),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Icon(Icons
                                                                            .favorite),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            } else {
                                                              return Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 40),
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Chapters',
                                                    style:
                                                        TextStyle(fontSize: 30),
                                                  ),
                                                ),
                                                Container(
                                                  child: FutureBuilder(
                                                    future: _getChapterData(
                                                        mangaId,
                                                        offset:
                                                            _chapterPageOffset *
                                                                10),
                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<
                                                                ch.ChapterData?>
                                                            chapterData) {
                                                      if (chapterData
                                                              .connectionState ==
                                                          ConnectionState
                                                              .done) {
                                                        _totalChapters =
                                                            chapterData
                                                                .data!.total;
                                                        print(chapterData
                                                            .data!.total);

                                                        print(chapterData
                                                            .data!.offset);
                                                        return Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      10.0),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    'Quick open chapter: ',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                  SizedBox(
                                                                      child:
                                                                          TextField(
                                                                        style:
                                                                            TextStyle(),
                                                                        inputFormatters: [
                                                                          FilteringTextInputFormatter
                                                                              .digitsOnly
                                                                        ],
                                                                        onChanged:
                                                                            (value) {
                                                                          _desiredInputChapterNumber =
                                                                              int.parse(value);
                                                                        },
                                                                      ),
                                                                      width:
                                                                          50),
                                                                  Text(
                                                                    ' / ${_totalChapters.toString()}',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 30,
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        hasPressed =
                                                                            true;
                                                                      });
                                                                      if (_desiredInputChapterNumber <=
                                                                          _totalChapters) {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                MangaReader(
                                                                              mangaTitle: mangaData.data!.data.attributes.title.en,
                                                                              token: token,
                                                                              mangaId: mangaId,
                                                                              chapterNumber: _desiredInputChapterNumber,
                                                                              dataSaver: widget.dataSaver,
                                                                            ),
                                                                          ),
                                                                        );
                                                                        setState(
                                                                            () {
                                                                          hasPressed =
                                                                              false;
                                                                        });
                                                                      }
                                                                    },
                                                                    child: Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                            'Open Chapter'),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            ListView.builder(
                                                                shrinkWrap:
                                                                    true,
                                                                itemCount:
                                                                    chapterData
                                                                        .data!
                                                                        .data
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return FutureBuilder(
                                                                      future: getAllReadChapters(
                                                                          token,
                                                                          mangaId),
                                                                      builder: (context,
                                                                          AsyncSnapshot<ReadChapters?>
                                                                              readChapters) {
                                                                        return Opacity(
                                                                          opacity: (readChapters.data == null)
                                                                              ? 1
                                                                              : (readChapters.data!.data.contains(chapterData.data!.data[index].id) ? 0.5 : 1.0),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 8, right: 8),
                                                                            child:
                                                                                ListTile(
                                                                              title: Text(
                                                                                'Chapter ' + chapterData.data!.data[index].attributes.chapter,
                                                                                style: TextStyle(fontSize: 17),
                                                                              ),
                                                                              subtitle: Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      'Volume ' + chapterData.data!.data[index].attributes.volume,
                                                                                      style: TextStyle(),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 10,
                                                                                    ),
                                                                                    Text(
                                                                                      'Language: ' + chapterData.data!.data[index].attributes.translatedLanguage,
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              trailing: PopupMenuButton<int>(
                                                                                itemBuilder: (context) => [
                                                                                  (readChapters.data == null)
                                                                                      ? PopupMenuItem(
                                                                                          child: ListTile(
                                                                                            leading: Icon(Icons.check_outlined),
                                                                                            title: Text("Mark as read"),
                                                                                          ),
                                                                                          onTap: () async {
                                                                                            await markChapterRead(token, chapterData.data!.data[index].id);
                                                                                          },
                                                                                        )
                                                                                      : readChapters.data!.data.contains(chapterData.data!.data[index].id)
                                                                                          ? PopupMenuItem(
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.check),
                                                                                                title: Text("Mark as unread"),
                                                                                              ),
                                                                                              onTap: () async {
                                                                                                var result = await markChapterUnread(token, chapterData.data!.data[index].id);
                                                                                                if (result.result == 'ok') {
                                                                                                  print('Marked ${chapterData.data!.data[index].id}');
                                                                                                } else {
                                                                                                  print('Something went wrong while marking ${chapterData.data!.data[index].id} as unread');
                                                                                                }
                                                                                              },
                                                                                            )
                                                                                          : PopupMenuItem(
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.check_outlined),
                                                                                                title: Text("Mark as read"),
                                                                                              ),
                                                                                              onTap: () async {
                                                                                                var result = await markChapterRead(token, chapterData.data!.data[index].id);
                                                                                                if (result.result == 'ok') {
                                                                                                  print('Marked ${chapterData.data!.data[index].id}');
                                                                                                } else {
                                                                                                  print('Something went wrong while marking ${chapterData.data!.data[index].id} as read');
                                                                                                }
                                                                                              },
                                                                                            ),
                                                                                ],
                                                                              ),
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  hasPressed = true;
                                                                                });
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => MangaReader(
                                                                                      mangaTitle: mangaData.data!.data.attributes.title.en,
                                                                                      token: token,
                                                                                      mangaId: mangaId,
                                                                                      chapterNumber: ((_chapterPageOffset) * 10) + index + 1,
                                                                                      dataSaver: widget.dataSaver,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                                setState(() {
                                                                                  hasPressed = false;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                        );
                                                                      });
                                                                }),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    if (_chapterPageOffset *
                                                                            10 !=
                                                                        0) {
                                                                      setState(
                                                                          () {
                                                                        _chapterPageOffset--;
                                                                      });
                                                                    }
                                                                  },
                                                                  icon: Icon(
                                                                    Icons
                                                                        .arrow_back,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(8),
                                                                  child: Text(
                                                                    '${_chapterPageOffset + 1}',
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      print(chapterData
                                                                          .data!
                                                                          .total);
                                                                      if (_chapterPageOffset *
                                                                              10 <
                                                                          chapterData
                                                                              .data!
                                                                              .total) {
                                                                        setState(
                                                                            () {
                                                                          _chapterPageOffset++;
                                                                        });
                                                                      }
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .arrow_forward,
                                                                    ))
                                                              ],
                                                            )
                                                          ],
                                                        );
                                                      } else if (chapterData
                                                          .hasError) {
                                                        return Center(
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  'Something went wrong :(',
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  'Please make sure you are connected to the internet and the internet is working properly',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Center(
                                                            child: SizedBox(
                                                              height: 100,
                                                              width: 100,
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else if (data.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else {
                              return Center(
                                child: Text(
                                  'Something went wrong :\'(',
                                  style: TextStyle(fontSize: 17),
                                ),
                              );
                            }
                          }));
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}

Future<MangaCheck> _followManga(String token, String mangaId) async {
  var unencodedPath = '/manga/$mangaId/follow';
  final uri = 'https://$authority$unencodedPath';
  var response = await http.delete(Uri.parse(uri), headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token'
  });
  print(response.body);
  return MangaCheck.fromJson(jsonDecode(response.body));
}

Future<MangaCheck> _unFollowManga(String token, String mangaId) async {
  var unencodedPath = '/manga/$mangaId/unfollow';
  final uri = 'https://$authority$unencodedPath';
  var response = await http.delete(Uri.parse(uri), headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $token'
  });
  print(response.body);
  return MangaCheck.fromJson(jsonDecode(response.body));
}
