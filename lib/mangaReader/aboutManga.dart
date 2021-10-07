import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
//import 'package:fludex/downloader/downloadManager.dart';
import 'package:fludex/mangaReader/readManga.dart';
import 'package:fludex/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mangadex_library/models/chapter/ChapterData.dart' as ch;
import 'package:mangadex_library/jsonSearchCommands.dart';
import 'package:mangadex_library/mangadex_library.dart';
import 'package:mangadex_library/models/common/singleMangaData.dart';
import 'package:mangadex_library/models/common/tags.dart';
import 'package:mangadex_library/models/user/user_followed_manga/manga_check.dart';

class AboutManga extends StatefulWidget {
  final bool dataSaver;
  final bool lightMode;
  final String token;
  final String mangaId;
  AboutManga(
      {required this.mangaId,
      required this.token,
      required this.lightMode,
      required this.dataSaver});
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
  JsonSearch _jsearch = JsonSearch();

  Future<SingleMangaData> _getMangaData(String mangaId) async {
    try {
      var _data = await _jsearch.getMangaDataByMangaId(mangaId);
      return _data;
    } catch (e) {
      print(e.toString());
      return await _jsearch.getMangaDataByMangaId(mangaId);
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
  Container _tagContainer(String _tag, bool lightMode) {
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

  List<Widget> _tagWidgets(List<Tags> _tags, bool lightMode) {
    List<Widget> _widgets = [];
    for (int i = 0; i < _tags.length; i++) {
      _widgets.add(_tagContainer(_tags[i].attributes.name.en, lightMode));
    }
    return _widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MangaReader(
                lightMode: widget.lightMode,
                token: token,
                mangaId: mangaId,
                chapterNumber: 1,
                dataSaver: widget.dataSaver,
              ),
            ),
          );
        },
        label: Text("Read now"),
        backgroundColor: Colors.redAccent,
        icon: Icon(Icons.arrow_forward),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: widget.lightMode ? Colors.black : Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor:
            widget.lightMode ? Colors.white : Color.fromARGB(255, 18, 18, 18),
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
      backgroundColor:
          widget.lightMode ? Colors.white : Color.fromARGB(255, 18, 18, 18),
      body: hasPressed
          ? Center(
              child: CircularProgressIndicator(
                color: widget.lightMode
                    ? Color.fromARGB(255, 255, 103, 64)
                    : Colors.white,
              ),
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
                                  color: widget.lightMode
                                      ? Colors.white
                                      : Color.fromARGB(255, 18, 18, 18),
                                  image: widget.lightMode
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            data.data!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: widget.lightMode
                                                ? Colors.white
                                                : Color.fromARGB(
                                                    18, 255, 255, 255),
                                            boxShadow: widget.lightMode
                                                ? [
                                                    BoxShadow(
                                                      blurRadius: 5,
                                                      spreadRadius: 0.2,
                                                      offset: Offset(1, 1),
                                                    )
                                                  ]
                                                : null,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      105, 18, 18, 18),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
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
                                                          child: Center(
                                                              child: CircularProgressIndicator(
                                                                  color: widget
                                                                          .lightMode
                                                                      ? Color.fromARGB(
                                                                          255,
                                                                          255,
                                                                          103,
                                                                          64)
                                                                      : Colors
                                                                          .white)),
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
                                                              color: widget
                                                                      .lightMode
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .white,
                                                              fontSize: 30),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Row(
                                                          children: _tagWidgets(
                                                              mangaData
                                                                  .data!
                                                                  .data
                                                                  .attributes
                                                                  .tags,
                                                              widget.lightMode),
                                                        ),
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
                                                          style: TextStyle(
                                                              color: widget
                                                                      .lightMode
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          FludexUtils.ratingContainer(
                                                              mangaData
                                                                  .data!
                                                                  .data
                                                                  .attributes
                                                                  .contentRating,
                                                              widget.lightMode),
                                                          FludexUtils
                                                              .statusContainer(
                                                                  mangaData
                                                                      .data!
                                                                      .data
                                                                      .attributes
                                                                      .status,
                                                                  widget
                                                                      .lightMode),
                                                          FludexUtils.demographicContainer(
                                                              mangaData
                                                                  .data!
                                                                  .data
                                                                  .attributes
                                                                  .publicationDemographic,
                                                              widget.lightMode),
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
                                                          style: TextStyle(
                                                              color: widget
                                                                      .lightMode
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          'No. of Chapters: $_totalChapters',
                                                          style: TextStyle(
                                                              color: widget
                                                                      .lightMode
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .white),
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
                                                                  style: ElevatedButton.styleFrom(
                                                                      primary:
                                                                          Colors
                                                                              .redAccent,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              10)),
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
                                                                  style: ElevatedButton.styleFrom(
                                                                      primary:
                                                                          Colors
                                                                              .redAccent,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              10)),
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
                                                                    CircularProgressIndicator(
                                                                  color: widget
                                                                          .lightMode
                                                                      ? Color.fromARGB(
                                                                          255,
                                                                          255,
                                                                          103,
                                                                          64)
                                                                      : Colors
                                                                          .white,
                                                                ),
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
                                            decoration: BoxDecoration(
                                              color: widget.lightMode
                                                  ? Colors.white
                                                  : Color.fromARGB(
                                                      18, 255, 255, 255),
                                              boxShadow: widget.lightMode
                                                  ? [
                                                      BoxShadow(
                                                        blurRadius: 5,
                                                        spreadRadius: 0.2,
                                                        offset: Offset(1, 1),
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Chapters',
                                                    style: TextStyle(
                                                        color: widget.lightMode
                                                            ? Colors.black
                                                            : Colors.white,
                                                        fontSize: 30),
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
                                                                        color: widget.lightMode
                                                                            ? Colors
                                                                                .black
                                                                            : Colors
                                                                                .white,
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                  SizedBox(
                                                                      child:
                                                                          TextField(
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
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
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                        color: widget.lightMode
                                                                            ? Colors.black
                                                                            : Colors.white),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 30,
                                                                  ),
                                                                  ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          primary: Colors
                                                                              .redAccent,
                                                                          padding: EdgeInsets.all(
                                                                              8)),
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
                                                                              builder: (context) => MangaReader(
                                                                                token: token,
                                                                                mangaId: mangaId,
                                                                                chapterNumber: _desiredInputChapterNumber,
                                                                                lightMode: widget.lightMode,
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
                                                                      child:
                                                                          Row(
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
                                                                      )),
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
                                                                  return Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left: 8,
                                                                        right:
                                                                            8),
                                                                    child:
                                                                        ListTile(
                                                                      tileColor: widget.lightMode
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black38,
                                                                      hoverColor: widget.lightMode
                                                                          ? Colors
                                                                              .black12
                                                                          : Colors
                                                                              .black54,
                                                                      title:
                                                                          Text(
                                                                        'Chapter ' +
                                                                            chapterData.data!.data[index].attributes.chapter,
                                                                        style: TextStyle(
                                                                            color: widget.lightMode
                                                                                ? Colors.black
                                                                                : Colors.white,
                                                                            fontSize: 17),
                                                                      ),
                                                                      subtitle:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Text(
                                                                              'Volume ' + chapterData.data!.data[index].attributes.volume,
                                                                              style: TextStyle(
                                                                                color: widget.lightMode ? Colors.black : Colors.white,
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Text(
                                                                              'Language: ' + chapterData.data!.data[index].attributes.translatedLanguage,
                                                                              style: TextStyle(color: widget.lightMode ? Colors.black : Colors.white),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          hasPressed =
                                                                              true;
                                                                        });
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                MangaReader(
                                                                              token: token,
                                                                              mangaId: mangaId,
                                                                              chapterNumber: ((_chapterPageOffset) * 10) + index + 1,
                                                                              lightMode: widget.lightMode,
                                                                              dataSaver: widget.dataSaver,
                                                                            ),
                                                                          ),
                                                                        );
                                                                        setState(
                                                                            () {
                                                                          hasPressed =
                                                                              false;
                                                                        });
                                                                      },
                                                                    ),
                                                                  );
                                                                }),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                IconButton(
                                                                  color: Colors
                                                                      .white,
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
                                                                    color: widget.lightMode
                                                                        ? Colors
                                                                            .black
                                                                        : Colors
                                                                            .white,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(8),
                                                                  child: Text(
                                                                    '${_chapterPageOffset + 1}',
                                                                    style:
                                                                        TextStyle(
                                                                      color: widget.lightMode
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                    color: Colors
                                                                        .white,
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
                                                                      color: widget.lightMode
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .white,
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
                                                                  style: TextStyle(
                                                                      color: widget.lightMode
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .white),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  'Please make sure you are connected to the internet and the internet is working properly',
                                                                  style: TextStyle(
                                                                      color: widget.lightMode
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .white),
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
                                                                  CircularProgressIndicator(
                                                                color: widget
                                                                        .lightMode
                                                                    ? Color
                                                                        .fromARGB(
                                                                            255,
                                                                            255,
                                                                            103,
                                                                            64)
                                                                    : Colors
                                                                        .white,
                                                              ),
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
                              return CircularProgressIndicator(
                                color: widget.lightMode
                                    ? Color.fromARGB(255, 255, 103, 64)
                                    : Colors.white,
                              );
                            } else {
                              return Center(
                                child: Text(
                                  'Something went wrong :\'(',
                                  style: TextStyle(
                                      color: widget.lightMode
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 17),
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
                        child: CircularProgressIndicator(
                          color: widget.lightMode
                              ? Color.fromARGB(255, 255, 103, 64)
                              : Colors.white,
                        ),
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
