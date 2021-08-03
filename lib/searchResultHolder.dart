import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'mangaReader/readManga.dart';
import 'package:mangadex_library/cover/Cover.dart';

class SearchResultHolder extends StatefulWidget {
  final String token;
  final String mangaID;
  final String baseUrl;
  final String title;
  SearchResultHolder(
      {required this.baseUrl,
      required this.mangaID,
      required this.title,
      required this.token});
  _SearchResultHolder createState() =>
      _SearchResultHolder(mangaID, title, baseUrl, token);
}

class _SearchResultHolder extends State<SearchResultHolder> {
  final String mangaId;
  final String baseUrl;
  final String title;
  final String token;
  _SearchResultHolder(this.mangaId, this.title, this.baseUrl, this.token);
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: lib.getCoverArt(mangaId),
        builder: (context, AsyncSnapshot<Cover> cover) {
          if (cover.connectionState == ConnectionState.done) {
            var coverFileName = cover.data!.results[0].data.attributes.fileName;
            return InkWell(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(offset: Offset(5, 5), blurRadius: 5)
                    ]),
                child: Stack(
                  children: [
                    Container(
                      child: (Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(
                            '$baseUrl/covers/$mangaId/$coverFileName'),
                      )),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.amberAccent,
                        child: Text(title),
                      ),
                    )
                  ],
                ),
              ),
              onTap: () async {
                var chapterData = await lib.getChapters(mangaId);
                var chapterId = chapterData.result[0].data.id;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MangaReader(
                      token: token,
                      chapterId: chapterId,
                      mangaId: mangaId,
                    ),
                  ),
                );
              },
            );
          } else {
            return Container(
                height: 50, width: 50, child: CircularProgressIndicator());
          }
        });
  }
}
