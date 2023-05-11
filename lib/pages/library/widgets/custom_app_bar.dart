import 'package:flutter/material.dart';
import 'package:mangadex_library/models/user/logged_user_details/logged_user_details.dart';

import '../../../services/api/mangadex/library_functions.dart';
import '../../../services/controllers/animation_controllers/login_page_anim_controller.dart';
import '../../../utils/utils.dart';
import '../../about/aboutFludex.dart';
import '../../saucenao/saucenao_page.dart';
import '../../search/search_page.dart';

class CustomAppBar extends StatefulWidget {
  final dataSaver;

  const CustomAppBar({Key? key, required this.dataSaver}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Drawer build(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          children: [
            Container(
              child: Center(
                child: FutureBuilder(
                    future: LibraryFunctions.getLoggedUserDetails(),
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
                                    snapshot.data!.data!.attributes!.username!
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
                                snapshot.data!.data!.attributes!.username!,
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
                style: TextStyle(
                  fontSize: 16,
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
              ),
              title: Text(
                'Search Manga',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SearchPage(dataSaver: widget.dataSaver),
                  ),
                );
              },
            ),
            ListTile(
              leading: SizedBox(
                height: 24,
                width: 24,
                child: Image(
                  image: AssetImage('data/media/SauceNAO_ico.png'),
                  color: widget.dataSaver ? Colors.grey : Colors.white,
                ),
              ),
              title: Text('SauceNAO'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SaucenaoSearch()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
              ),
              title: Text(
                'Logout',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () async {
                Navigator.pop(context);
                FludexUtils().disposeLoginData();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPageAnimator(),
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
                style: TextStyle(fontSize: 16),
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
    );
  }
}
