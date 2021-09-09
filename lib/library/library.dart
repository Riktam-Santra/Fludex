import 'package:fludex/search/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:mangadex_library/user/user_followed_manga/user_followed_manga.dart';
import '/search/searchResultHolder.dart';

class Library extends StatefulWidget {
  final String token;
  Library({required this.token});
  _Library createState() => _Library(token);
}

class _Library extends State<Library> {
  final String token;
  _Library(this.token);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        // leading: Icon(
        //   Icons.library_books,
        // ),
        title: Text('Library'),
      ),
      drawer: Drawer(
        child: Container(
          color: Color.fromARGB(255, 18, 18, 18),
          child: ListView(
            children: [
              Container(
                height: 50,
                child: Center(
                  child: Text(
                    'Fludex',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                color: Colors.redAccent,
              ),
              ListTile(
                leading: Icon(
                  Icons.library_books,
                  color: Colors.white,
                ),
                title: Text(
                  'Library',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                title: Text(
                  'Search Manga',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(token: token),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      body: Container(
        child: FutureBuilder(
          future: lib.getUserFollowedManga(token),
          builder: (context, AsyncSnapshot<UserFollowedManga> searchData) {
            if (searchData.connectionState == ConnectionState.done) {
              if (searchData.hasError) {
                return Container(
                  child: Center(
                    child: Text(
                      'Something went wrong :\'(',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                );
              } else if (searchData.data!.results.length == 0) {
                print(searchData.data!.results.length);
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
                return Container(
                    child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisExtent: 300,
                          crossAxisCount: 2,
                        ),
                        itemCount: searchData.data!.results.length,
                        itemBuilder: (BuildContext context, index) {
                          for (int i = 0;
                              i <
                                  searchData.data!.results[index].data
                                      .attributes.tags.length;
                              i++) {
                            tags.add(searchData.data!.results[index].data
                                .attributes.tags[i].attributes.name.en);
                          }
                          return SearchResultHolder(
                            token: token,
                            description: searchData.data!.results[index].data
                                .attributes.description.en,
                            title: searchData
                                .data!.results[index].data.attributes.title.en,
                            mangaID: searchData.data!.results[index].data.id,
                            baseUrl: 'https://uploads.mangadex.org',
                            tags: tags,
                          );
                        }));
              }
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Container(
                    child: LinearProgressIndicator(
                      backgroundColor: Color.fromARGB(255, 18, 18, 18),
                      color: Colors.white,
                    ),
                    height: 30,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
