import 'package:fludex/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangadex_library/mangadex_library.dart';
import 'package:mangadex_library/models/common/data.dart';
import 'package:mangadex_library/models/login/Login.dart';
import 'package:mangadex_library/models/chapter/ChapterData.dart' as ch;

class MangaReader extends StatefulWidget {
  final Data mangaData;
  final ch.Data chapterData;
  final Token? token;
  final int chapterNumber;
  final bool dataSaver;

  MangaReader(
      {required this.mangaData,
      required this.token,
      required this.chapterNumber,
      required this.chapterData,
      required this.dataSaver});
  _MangaReaderState createState() => _MangaReaderState();
}

class _MangaReaderState extends State<MangaReader> {
  double opacity = 0.03;
  int filterRed = 18;
  int filterGreen = 18;
  int filterBlue = 18;
  late bool dataSaver;
  late int chapterNumber;
  late Future<List<String>> filepaths;

  void initState() {
    super.initState();
    chapterNumber = widget.chapterNumber;
    dataSaver = widget.dataSaver;
    filepaths =
        FludexUtils().getAllFilePaths(widget.chapterData.id, widget.dataSaver);
  }

  bool imgLoading = false;
  int pageIndex = 0;
  bool hasChangedChapter = false;
  bool colorDialogVisible = false;
  final _controller = ScrollController();

  // Future<List<String>> _getAllFilePaths(
  //     String chapterId, bool isDataSaverMode) async {
  //   return await FludexUtils().getAllFilePaths(chapterId, isDataSaverMode);
  // }

  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: filepaths,
      builder: (context, AsyncSnapshot<List<String>?> data) {
        if (data.hasData) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  colorDialogVisible
                      ? colorDialogVisible = false
                      : colorDialogVisible = true;
                  print(colorDialogVisible);
                });
              },
              child: Icon(Icons.filter_b_and_w),
              tooltip: "Color Filters",
            ),
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(widget.mangaData.attributes.title.en),
            ),
            body: Stack(children: [
              SingleChildScrollView(
                controller: _controller,
                child: Column(
                  children: [
                    Container(
                      height: 75,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Center(
                              child: Row(
                                children: [
                                  Container(
                                    child: IconButton(
                                      icon: Icon(Icons.skip_previous),
                                      onPressed: () {
                                        if (chapterNumber != 0) {
                                          setState(
                                            () {
                                              chapterNumber--;
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 8.0, right: 8.0),
                                    child: Text(
                                      'Chapter ' + (chapterNumber).toString(),
                                    ),
                                  ),
                                  Container(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.skip_next,
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          hasChangedChapter = true;
                                        });
                                        try {
                                          if (widget.token != null) {
                                            await markChapterRead(
                                              widget.token!.session,
                                              await FludexUtils().getChapterID(
                                                  widget.mangaData.id,
                                                  chapterNumber,
                                                  1),
                                            );
                                          }
                                          var newChapId = await FludexUtils()
                                              .getChapterID(widget.mangaData.id,
                                                  chapterNumber, 1);
                                          setState(() {
                                            pageIndex = 0;
                                            filepaths = FludexUtils()
                                                .getAllFilePaths(newChapId,
                                                    widget.dataSaver);
                                          });
                                        } catch (e) {
                                          print(e);
                                        }
                                        setState(() {
                                          chapterNumber++;
                                          hasChangedChapter = false;
                                        });

                                        print('Marked chapter as read');
                                        setState(() {
                                          hasChangedChapter = false;
                                        });
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
                    Container(
                      child: hasChangedChapter
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Container(
                              foregroundDecoration: BoxDecoration(
                                color: Color.fromRGBO(filterRed, filterGreen,
                                    filterBlue, opacity / 100),
                              ), //brightness Control
                              child: Center(
                                child: InkWell(
                                  child: CachedNetworkImage(
                                    imageUrl: data.data![pageIndex],
                                    placeholder: (BuildContext context, value) {
                                      return Container(
                                        child: Center(
                                          child: SizedBox(
                                            height: 1000,
                                            child: Center(
                                              child: SizedBox(
                                                height: 200,
                                                width: 200,
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    errorWidget: (context, String a, b) {
                                      return Container(
                                        child: Center(
                                          child: Text("Unable to load image"),
                                        ),
                                      );
                                    },
                                  ),
                                  onDoubleTap: () async {
                                    if (pageIndex != 0) {
                                      imgLoading = true;
                                      pageIndex--;
                                      imgLoading = false;
                                    } else if (chapterNumber != 1 &&
                                        pageIndex == 0) {
                                      setState(() {
                                        hasChangedChapter = true;
                                        chapterNumber--;
                                      });
                                      var newChapId = await FludexUtils()
                                          .getChapterID(widget.mangaData.id,
                                              chapterNumber, 1);
                                      filepaths = FludexUtils().getAllFilePaths(
                                          newChapId, widget.dataSaver);
                                      setState(() {
                                        pageIndex = 0;
                                        hasChangedChapter = false;
                                      });
                                    }
                                  },
                                  onTap: () async {
                                    if (data.data!.length != pageIndex + 1) {
                                      setState(() {
                                        imgLoading = true;
                                        pageIndex++;
                                        imgLoading = false;
                                      });
                                    } else if (data.data!.length ==
                                        pageIndex + 1) {
                                      setState(() {
                                        hasChangedChapter = true;
                                        chapterNumber++;
                                      });
                                      if (widget.token != null) {
                                        markChapterRead(
                                            widget.token!.session,
                                            await FludexUtils().getChapterID(
                                                widget.mangaData.id,
                                                chapterNumber,
                                                1));
                                      }
                                      setState(() {
                                        pageIndex = 0;
                                        hasChangedChapter = false;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Page ${(pageIndex + 1).toString()}/${data.data!.length}',
                          style: TextStyle(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              colorDialogVisible
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 200, right: 200),
                        child: AnimatedContainer(
                          duration: Duration(microseconds: 250),
                          curve: Curves.easeIn,
                          child: Card(
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  Text(
                                    "Color filters",
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Brightness / Opacity",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.brightness_3),
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
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  ListTile(
                                    leading: Text(
                                      "R",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30),
                                    ),
                                    title: Slider(
                                      value: filterRed.toDouble(),
                                      onChanged: (value) => setState(() {
                                        filterRed = value.toInt();
                                      }),
                                      min: 0,
                                      max: 255,
                                    ),
                                  ),
                                  ListTile(
                                    leading: Text(
                                      "G",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30),
                                    ),
                                    title: Slider(
                                      value: filterGreen.toDouble(),
                                      onChanged: (value) => setState(() {
                                        filterGreen = value.toInt();
                                      }),
                                      min: 0,
                                      max: 255,
                                    ),
                                  ),
                                  ListTile(
                                    leading: Text(
                                      "B",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30),
                                    ),
                                    title: Slider(
                                      value: filterBlue.toDouble(),
                                      onChanged: (value) => setState(() {
                                        filterBlue = value.toInt();
                                      }),
                                      min: 0,
                                      max: 255,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: Text(
                                          "Reset",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            opacity = 0.0;
                                            filterRed = 18;
                                            filterGreen = 18;
                                            filterBlue = 18;
                                          });
                                          print(colorDialogVisible);
                                        },
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      TextButton(
                                        child: Text(
                                          "Close",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            colorDialogVisible = false;
                                          });
                                          print(colorDialogVisible);
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
            ]),
          );
        } else {
          return Center(
            child: Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
