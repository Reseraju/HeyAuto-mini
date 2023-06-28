import 'package:flutter/material.dart';
import 'package:newheyauto/passenger/pages/pre_book.dart';
import 'package:newheyauto/passenger/pages/ride_status.dart';

class PreBookHome extends StatefulWidget {
  @override
  State<PreBookHome> createState() => _PreBookHomeState();
}

class _PreBookHomeState extends State<PreBookHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookings',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.green.shade400,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.pending),
            title: const Text('View Status of Ride Requests'),
            onTap: () {
              // Handle view pending ride requests option
              navigateToPendingRideRequests();
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Book a Ride'),
            onTap: () {
              // Handle book a ride option
              navigateToBookARide();
            },
          ),
        ],
      ),
    );
  }

  void navigateToPendingRideRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RideStatusPage()));
  }

  void navigateToBookARide() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PreBookRidePage()));
  }
}
