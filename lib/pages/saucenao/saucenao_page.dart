import 'package:fludex/pages/saucenao/widgets/img_picker.dart';
import 'package:fludex/services/data_models/settings_data/settings.dart';
import 'package:fludex/utils/utils.dart';
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
          FutureBuilder(
              future: FludexUtils().getSettings(),
              builder: (context, AsyncSnapshot<Settings?> settings) {
                if (settings.connectionState == ConnectionState.done) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Image(
                        image: AssetImage('data/media/SauceNAO_banner.png'),
                        color: settings.data!.lightMode
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Image(
                          image: AssetImage('data/media/SauceNAO_banner.png'),
                          color: Colors.black),
                    ),
                  );
                }
              }),
          SizedBox(
            width: 500,
            child: TextField(
              decoration: InputDecoration(hintText: 'Enter a URL'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: ImgFilePicker(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 25),
            child: ElevatedButton(
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Search",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
