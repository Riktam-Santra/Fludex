import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/jsonSearchCommands.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MangaReader extends StatefulWidget {
  final String mangaId;
  final String token;
  final int chapterNumber;

  MangaReader({
    required this.token,
    required this.mangaId,
    required this.chapterNumber,
  });
  _MangaReaderState createState() => _MangaReaderState(
        globalToken: token,
        mangaId: mangaId,
        chapterNumber: chapterNumber,
      );
}

class _MangaReaderState extends State<MangaReader> {
  final String globalToken;
  late String mangaId;
  late int chapterNumber;

  _MangaReaderState(
      {required this.globalToken,
      required this.mangaId,
      required this.chapterNumber});
  bool imgLoading = false;
  int pageIndex = 0;

  Future<String> getChapterID(int? chapterNum, int? limit) async {
    var _chapterId =
        await lib.getChapters(mangaId, offset: (chapterNum! - 1), limit: limit);
    return _chapterId!.result[0].data.id;
  }

  JsonSearch jsonsearch = new JsonSearch();
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: getAllFilePaths(getChapterID(chapterNumber, 1), false),
      builder: (context, AsyncSnapshot<List<String>?> data) {
        if (data.hasData) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromARGB(18, 255, 255, 255),
            ),
            backgroundColor: Color.fromARGB(255, 18, 18, 18),
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
                                    color: Colors.white,
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
                                  color: Colors.white,
                                  child: Text(
                                      'Chapter ' + (chapterNumber).toString()),
                                ),
                                Container(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.skip_next,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        try {
                                          chapterNumber++;
                                        } catch (e) {
                                          print(e);
                                        }
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
                    color: Color.fromARGB(255, 18, 18, 18),
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
                                        color: Colors.white),
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Page ${(pageIndex + 1).toString()}/${data.data!.length}',
                        style: TextStyle(color: Colors.white),
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
                color: Colors.white,
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<String>?> getAllFilePaths(
      Future<String> chapterId, bool isDataSaverMode) async {
    var chapter = await lib.getChapters(mangaId);
    if (chapter != null) {
      var token = globalToken;
      if (token.isEmpty) {
        print('THERE IS NO TOKEN!');
      }
      var baseUrl = 'https://uploads.mangadex.org';
      var filenames = await jsonsearch.getChapterFilenames(
          await chapterId, isDataSaverMode);
      var urls = <String>[];
      var chapterData =
          await jsonsearch.getChapterDataByChapterId(await chapterId);
      var chapterHash = chapterData.data.attributes.hash;

      filenames.forEach(
        (v) {
          isDataSaverMode
              ? urls.add('$baseUrl/$token/data-saver/$chapterHash/$v')
              : urls.add('$baseUrl/$token/data/$chapterHash/$v');
        },
      );
      return urls;
    }
  }
}
