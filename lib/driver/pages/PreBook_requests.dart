import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:newheyauto/driver/pages/drvr_home.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../../main.dart';

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
          content:
              const Text('Are you sure you want to cancel this ride request?'),
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
                    .update({'status': 'Cancelled'}).then((_) {
                  // Request cancelled successfully
                  print('Ride request cancelled');
                  // Perform any other necessary actions
                }).catchError((error) {
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

  void acceptRequest(String requestId,DateTime dateTime) {
    FirebaseFirestore.instance
        .collection('PreBookRide')
        .doc(requestId)
        .update({'status': 'Accepted'}).then((_) {
      // Request accepted successfully
      print('Ride request accepted');
      //show set reminder dialog box
      _showReminderDialog(requestId, dateTime);
    }).catchError((error) {
      // An error occurred while accepting the request
      print('Error accepting ride request: $error');
    });
  }

  void _showReminderDialog(String requestId,DateTime dateTime) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Reminder'),
          content: const Text('Do you want to set a reminder for this ride?'),
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
                // Handle setting the reminder
                setReminder( dateTime);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmationDialog(String requestId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete History'),
          content: const Text('Are you sure you want to delete this history?'),
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
                // Delete the history
                deleteHistory(requestId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteHistory(String requestId) {
    FirebaseFirestore.instance
        .collection('PreBookRide')
        .doc(requestId)
        .delete()
        .then((_) {
      // History deleted successfully
      print('History deleted');
      // Perform any other necessary actions
    }).catchError((error) {
      // An error occurred while deleting the history
      print('Error deleting history: $error');
    });
  }

  void setReminder(DateTime dateTime) async {
    // Initialize the local notifications plugin
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Define the notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Channel',
      //'Channel for reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Initialize time zones
    tz.initializeTimeZones();
    final location = tz.getLocation('YOUR_TIMEZONE'); // Replace with your desired timezone

    // Convert the DateTime to the corresponding TZDateTime based on the location
    final scheduledDate = tz.TZDateTime.from(dateTime, location);

    // Schedule the reminder notification
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0, // Notification ID
    'Reminder', // Notification title
    'Reminder for your appointment', // Notification body
    scheduledDate, // Scheduled date and time in the specified timezone
    platformChannelSpecifics,
    //androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('PreBookRide').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text('Error retrieving pre-booked requests'));
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
                  onLongPress: () {
                    // Show the delete confirmation dialog
                    showDeleteConfirmationDialog(requestId);
                  },
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
                                acceptRequest(requestId, dateTime);
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
