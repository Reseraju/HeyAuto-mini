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

              return Card(
                child: ListTile(
                  title: Text('Request ID: $requestId'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup Location: $pickupLocation'),
                      Text('Destination: $destination'),
                      Text('Date and Time: $dateTime'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Handle accept request
                          _acceptRequest(requestId);
                        },
                        icon: const Icon(Icons.check),
                      ),
                      IconButton(
                        onPressed: () {
                          // Handle reject request
                          _rejectRequest(requestId);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _acceptRequest(String requestId) {
    // TODO: Implement logic to accept the pre-booked request
  }

  void _rejectRequest(String requestId) {
    // TODO: Implement logic to reject the pre-booked request
  }
}
