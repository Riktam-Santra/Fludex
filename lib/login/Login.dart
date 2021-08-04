import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;
import 'package:fludex/homepage.dart';

class Login extends StatefulWidget {
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String password;
  late String username;
  bool hasPressedLogIn = false;
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          height: 500,
          width: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(blurRadius: 5, spreadRadius: 0.2, offset: Offset(1, 1))
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 103, 64),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Center(
                    child: Text(
                      'Login to your mangadex account!',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  height: 100,
                  width: double.infinity),
              SizedBox(
                height: 100,
              ),
              Center(
                child: hasPressedLogIn
                    ? Container(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 255, 103, 64),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 280,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextField(
                              obscureText: false,
                              decoration: InputDecoration(
                                fillColor: Color.fromARGB(255, 255, 103, 64),
                                hintText: 'Username',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  username = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                fillColor: Color.fromARGB(255, 255, 103, 64),
                                hintText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 255, 103, 64),
                                  borderRadius: BorderRadius.circular(50)),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 28),
                              ),
                            ),
                            onTap: () async {
                              var loginData =
                                  await lib.login(username, password);
                              setState(() {
                                // print('Username: ' + username);
                                // print('Password: ' + password);
                                if (password == '' && username == '' ||
                                    password == '' ||
                                    username == '') {
                                  print('username or password empty');
                                } else {
                                  hasPressedLogIn = true;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(
                                        token: loginData.token.session,
                                      ),
                                    ),
                                  );
                                }
                              });
                            },
                          )
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
