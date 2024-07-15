import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_page.dart';
import 'constants.dart' as constants;

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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String _errorMessage = '';

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
          _errorMessage = responseBody['error'];
        });
      } else {
        setState(() {
          // Update the local state with new names
          widget.firstName = newFirstName;
          widget.lastName = newLastName;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Name updated successfully.'),
          duration: Duration(seconds: 2),
        ));
      }
    } else {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  void _showNameChangeDialog() {
    final TextEditingController _firstNameController =
        TextEditingController(text: widget.firstName);
    final TextEditingController _lastNameController =
        TextEditingController(text: widget.lastName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                _changeName(
                    _firstNameController.text, _lastNameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: constants.lightslategray,
            centerTitle: true,
            title: Image.asset('assets/logo.png', height: 60)),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              Text('${widget.email}'),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _changeName(
                      _firstNameController.text, _lastNameController.text);
                },
                child: const Text('Update Name'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Reset Password'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route route) => false);
                },
                child: const Text('Log Out'),
              ),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ));
  }
}
