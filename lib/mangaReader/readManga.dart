import 'package:flutter/material.dart';
import 'package:mangadex_library/chapter/ChapterData.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/jsonSearchCommands.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MangaReader extends StatefulWidget {
  final ChapterData chapterData;
  final String mangaId;
  final String token;
  final String chapterId;

  MangaReader(
      {required this.token,
      required this.chapterId,
      required this.mangaId,
      required this.chapterData});
  _MangaReaderState createState() => _MangaReaderState(
      globalToken: token,
      chapterId: chapterId,
      mangaId: mangaId,
      chapterData: chapterData);
}

class _MangaReaderState extends State<MangaReader> {
  final String globalToken;
  late String chapterId;
  final ChapterData chapterData;
  late String mangaId;

  _MangaReaderState(
      {required this.globalToken,
      required this.chapterId,
      required this.mangaId,
      required this.chapterData});
  JsonSearch jsonsearch = new JsonSearch();
  Widget build(BuildContext context) {
    int chapterNumberTracker = 0;
    chapterId = chapterData.result[chapterNumberTracker].data.id;
    return new FutureBuilder(
      future: getAllFilePaths(chapterId, false),
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
                                        setState(() {
                                          chapterNumberTracker--;
                                        });
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
                                      setState(() {
                                        chapterNumberTracker++;
                                      });
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
                    child: ListView.builder(
                      itemCount: data.data!.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, index) {
                        return Container(
                          child: CachedNetworkImage(
                            fit: BoxFit.contain,
                            imageUrl: data.data![index],
                            placeholder: (context, url) => Container(
                              child: Center(child: CircularProgressIndicator()),
                              height: 100,
                              width: 100,
                            ),
                          ),
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
      var baseUrlClassInstance = await lib.getBaseUrl(chapterId);
      var baseUrl = baseUrlClassInstance!.baseUrl;
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
