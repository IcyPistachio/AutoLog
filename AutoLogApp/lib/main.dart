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
        scaffoldBackgroundColor: constants.lightslategray,
        primarySwatch: Colors.blue,
        iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
                iconColor: WidgetStateProperty.all(constants.darkgray))),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: constants.darkgray,
        ),
        highlightColor: constants.orange,
        dialogTheme: const DialogTheme(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)))),
      ),
      home: const SplashScreen(),
    );
  }
}
