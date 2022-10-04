import 'dart:convert';
import 'dart:io';
import 'package:fludex/services/data_models/settings_data/settings.dart';
import 'package:mangadex_library/models/common/reading_status.dart';
import 'package:mangadex_library/models/login/Login.dart' as l;
import 'package:mangadex_library/mangadex_library.dart';
import 'package:fludex/services/data_models/user_data/login_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class FludexUtils {
  Future<LoginData?> getLoginData() async {
    var file =
        await File('data/appData/loginData.json').create(recursive: true);
    try {
      var contents = await file.readAsString();
      if (contents == '') {
        return null;
      } else {
        try {
          var data = LoginData.fromJson(jsonDecode(contents));
          if ((DateTime.now().millisecondsSinceEpoch - data.timestamp) >=
              840000) {
            debugPrint(
                'The saved login data seems to be older than 14 minutes of being requested, refreshing...');
            var newToken = await refresh(data.refresh);
            await saveLoginData(newToken.token.session, newToken.token.refresh);
            debugPrint('done!');
            var newLoginData = await getLoginData();
            return newLoginData;
          } else {
            return data;
          }
        } on Exception catch (e) {
          print(e);
          return null;
        }
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> saveLoginData(String session, String refresh) async {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var user = LoginData(session, refresh, timestamp);
    var encodedJson = jsonEncode(user);
    var file =
        await File('data/appData/loginData.json').create(recursive: true);
    await file.writeAsString(encodedJson);
  }

  Future<Settings?> getSettings() async {
    var file = await File('data/appData/settings.json').create(recursive: true);
    try {
      var contents = await file.readAsString();
      if (contents == '') {
        await file.writeAsString(
          jsonEncode(
            Settings(lightMode: true, dataSaver: false),
          ),
        );
      }
      return Settings.fromJson(jsonDecode(contents));
    } on Exception catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  Future<bool?> getLightModeSetting() async {
    try {
      var settings = await getSettings();
      return settings?.lightMode;
    } on Exception catch (e) {
      //await FludexUtils().saveSettings(true, false);
      // var settings = await getSettings();
      // return settings?.lightMode;
      throw Exception(e);
    }
  }

  void disposeLoginData() async {
    var file = File('data/appData/loginData.json');
    if (await file.exists()) {
      await file.writeAsString('');
    }
  }

  Future<void> saveSettings(bool lightMode, bool dataSaver) async {
    var user = Settings(lightMode: lightMode, dataSaver: dataSaver);
    var encodedJson = jsonEncode(user);
    var file = File('data/appData/settings.json');
    await file.writeAsString(encodedJson);
  }

  Future<void> refreshAndSaveData(String session, String refreshdd) async {
    var dataResponse = await getDataResponse(refreshdd);
    print(dataResponse.body);
    var data = l.Login.fromJson(jsonDecode(dataResponse.body));
    print(data.result);
    try {
      await saveLoginData(data.token.session, data.token.refresh);
    } catch (e) {
      await saveLoginData(session, refreshdd);
    }
  }

  Future<http.Response> getDataResponse(String refresh) async {
    var dataResponse = getRefreshResponse(refresh);
    return dataResponse;
  }

  Future<List<String>> getAllFilePaths(
      String chapterId, bool isDataSaverMode) async {
    var urls = <String>[];
    var chapterData = await getChapterDataByChapterId(chapterId);
    if (isDataSaverMode) {
      for (String filename in chapterData.chapter.dataSaver) {
        urls.add(
          constructPageUrl(
            chapterData.baseUrl,
            isDataSaverMode,
            chapterData.chapter.hash,
            filename,
          ),
        );
      }
    } else {
      for (String filename in chapterData.chapter.data) {
        urls.add(
          constructPageUrl(
            chapterData.baseUrl,
            isDataSaverMode,
            chapterData.chapter.hash,
            filename,
          ),
        );
      }
    }
    return urls;
  }

  Future<String> getChapterID(
      String mangaId, int? chapterNum, int? limit) async {
    var _chapterId =
        await getChapters(mangaId, offset: (chapterNum! - 1), limit: limit);
    return _chapterId.data[0].id;
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
