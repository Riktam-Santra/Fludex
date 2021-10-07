import 'package:fludex/constants.dart';
import 'package:flutter/material.dart';

class AboutFludex extends StatefulWidget {
  const AboutFludex({Key? key}) : super(key: key);

  @override
  _AboutFludexState createState() => _AboutFludexState();
}

class _AboutFludexState extends State<AboutFludex> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text(
          'About',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Container(
          color: Color.fromARGB(18, 255, 255, 255),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Fludex',
                      style: Constants().normalTextStyle.copyWith(fontSize: 50),
                    ),
                    Text('A very basic manga reader',
                        style: Constants().normalTextStyle),
                    Text('Version: 0.0.8', style: Constants().normalTextStyle),
                    Text('Powered by Mangadex',
                        style: Constants().normalTextStyle),
                    Text('Made possbile by Flutter',
                        style: Constants().normalTextStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
