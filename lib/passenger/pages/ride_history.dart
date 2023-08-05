import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newheyauto/passenger/pages/ride_details.dart';

class RideHistoryPage extends StatefulWidget {
  @override
  _RideHistoryPageState createState() => _RideHistoryPageState();
}

class _RideHistoryPageState extends State<RideHistoryPage> {
  List<Map<String, dynamic>> rideHistory = [];

  @override
  void initState() {
    super.initState();
    fetchRideHistory();
  }

  void deleteRideHistory() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final passengerId = _auth.currentUser!.uid;
    final ridesRef = FirebaseFirestore.instance
        .collection('Passengers')
        .doc(passengerId)
        .collection('rides');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Ride History'),
          content: const Text(
              'Are you sure you want to delete all your previous ride history?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                // Delete each ride document
                final querySnapshot = await ridesRef.get();
                querySnapshot.docs.forEach((doc) {
                  doc.reference.delete();
                });

                // Refresh ride history list
                setState(() {
                  rideHistory.clear();
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void fetchRideHistory() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final passengerId = _auth.currentUser!.uid;
    final ridesRef = FirebaseFirestore.instance
        .collection('Passengers')
        .doc(passengerId)
        .collection('rides');

    final querySnapshot = await ridesRef.get();

    setState(() {
      rideHistory = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Ride History', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.green.shade400,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteRideHistory,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: rideHistory.length,
        itemBuilder: (context, index) {
          var ride = rideHistory[index];
          var destination = ride['destinationLocation'];
          var startLocation = ride['startLocation'];
          var driverId = ride['driverId'];

          // final duration = ride['duration'];
          // final dateOfTravel = ride['dateOfTravel'];

          return ListTile(
            title: Text(destination),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start: $startLocation ',
                ),
                Text('Destination: $destination '),
                // Text('Duration: $duration minutes'),
                // Text('Date of Travel: $dateOfTravel'),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RideDetailsPage(driverId: {'driverId': driverId}),
                ),
              );
            },
            // Add additional styling or functionality as needed
          );
        },
      ),
    );
  }
}
