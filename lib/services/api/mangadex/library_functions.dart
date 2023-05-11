import 'dart:convert';
import 'dart:io';

import 'package:fludex/services/api/mangadex/reading_status_functions.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadexServerException.dart';
import 'package:mangadex_library/models/user/logged_user_details/logged_user_details.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/models/user/user_followed_manga/user_followed_manga.dart';
import 'package:mangadex_library/models/common/data.dart' as mangadat;

import '../../../utils/utils.dart';

class LibraryFunctions {
  static Future<UserDetails> getLoggedUserDetails() async {
    var loginData = await FludexUtils().getLoginData();
    if (loginData != null) {
      try {
        var userDetails = await lib.getLoggedUserDetails(loginData.session);
        return userDetails;
      } on Exception catch (e) {
        debugPrint(e.toString());
        return Future.error('Unable to connect to the internet');
      }
    } else {
      return UserDetails(
          'ok',
          Data(
            '',
            '',
            Attributes(
              'Anonymous',
              [],
              0,
            ),
            [],
          ),
          '');
    }
  }

  static Future<UserFollowedManga?> getUserLibrary(int? _offset) async {
    var loginData = await FludexUtils().getLoginData();
    if (loginData != null) {
      var response = await lib.getUserFollowedMangaResponse(loginData.session,
          offset: _offset);
      try {
        return UserFollowedManga.fromJson(jsonDecode(response.body));
      } on Exception catch (e) {
        debugPrint(e.toString());
        return Future.error('Unable to connect to the internet');
      }
    }
    return null;
  }

  static Future<List<mangadat.Data>> filterManga(String selectedValue) async {
    var loginData = await FludexUtils().getLoginData();
    List<mangadat.Data> mangaList = [];
    try {
      if (loginData != null) {
        var followedManga = await lib.getUserFollowedManga(loginData.session);
        var mangaWithStatus = await lib.getAllUserMangaReadingStatus(
            loginData.session,
            readingStatus:
                ReadingStatusFunctions.checkReadingStatus(selectedValue));
        followedManga.data!.forEach((element) {
          if (mangaWithStatus.statuses!.containsKey(element.id)) {
            mangaList.add(element);
          }
        });
      }
    } on MangadexServerException catch (e) {
      e.info.errors!.forEach((element) {
        print(element);
      });

      // var followedManga = await lib.getUserFollowedManga(loginData!.session);
      // var mangaWithStatus = await lib.getAllUserMangaReadingStatus(
      //     loginData.session,
      //     readingStatus: checkReadingStatus(selectedValue));
      // followedManga.data.forEach((element) {
      //   if (mangaWithStatus.statuses.containsKey(element.id)) {
      //     mangaList.add(element);
      //   }
      // });
      // return mangaList;
    } on SocketException {
      return Future.error(Exception('Unable to connect to the internet'));
    }
    return mangaList;
  }
}
