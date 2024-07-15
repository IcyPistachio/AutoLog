import 'package:flutter/material.dart';

import 'constants.dart' as constants;
import 'splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoLog',
      theme: ThemeData(
        fontFamily: 'Monaco',
        scaffoldBackgroundColor: constants.slategray,
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
