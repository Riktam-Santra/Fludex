import 'dart:io';
import 'dart:ui';
import 'package:fludex/library/library.dart';
import 'package:flutter/material.dart';
import 'package:mangadex_library/mangadex_library.dart' as lib;

import '../utils.dart';

class UserLogin extends StatefulWidget {
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  String password = '';
  String username = '';

  String loginText = '';
  bool lightMode = true;
  bool dataSaver = false;
  bool hasPressedLogIn = false;
  bool isOnLogin = false;

  void initState() {
    super.initState();
    setData();
  }

  void setData() async {
    var content = await FludexUtils().getSettings();
    lightMode = content.lightMode;
    dataSaver = content.dataSaver;
    //print('$lightMode $dataSaver');
  }

  FludexUtils utils = FludexUtils();

  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Color.fromARGB(255, 18, 18, 18),
      child: Stack(
        children: [
          Container(
            child: lightMode
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Row(
                        children: [
                          Image(
                            image: AssetImage('data/media/1.jpg'),
                            fit: BoxFit.cover,
                          ),
                          Image(
                            image: AssetImage('data/media/2.jpg'),
                            fit: BoxFit.cover,
                          ),
                          Image(
                            image: AssetImage(
                              'data/media/3.jpg',
                            ),
                            fit: BoxFit.cover,
                          )
                        ],
                      ),
                    ),
                  )
                : null,
          ),
          Center(
            child: Hero(
              tag: 'login_transition',
              child: Material(
                child: Container(
                  height: 500,
                  width: 500,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: lightMode
                            ? Color.fromARGB(255, 29, 29, 29)
                            : Color.fromARGB(255, 255, 103, 64),
                        width: 50,
                      ),
                    ),
                    color: lightMode
                        ? Colors.white
                        : Color.fromARGB(18, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5,
                          spreadRadius: 0.2,
                          offset: Offset(1, 1))
                    ],
                    //borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: hasPressedLogIn
                            ? Center(
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  child: CircularProgressIndicator(
                                    color: lightMode
                                        ? Color.fromARGB(255, 255, 103, 64)
                                        : Colors.white,
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Login to your mangadex account!',
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: lightMode
                                            ? Colors.black
                                            : Colors.white),
                                  ),
                                  SizedBox(
                                    height: 75,
                                  ),
                                  Text(
                                    '$loginText',
                                    style: TextStyle(
                                      color: lightMode
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 280,
                                          child: TextField(
                                            style: lightMode
                                                ? null
                                                : TextStyle(
                                                    color: Colors.white),
                                            cursorColor:
                                                lightMode ? null : Colors.white,
                                            obscureText: false,
                                            decoration: lightMode
                                                ? InputDecoration(
                                                    hintText: 'Username',
                                                  )
                                                : InputDecoration(
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      borderSide: BorderSide(
                                                          color: Colors.white),
                                                    ),
                                                    hintText: 'Username',
                                                    hintStyle: TextStyle(
                                                        color: Colors.white),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white,
                                                          width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
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
                                            style: lightMode
                                                ? null
                                                : TextStyle(
                                                    color: Colors.white),
                                            cursorColor:
                                                lightMode ? null : Colors.white,
                                            obscureText: true,
                                            decoration: lightMode
                                                ? InputDecoration(
                                                    hintText: 'Password',
                                                  )
                                                : InputDecoration(
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      borderSide: BorderSide(
                                                          color: Colors.white),
                                                    ),
                                                    hintText: 'Password',
                                                    hintStyle: TextStyle(
                                                        color: Colors.white),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white,
                                                          width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
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
                                              if (password == '' &&
                                                      username == '' ||
                                                  password == '' ||
                                                  username == '') {
                                                setState(() {
                                                  loginText =
                                                      'username or password empty';
                                                });
                                              } else {
                                                setState(() {
                                                  hasPressedLogIn = true;
                                                });
                                                var loginData = await lib.login(
                                                    username, password);
                                                if (loginData!.result == 'ok') {
                                                  print(hasPressedLogIn);
                                                  print('got loginData');
                                                  print(
                                                      loginData.token.session);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Library(
                                                        token: loginData.token,
                                                        lightMode: lightMode,
                                                        dataSaver: dataSaver,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  setState(() {
                                                    loginText =
                                                        'Username or Password incorrect.';
                                                    hasPressedLogIn = false;
                                                  });
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  InkWell(
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 150),
                                      padding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: 10,
                                          bottom: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: lightMode
                                              ? Color.fromARGB(255, 29, 29, 29)
                                              : Color.fromARGB(
                                                  255, 255, 103, 64),
                                        ),
                                        color: lightMode
                                            ? (isOnLogin
                                                ? Colors.white
                                                : Color.fromARGB(
                                                    255, 29, 29, 29))
                                            : (isOnLogin
                                                ? Colors.white
                                                : Color.fromARGB(
                                                    255, 255, 103, 64)),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                            color: lightMode
                                                ? (isOnLogin
                                                    ? Colors.black
                                                    : Colors.white)
                                                : (isOnLogin
                                                    ? Color.fromARGB(
                                                        255, 255, 103, 64)
                                                    : Colors.white),
                                            fontSize: 28),
                                      ),
                                    ),
                                    onTap: () async {
                                      if (password == '' && username == '' ||
                                          password == '' ||
                                          username == '') {
                                        setState(() {
                                          loginText =
                                              'username or password empty';
                                        });
                                      } else {
                                        setState(() {
                                          hasPressedLogIn = true;
                                        });
                                        var loginData =
                                            await lib.login(username, password);
                                        if (loginData!.result == 'ok') {
                                          print('got loginData');
                                          // utils.saveLoginData(
                                          //     username,
                                          //     password,
                                          //     loginData.token.session,
                                          //     loginData.token.refresh);
                                          //print('saved login data');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Library(
                                                token: loginData.token,
                                                lightMode: lightMode,
                                                dataSaver: dataSaver,
                                              ),
                                            ),
                                          );
                                          setState(() {
                                            hasPressedLogIn = false;
                                          });
                                        } else {
                                          setState(() {
                                            hasPressedLogIn = false;
                                            loginText =
                                                'Username or Password incorrect.';
                                          });
                                        }
                                        setState(() {
                                          hasPressedLogIn = false;
                                        });
                                      }
                                    },
                                    onHover: (value) {
                                      setState(() {
                                        isOnLogin = value;
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
            ),
          ),
        ],
      ),
    ));
  }
}
