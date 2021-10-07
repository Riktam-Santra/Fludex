import 'package:fludex/utils.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/jsonSearchCommands.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangadex_library/mangadex_library.dart';

class MangaReader extends StatefulWidget {
  final String mangaId;
  final String token;
  final int chapterNumber;
  final bool lightMode;
  final bool dataSaver;

  MangaReader(
      {required this.token,
      required this.mangaId,
      required this.chapterNumber,
      required this.lightMode,
      required this.dataSaver});
  _MangaReaderState createState() => _MangaReaderState();
}

class _MangaReaderState extends State<MangaReader> {
  late bool lightMode;
  late bool dataSaver;
  late int chapterNumber;

  void initState() {
    super.initState();
    chapterNumber = widget.chapterNumber;
    lightMode = widget.lightMode;
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

  JsonSearch jsonsearch = new JsonSearch();
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: _getAllFilePaths(
          FludexUtils().getChapterID(widget.mangaId, chapterNumber, 1),
          widget.dataSaver),
      builder: (context, AsyncSnapshot<List<String>?> data) {
        if (data.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor:
                  lightMode ? Colors.white : Color.fromARGB(18, 255, 255, 255),
            ),
            backgroundColor:
                lightMode ? Colors.white : Color.fromARGB(255, 18, 18, 18),
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
                                    color:
                                        lightMode ? Colors.black : Colors.white,
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
                                  color:
                                      lightMode ? Colors.black : Colors.white,
                                  child: Text(
                                      'Chapter ' + (chapterNumber).toString()),
                                ),
                                Container(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.skip_next,
                                      color: lightMode
                                          ? Colors.black
                                          : Colors.white,
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
                            color: lightMode
                                ? Colors.white
                                : Color.fromARGB(255, 18, 18, 18),
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
                                            child: CircularProgressIndicator(
                                              color: widget.lightMode
                                                  ? Color.fromARGB(
                                                      255, 255, 103, 64)
                                                  : Colors.white,
                                            ),
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
                                    }
                                  },
                                );
                              },
                              onTap: () {
                                setState(
                                  () {
                                    if (data.data!.length != pageIndex + 1) {
                                      imgLoading = true;
                                      pageIndex++;
                                      imgLoading = false;
                                    }
                                  },
                                );
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
                        style: TextStyle(
                            color: lightMode ? Colors.black : Colors.white),
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
              child: CircularProgressIndicator(
                color: widget.lightMode
                    ? Color.fromARGB(255, 255, 103, 64)
                    : Colors.white,
              ),
            ),
          );
        }
      },
    );
  }
}
