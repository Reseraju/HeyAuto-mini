import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PreBookRidePage extends StatefulWidget {
  @override
  _PreBookRidePageState createState() => _PreBookRidePageState();
}

class _PreBookRidePageState extends State<PreBookRidePage> {
  TextEditingController _pickupController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String selectedDriverId = ''; // Track the selected driver's ID

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _showRequestDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request Sent'),
          content: const Text(
              'Your pre-booked ride request has been sent. Please wait for the driver to accept the ride.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    late String driverName = '';
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pre-book a Ride',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.green.shade400,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pickup Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _pickupController,
                decoration: const InputDecoration(
                  hintText: 'Enter pickup location',
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Destination',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  hintText: 'Enter destination',
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _selectTime(context),
                    child: Text(
                      '${_selectedTime.format(context)}',
                    ),
                  ),
                ],
              ),
              // Fetch driver names from Firestore and populate dropdown options
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Drivers')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  List<DropdownMenuItem<String>> dropdownItems = [];
                  dropdownItems.add(const DropdownMenuItem<String>(
                    value: '', // Empty value for the default item
                    child: Text('Select a driver'),
                  ));
                  snapshot.data!.docs.forEach((doc) {
                    String driverId = doc.id;
                    driverName = doc['name'];

                    String uniqueDriverId = driverId + '-' + driverName;
                    print(uniqueDriverId);
                    dropdownItems.add(DropdownMenuItem<String>(
                      value: uniqueDriverId,
                      child: Text(driverName),
                    ));
                  });

                  return DropdownButtonFormField<String>(
                    value: selectedDriverId,
                    onChanged: (value) {
                      setState(() {
                        selectedDriverId = value!;
                      });
                    },
                    items: dropdownItems,
                    decoration: const InputDecoration(
                      labelText: 'Select Driver',
                      hintText: 'Choose a driver',
                    ),
                  );
                },
              ),

              const SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Perform pre-booking action
                    String pickupLocation = _pickupController.text;
                    String destination = _destinationController.text;
                    DateTime selectedDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );
              
                    // Perform any desired actions with the pre-booked ride details
                    print('Pickup Location: $pickupLocation');
                    print('Destination: $destination');
                    print('Date and Time: $selectedDateTime');
              
                    // Store pre-booked ride details to Firestore
                    FirebaseFirestore.instance.collection('PreBookRide').add({
                      'pickup_location': pickupLocation,
                      'destination': destination,
                      'date_time': selectedDateTime,
                      'passenger_id': FirebaseAuth.instance.currentUser!.uid,
                      'driver_id': selectedDriverId,
                      'driver_name': driverName,
                      'status': 'Pending',
                    }).then((value) {
                      // Pre-booked ride request successfully stored
                      print('Pre-booked ride request stored in Firestore');
              
                      // Show the request dialog
                      _showRequestDialog();
                    }).catchError((error) {
                      // An error occurred while storing pre-booked ride request
                      print('Error storing pre-booked ride request: $error');
                      // Show an error dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'An error occurred while processing your pre-booked ride request. Please try again.'),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('OK'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green, 
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Pre-book Ride'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
