import 'package:flutter/material.dart';

import '../../../pages/login/login_page.dart';

class LoginPageAnimator extends StatefulWidget {
  const LoginPageAnimator({Key? key}) : super(key: key);

  @override
  _LoginPageAnimatorState createState() => _LoginPageAnimatorState();
}

class _LoginPageAnimatorState extends State<LoginPageAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginPage(
      controller: _controller,
    );
  }
}
