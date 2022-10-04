import 'package:fludex/services/data_models/settings_data/settings.dart';
import 'package:fludex/utils/utils.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool dataSaver;
  late bool lightMode;
  late Future<Settings?> settings;

  void initState() {
    super.initState();
    settings = FludexUtils().getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Settings',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FludexUtils().saveSettings(lightMode, dataSaver);
              showBanner();
            },
            icon: Icon(
              Icons.check,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
          future: settings,
          builder: (context, AsyncSnapshot<Settings?> settings) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 150),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Container(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.data_saver_on,
                        ),
                        title: Text(
                          'Data saver',
                        ),
                        trailing: Switch(
                          value: settings.data!.dataSaver,
                          onChanged: (value) {
                            setState(() {
                              dataSaver = value;
                            });
                            print(dataSaver);
                          },
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.light_mode,
                        ),
                        title: Text(
                          'Light mode',
                        ),
                        trailing: Switch(
                          value: settings.data!.lightMode,
                          onChanged: (value) {
                            setState(() {
                              lightMode = value;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  void showBanner() => ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content:
              Text('You may have to restart Fludex to apply your settings'),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: Text('Dismiss'),
              style: TextButton.styleFrom(),
            )
          ],
        ),
      );
}
