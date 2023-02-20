import 'package:flutter/material.dart';

import 'package:fludex/pages/library/widgets/custom_app_bar.dart';
import 'package:fludex/services/api/mangadex/library_functions.dart';
import 'package:fludex/services/data_models/user_data/login_data.dart';
import 'package:fludex/utils/utils.dart';
import 'package:fludex/pages/settings/settings_page.dart';
import 'package:fludex/pages/search/widgets/search_result_holder_widget.dart';
import 'package:fludex/services/controllers/animation_controllers/login_page_anim_controller.dart';

import 'package:mangadex_library/models/user/logged_user_details/logged_user_details.dart';
import 'package:mangadex_library/models/user/user_followed_manga/user_followed_manga.dart';
import 'package:mangadex_library/models/common/data.dart' as mangadat;

class Library extends StatefulWidget {
  final bool dataSaver;

  Library({required this.dataSaver});
  _Library createState() => _Library();
}

class _Library extends State<Library> {
  int gridCount = 2;
  int resultOffset = 0;
  bool gridView = false;
  bool lightMode = true;
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

  late Future<UserFollowedManga?> userLibrary;
  late Future<List<mangadat.Data>> filteredMangaList;
  late Future<UserDetails> userDetails;

  @override
  void initState() {
    super.initState();
    userLibrary = LibraryFunctions.getUserLibrary(
      (resultOffset * 10),
    );
    filteredMangaList = LibraryFunctions.filterManga(selectedValue);
    userDetails = LibraryFunctions.getLoggedUserDetails();

    FludexUtils()
        .getLightModeSetting()
        .then((value) => {lightMode = value ?? true});
  }

  Future<UserDetails> dummyDetails() async {
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
                filteredMangaList = LibraryFunctions.filterManga(selectedValue);
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
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
      drawer: CustomAppBar(dataSaver: widget.dataSaver),
      body: Hero(
        tag: 'login_transition',
        child: FutureBuilder(
            future: FludexUtils().getLoginData(),
            builder: (context, AsyncSnapshot<LoginData?> localtoken) {
              if (localtoken.connectionState == ConnectionState.done) {
                return Container(
                  child: (localtoken.data == null)
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
                                        builder: (context) =>
                                            LoginPageAnimator(),
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
                              AsyncSnapshot<UserFollowedManga?> followedManga) {
                            if (followedManga.connectionState ==
                                ConnectionState.done) {
                              if (followedManga.hasError) {
                                return Container(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Something went wrong :\'(',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(25),
                                          child: Text(
                                            'But you can try logging in again',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
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
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  18, 255, 255, 255)),
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
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                );
                              } else {
                                var tags = <String>[];
                                return Column(
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                  value: value);
                                            }).toList(),
                                            value: selectedValue,
                                            onChanged: (newValue) {
                                              setState(() {
                                                selectedValue =
                                                    newValue.toString();
                                              });
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: (localtoken.data == null)
                                          ? Center(
                                              child: Container(),
                                            )
                                          : FutureBuilder(
                                              future: filteredMangaList,
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<
                                                          List<mangadat.Data>>
                                                      allMangaStatus) {
                                                if (allMangaStatus
                                                        .connectionState ==
                                                    ConnectionState.done) {
                                                  return allMangaStatus
                                                              .data!.length ==
                                                          0
                                                      ? Center(
                                                          child: Text(
                                                            "Nothing found >:3",
                                                            style: TextStyle(
                                                                fontSize: 24),
                                                          ),
                                                        )
                                                      : SingleChildScrollView(
                                                          child: LayoutBuilder(
                                                              builder: (context,
                                                                  constraints) {
                                                            return Container(
                                                              child: GridView
                                                                  .builder(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                shrinkWrap:
                                                                    true,
                                                                gridDelegate:
                                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                                  mainAxisExtent:
                                                                      300,
                                                                  crossAxisCount: (constraints
                                                                              .maxWidth >
                                                                          908)
                                                                      ? ((gridView ==
                                                                              false)
                                                                          ? 2
                                                                          : 8)
                                                                      : ((constraints.maxWidth < 908 && gridView == true ||
                                                                              constraints.maxWidth < 908 ||
                                                                              gridView == true)
                                                                          ? 4
                                                                          : 2),
                                                                ),
                                                                itemCount:
                                                                    allMangaStatus
                                                                        .data!
                                                                        .length,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        index) {
                                                                  tags = [];
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          allMangaStatus
                                                                              .data![index]
                                                                              .attributes
                                                                              .tags
                                                                              .length;
                                                                      i++) {
                                                                    tags.add(allMangaStatus
                                                                        .data![
                                                                            index]
                                                                        .attributes
                                                                        .tags[i]
                                                                        .attributes
                                                                        .name
                                                                        .en);
                                                                  }
                                                                  return SearchResultHolder(
                                                                    gridView:
                                                                        gridView,
                                                                    mangaData:
                                                                        allMangaStatus
                                                                            .data![index],
                                                                    dataSaver:
                                                                        widget
                                                                            .dataSaver,
                                                                  );
                                                                },
                                                              ),
                                                            );
                                                          }),
                                                        );
                                                } else if (allMangaStatus
                                                    .hasError) {
                                                  return Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 100),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                              "Unable to fetch your library at the moment."),
                                                          TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                filteredMangaList =
                                                                    LibraryFunctions
                                                                        .filterManga(
                                                                            selectedValue);
                                                              });
                                                            },
                                                            child:
                                                                Text("Retry"),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                                    if (resultOffset * 10 !=
                                                        0) {
                                                      setState(
                                                        () {
                                                          resultOffset--;
                                                          userLibrary =
                                                              LibraryFunctions
                                                                  .getUserLibrary(
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
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Text(
                                                    '${resultOffset + 1}',
                                                  ),
                                                ),
                                                IconButton(
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    print(followedManga
                                                        .data!.total);
                                                    if (resultOffset * 10 <
                                                        (followedManga
                                                                .data!.total ~/
                                                            10)) {
                                                      setState(() {
                                                        resultOffset++;
                                                        userLibrary =
                                                            LibraryFunctions
                                                                .getUserLibrary(
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
                );
              } else if (localtoken.connectionState ==
                  ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                return Center(
                  child: Text("Something went wrong!"),
                );
              }
            }),
      ),
    );
  }
}
