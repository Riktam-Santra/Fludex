import 'package:flutter/material.dart';

class SaucenaoSearch extends StatefulWidget {
  const SaucenaoSearch({Key? key}) : super(key: key);

  @override
  State<SaucenaoSearch> createState() => _SaucenaoSearchState();
}

class _SaucenaoSearchState extends State<SaucenaoSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Image(
                image: AssetImage('data/media/SauceNAO_banner.png'),
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
              height: 500,
              width: 500,
              child: Card(
                child: PageView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                                "Has it ever occured to you that you find a manga page and you don't know from which manga it was?"),
                          ),
                          Center(
                            child: Text(
                                "Well, now you can find them all! It's easy! Just "),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
