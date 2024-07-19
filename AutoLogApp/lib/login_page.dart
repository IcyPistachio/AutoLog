import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart' as constants;
import 'register_page.dart';
import 'garage_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum FormInputType { email, password }

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(String email, String password) async {
    final response = await http.post(
      Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['error'] != '') {
        ScaffoldMessenger.of(context)
            .showSnackBar(constants.errorSnackBar(responseBody['error']));
      } else if (!responseBody['isVerified']) {
        ScaffoldMessenger.of(context)
            .showSnackBar(constants.errorSnackBar('Email not verified'));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CarUI(
                userId: responseBody['id'],
                firstName: responseBody['firstName'],
                lastName: responseBody['lastName'],
                email: email),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          constants.errorSnackBar('An error occurred. Please try again.'));
    }
  }

  Future<void> _openForgotPasswordPage() async {
    // Show confirmation dialog
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
              'Are you sure you want to go to the forgot password page?'),
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

    // If user confirms, open web browser
    if (confirm == true) {
      Uri url = Uri.parse(
          'https://autolog-b358aa95bace.herokuapp.com/forgot-password');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  Widget _loginFormInput(FormInputType formInputType) {
    String? inputLabelText;
    TextEditingController? controller;

    switch (formInputType) {
      case FormInputType.email:
        controller = _emailController;
        inputLabelText = 'Email';
        break;
      case FormInputType.password:
        controller = _passwordController;
        inputLabelText = 'Password';
        break;
      default:
    }

    String? emptyValidator(String? value) {
      return (value == null || value.isEmpty) ? '*Required' : null;
    }

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
        labelText: inputLabelText,
        labelStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        errorStyle: constants.errorTextStyle,
        filled: true,
        fillColor: constants.lightslategray,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: constants.orange, width: 2.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2.0),
        ),
      ),
      style: const TextStyle(
          color: constants.darkgray, fontWeight: FontWeight.bold),
      obscureText: formInputType == FormInputType.password,
      validator: emptyValidator,
    );
  }

  Widget _spacer() {
    return const SizedBox(height: 20.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: constants.slategray,
          centerTitle: true,
          title: Image.asset(
            'assets/logo.png',
            height: 60,
          )),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
            key: _formKey,
            child: Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                  const Center(
                      child: Text("LOG IN", style: constants.headerTextStyle)),
                  _spacer(),
                  _loginFormInput(FormInputType.email),
                  _spacer(),
                  _loginFormInput(FormInputType.password),
                  _spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login(_emailController.text, _passwordController.text);
                      }
                    },
                    style: constants.accentButtonStyle,
                    child: const Text('LOG IN ->',
                        style: constants.buttonTextStyle),
                  ),
                  TextButton(
                    onPressed: _openForgotPasswordPage,
                    child: const Text('Forgot Password?',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    style: constants.defaultButtonStyle,
                    child:
                        const Text('SIGN UP', style: constants.buttonTextStyle),
                  ),
                ]))),
      ),
    );
  }
}
