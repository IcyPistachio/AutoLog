import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const slategray = Color(0xFF708090);
const lightslategray = Color(0xFF778899);
const darkgray = Color(0xFF2E343B);
const lightgray = Color(0xFFD9D9D9);
const orange = Color(0xFFFF9400);
const red = Color(0xFF800000);
const green = Color(0xFF113321);
const blue = Color(0xFF00008B);

// Text Styles
const headerTextStyle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: darkgray,
    height: 3,
    shadows: <Shadow>[
      Shadow(
          offset: Offset(2.0, 2.0),
          blurRadius: 1.0,
          color: Color.fromARGB(59, 18, 21, 24))
    ]);
const header2TextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkgray,
    shadows: <Shadow>[
      Shadow(
          offset: Offset(2.0, 2.0),
          blurRadius: 1.0,
          color: Color.fromARGB(59, 18, 21, 24))
    ]);
const header3TextStyle =
    TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white);
const subHeaderTextStyle =
    TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold);
const subHeader2TextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkgray);
const buttonTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black);
const errorTextStyle =
    TextStyle(fontSize: 12, color: red, fontWeight: FontWeight.bold);

// Button Styles
final accentButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(orange),
    foregroundColor: WidgetStateProperty.all(Colors.black),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)))));
final defaultButtonStyle = ButtonStyle(
    foregroundColor: WidgetStateProperty.all(Colors.black),
    side: WidgetStateProperty.all<BorderSide>(
        const BorderSide(color: Colors.black, width: 2)),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)))));
final roundButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(darkgray),
    foregroundColor: WidgetStateProperty.all(lightslategray),
    shape: WidgetStateProperty.all<CircleBorder>(const CircleBorder()));

// SnackBar
SnackBar errorSnackBar(String errMsg) {
  return SnackBar(
      content: Row(children: <Widget>[
        const Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,
        ),
        const SizedBox(width: 5),
        Text(errMsg, style: const TextStyle(fontSize: 12, color: Colors.white))
      ]),
      padding: const EdgeInsets.all(15));
}
