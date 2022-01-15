import 'package:flutter/cupertino.dart';

class HomePageEnterAnimation {
  HomePageEnterAnimation(this.controller)
      : barheight = Tween<double>(begin: 0, end: 500).animate(CurvedAnimation(
            parent: controller,
            curve: const Interval(0, 0.3, curve: Curves.easeIn))),
        iconOpacity = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0, 0.2, curve: Curves.easeIn),
          ),
        ),
        iconAlignment =
            Tween<Alignment>(begin: Alignment.center, end: Alignment.topCenter)
                .animate(CurvedAnimation(
                    parent: controller,
                    curve: const Interval(0.2, 0.4, curve: Curves.ease))),
        mainContainerOpacity = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.4, 0.6, curve: Curves.easeIn),
          ),
        ),
        loginTextOpacity = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
          ),
        ),
        textFieldOpacity = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.8, 1, curve: Curves.easeIn),
          ),
        ),
        loginButtonOpacity = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.9, 1, curve: Curves.easeIn),
          ),
        );

  final AnimationController controller;
  final Animation<double> barheight;
  final Animation<Alignment> iconAlignment;
  final Animation<double> mainContainerOpacity;
  final Animation<double> loginTextOpacity;
  final Animation<double> textFieldOpacity;
  final Animation<double> loginButtonOpacity;
  final Animation<double> iconOpacity;
}
