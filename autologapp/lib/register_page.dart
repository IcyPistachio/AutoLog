import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import 'dart:convert';
import 'constants.dart' as constants;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

enum FormInputType { first, last, email }

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  String _confirmationMessage = '';
  bool _passwordsMatch = false;
  bool _showPasswordRequirements = false;
  bool _isPasswordValid = false;

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch =
          _confirmPasswordController.text == _passwordController.text;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _isPasswordValid = _isPasswordCompliant(value);
      _showPasswordRequirements = !_isPasswordValid;
    });
  }

  bool _isPasswordCompliant(String password) {
    if (password.isEmpty) {
      return false;
    }

    final passwordRegExp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _register() async {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    final response = await http.post(
      Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody.containsKey('error')) {
        setState(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(constants.errorSnackBar(responseBody['error']));
        });
      } else if (responseBody.containsKey('message')) {
        setState(() {
          _confirmationMessage = responseBody['message'];
          _clearForm();
        });
      } else {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
              constants.errorSnackBar('Unexpected error occurred'));
        });
      }
    } else {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
            constants.errorSnackBar('User with this email already exists'));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() {
      setState(() {
        _showPasswordRequirements = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildValidatorIcon(bool requirementsMet) {
    return requirementsMet
        ? const Icon(Icons.check_circle, color: constants.green)
        : const Icon(Icons.cancel, color: constants.red);
  }

  Widget _registerFormInput(FormInputType formInputType) {
    String? inputLabelText;
    TextEditingController? controller;

    switch (formInputType) {
      case FormInputType.first:
        controller = _firstNameController;
        inputLabelText = 'First Name';
        break;
      case FormInputType.last:
        controller = _lastNameController;
        inputLabelText = 'Last Name';
        break;
      case FormInputType.email:
        controller = _emailController;
        inputLabelText = 'Email';
        break;
      default:
    }

    String? formValidator(String? value) {
      // Empty validator
      if (value == null || value.isEmpty) {
        return '*Required';
      }

      if (formInputType == FormInputType.email) {
        return !EmailValidator.validate(value.toString())
            ? '*Invalid email'
            : null;
      }

      return null;
    }

    return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
          filled: true,
          fillColor: constants.lightslategray,
          labelStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          labelText: inputLabelText,
          errorStyle: constants.errorTextStyle,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: constants.darkgray, width: 2.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
          ),
        ),
        style: const TextStyle(
            color: constants.darkgray, fontWeight: FontWeight.bold),
        validator: formValidator);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: constants.lightslategray,
          centerTitle: true,
          title: Image.asset(
            'assets/logo.png',
            height: 60,
          )),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const Center(
                  child: Text("REGISTER", style: constants.headerTextStyle)),
              Row(children: [
                Expanded(child: _registerFormInput(FormInputType.first)),
                const SizedBox(width: 20.0),
                Expanded(child: _registerFormInput(FormInputType.last))
              ]),
              const SizedBox(height: 20.0),
              _registerFormInput(FormInputType.email),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 3.0, horizontal: 10.0),
                  filled: true,
                  fillColor: constants.lightslategray,
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  errorStyle: constants.errorTextStyle,
                  suffixIcon: _buildValidatorIcon(_isPasswordValid),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: constants.darkgray, width: 2.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                  ),
                ),
                style: const TextStyle(
                    color: constants.darkgray, fontWeight: FontWeight.bold),
                obscureText: true,
                focusNode: _passwordFocusNode,
                onChanged: (value) {
                  _validatePassword(value);
                  _checkPasswordsMatch(); // Update passwords match status
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                  if (!_isPasswordValid) {
                    return '*Invalid password';
                  }
                  return null;
                },
              ),
              Visibility(
                visible: _showPasswordRequirements,
                child: const Text(
                    "Password must be 8-20 characters, with at least one uppercase, lowercase, number, and symbol.",
                    style: constants.errorTextStyle),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 3.0, horizontal: 10.0),
                  filled: true,
                  fillColor: constants.lightslategray,
                  labelStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  labelText: 'Confirm Password',
                  errorStyle: constants.errorTextStyle,
                  suffixIcon: _buildValidatorIcon(_passwordsMatch),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: constants.darkgray, width: 2.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                  ),
                ),
                style: const TextStyle(
                    color: constants.darkgray, fontWeight: FontWeight.bold),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                  if (value != _passwordController.text) {
                    return '*Passwords do not match';
                  }
                  return null;
                },
                onChanged: (value) {
                  _checkPasswordsMatch(); // Update passwords match status
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register();
                  }
                },
                style: constants.accentButtonStyle,
                child: const Text('Register', style: constants.buttonTextStyle),
              ),
              const SizedBox(height: 20.0),
              Text(
                _confirmationMessage,
                style: const TextStyle(color: constants.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
