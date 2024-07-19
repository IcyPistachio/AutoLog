import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_page.dart';
import 'constants.dart' as constants;

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  int userId;
  String firstName, lastName, email;

  ProfilePage(
      {required this.userId,
      required this.firstName,
      required this.lastName,
      required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

enum FormInputType { firstName, lastName, email }

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _changeName(String newFirstName, String newLastName) async {
    final response = await http.post(
      Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/changename'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': widget.userId,
        'firstName': newFirstName,
        'lastName': newLastName,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['error'] != '') {
        setState(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(constants.errorSnackBar(responseBody['error']));
        });
      } else {
        setState(() {
          // Update the local state with new names
          widget.firstName = newFirstName;
          widget.lastName = newLastName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            constants.defaultSnackBar('Name updated successfully.'));
      }
    } else {}
  }

  Widget _profileTextField(String label, TextEditingController control) {
    return TextFormField(
        controller: control,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
            labelText: label,
            labelStyle: const TextStyle(
                color: constants.darkgray, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: constants.lightslategray,
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: constants.orange, width: 2.0),
            ),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: constants.darkgray, width: 2.0))),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
  }

  Future<void> _openForgotPasswordPage() async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
              'Are you sure you want to go to the reset password page?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false when cancel button is clicked
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true when yes button is clicked
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _firstNameController =
        TextEditingController(text: widget.firstName);
    final TextEditingController _lastNameController =
        TextEditingController(text: widget.lastName);
    final TextEditingController _emailController =
        TextEditingController(text: widget.email);
    return Scaffold(
        appBar: AppBar(
            backgroundColor: constants.slategray,
            centerTitle: true,
            title: Image.asset('assets/logo.png', height: 60)),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _profileTextField('First Name', _firstNameController),
              const SizedBox(height: 20),
              _profileTextField('Last Name', _lastNameController),
              const SizedBox(height: 20),
              TextField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                          color: constants.darkgray,
                          fontWeight: FontWeight.bold),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20.0),
              OutlinedButton(
                onPressed: () {
                  _changeName(
                      _firstNameController.text, _lastNameController.text);
                },
                style: constants.accentButtonStyle,
                child:
                    const Text('UPDATE NAME', style: constants.buttonTextStyle),
              ),
              OutlinedButton(
                style: constants.defaultButtonStyle,
                onPressed: _openForgotPasswordPage,
                child: const Text('RESET PASSWORD',
                    style: constants.buttonTextStyle),
              ),
              Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          margin: const EdgeInsets.all(30),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                  (Route route) => false);
                            },
                            child: const Text('LOG OUT',
                                style: TextStyle(
                                    color: constants.red,
                                    fontWeight: FontWeight.bold)),
                          )))),
            ],
          ),
        ));
  }
}
