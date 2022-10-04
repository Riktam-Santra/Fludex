import 'dart:ui';

import 'package:fludex/pages/library/library.dart';
import 'package:fludex/services/controllers/animation_controllers/login_page_anim_controller.dart';
import 'package:fludex/services/data_models/settings_data/settings.dart';
import 'package:fludex/services/data_models/user_data/login_data.dart';
import 'package:fludex/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/models/login/Login.dart';

void main() {
  runApp(MainPage());
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FludexUtils().getSettings(),
        builder: (context, AsyncSnapshot<Settings?> settings) {
          if (settings.connectionState == ConnectionState.done) {
            return MaterialApp(
              scrollBehavior: MyCustomScrollBehavior(),
              debugShowCheckedModeBanner: false,
              theme: ((settings.data == null) ? true : settings.data!.lightMode)
                  ? ThemeData(
                      primaryColor: Color.fromARGB(255, 255, 103, 64),
                      primarySwatch: createMaterialColor(
                        Color(0xFFFF6740),
                      ),
                    )
                  : ThemeData.dark().copyWith(
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Color.fromARGB(255, 255, 103, 64),
                        ),
                      ),
                      primaryColor: Color.fromARGB(255, 255, 103, 64),
                      progressIndicatorTheme: ProgressIndicatorThemeData(
                        color: Color.fromARGB(255, 255, 103, 64),
                      ),
                      floatingActionButtonTheme: FloatingActionButtonThemeData(
                        backgroundColor: Color.fromARGB(255, 255, 103, 64),
                        extendedTextStyle: TextStyle(color: Colors.white),
                      ),
                      elevatedButtonTheme: ElevatedButtonThemeData(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(10),
                          backgroundColor: Color.fromARGB(255, 255, 103, 64),
                        ),
                      ),
                    ),
              home: Scaffold(
                body: FutureBuilder(
                    future: FludexUtils().getLoginData(),
                    builder: (context, AsyncSnapshot<LoginData?> loginData) {
                      if (loginData.connectionState == ConnectionState.done) {
                        if (loginData.data != null) {
                          return Library(
                            dataSaver: settings.data!.dataSaver,
                          );
                        } else {
                          return LoginPageAnimator();
                        }
                      } else {
                        return Container();
                      }
                    }),
              ),
            );
          } else {
            return MaterialApp(
              home: Scaffold(
                body: Container(),
              ),
            );
          }
        });
  }
}

MaterialColor createMaterialColor(Color color) {
  // taken from https://medium.com/@filipvk/creating-a-custom-color-swatch-in-flutter-554bcdcb27f3
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
