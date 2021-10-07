import 'dart:ui';
import 'package:flutter/material.dart';

class Background {
  final Widget backgroundWidget = ImageFiltered(
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
  );
}
