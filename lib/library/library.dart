import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:fludex/info/aboutFludex.dart';
import 'package:fludex/search/searchScreen.dart';
import 'package:fludex/settings/settingsPage.dart';
import 'package:fludex/search/searchResultHolder.dart';
import 'package:fludex/utils.dart';
import 'package:fludex/login/home_page_animator.dart';
import 'package:mangadex_library/mangadexServerException.dart';

import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/models/common/reading_status.dart';
import 'package:mangadex_library/models/login/Login.dart';
import 'package:mangadex_library/models/user/logged_user_details/logged_user_details.dart';
import 'package:mangadex_library/models/user/user_followed_manga/user_followed_manga.dart';
import 'package:mangadex_library/models/common/data.dart' as mangadat;

class Library extends StatefulWidget {
  final bool dataSaver;
  final Token? token;

  Library({this.token, required this.dataSaver});
  _Library createState() => _Library();
}

class _Library extends State<Library> {
  late Token? token;
  int gridCount = 2;
  int resultOffset = 0;
  bool gridView = false;
  List<String> dropDownMenuItems = [
    'All',
    'Reading',
    'Completed',
    'Dropped',
    'Plan to read',
    'Re-Reading',
    'On Hold'
  ];

  String selectedValue = 'All';

  late Future<UserFollowedManga> userLibrary;
  late Future<List<mangadat.Data>> filteredMangaList;
  late Future<UserDetails> userDetails;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      userLibrary = _getUserLibrary(
        widget.token!,
        (resultOffset * 10),
      );
      filteredMangaList = _filterManga(widget.token!);
    }
    userDetails = _getLoggedUserDetails(widget.token);
    token = widget.token;
  }

  Future<UserDetails> _getLoggedUserDetails(Token? _token) async {
    if (widget.token != null && _token != null) {
      try {
        var userDetails = await lib.getLoggedUserDetails(_token.session);

        return userDetails;
      } on Exception catch (e) {
        if (e is MangadexServerException) {
          token = (await lib.refresh(widget.token!.refresh)).token;
          return await lib.getLoggedUserDetails(token!.session);
        } else {
          return Future.error('Unable to connect to the internet');
        }
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
      );
    }
  }

  Future<UserFollowedManga> _getUserLibrary(Token _token, int? _offset) async {
    var response =
        await lib.getUserFollowedMangaResponse(_token.session, offset: _offset);
    try {
      return UserFollowedManga.fromJson(jsonDecode(response.body));
    } on Exception catch (e) {
      if (e is MangadexServerException) {
        _token = (await lib.refresh(_token.refresh)).token;
        var _refreshedResponse =
            await lib.getUserFollowedMangaResponse(_token.session);
        token = _token;
        FludexUtils().saveLoginData(_token.session, _token.refresh);
        return UserFollowedManga.fromJson(jsonDecode(_refreshedResponse.body));
      } else {
        return Future.error('Unable to connect to the internet');
      }
    }
  }

  ReadingStatus? checkReadingStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return null;
    } else {
      return FludexUtils.statusStringToEnum(status.toLowerCase());
    }
  }

  Future<List<mangadat.Data>> _filterManga(Token _token) async {
    List<mangadat.Data> mangaList = [];
    try {
      var followedManga = await lib.getUserFollowedManga(_token.session);
      var mangaWithStatus = await lib.getAllUserMangaReadingStatus(
          _token.session,
          readingStatus: checkReadingStatus(selectedValue));
      followedManga.data.forEach((element) {
        if (mangaWithStatus.statuses.containsKey(element.id)) {
          mangaList.add(element);
        }
      });
      return mangaList;
    } on MangadexServerException catch (e) {
      e.info.errors.forEach((element) {
        print(element);
      });
      token = (await lib.refresh(widget.token!.refresh)).token;

      var followedManga = await lib.getUserFollowedManga(token!.session);
      var mangaWithStatus = await lib.getAllUserMangaReadingStatus(
          token!.session,
          readingStatus: checkReadingStatus(selectedValue));
      followedManga.data.forEach((element) {
        if (mangaWithStatus.statuses.containsKey(element.id)) {
          mangaList.add(element);
        }
      });
      return mangaList;
    } on SocketException {
      return Future.error(Exception('Unable to connect to the internet'));
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh library',
            onPressed: () {
              setState(() {
                filteredMangaList = _filterManga(widget.token!);
              });
            },
            icon: Icon(Icons.refresh),
          ),
          Divider(
            thickness: 2,
            height: 10,
            color: Colors.white,
            indent: 1,
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () async {
              var settings = await FludexUtils().getSettings();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    settings: settings,
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.settings,
            ),
          ),
        ],
        title: Text(
          'Library',
        ),
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: [
              Container(
                child: Center(
                  child: FutureBuilder(
                      future: userDetails,
                      builder: (context, AsyncSnapshot<UserDetails> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Unable to load data, please check your internet",
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {});
                                    },
                                    child: Text("Retry"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(20),
                                  height: 150,
                                  child: Center(
                                    child: Text(
                                      snapshot.data!.data.attributes.username
                                          .characters.first
                                          .toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 70),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 103, 64),
                                      shape: BoxShape.circle),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  snapshot.data!.data.attributes.username,
                                  style: TextStyle(fontSize: 17),
                                )
                              ],
                            );
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      }),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.library_books,
                ),
                title: Text(
                  'Library',
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.search,
                ),
                title: Text(
                  'Search Manga',
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchPage(token: token, dataSaver: widget.dataSaver),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                ),
                title: Text(
                  'Logout',
                ),
                onTap: () async {
                  Navigator.pop(context);
                  FludexUtils().disposeLoginData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePageAnimator(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.info,
                ),
                title: Text(
                  'About Fludex',
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutFludex(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Hero(
        tag: 'login_transition',
        child: Container(
          child: (token == null)
              ? Center(
                  child: SizedBox(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                              'Please login into your mangadex account to start using the library'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            FludexUtils().disposeLoginData();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePageAnimator(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text("Logout"),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : FutureBuilder(
                  future: userLibrary,
                  builder: (context,
                      AsyncSnapshot<UserFollowedManga> followedManga) {
                    if (followedManga.connectionState == ConnectionState.done) {
                      if (followedManga.hasError) {
                        return Container(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Something went wrong :\'(',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(25),
                                  child: Text(
                                    'But you can try logging in again',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Login again',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      primary:
                                          Color.fromARGB(18, 255, 255, 255)),
                                )
                              ],
                            ),
                          ),
                        );
                      } else if (followedManga.data!.data.length == 0) {
                        return Container(
                          child: Center(
                            child: Text(
                              'A way too empty library...',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        );
                      } else {
                        var tags = <String>[];
                        return Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      tooltip: 'Change view',
                                      onPressed: () {
                                        setState(() {
                                          gridView = !gridView;
                                        });
                                      },
                                      icon: Icon(Icons.grid_view)),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Icon(Icons.filter_alt),
                                  ),
                                  DropdownButton(
                                    elevation: 10,
                                    underline: Container(),
                                    items: dropDownMenuItems
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                          child: Container(
                                            margin: EdgeInsets.all(10),
                                            child: Text(
                                              value,
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          value: value);
                                    }).toList(),
                                    value: selectedValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedValue = newValue.toString();
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: (token == null)
                                  ? Center(
                                      child: Container(),
                                    )
                                  : FutureBuilder(
                                      future: filteredMangaList,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<mangadat.Data>>
                                              allMangaStatus) {
                                        if (allMangaStatus.connectionState ==
                                            ConnectionState.done) {
                                          return allMangaStatus.data!.length ==
                                                  0
                                              ? Center(
                                                  child: Text(
                                                    "Nothing found >:3",
                                                    style:
                                                        TextStyle(fontSize: 24),
                                                  ),
                                                )
                                              : SingleChildScrollView(
                                                  child: LayoutBuilder(builder:
                                                      (context, constraints) {
                                                    return Container(
                                                      child: GridView.builder(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        shrinkWrap: true,
                                                        gridDelegate:
                                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                          mainAxisExtent: 300,
                                                          crossAxisCount: (constraints
                                                                      .maxWidth >
                                                                  908)
                                                              ? ((gridView ==
                                                                      false)
                                                                  ? 2
                                                                  : 8)
                                                              : ((constraints.maxWidth <
                                                                              908 &&
                                                                          gridView ==
                                                                              true ||
                                                                      constraints
                                                                              .maxWidth <
                                                                          908 ||
                                                                      gridView ==
                                                                          true)
                                                                  ? 4
                                                                  : 2),
                                                        ),
                                                        itemCount:
                                                            allMangaStatus
                                                                .data!.length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                index) {
                                                          tags = [];
                                                          for (int i = 0;
                                                              i <
                                                                  allMangaStatus
                                                                      .data![
                                                                          index]
                                                                      .attributes
                                                                      .tags
                                                                      .length;
                                                              i++) {
                                                            tags.add(
                                                                allMangaStatus
                                                                    .data![
                                                                        index]
                                                                    .attributes
                                                                    .tags[i]
                                                                    .attributes
                                                                    .name
                                                                    .en);
                                                          }
                                                          return SearchResultHolder(
                                                            gridView: gridView,
                                                            token: token,
                                                            mangaData:
                                                                allMangaStatus
                                                                        .data![
                                                                    index],
                                                            dataSaver: widget
                                                                .dataSaver,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  }),
                                                );
                                        } else if (allMangaStatus.hasError) {
                                          return Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 100),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      "Unable to fetch your library at the moment."),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        filteredMangaList =
                                                            filteredMangaList =
                                                                _filterManga(
                                                                    widget
                                                                        .token!);
                                                      });
                                                    },
                                                    child: Text("Retry"),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 100),
                                              child: Container(
                                                child:
                                                    LinearProgressIndicator(),
                                                height: 30,
                                                width: 500,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: (followedManga.data!.total > 10)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          color: Colors.white,
                                          onPressed: () {
                                            if (resultOffset * 10 != 0) {
                                              setState(
                                                () {
                                                  resultOffset--;
                                                  userLibrary = _getUserLibrary(
                                                    widget.token!,
                                                    (resultOffset * 10),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          icon: Icon(
                                            Icons.arrow_back,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            '${resultOffset + 1}',
                                          ),
                                        ),
                                        IconButton(
                                          color: Colors.white,
                                          onPressed: () {
                                            print(followedManga.data!.total);
                                            if (resultOffset * 10 <
                                                (followedManga.data!.total ~/
                                                    10)) {
                                              setState(() {
                                                resultOffset++;
                                                userLibrary = _getUserLibrary(
                                                  widget.token!,
                                                  (resultOffset * 10),
                                                );
                                              });
                                            }
                                          },
                                          icon: Icon(
                                            Icons.arrow_forward,
                                          ),
                                        )
                                      ],
                                    )
                                  : null,
                            )
                          ],
                        );
                      }
                    } else {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Container(
                            child: LinearProgressIndicator(),
                            height: 30,
                            width: 500,
                          ),
                        ),
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }
}
