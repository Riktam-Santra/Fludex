import 'package:fludex/saveDataModels/settings.dart';
import 'package:fludex/utils.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool lightMode;
  final Settings settings;
  const SettingsPage(
      {Key? key, required this.lightMode, required this.settings})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool dataSaver;
  late bool lightMode;

  void initState() {
    super.initState();
    dataSaver = false;
    lightMode = widget.settings.lightMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: lightMode ? Colors.black : Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor:
            lightMode ? Colors.white : Color.fromARGB(255, 18, 18, 18),
        title: Text(
          'Settings',
          style: TextStyle(color: lightMode ? Colors.black : Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FludexUtils().saveSettings(lightMode, dataSaver);
              showBanner();
            },
            icon: Icon(Icons.check,
                color: lightMode ? Colors.black : Colors.white),
          ),
        ],
      ),
      backgroundColor:
          lightMode ? Colors.white : Color.fromARGB(255, 18, 18, 18),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        color: lightMode ? Colors.white : Color.fromARGB(255, 18, 18, 18),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Container(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.data_saver_on,
                      color: lightMode ? Colors.grey : Colors.white),
                  title: Text(
                    'Data saver',
                    style: TextStyle(
                        color: lightMode ? Colors.black : Colors.white),
                  ),
                  trailing: Switch(
                    activeColor: lightMode ? null : Colors.black87,
                    activeTrackColor: lightMode ? null : Colors.black12,
                    inactiveThumbColor: lightMode ? null : Colors.black87,
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
                  leading: Icon(Icons.light_mode,
                      color: lightMode ? Colors.grey : Colors.white),
                  title: Text(
                    'Light mode',
                    style: TextStyle(
                        color: lightMode ? Colors.black : Colors.white),
                  ),
                  trailing: Switch(
                    activeColor: lightMode ? null : Colors.black87,
                    activeTrackColor: lightMode ? null : Colors.black12,
                    inactiveThumbColor: lightMode ? null : Colors.black87,
                    value: lightMode,
                    onChanged: (value) {
                      setState(() {
                        lightMode = value;
                      });
                      print(lightMode);
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

  void showBanner() =>
      ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
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
          ]));
}
