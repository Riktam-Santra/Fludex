import 'package:flutter/material.dart';

import 'home_page.dart';

class HomePageAnimator extends StatefulWidget {
  const HomePageAnimator({Key? key}) : super(key: key);

  @override
  _HomePageAnimatorState createState() => _HomePageAnimatorState();
}

class _HomePageAnimatorState extends State<HomePageAnimator>
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
    return HomePage(
      controller: _controller,
    );
  }
}
