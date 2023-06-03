import 'package:flutter/material.dart';

class PreBookRidePage extends StatefulWidget {
  @override
  _PreBookRidePageState createState() => _PreBookRidePageState();
}

class _PreBookRidePageState extends State<PreBookRidePage> {
  TextEditingController _pickupController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pre-book a Ride',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 1,
      ),
      body: Padding(
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
            const SizedBox(height: 32.0),
            ElevatedButton(
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
              },
              child: const Text('Pre-book Ride'),
            ),
          ],
        ),
      ),
    );
  }
}
