import 'dart:convert';
import 'dart:io';

import 'package:fludex/services/api/mangadex/api.dart';
import 'package:fludex/services/api/mangadex/reading_status_functions.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_client.dart';

import '../../../utils/utils.dart';

class LibraryFunctions {
  static Future<UserDetails> getLoggedUserDetails() async {
    var loginData = await FludexUtils().getLoginData();
    if (loginData != null) {
      try {
        var userDetails =
            await mangadexClient.getLoggedUserDetails(loginData.session);
        return userDetails;
      } on Exception catch (e) {
        debugPrint(e.toString());
        return Future.error('Unable to connect to the internet');
      }
    } else {
      return UserDetails(
          'ok',
          UserDetailsData(
            '',
            '',
            UserDetailsAttributes(
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
      var response = await mangadexClient
          .getUserFollowedMangaResponse(loginData.session, offset: _offset);
      try {
        return UserFollowedManga.fromJson(jsonDecode(response.body));
      } on Exception catch (e) {
        debugPrint(e.toString());
        return Future.error('Unable to connect to the internet');
      }
    }
    return null;
  }

  static Future<List<SearchData>> filterManga(String selectedValue) async {
    var loginData = await FludexUtils().getLoginData();
    List<SearchData> mangaList = [];
    try {
      if (loginData != null) {
        var followedManga =
            await mangadexClient.getUserFollowedManga(loginData.session);
        var mangaWithStatus = await mangadexClient.getAllUserMangaReadingStatus(
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
