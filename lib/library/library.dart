import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:fludex/info/aboutFludex.dart';
import 'package:fludex/search/searchScreen.dart';
import 'package:fludex/settings/settingsPage.dart';
import 'package:fludex/search/searchResultHolder.dart';
import 'package:fludex/utils.dart';
import 'package:fludex/login/home_page_animator.dart';

import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/src/models/login/Login.dart';
import 'package:mangadex_library/src/models/user/logged_user_details/logged_user_details.dart';
import 'package:mangadex_library/src/models/user/user_followed_manga/user_followed_manga.dart';

class Library extends StatefulWidget {
  final bool dataSaver;
  final Token token;
  Library({required this.token, required this.dataSaver});
  _Library createState() => _Library();
}

class _Library extends State<Library> {
  late Token token;
  int resultOffset = 0;
  @override
  void initState() {
    super.initState();
    token = widget.token;
  }

  Future<UserDetails> _getLoggedUserDetails(Token _token) async {
    try {
      var userDetails = await lib.getLoggedUserDetails(_token.session);

      return userDetails;
    } catch (e) {
      token = (await lib.refresh(widget.token.refresh)).token;
      return await lib.getLoggedUserDetails(token.session);
    }
  }

  Future<UserFollowedManga> _getUserLibrary(Token _token, int? _offset) async {
    var response =
        await lib.getUserFollowedMangaResponse(_token.session, offset: _offset);
    _data() async {
      try {
        return UserFollowedManga.fromJson(jsonDecode(response.body));
      } catch (e) {
        _token = (await lib.refresh(_token.refresh)).token;
        var _refreshedResponse =
            await lib.getUserFollowedMangaResponse(_token.session);
        token = _token;
        FludexUtils().saveLoginData(_token.session, _token.refresh);
        return UserFollowedManga.fromJson(jsonDecode(_refreshedResponse.body));
      }
    }

    return _data();
  }

  // Widget _buildPopupDialog(BuildContext context) {
  //   //default filter values
  //   bool value_reading = true;

  //   return new AlertDialog(
  //     title: const Text('Filters'),
  //     content: new Column(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         CheckboxListTile(
  //           value: value_reading,
  //           onChanged: (value) {},
  //           title: Text("Reading"),
  //         ),
  //       ],
  //     ),
  //     actions: <Widget>[
  //       new TextButton(
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //           setState(() {});
  //         },
  //         child: const Text('Apply'),
  //       ),
  //       new TextButton(
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         },
  //         child: const Text('Close'),
  //       ),
  //     ],
  //   );
  // }

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
            tooltip: "Settings",
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
                      builder: (context) => SearchPage(
                          token: token.session, dataSaver: widget.dataSaver),
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
                onTap: () {
                  Navigator.pop(context);
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
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
                                  token: token.session,
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
                        child: (followedManga.data!.total > 10)
                            ? Row(
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
                                            (followedManga.data!.total ~/ 10)) {
                                          setState(() {
                                            resultOffset++;
                                          });
                                        }
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward,
                                      ))
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
