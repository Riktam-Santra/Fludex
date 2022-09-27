import 'package:fludex/services/data_models/settings_data/settings.dart';
import 'package:fludex/utils/utils.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;
  const SettingsPage({Key? key, required this.settings}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool dataSaver;
  late bool lightMode;

  void initState() {
    super.initState();
    dataSaver = widget.settings.dataSaver;
    lightMode = widget.settings.lightMode;
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
            onPressed: () {
              FludexUtils().saveSettings(lightMode, dataSaver);
              showBanner();
            },
            icon: Icon(
              Icons.check,
            ),
          ),
        ],
      ),
      body: AnimatedContainer(
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
                    value: dataSaver,
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
                    value: lightMode,
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
      ),
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
