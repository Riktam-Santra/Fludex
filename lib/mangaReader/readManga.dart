import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/jsonSearchCommands.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MangaReader extends StatefulWidget {
  final String mangaId;
  final String token;
  final String chapterId;
  MangaReader(
      {required this.token, required this.chapterId, required this.mangaId});
  _MangaReaderState createState() => _MangaReaderState(
      globalToken: token, chapterId: chapterId, mangaId: mangaId);
}

class _MangaReaderState extends State<MangaReader> {
  final String globalToken;
  final String chapterId;
  final String mangaId;
  _MangaReaderState(
      {required this.globalToken,
      required this.chapterId,
      required this.mangaId});
  JsonSearch jsonsearch = new JsonSearch();
  bool isLoading = false;
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: getAllFilePaths(chapterId, true),
        builder: (context, AsyncSnapshot<List<String>> data) {
          if (data.hasData) {
            return Scaffold(
                body: Stack(
              children: [
                Container(
                  color: Colors.black87,
                  child: ListView.builder(
                    itemCount: data.data!.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, index) {
                      return Container(
                        //   child: Image(
                        //     image: NetworkImage(data.data![index]),
                        //     loadingBuilder: (context, child, loadingProgress) {
                        //       if (loadingProgress == null) return child;
                        //       return Container(
                        //         width: 100,
                        //         padding: EdgeInsets.all(10),
                        //         child: Center(
                        //             child: Container(
                        //           height: 100,
                        //           width: 100,
                        //           child: CircularProgressIndicator(
                        //             color: Colors.white,
                        //           ),
                        //         )),
                        //       );
                        //     },
                        //   ),
                        child: CachedNetworkImage(
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
                Container(
                  height: 75,
                  width: double.infinity,
                  color: Colors.black54,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: BackButton(
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          color: Colors.white,
                          child: TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                                //hintText: '$pageNumber',
                                fillColor: Colors.white),
                          ),
                          width: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
          } else {
            return Center(
              child: Container(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
            );
          }
        });
  }

  Future<List<String>> getAllFilePaths(
      String chapterId, bool isDataSaverMode) async {
    var chapter = await lib.getChapters(mangaId);
    var token = globalToken;
    if (token.isEmpty) {
      print('THERE IS NO TOKEN!');
    }
    var baseUrlClassInstance = await lib.getBaseUrl(chapterId);
    var baseUrl = baseUrlClassInstance.baseUrl;
    var filenames =
        jsonsearch.getChapterFilenames(chapterId, chapter, isDataSaverMode);
    var urls = <String>[];

    var chapterData = jsonsearch.getChapterDataByChapterId(chapterId, chapter);
    var chapterHash = chapterData.data.attributes.hash;

    filenames.forEach((v) {
      isDataSaverMode
          ? urls.add('$baseUrl/$token/data-saver/$chapterHash/$v')
          : urls.add('$baseUrl/$token/data-saver/$chapterHash/$v');
    });
    return urls;
    // ImageManager imageManager = new ImageManager();
    // var paths = <String>[];
    // for (int i = 0; i < urls.length; i++) {
    //   paths.add(imageManager.storeAndGetImage(urls[i], filenames[i]));
    // }
    // return paths;
  }
}
