import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RideStatusPage extends StatefulWidget {
  @override
  _RideStatusPageState createState() => _RideStatusPageState();
}

class _RideStatusPageState extends State<RideStatusPage> {
  late Stream<QuerySnapshot> _rideRequestsStream;

  @override
  void initState() {
    super.initState();
    String passengerId = FirebaseAuth.instance.currentUser!.uid;
    _rideRequestsStream = FirebaseFirestore.instance
        .collection('PreBookRide')
        .where('passenger_id', isEqualTo: passengerId)
        .snapshots();
  }

  Future<void> _cancelRideRequest(String requestId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Ride Request'),
          content: const Text('Are you sure you want to cancel this ride request?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('PreBookRide')
                      .doc(requestId)
                      .update({'status': 'Cancelled'});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ride request cancelled')),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error cancelling ride request: $error')),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Pending') {
      return Colors.yellow;
    } else if (status == 'Accepted') {
      return Colors.green;
    } else if (status == 'Cancelled') {
      return Colors.red;
    }
    return Colors.black; // Default color
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ride Status',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.green.shade400,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _rideRequestsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No ride requests found'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final requestId = doc.id;
              final pickupLocation = doc['pickup_location'];
              final destination = doc['destination'];
              final dateTime = doc['date_time'].toDate();
              final status = doc['status'];

              return Card(
                child: ListTile(
                  title: Text('Request ID: $requestId'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup Location: $pickupLocation'),
                      Text('Destination: $destination'),
                      Text('Date and Time: $dateTime'),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                  trailing: status != 'Cancelled'
                      ? IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            _cancelRideRequest(requestId);
                          },
                        )
                      : null,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
