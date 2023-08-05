import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isAutoDeleteEnabled = false;
  String _selectedTimeInterval = '24 hours';

  String passengerId = FirebaseAuth.instance.currentUser!.uid;

  void _toggleAutoDelete(bool value) {
    setState(() {
      _isAutoDeleteEnabled = value;
    });

    if (_isAutoDeleteEnabled) {
      _showDurationSelectionDialog();
    } else {
      // Update the auto deletion status in the Passengers collection
      FirebaseFirestore.instance
          .collection('Passengers')
          .doc(passengerId) // Use the passengerId variable
          .update({'autoDeleteEnabled': false})
          .then((_) {
            // Update successful
            print('Auto deletion status updated: disabled');
          })
          .catchError((error) {
            // An error occurred while updating the status
            print('Error updating auto deletion status: $error');
          });
    }
  }


  Future<void> _showDurationSelectionDialog() async {
    final selectedDuration = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Auto Delete Ride History'),
          content: DropdownButton<String>(
            value: _selectedTimeInterval,
            items: const [
              DropdownMenuItem(
                value: '24 hours',
                child: Text('24 hours'),
              ),
              DropdownMenuItem(
                value: '1 week',
                child: Text('1 week'),
              ),
              DropdownMenuItem(
                value: '1 month',
                child: Text('1 month'),
              ),
            ],
            onChanged: _onTimeIntervalChanged,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _toggleAutoDelete(false); // Disable auto delete if canceled
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(_selectedTimeInterval);
              },
            ),
          ],
        );
      },
    );

    if (selectedDuration != null) {
      setState(() {
        _selectedTimeInterval = selectedDuration;
      });

      // Perform any necessary actions based on the selected duration
      // For example, you can save the selected duration in shared preferences or apply it to the ride history deletion logic.

      // Update the auto deletion status and selected duration in the Passengers collection
      FirebaseFirestore.instance
          .collection('Passengers')
          .doc('user_id') // Replace 'user_id' with the actual user ID
          .update({
            'autoDeleteEnabled': true,
            'selectedTimeInterval': selectedDuration,
          })
          .then((_) {
            // Update successful
            print('Auto deletion status updated: enabled');
            print('Selected time interval updated: $selectedDuration');
          })
          .catchError((error) {
            // An error occurred while updating the status and duration
            print('Error updating auto deletion status and selected time interval: $error');
          });
    }
  }

  void _onTimeIntervalChanged(String? value) {
    setState(() {
      _selectedTimeInterval = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auto Delete Ride History',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SwitchListTile(
              title: const Text('Enable Auto Delete'),
              value: _isAutoDeleteEnabled,
              onChanged: _toggleAutoDelete,
            ),
            if (_isAutoDeleteEnabled)
              ListTile(
                title: const Text('Auto Delete Duration'),
                subtitle: Text(_selectedTimeInterval),
                onTap: _showDurationSelectionDialog,
              ),
          ],
        ),
      ),
    );
  }
}
