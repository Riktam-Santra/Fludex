import 'package:cached_network_image/cached_network_image.dart';
import 'package:fludex/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadexServerException.dart';
import 'package:mangadex_library/mangadex_library.dart';
import 'package:mangadex_library/models/aggregate/Aggregate.dart';
import 'package:mangadex_library/models/common/data.dart';
import 'package:mangadex_library/models/common/language_codes.dart';
import 'package:mangadex_library/models/login/Login.dart';

class MangaReader extends StatefulWidget {
  const MangaReader({
    Key? key,
    required this.mangaData,
    required this.mangaAggregate,
    required this.dataSaver,
    required this.lightMode,
    required this.translatedLanguage,
    required this.chapterId,
    this.chapterNumber,
    this.volume,
  }) : super(key: key);
  final LanguageCodes translatedLanguage;
  final Data mangaData;
  final String? chapterNumber;
  final bool lightMode;
  final bool dataSaver;
  final String? volume;
  final Aggregate mangaAggregate;
  final String chapterId;

  @override
  State<MangaReader> createState() => _MangaReaderState();
}

class _MangaReaderState extends State<MangaReader> {
  double opacity = 0.03;
  int filterRed = 18;
  int filterGreen = 18;
  int filterBlue = 18;

  late int currentVolume = 0;
  int currentChapter = 1;
  int currentPage = 0;
  late bool dataSaver;
  late Future<List<String>> filepaths;
  late int totalPages = 0;
  Token? loginData;
  bool isFullscreen = false;
  bool colorDialogVisible = false;

