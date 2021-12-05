import 'dart:convert';
import 'dart:io';
import 'package:fludex/saveDataModels/settings.dart';
import 'package:mangadex_library/models/common/reading_status.dart';
import 'package:mangadex_library/models/login/Login.dart' as l;
import 'package:mangadex_library/mangadex_library.dart';
import 'package:fludex/saveDataModels/loginData.dart';
import 'package:mangadex_library/jsonSearchCommands.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class FludexUtils {
  Future<String> getTokenIfFileExists() async {
    var file = File('data/appData/loginData.json');
    if (await file.exists()) {
      try {
        var contents = await file.readAsString();
        var jsonData = LoginData.fromJson(jsonDecode(contents));
        return jsonData.session;
      } catch (e) {
        return '';
      }
    } else {
      return '';
    }
  }

  Future<Settings> getSettings() async {
    var file = await File('data/appData/settings.json').create(recursive: true);
    var contents = await file.readAsString();
    if (contents == '') {
      await file.writeAsString(
        jsonEncode(
          Settings(lightMode: true, dataSaver: false),
        ),
      );
    }
    var jsonData = Settings.fromJson(jsonDecode(contents));
    return jsonData;
  }

  void saveLoginData(String session, String refresh) async {
    var user = LoginData(session, refresh);
    var encodedJson = jsonEncode(user);
    var file = File('data/loginData.json');
    await file.writeAsString(encodedJson);
  }

  void disposeLoginData() async {
    var file = File('data/loginData.json');
    await file.writeAsString('');
  }

  void saveSettings(bool lightMode, bool dataSaver) async {
    var user = Settings(lightMode: lightMode, dataSaver: dataSaver);
    var encodedJson = jsonEncode(user);
    var file = File('data/appData/settings.json');
    await file.writeAsString(encodedJson);
  }

  void refreshAndSaveData(String session, String refreshdd) async {
    var dataResponse = await getDataResponse(refreshdd);
    print(dataResponse.body);
    var data = l.Login.fromJson(jsonDecode(dataResponse.body));
    print(data.result);
    try {
      saveLoginData(data.token.session, data.token.refresh);
    } catch (e) {
      saveLoginData(session, refreshdd);
    }
  }

  Future<http.Response> getDataResponse(String refresh) async {
    var dataResponse = getRefreshResponse(refresh);
    return dataResponse;
  }

  Future<List<String>?> getAllFilePaths(String globalToken,
      Future<String> chapterId, String mangaId, bool isDataSaverMode) async {
    var chapter = await getChapters(mangaId);
    if (chapter != null) {
      var token = globalToken;
      if (token.isEmpty) {
        print('THERE IS NO TOKEN!');
      }
      var baseUrl = 'https://uploads.mangadex.org';
      var filenames =
          await JsonUtils.getChapterFilenames(await chapterId, isDataSaverMode);
      var urls = <String>[];
      var chapterData =
          await JsonUtils.getChapterDataByChapterId(await chapterId);
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

  Future<String> getChapterID(
      String mangaId, int? chapterNum, int? limit) async {
    var _chapterId =
        await getChapters(mangaId, offset: (chapterNum! - 1), limit: limit);
    return _chapterId!.data[0].id;
  }

  static Container statusContainer(String status, bool lightMode) {
    if (status == 'ongoing') {
      return Container(
        decoration: lightMode
            ? BoxDecoration(
                border: Border.all(color: Colors.teal),
                borderRadius: BorderRadius.circular(5),
                color: Colors.white)
            : BoxDecoration(
                color: Colors.teal, borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Text(
          'Ongoing',
          style: TextStyle(color: lightMode ? Colors.teal : Colors.white),
        ),
      );
    } else if (status == 'completed') {
      return Container(
        decoration: lightMode
            ? BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              )
            : BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Text(
          'Completed',
          style: TextStyle(color: Colors.black),
        ),
      );
    } else if (status == 'cancelled') {
      return Container(
        decoration: lightMode
            ? BoxDecoration(
                border: Border.all(color: Colors.redAccent),
                color: Colors.white,
                borderRadius: BorderRadius.circular(5))
            : BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Text(
          'Cancelled',
          style: TextStyle(color: lightMode ? Colors.redAccent : Colors.white),
        ),
      );
    } else if (status == 'haitus') {
      return Container(
        decoration: lightMode
            ? BoxDecoration(
                border: Border.all(
                  color: Colors.orangeAccent,
                ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(5))
            : BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Text(
          'Haitus',
          style:
              TextStyle(color: lightMode ? Colors.orangeAccent : Colors.white),
        ),
      );
    } else {
      return Container();
    }
  }

  static Container demographicContainer(String demographic, bool lightMode) {
    if (demographic == 'shounen') {
      return Container(
        decoration: lightMode
            ? BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 212, 115, 0)),
                color: Colors.white,
                borderRadius: BorderRadius.circular(5))
            : BoxDecoration(
                color: Color.fromARGB(255, 212, 115, 0),
                borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Text(
          'Shounen',
          style: TextStyle(
              color:
                  lightMode ? Color.fromARGB(255, 212, 115, 0) : Colors.white),
        ),
      );
    } else if (demographic == 'shoujo') {
      return Container(
        decoration: lightMode
            ? BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 210, 0, 242)),
                color: Colors.white,
                borderRadius: BorderRadius.circular(5))
            : BoxDecoration(
                color: Color.fromARGB(255, 210, 0, 242),
                borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Text(
          'Shoujo',
          style: TextStyle(
            color: lightMode ? Color.fromARGB(255, 210, 0, 242) : Colors.white,
          ),
        ),
      );
    } else if (demographic == 'josei') {
      return Container(
        decoration: lightMode
            ? BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 24, 160, 178)),
                color: Colors.white,
                borderRadius: BorderRadius.circular(5))
            : BoxDecoration(
                color: Color.fromARGB(255, 24, 160, 178),
                borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Text(
          'Josei',
          style: TextStyle(
            color: lightMode ? Color.fromARGB(255, 24, 160, 178) : Colors.white,
          ),
        ),
      );
    } else if (demographic == 'seinen') {
      return Container(
        decoration: lightMode
            ? BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 203, 154, 52)),
                color: Colors.white,
                borderRadius: BorderRadius.circular(5))
            : BoxDecoration(
                color: Color.fromARGB(255, 203, 154, 52),
                borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Text(
          'Seinen',
          style: TextStyle(
            color: lightMode ? Color.fromARGB(255, 203, 154, 52) : Colors.white,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  static Container ratingContainer(String rating, bool lightMode) {
    if (rating == 'safe') {
      return Container(
        decoration: lightMode
            ? BoxDecoration(
                border: Border.all(color: Colors.teal),
                color: Colors.white,
                borderRadius: BorderRadius.circular(5))
            : BoxDecoration(
                color: Colors.teal, borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Text(
          'Safe',
          style: TextStyle(
            color: lightMode ? Colors.teal : Colors.white,
          ),
        ),
      );
    } else if (rating == 'suggestive') {
      return Container(
        decoration: lightMode
            ? BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                color: Colors.white,
                borderRadius: BorderRadius.circular(5))
            : BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Text(
          'Suggestive',
          style: TextStyle(
            color: lightMode ? Colors.blueAccent : Colors.white,
          ),
        ),
      );
    } else if (rating == 'erotica') {
      return Container(
        decoration: lightMode
            ? BoxDecoration(
                border: Border.all(color: Colors.orangeAccent),
                color: Colors.white,
                borderRadius: BorderRadius.circular(5))
            : BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Text(
          'Erotica',
          style: TextStyle(
            color: lightMode ? Colors.orangeAccent : Colors.white,
          ),
        ),
      );
    } else if (rating == 'pornographic') {
      return Container(
        decoration: lightMode
            ? BoxDecoration(
                border: Border.all(color: Colors.redAccent),
                color: Colors.white,
                borderRadius: BorderRadius.circular(5))
            : BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Text(
          'Pornographic',
          style: TextStyle(
            color: lightMode ? Colors.redAccent : Colors.white,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  static ReadingStatus statusStringToEnum(String status) {
    switch (status) {
      case 'reading':
        return ReadingStatus.reading;
      case 'completed':
        return ReadingStatus.completed;
      case 'dropped':
        return ReadingStatus.dropped;
      case 'on_hold':
        return ReadingStatus.on_hold;
      case 'plan_to_read':
        return ReadingStatus.plan_to_read;
      case 're_reading':
        return ReadingStatus.re_reading;
      default:
        return ReadingStatus.reading;
    }
  }
}
