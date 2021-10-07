import 'dart:convert';
import 'dart:io';
import 'package:mangadex_library/models/login/Login.dart' as l;
import 'package:mangadex_library/mangadex_library.dart';
import 'package:fludex/saveDataModels/loginData.dart';
import 'package:http/http.dart' as http;

class FludexUtils {
  Future<String> getTokenIfFileExists() async {
    var file = File('data/loginData.json');
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

  void saveLoginData(
      String username, String password, String session, String refresh) {
    var user = LoginData(username, password, session, refresh);
    var encodedJson = jsonEncode(user);
    var file = File('data/loginData.json');
    file.writeAsString(encodedJson);
  }

  void refreshAndSaveData(String username, String password, String session,
      String refreshdd) async {
    var dataResponse = await getDataResponse(refreshdd);
    print(dataResponse.body);
    var data = l.Login.fromJson(jsonDecode(dataResponse.body));
    print(data.result);
    try {
      saveLoginData(username, password, data.token.session, data.token.refresh);
    } catch (e) {
      saveLoginData(username, password, session, refreshdd);
    }
  }

  Future<http.Response> getDataResponse(String refresh) async {
    var dataResponse = getRefreshResponse(refresh);
    return dataResponse;
  }
}
