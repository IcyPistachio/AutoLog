import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart' as intl;

import 'constants.dart' as constants;

class CarInfo extends StatefulWidget {
  final int userId;
  final int carId;

  CarInfo({required this.userId, required this.carId});

  @override
  _CarInfoState createState() => _CarInfoState();
}

class _CarInfoState extends State<CarInfo> {
  Map<String, dynamic>? _carInfo;
  List<dynamic>? _carNotes;
  List<dynamic>? _filteredCarNotes;
  String _errorMessage = '';
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteTypeController = TextEditingController();
  final TextEditingController _noteMilesController = TextEditingController();
  final TextEditingController _noteTextController = TextEditingController();

  Future<void> _fetchCarInfo() async {
    final response = await http.post(
      Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/getcarinfo'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'carId': widget.carId,
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
          _carInfo = responseBody['car'];
          _errorMessage = '';
          _makeController.text = _carInfo!['make'];
          _modelController.text = _carInfo!['model'];
          _yearController.text = _carInfo!['year'];
          _odometerController.text = _carInfo!['odometer'];
          _colorController.text = _carInfo!['color'];
        });
      }
    } else {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _fetchCarNotes() async {
    final response = await http.post(
      Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/getcarnotes'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'carId': widget.carId,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      if (responseBody['error'] != '') {
        setState(() {
          _errorMessage = responseBody['error'];
        });
      } else {
        List<dynamic> notes = responseBody['notes'];
        // Sort notes by dateCreated in descending order
        notes.sort((a, b) => DateTime.parse(b['dateCreated'])
            .compareTo(DateTime.parse(a['dateCreated'])));

        setState(() {
          _carNotes = notes;
          _filteredCarNotes = _carNotes;
          _errorMessage = '';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _updateCarInfo(Map<String, dynamic> updatedInfo) async {
    final response = await http.post(
      Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/updatecar'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'carId': widget.carId,
        'make': updatedInfo['make'],
        'model': updatedInfo['model'],
        'year': updatedInfo['year'],
        'odometer': updatedInfo['odometer'],
        'color': updatedInfo['color'],
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
          _errorMessage = '';

          _fetchCarInfo(); // Refresh car info
          _fetchCarNotes(); // Refresh car notes
        });
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
                Navigator.pop(context);
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

  Future<void> _addNewNote() async {
    final response = await http.post(
      Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/addnote'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'carId': widget.carId,
        'note': _noteTextController.text,
        'type': _noteTypeController.text,
        'miles': _noteMilesController.text,
        'dateCreated': DateTime.now().toIso8601String(),
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
          _errorMessage = '';
          _noteTypeController.clear();
          _noteMilesController.clear();
          _noteTextController.clear();
          _fetchCarNotes(); // Refresh car notes
        });
      }
    } else {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  Future<void> _deleteNote(int noteId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
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
                Navigator.of(context).pop(); // Close the dialog
                final response = await http.post(
                  Uri.parse(
                      'https://autolog-b358aa95bace.herokuapp.com/api/deletenote'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, dynamic>{
                    'carId': widget.carId,
                    'noteId': noteId,
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
                      _errorMessage = '';
                      _fetchCarNotes(); // Refresh car notes after deletion
                    });
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

  Future<void> _updateNote(
      int noteId, String type, String miles, String note) async {
    final response = await http.post(
      Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/updatenote'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'carId': widget.carId,
        'noteId': noteId,
        'type': type,
        'miles': miles,
        'note': note,
        'dateCreated': DateTime.now().toIso8601String(),
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
          _errorMessage = '';
          _fetchCarNotes(); // Refresh car notes
        });
      }
    } else {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  void _showEditCarDialog() {
    // Create new controllers for the edit dialog
    final TextEditingController makeController =
        TextEditingController(text: _makeController.text);
    final TextEditingController modelController =
        TextEditingController(text: _modelController.text);
    final TextEditingController yearController =
        TextEditingController(text: _yearController.text);
    final TextEditingController odometerController =
        TextEditingController(text: _odometerController.text);
    final TextEditingController colorController =
        TextEditingController(text: _colorController.text);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Car Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: makeController,
                decoration: const InputDecoration(labelText: 'Make'),
              ),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              TextField(
                controller: odometerController,
                decoration: const InputDecoration(labelText: 'Odometer'),
              ),
              TextField(
                controller: colorController,
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
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                // Create a map with the updated values
                Map<String, dynamic> updatedInfo = {
                  'make': makeController.text,
                  'model': modelController.text,
                  'year': yearController.text,
                  'odometer': odometerController.text,
                  'color': colorController.text,
                };

                // Call _updateCarInfo with the updated values
                _updateCarInfo(updatedInfo);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddNoteDialog() {
    _noteTypeController.clear();
    _noteMilesController.clear();
    _noteTextController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _noteTypeController,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              TextField(
                controller: _noteMilesController,
                decoration: const InputDecoration(labelText: 'Miles'),
              ),
              TextField(
                controller: _noteTextController,
                decoration: const InputDecoration(labelText: 'Note'),
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
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                _addNewNote();
              },
            ),
          ],
        );
      },
    );
  }

  void _filterNotes(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCarNotes = _carNotes;
      });
    } else {
      setState(() {
        _filteredCarNotes = _carNotes!.where((note) {
          // Convert date string to DateTime object
          DateTime noteDate = DateTime.parse(note['dateCreated']);
          String monthName = intl.DateFormat.MMMM().format(noteDate);
          String day = intl.DateFormat.d().format(noteDate);
          String year = intl.DateFormat.y().format(noteDate);

          return note['note']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              note['type']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              note['miles']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              monthName.toLowerCase().contains(query.toLowerCase()) ||
              day.contains(query) || // Check for day number
              year.contains(query); // Check for year number
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCarInfo();
    _fetchCarNotes();
    _searchController.addListener(() {
      _filterNotes(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: constants.slategray,
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 60),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _carInfo == null
            ? Center(
                child: Text(
                  _errorMessage.isNotEmpty ? _errorMessage : 'Loading...',
                  style: constants.subHeaderTextStyle,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_carInfo!['year']} ${_carInfo!['make']} ${_carInfo!['model']}',
                          style: constants.header3TextStyle,
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          'Color: ${_carInfo!['color']}',
                          style: constants.subHeader2TextStyle,
                        ),
                        Row(children: [
                          Text(
                            'ODO: ${_carInfo!['odometer']}',
                            style: constants.subHeader2TextStyle,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditCarDialog();
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteCar(widget.carId);
                            },
                          )
                        ]),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Row(children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Search Notes',
                            labelStyle: TextStyle(color: constants.darkgray),
                            prefixIcon:
                                Icon(Icons.search, color: constants.darkgray),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: constants.darkgray, width: 2)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: constants.orange, width: 2)),
                          ),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton(
                          style: constants.roundButtonStyle,
                          onPressed: _showAddNoteDialog,
                          child: const Icon(Icons.add)),
                    ]),
                    const SizedBox(height: 20.0),
                    const SizedBox(height: 20.0),
                    _filteredCarNotes == null
                        ? Center(
                            child: Text(
                              _errorMessage.isNotEmpty
                                  ? _errorMessage
                                  : 'Loading notes...',
                              style: constants.subHeaderTextStyle,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _filteredCarNotes!.map((note) {
                              final noteId = note['noteId'];

                              // Format the dateCreated field
                              final createdDate =
                                  DateTime.parse(note['dateCreated']);
                              final formattedDate =
                                  '${intl.DateFormat.yMMMMd().format(createdDate)}';

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${note['type']}',
                                                style: constants
                                                    .subHeaderTextStyle,
                                              ),
                                              Text(
                                                'Miles: ${note['miles']}',
                                                style: constants
                                                    .subHeader2TextStyle,
                                              ),
                                              Text(
                                                '${note['note']}',
                                                style:
                                                    constants.subtitleTextStyle,
                                              ),
                                              Text(
                                                '$formattedDate',
                                                style: const TextStyle(
                                                    fontSize: 12.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            // Create new controllers for the edit dialog
                                            final TextEditingController
                                                typeController =
                                                TextEditingController(
                                                    text: note['type']);
                                            final TextEditingController
                                                milesController =
                                                TextEditingController(
                                                    text: note['miles']);
                                            final TextEditingController
                                                noteController =
                                                TextEditingController(
                                                    text: note['note']);

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      const Text('Edit Note'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextField(
                                                        controller:
                                                            typeController,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Service Type'),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            milesController,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Miles'),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            noteController,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Note'),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child:
                                                          const Text('Cancel'),
                                                      onPressed: () {
                                                        // Clear text in controllers when cancel is pressed
                                                        typeController.clear();
                                                        milesController.clear();
                                                        noteController.clear();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text('Save'),
                                                      onPressed: () {
                                                        _updateNote(
                                                            noteId,
                                                            typeController.text,
                                                            milesController
                                                                .text,
                                                            noteController
                                                                .text);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () =>
                                              _deleteNote(note['noteId']),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
      ),
    );
  }
}
