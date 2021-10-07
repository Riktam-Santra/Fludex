import 'dart:io';
import 'package:fludex/library/library.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;

import '../utils.dart';

class UserLogin extends StatefulWidget {
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  late String password;
  late String username;
  late File dataFile;

  String loginText = '';
  bool hasPressedLogIn = false;
  var loginData;

  FludexUtils utils = FludexUtils();

  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          height: 500,
          width: 500,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 25, 25, 25),
            boxShadow: [
              BoxShadow(blurRadius: 5, spreadRadius: 0.2, offset: Offset(1, 1))
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: Colors.redAccent,
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
                    ? Center(
                        child: Container(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$loginText',
                            style: TextStyle(color: Colors.white),
                          ),
                          Container(
                            width: 280,
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              obscureText: false,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                hintText: 'Username',
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white, width: 1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onChanged: (value) {
                                setState(
                                  () {
                                    username = value;
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 280,
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              obscureText: true,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                hintText: 'Password',
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.white, width: 1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onChanged: (value) {
                                setState(
                                  () {
                                    password = value;
                                  },
                                );
                              },
                              onEditingComplete: () async {
                                if (password == '' && username == '' ||
                                    password == '' ||
                                    username == '') {
                                  setState(() {
                                    loginText = 'username or password empty';
                                  });
                                } else {
                                  setState(() {
                                    hasPressedLogIn = true;
                                  });
                                  var loginData =
                                      await lib.login(username, password);
                                  if (loginData!.result == 'ok') {
                                    print(hasPressedLogIn);
                                    print('got loginData');

                                    print(loginData.token.session);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Library(
                                          token: loginData.token.session,
                                        ),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      loginText =
                                          'Username or Password incorrect.';
                                    });
                                  }
                                }
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
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 28),
                              ),
                            ),
                            onTap: () async {
                              if (password == '' && username == '' ||
                                  password == '' ||
                                  username == '') {
                                setState(() {
                                  loginText = 'username or password empty';
                                });
                              } else {
                                setState(() {
                                  hasPressedLogIn = true;
                                });
                                var loginData =
                                    await lib.login(username, password);
                                if (loginData!.result == 'ok') {
                                  print(hasPressedLogIn);
                                  print('got loginData');
                                  utils.saveLoginData(
                                      username,
                                      password,
                                      loginData.token.session,
                                      loginData.token.refresh);
                                  print('saved login data');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Library(
                                        token: loginData.token.refresh,
                                      ),
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    loginText =
                                        'Username or Password incorrect.';
                                  });
                                }
                                setState(() {
                                  hasPressedLogIn = false;
                                });
                              }
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
