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
  final formatter = intl.NumberFormat('#,###');
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

  Future<void> _updateCarInfo(Map<String, dynamic> updatedInfo) async {
    final response = await http.post(
      Uri.parse('https://autolog-b358aa95bace.herokuapp.com/api/updatecar'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'carId': updatedInfo['carId'],
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
          _fetchCarInfo();
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
        final milesString =
            _noteMilesController.text.replaceAll(RegExp(r'[^0-9]'), '');
        final odometerString =
            _carInfo!['odometer'].replaceAll(RegExp(r'[^0-9]'), '');

        int newMileage = int.tryParse(milesString) ?? 0;
        int currentOdometer = int.tryParse(odometerString) ?? 0;

        setState(() {
          _errorMessage = '';
          _noteTypeController.clear();
          _noteMilesController.clear();
          _noteTextController.clear();
          _fetchCarNotes(); // Refresh car notes

          if (newMileage > currentOdometer) {
            Map<String, dynamic> updatedInfo = {
              'carId': _carInfo!['carId'],
              'make': _carInfo!['make'],
              'model': _carInfo!['model'],
              'year': _carInfo!['year'],
              'odometer': formatter.format(newMileage),
              'color': _carInfo!['color'],
            };
            _updateCarInfo(updatedInfo);
          }
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
          title: const Text('Delete Log'),
          content:
              const Text('Are you sure you want to delete this log entry?'),
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

  void _showAddNoteDialog() {
    _noteTypeController.clear();
    _noteMilesController.clear();
    _noteTextController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Log'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _noteTypeController,
                decoration: const InputDecoration(labelText: 'Service Type'),
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
              style: constants.defaultButtonStyle,
              child:
                  const Text('Cancel', style: constants.dialogButtonTextStyle),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: constants.accentButtonStyle,
              child: const Text('Add', style: constants.dialogButtonTextStyle),
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

  void _showEditNoteDialog(Map<String, dynamic> note) {
// Create new controllers for the edit dialog
    final TextEditingController typeController =
        TextEditingController(text: note['type']);
    final TextEditingController milesController =
        TextEditingController(text: note['miles']);
    final TextEditingController noteController =
        TextEditingController(text: note['note']);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Log'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Service Type'),
                ),
                TextField(
                  controller: milesController,
                  decoration: const InputDecoration(labelText: 'Miles'),
                ),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                style: constants.defaultButtonStyle,
                child: const Text('Cancel',
                    style: constants.dialogButtonTextStyle),
                onPressed: () {
                  // Clear text in controllers when cancel is pressed
                  typeController.clear();
                  milesController.clear();
                  noteController.clear();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: constants.accentButtonStyle,
                child:
                    const Text('Save', style: constants.dialogButtonTextStyle),
                onPressed: () {
                  _updateNote(note['noteId'], typeController.text,
                      milesController.text, noteController.text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _showEditOdometerDialog() {
    final TextEditingController odometerController =
        TextEditingController(text: _carInfo!['odometer']);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update Odometer'),
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              TextField(
                controller: odometerController,
                decoration: const InputDecoration(labelText: 'Odometer'),
              )
            ]),
            actions: <Widget>[
              TextButton(
                  style: constants.defaultButtonStyle,
                  child: const Text('Cancel',
                      style: constants.dialogButtonTextStyle),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  style: constants.accentButtonStyle,
                  child: const Text('Update',
                      style: constants.dialogButtonTextStyle),
                  onPressed: () {
                    Map<String, dynamic> updatedInfo = {
                      'carId': _carInfo!['carId'],
                      'make': _carInfo!['make'],
                      'model': _carInfo!['model'],
                      'year': _carInfo!['year'],
                      'odometer': odometerController.text,
                      'color': _carInfo!['color'],
                    };
                    _updateCarInfo(updatedInfo);
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
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
                          '${_carInfo!['year']} ${_carInfo!['make']}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_carInfo!['color']} ${_carInfo!['model']}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              'ODO: ${_carInfo!['odometer']}',
                              style: constants.header4TextStyle,
                            ),
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showEditOdometerDialog();
                                })
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Row(children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Search Logs',
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
                          child: const Icon(Icons.post_add)),
                    ]),
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
                                  '${intl.DateFormat('MM/dd/yyyy').format(createdDate)}';

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
                                                '${note['miles']} miles',
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
                                        MenuAnchor(
                                            builder: (BuildContext context,
                                                MenuController controller,
                                                Widget? child) {
                                              return IconButton(
                                                  icon: const Icon(
                                                      Icons.more_vert,
                                                      size: 30),
                                                  onPressed: () {
                                                    if (controller.isOpen) {
                                                      controller.close();
                                                    } else {
                                                      controller.open();
                                                    }
                                                  });
                                            },
                                            menuChildren: <MenuItemButton>[
                                              MenuItemButton(
                                                  child: const Text('Edit'),
                                                  onPressed: () {
                                                    _showEditNoteDialog(note);
                                                  }),
                                              MenuItemButton(
                                                  child: const Text('Delete'),
                                                  onPressed: () {
                                                    _deleteNote(noteId);
                                                  })
                                            ]),
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
