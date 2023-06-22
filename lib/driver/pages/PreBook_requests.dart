import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newheyauto/driver/pages/drvr_home.dart';

class PreBookRequests extends StatefulWidget {
  const PreBookRequests({Key? key}) : super(key: key);

  @override
  State<PreBookRequests> createState() => _PreBookRequestsState();
}

class _PreBookRequestsState extends State<PreBookRequests> {
  late String driverId;

  @override
  void initState() {
    super.initState();
    driverId = FirebaseAuth.instance.currentUser!.uid;
  }

  void cancelRequest(String requestId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Ride Request'),
          content: const Text('Are you sure you want to cancel this ride request?'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () {
                // Update the ride request status to "Cancelled"
                FirebaseFirestore.instance
                  .collection('PreBookRide')
                  .doc(requestId)
                  .update({'status': 'Cancelled'})
                  .then((_) {
                    // Request cancelled successfully
                    print('Ride request cancelled');
                    // Perform any other necessary actions
                  })
                  .catchError((error) {
                    // An error occurred while cancelling the request
                    print('Error cancelling ride request: $error');
                  });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void acceptRequest(String requestId) {
    FirebaseFirestore.instance
      .collection('PreBookRide')
      .doc(requestId)
      .update({'status': 'Accepted'})
      .then((_) {
        // Request accepted successfully
        print('Ride request accepted');
        // Perform any other necessary actions
      })
      .catchError((error) {
        // An error occurred while accepting the request
        print('Error accepting ride request: $error');
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('PreBookRide').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error retrieving pre-booked requests'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final preBookedRequests = snapshot.data!.docs.where((doc) {
            final driverIdWithDriverName = doc['driver_id'] as String;
            final originalDriverId = driverIdWithDriverName.split('-')[0];
            return originalDriverId == driverId;
          }).toList();

          if (preBookedRequests.isEmpty) {
            return const Center(child: Text('No pre-booked requests found'));
          }

          return ListView(
            children: preBookedRequests.map((doc) {
              final requestId = doc.id;
              final pickupLocation = doc['pickup_location'];
              final destination = doc['destination'];
              final dateTime = doc['date_time'].toDate();
              final status = doc['status'];

              Color statusColor;
              if (status == 'Pending') {
                statusColor = Colors.yellow;
              } else if (status == 'Accepted') {
                statusColor = Colors.green;
              } else if (status == 'Cancelled') {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.black;
              }

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
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: status == 'Pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                // Handle accept request
                                acceptRequest(requestId);
                              },
                              icon: const Icon(Icons.check),
                            ),
                            IconButton(
                              onPressed: () {
                                // Handle cancel request
                                cancelRequest(requestId);
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        )
                      : IconButton(
                          onPressed: () {
                            // Handle cancel request
                            cancelRequest(requestId);
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
