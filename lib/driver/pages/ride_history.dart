import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  void fetchRideHistory() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final passengerId = _auth.currentUser!.uid;
    final ridesRef = FirebaseFirestore.instance
        .collection('Drivers')
        .doc(passengerId)
        .collection('acceptedRides');

    final querySnapshot = await ridesRef.get();

    setState(() {
      rideHistory = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  void deleteRideHistory() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final passengerId = _auth.currentUser!.uid;
    final ridesRef = FirebaseFirestore.instance
        .collection('Drivers')
        .doc(passengerId)
        .collection('acceptedRides');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History',style: TextStyle(color: Colors.black),),
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
          // final duration = ride['duration'];
          // final dateOfTravel = ride['dateOfTravel'];

          return ListTile(
            title: Text(destination),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Start: $startLocation ',),
                Text('Destination: $destination '),
                // Text('Duration: $duration minutes'),
                // Text('Date of Travel: $dateOfTravel'),
              ],
            ),
            // Add additional styling or functionality as needed
          );
        },
      ),
    );
  }
}
