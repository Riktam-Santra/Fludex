import 'package:fludex/login/home_page_animator.dart';
import 'package:fludex/utils.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MainPage());
}

Future<bool> getLightModeSetting() async {
  var settings = await FludexUtils().getSettings();
  return settings.lightMode;
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getLightModeSetting(),
        builder: (context, AsyncSnapshot<bool> lightMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: (lightMode.data ?? true)
                ? ThemeData(
                    primaryColor: Color.fromARGB(255, 255, 103, 64),
                    primarySwatch: createMaterialColor(Color(0xFFFF6740)))
                : ThemeData.dark().copyWith(
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
                        primary: Color.fromARGB(255, 255, 103, 64),
                      ),
                    ),
                  ),
            home: Scaffold(
              body: HomePageAnimator(),
            ),
          );
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