  @override
  void initState() {
    FludexUtils().getLoginData().then((value) {
      if (value != null) {
        loginData = Token(value.session, value.refresh);
      }
    });
    dataSaver = widget.dataSaver;
    (widget.chapterNumber == null)
        ? currentChapter = 1
        : currentChapter = int.parse(widget.chapterNumber!);
    if (widget.volume == null) {
      currentVolume = 0;
    } else {
      try {
        currentVolume = int.parse(widget.volume!);
      } catch (e) {
        currentVolume = 0;
      }
    }

    var requiredChapter = '';
    print('chapterID: ' + widget.chapterId);

    var volumes = widget.mangaAggregate.volumes;
    var volumeIndex = 0;
    volumes.asMap().forEach((key, value) {
      if (value.volume == widget.volume) {
        volumeIndex = key;
      }
    });
    volumes.forEach((element) {
      if (element.volume == widget.volume) {
        print('element.volume was: ${element.volume}: ${widget.volume}');
        element.chapters.forEach((key, value) {
          print('current value of key is : $key');
          if (widget.mangaAggregate.volumes[volumeIndex].chapters[key]!.id ==
              widget.chapterId) {
            print(
                '$key : ${widget.mangaAggregate.volumes[volumeIndex].chapters[key]!.id}');
            requiredChapter = key;
          }
        });
      }
    });

    // widget.mangaAggregate.volumes[currentVolume].chapters.forEach((key, value) {
    //   if (widget.mangaAggregate.volumes[currentVolume].chapters[key]!.id ==
    //       widget.chapterId) {
    //     print(
    //         '$key : ${widget.mangaAggregate.volumes[currentVolume].chapters[key]!.id}');
    //     requiredChapter = key;
    //   }
    // });

    filepaths = FludexUtils().getAllFilePaths(
        widget.mangaAggregate.volumes[volumeIndex].chapters["$requiredChapter"]!
            .id,
        widget.dataSaver);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Volume give: ${widget.volume}');
    print('Chapter number given: ${widget.chapterNumber}');
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.mangaData.attributes.title.en),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: isFullscreen
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          isFullscreen = false;
                        });
                      },
                      icon: Icon(
                        Icons.fullscreen_exit,
                      ),
                      tooltip: 'Exit Fullscreen',
                    )
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          isFullscreen = true;
                        });
                      },
                      icon: Icon(
                        Icons.fullscreen,
                      ),
                      tooltip: 'Fullscreen',
                    ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              colorDialogVisible
                  ? colorDialogVisible = false
                  : colorDialogVisible = true;
              print(colorDialogVisible);
            });
          },
          child: Icon(
            Icons.filter_b_and_w,
            color: Colors.white,
          ),
          tooltip: "Color Filters",
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IconButton(
                      onPressed: () {
                        if (currentChapter != 1) {
                          setState(() {
                            currentChapter -= 1;
                            filepaths = FludexUtils().getAllFilePaths(
                                widget.mangaAggregate.volumes[currentVolume]
                                    .chapters["$currentChapter"]!.id,
                                widget.dataSaver);
                            currentPage = 0;
                          });
                        }
                      },
                      icon: Icon(Icons.skip_previous_rounded)),
                ),
                Text('Chapter $currentChapter'),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IconButton(
                      onPressed: () async {
                        if (loginData != null) {
                          try {
                            await markChapterReadOrUnRead(
                                widget.mangaData.id, loginData!.session,
                                chapterIdsRead: [
                                  widget.mangaAggregate.volumes[currentVolume]
                                      .chapters[currentChapter]!.id,
                                ]);
                            print('marked chapter as read.');
                          } catch (e) {
                            if (e is MangadexServerException) {
                              // if (e.info.errors[0].status == 401) {
                              //   var refreshed =
                              //       await refresh(loginData!.refresh);
                              //   if (refreshed.result == 'ok') {
                              //     setState(() {
                              //       loginData = refreshed.token;
                              //     });
                              //   }
                              // }
                              print(e);
                            }
                          }
                        }
                        if (currentChapter <
                            widget.mangaAggregate.volumes[currentVolume]
                                .chapters.length) {
                          setState(() {
                            currentChapter += 1;
                            filepaths = FludexUtils().getAllFilePaths(
                                widget.mangaAggregate.volumes[currentVolume]
                                    .chapters["$currentChapter"]!.id,
                                widget.dataSaver);
                            currentPage = 0;
                          });
                        }
                      },
                      icon: Icon(Icons.skip_next_rounded)),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder(
                  future: filepaths,
                  builder: (context, AsyncSnapshot<List<String>> urls) {
                    if (urls.connectionState == ConnectionState.done) {
                      totalPages = urls.data!.length;
                      return GestureDetector(
                        onTap: () {
                          if (currentPage < urls.data!.length - 1) {
                            setState(() {
                              currentPage += 1;
                            });
                          }
                        },
                        onDoubleTap: () {
                          if (currentPage != 0) {
                            setState(() {
                              currentPage -= 1;
                            });
                          }
                        },
                        child: Container(
                          foregroundDecoration: BoxDecoration(
                            color: Color.fromRGBO(filterRed, filterGreen,
                                filterBlue, opacity / 100),
                          ),
                          child: Stack(
                            children: [
                              isFullscreen
                                  ? SingleChildScrollView(
                                      child: Center(
                                        child: CachedNetworkImage(
                                          imageUrl: urls.data![currentPage],
                                          fit: BoxFit.fitWidth,
                                          alignment: Alignment.center,
                                          filterQuality: FilterQuality.high,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: InteractiveViewer(
                                        alignPanAxis: true,
                                        clipBehavior: Clip.none,
                                        child: CachedNetworkImage(
                                          imageUrl: urls.data![currentPage],
                                          fit: BoxFit.fitWidth,
                                          alignment: Alignment.center,
                                          filterQuality: FilterQuality.high,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                        ),
                                      ),
                                    ),
                              Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Spacer(),
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: Text(
                                        '${currentPage + 1}/${urls.data!.length}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              colorDialogVisible
                                  ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 200, right: 200),
                                        child: AnimatedContainer(
                                          duration: Duration(microseconds: 250),
                                          curve: Curves.easeIn,
                                          child: Card(
                                            elevation: 10,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: ListView(
                                                shrinkWrap: true,
                                                children: [
                                                  Text(
                                                    "Color filters",
                                                    style:
                                                        TextStyle(fontSize: 30),
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    "Brightness / Opacity",
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                  ListTile(
                                                    leading: Icon(
                                                        Icons.brightness_3),
                                                    // title: StatefulBuilder(
                                                    //   builder: (BuildContext context,
                                                    //       StateSetter setState) {
                                                    //     return Slider(
                                                    //       value: opacity * 10,
                                                    //       onChanged: (value) => setState(() {
                                                    //         opacity = value / 10;
                                                    //       }),
                                                    //       min: 0,
                                                    //       max: 100,
                                                    //     );
                                                    //   },
                                                    // ),
                                                    title: Slider(
                                                      value: opacity,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          opacity = value;
                                                        });
                                                      },
                                                      min: 0,
                                                      max: 100,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Filter Colors",
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                  ListTile(
                                                    leading: Text(
                                                      "R",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30),
                                                    ),
                                                    title: Slider(
                                                      value:
                                                          filterRed.toDouble(),
                                                      onChanged: (value) =>
                                                          setState(() {
                                                        filterRed =
                                                            value.toInt();
                                                      }),
                                                      min: 0,
                                                      max: 255,
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: Text(
                                                      "G",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30),
                                                    ),
                                                    title: Slider(
                                                      value: filterGreen
                                                          .toDouble(),
                                                      onChanged: (value) =>
                                                          setState(() {
                                                        filterGreen =
                                                            value.toInt();
                                                      }),
                                                      min: 0,
                                                      max: 255,
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: Text(
                                                      "B",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30),
                                                    ),
                                                    title: Slider(
                                                      value:
                                                          filterBlue.toDouble(),
                                                      onChanged: (value) =>
                                                          setState(() {
                                                        filterBlue =
                                                            value.toInt();
                                                      }),
                                                      min: 0,
                                                      max: 255,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        child: Text(
                                                          "Reset",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            opacity = 0.0;
                                                            filterRed = 18;
                                                            filterGreen = 18;
                                                            filterBlue = 18;
                                                          });
                                                          print(
                                                              colorDialogVisible);
                                                        },
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      TextButton(
                                                        child: Text(
                                                          "Close",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            colorDialogVisible =
                                                                false;
                                                          });
                                                          print(
                                                              colorDialogVisible);
                                                        },
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      );
                    } else if (urls.connectionState == ConnectionState.done) {
                      return CircularProgressIndicator();
                    } else {
                      return Container();
                    }
                  }),
            ),
          ],
        ));
  }
}
