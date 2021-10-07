import 'dart:convert';

import 'package:fludex/constants.dart';
import 'package:fludex/info/aboutFludex.dart';
import 'package:fludex/login/login.dart';
import 'package:fludex/search/searchScreen.dart';
import 'package:fludex/settings/settingsPage.dart';
import 'package:fludex/utils.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/models/login/Login.dart';
import 'package:mangadex_library/models/user/logged_user_details/logged_user_details.dart';
import 'package:mangadex_library/models/user/user_followed_manga/user_followed_manga.dart';
import '/search/searchResultHolder.dart';

class Library extends StatefulWidget {
  final bool dataSaver;
  final Token token;
  final bool lightMode;
  Library(
      {required this.token, required this.lightMode, required this.dataSaver});
  _Library createState() => _Library();
}

Future<UserFollowedManga> _getUserLibrary(String token, int? offset) async {
  var response = await lib.getUserFollowedMangaResponse(token, offset: offset);
  _data() async {
    try {
      return UserFollowedManga.fromJson(jsonDecode(response.body));
    } catch (e) {
      token = (await lib.refresh(token)).token.session;
      var _refreshedResponse = await lib.getUserFollowedMangaResponse(token);
      return UserFollowedManga.fromJson(jsonDecode(_refreshedResponse.body));
    }
  }

  return _data();
}

class _Library extends State<Library> {
  late String token;
  int resultOffset = 0;
  @override
  void initState() {
    super.initState();
    token = widget.token.session;
  }

  Future<UserDetails> _getLoggedUserDetails(Token _token) async {
    try {
      var userDetails = await lib.getLoggedUserDetails(_token.session);

      return userDetails;
    } catch (e) {
      token = (await lib.refresh(widget.token.refresh)).token.session;
      return await lib.getLoggedUserDetails(token);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu,
                  color: widget.lightMode ? Colors.black54 : Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              var settings = await FludexUtils().getSettings();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    lightMode: widget.lightMode,
                    settings: settings,
                  ),
                ),
              );
            },
            icon: Icon(Icons.settings,
                color: widget.lightMode ? Colors.black : Colors.white),
          )
        ],
        backgroundColor: widget.lightMode ? Colors.white : Colors.redAccent,
        title: Text(
          'Library',
          style:
              TextStyle(color: widget.lightMode ? Colors.black : Colors.white),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color:
              widget.lightMode ? Colors.white : Color.fromARGB(255, 18, 18, 18),
          child: ListView(
            children: [
              Container(
                child: Center(
                  child: FutureBuilder(
                      future: _getLoggedUserDetails(widget.token),
                      builder: (context, AsyncSnapshot<UserDetails> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
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
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                snapshot.data!.data.attributes.username,
                                style: TextStyle(
                                    color:
                                        widget.lightMode ? null : Colors.white,
                                    fontSize: 17),
                              )
                            ],
                          );
                        } else {
                          return CircularProgressIndicator(
                            color: widget.lightMode
                                ? Color.fromARGB(255, 255, 103, 64)
                                : Colors.white,
                          );
                        }
                      }),
                ),
                color: widget.lightMode
                    ? Colors.white
                    : Color.fromARGB(255, 18, 18, 18),
              ),
              ListTile(
                leading: Icon(
                  Icons.library_books,
                  color: widget.lightMode ? Colors.black54 : Colors.white,
                ),
                title: Text(
                  'Library',
                  style: TextStyle(
                    color: widget.lightMode ? null : Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.search,
                  color: widget.lightMode ? Colors.black54 : Colors.white,
                ),
                title: Text(
                  'Search Manga',
                  style: TextStyle(
                    color: widget.lightMode ? null : Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(
                          token: token,
                          lightMode: widget.lightMode,
                          dataSaver: widget.dataSaver),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: widget.lightMode ? Colors.black54 : Colors.white,
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: widget.lightMode ? null : Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserLogin(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: widget.lightMode ? Colors.black54 : Colors.white,
                ),
                title: Text(
                  'About Fludex',
                  style: TextStyle(
                    color: widget.lightMode ? null : Colors.white,
                  ),
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
      backgroundColor:
          widget.lightMode ? Colors.white : Color.fromARGB(255, 18, 18, 18),
      body: Hero(
        tag: 'login_transition',
        child: Container(
          child: FutureBuilder(
            future: _getUserLibrary(token, (resultOffset * 10)),
            builder: (context, AsyncSnapshot<UserFollowedManga> followedManga) {
              if (followedManga.connectionState == ConnectionState.done) {
                if (followedManga.hasError) {
                  return Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Something went wrong :\'(',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          Padding(
                            padding: EdgeInsets.all(25),
                            child: Text(
                              'But you can try logging in again',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
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
                                style: Constants()
                                    .normalTextStyle
                                    .copyWith(fontSize: 20),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Color.fromARGB(18, 255, 255, 255)),
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
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  );
                } else {
                  var tags = <String>[];
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisExtent: 300,
                                crossAxisCount: 2,
                              ),
                              itemCount: followedManga.data!.data.length,
                              itemBuilder: (BuildContext context, index) {
                                tags = [];
                                for (int i = 0;
                                    i <
                                        followedManga.data!.data[index]
                                            .attributes.tags.length;
                                    i++) {
                                  tags.add(followedManga.data!.data[index]
                                      .attributes.tags[i].attributes.name.en);
                                }
                                return SearchResultHolder(
                                  lightMode: widget.lightMode,
                                  token: token,
                                  description: followedManga.data!.data[index]
                                      .attributes.description.en,
                                  title: followedManga
                                      .data!.data[index].attributes.title.en,
                                  mangaId: followedManga.data!.data[index].id,
                                  baseUrl: 'https://uploads.mangadex.org',
                                  status: followedManga
                                      .data!.data[index].attributes.status,
                                  tags: tags,
                                  demographic: followedManga.data!.data[index]
                                      .attributes.publicationDemographic,
                                  rating: followedManga.data!.data[index]
                                      .attributes.contentRating,
                                  dataSaver: widget.dataSaver,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              color: Colors.white,
                              onPressed: () {
                                if (resultOffset * 10 != 0) {
                                  setState(() {
                                    resultOffset--;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: widget.lightMode
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                '${resultOffset + 1}',
                                style: TextStyle(
                                  color: widget.lightMode
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                                color: Colors.white,
                                onPressed: () {
                                  print(followedManga.data!.total);
                                  if (resultOffset * 10 <
                                      (followedManga.data!.total ~/ 10)) {
                                    setState(() {
                                      resultOffset++;
                                    });
                                  }
                                },
                                icon: Icon(
                                  Icons.arrow_forward,
                                  color: widget.lightMode
                                      ? Colors.black
                                      : Colors.white,
                                ))
                          ],
                        ),
                      )
                    ],
                  );
                }
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Container(
                      child: LinearProgressIndicator(
                        backgroundColor: widget.lightMode
                            ? Colors.white
                            : Color.fromARGB(255, 18, 18, 18),
                        color: widget.lightMode ? Colors.black54 : Colors.white,
                      ),
                      height: 30,
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
