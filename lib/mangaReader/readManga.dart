import 'package:fludex/utils.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangadex_library/mangadex_library.dart';

class MangaReader extends StatefulWidget {
  final String mangaTitle;
  final String mangaId;
  final String token;
  final int chapterNumber;
  final bool dataSaver;

  MangaReader(
      {required this.mangaTitle,
      required this.token,
      required this.mangaId,
      required this.chapterNumber,
      required this.dataSaver});
  _MangaReaderState createState() => _MangaReaderState();
}

class _MangaReaderState extends State<MangaReader> {
  late bool dataSaver;
  late int chapterNumber;

  void initState() {
    super.initState();
    chapterNumber = widget.chapterNumber;
    dataSaver = widget.dataSaver;
  }

  bool imgLoading = false;
  int pageIndex = 0;
  bool hasChangedChapter = false;

  Future<List<String>?> _getAllFilePaths(
      Future<String> chapterId, bool isDataSaverMode) async {
    return await FludexUtils().getAllFilePaths(
        widget.token, chapterId, widget.mangaId, isDataSaverMode);
  }

  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: _getAllFilePaths(
          FludexUtils().getChapterID(widget.mangaId, chapterNumber, 1),
          widget.dataSaver),
      builder: (context, AsyncSnapshot<List<String>?> data) {
        if (data.hasData) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(widget.mangaTitle),
            ),
            body: SingleChildScrollView(
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
                                  color: Colors.white,
                                  child: Text(
                                    'Chapter ' + (chapterNumber).toString(),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                Container(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.skip_next,
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        try {
                                          chapterNumber++;
                                        } catch (e) {
                                          print(e);
                                        }

                                        hasChangedChapter = true;
                                      });
                                      await markChapterRead(
                                        widget.token,
                                        await FludexUtils().getChapterID(
                                            widget.mangaId, chapterNumber, 1),
                                      );
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
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              onDoubleTap: () {
                                setState(
                                  () {
                                    if (pageIndex != 0) {
                                      imgLoading = true;
                                      pageIndex--;
                                      imgLoading = false;
                                    } else if (chapterNumber != 1 &&
                                        pageIndex == 0) {
                                      chapterNumber--;
                                    }
                                  },
                                );
                              },
                              onTap: () async {
                                if (data.data!.length != pageIndex + 1) {
                                  setState(() {
                                    imgLoading = true;
                                    pageIndex++;
                                    imgLoading = false;
                                  });
                                } else if (data.data!.length == pageIndex + 1) {
                                  setState(() {
                                    hasChangedChapter = true;
                                    chapterNumber++;
                                  });
                                  markChapterRead(
                                      widget.token,
                                      await FludexUtils().getChapterID(
                                          widget.mangaId, chapterNumber, 1));
                                  setState(() {
                                    pageIndex = 0;
                                    hasChangedChapter = false;
                                  });
                                }
                              },
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
