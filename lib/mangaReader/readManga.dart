import 'package:flutter/material.dart';
import 'package:mangadex_library/chapter/ChapterData.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/jsonSearchCommands.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MangaReader extends StatefulWidget {
  final ChapterData chapterData;
  final String mangaId;
  final String token;

  MangaReader(
      {required this.token, required this.mangaId, required this.chapterData});
  _MangaReaderState createState() => _MangaReaderState(
      globalToken: token, mangaId: mangaId, chapterData: chapterData);
}

class _MangaReaderState extends State<MangaReader> {
  final String globalToken;
  late ChapterData chapterData;
  late String mangaId;

  _MangaReaderState(
      {required this.globalToken,
      required this.mangaId,
      required this.chapterData});
  bool imgLoading = false;
  int chapterNumberTracker = 0;
  int pageIndex = 0;
  String getChapterID() {
    var chapterId = chapterData.result[chapterNumberTracker].data.id;
    return chapterId;
  }

  JsonSearch jsonsearch = new JsonSearch();
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: getAllFilePaths(getChapterID(), false),
      builder: (context, AsyncSnapshot<List<String>?> data) {
        if (data.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 75,
                    width: double.infinity,
                    color: Colors.black54,
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
                                      if (chapterNumberTracker != 0) {
                                        setState(
                                          () {
                                            chapterNumberTracker--;
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  child: Text('Chapter ' +
                                      (chapterNumberTracker + 1).toString()),
                                ),
                                Container(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.skip_next,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(
                                        () {
                                          chapterNumberTracker++;
                                        },
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.black87,
                    child: InkWell(
                      child: CachedNetworkImage(
                        imageUrl: data.data![pageIndex],
                        placeholder: (BuildContext context, value) {
                          return Container(
                            child: Center(
                              child: SizedBox(
                                child: CircularProgressIndicator(),
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
      String chapterId, bool isDataSaverMode) async {
    var chapter = await lib.getChapters(mangaId);
    if (chapter != null) {
      var token = globalToken;
      if (token.isEmpty) {
        print('THERE IS NO TOKEN!');
      }
      var baseUrl = 'https://uploads.mangadex.org';
      var filenames =
          jsonsearch.getChapterFilenames(chapterId, chapter, isDataSaverMode);
      var urls = <String>[];
      var chapterData =
          jsonsearch.getChapterDataByChapterId(chapterId, chapter);
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
