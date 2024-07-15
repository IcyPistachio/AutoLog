import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'constants.dart' as constants;
import 'profile_page.dart';
import 'carInfo_page.dart';

// ignore: must_be_immutable
class CarUI extends StatefulWidget {
  int userId;
  String firstName, lastName, email;

  CarUI(
      {required this.userId,
      required this.firstName,
      required this.lastName,
      required this.email});

  @override
  _CarUIState createState() => _CarUIState();
}

class _CarUIState extends State<CarUI> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _cars = [];
  String _errorMessage = '';
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  Future<void> _searchCars(String search) async {
    final response = await http.post(
      Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/searchcars'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': widget.userId,
        'search': search,
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
          _cars = responseBody['results'];
          _errorMessage = '';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _addCar() async {
    final make = _makeController.text;
    final model = _modelController.text;
    final year = _yearController.text;
    final odometer = _odometerController.text;
    final color = _colorController.text;

    final response = await http.post(
      Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/addcar'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': widget.userId,
        'make': make,
        'model': model,
        'year': year,
        'odometer': odometer,
        'color': color,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['error'] != '') {
        setState(() {
          _errorMessage = responseBody['error'];
        });
      } else {
        // Car added successfully, reset form and reload cars list
        setState(() {
          _errorMessage = '';
          _makeController.clear();
          _modelController.clear();
          _yearController.clear();
          _odometerController.clear();
          _colorController.clear();
        });
        _searchCars(''); // Refresh cars list
        Navigator.of(context).pop(); // Close the popup
      }
    } else {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _deleteCar(int carId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this vehicle?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                final response = await http.post(
                  Uri.parse(
                      'https://autolog-b358aa95bace.herokuapp.com/api/deletecar'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, dynamic>{
                    'userId': widget.userId,
                    'carId': carId,
                  }),
                );

                if (response.statusCode == 200) {
                  final responseBody = jsonDecode(response.body);
                  if (responseBody['error'] != '') {
                    setState(() {
                      _errorMessage = responseBody['error'];
                    });
                  } else {
                    // Car deleted successfully, refresh cars list
                    _searchCars('');
                  }
                } else {
                  setState(() {
                    _errorMessage = 'An error occurred. Please try again.';
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToCarInfo(int carId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarInfo(userId: widget.userId, carId: carId),
      ),
    );
    _searchCars(''); // Refresh cars list after returning from CarInfo
  }

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

  void _showAddCarDialog() {
    _makeController.clear();
    _modelController.clear();
    _yearController.clear();
    _odometerController.clear();
    _colorController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Vehicle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(labelText: 'Make'),
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              TextFormField(
                controller: _odometerController,
                decoration: const InputDecoration(labelText: 'Odometer'),
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
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
            ElevatedButton(
              child: const Text('Add Vehicle'),
              onPressed: () {
                _addCar();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _searchCars('');
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
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                          userId: widget.userId,
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                          email: widget.email)));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text("${widget.firstName}'s GARAGE",
                style: constants.subHeaderTextStyle),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Search Vehicles'),
              onChanged: (value) {
                _searchCars(value);
              },
            ),
            const SizedBox(height: 20.0),
            OutlinedButton(
                onPressed: () {
                  _showAddCarDialog();
                },
                style: constants.defaultButtonStyle,
                child: const Text('Add Vehicle',
                    style: constants.buttonTextStyle)),
            const SizedBox(height: 20.0),
            Expanded(
              child: _cars.isEmpty
                  ? Center(
                      child: Text(
                        _errorMessage.isNotEmpty
                            ? _errorMessage
                            : 'No vehicles found.',
                        style: const TextStyle(color: constants.red),
                      ),
                    )
                  : ListView.separated(
                      separatorBuilder: (context, index) =>
                          const Divider(color: constants.slategray),
                      itemCount: _cars.length,
                      itemBuilder: (context, index) {
                        final car = _cars[index];
                        return ListTile(
                          tileColor: constants.lightslategray,
                          title: Text(
                              '${car['year']} ${car['make']} ${car['model']}'),
                          subtitle: Text(
                              'Color: ${car['color']}, ODO: ${car['odometer']}'),
                          onTap: () {
                            _navigateToCarInfo(car['carId']);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteCar(car['carId']);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
