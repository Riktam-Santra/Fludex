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
        title: Text(
          'About',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Container(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Fludex',
                        style: TextStyle(
                          fontSize: 50,
                        )),
                    Text(
                      'A very basic manga reader',
                    ),
                    Text(
                      'Version: 0.1.2',
                    ),
                    Text(
                      'Powered by Mangadex',
                    ),
                    Text(
                      'Made possbile by Flutter',
                    ),
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
