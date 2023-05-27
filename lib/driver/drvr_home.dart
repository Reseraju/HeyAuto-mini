import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:newheyauto/driver/drvr_reg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../choose_role.dart';
import '../main.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({Key? key}) : super(key: key);

  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  bool _isAvailable = false;
  late CollectionReference _availabilityCollection;

  late FirebaseAuth auth;
  String? phoneNumber;
  String? userName;

  Future<void> _getDriverAvailability() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final driverDoc = _availabilityCollection.doc(currentUser.uid);

        final documentSnapshot = await driverDoc.get();
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          final availability = data['avail_status'] as bool? ?? false;

          setState(() {
            _isAvailable = availability;
            //userName = data['name'] as String?;
          });
        } else {
          await driverDoc.set({'avail_status': _isAvailable});
        }
      }
    } catch (e) {
      print('Error getting driver availability: $e');
    }
  }

  Future<void> _updateDriverAvailability(bool isAvailable) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final driverDoc = _availabilityCollection
            .doc(currentUser.uid); // Update the document reference

        final documentSnapshot = await driverDoc.get();
        if (documentSnapshot.exists) {
          await driverDoc.update({'avail_status': isAvailable});
        }

        // Save availability in SharedPreferences
        final preferences = await SharedPreferences.getInstance();
        await preferences.setBool('driverAvailability', isAvailable);

        setState(() {
          _isAvailable = isAvailable;
        });
      }
    } catch (e) {
      print('Error updating driver availability: $e');
    }
  }

  void getPhoneNumber() async {
    try {
      auth = FirebaseAuth.instance;
      phoneNumber = auth.currentUser?.phoneNumber;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final driverDoc = _availabilityCollection.doc(currentUser.uid);

        final documentSnapshot = await driverDoc.get();
        if (mounted && documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            _isAvailable = data['avail_status'] ?? false;
          });
        }
      }
    } catch (e) {
      print('Error getting driver availability: $e');
    }
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _availabilityCollection =
        FirebaseFirestore.instance.collection('Drvr_Availability');
    getPhoneNumber();
    _getDriverAvailability();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });
  }

  Future<void> _sendNotificationToPassenger(
      String passengerToken, bool isAccepted) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      final title = isAccepted ? 'Ride Accepted' : 'Ride Rejected';
      final body = isAccepted
          ? 'Your ride request has been accepted by the driver.'
          : 'Your ride request has been rejected by the driver.';

      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: 'default_notification_channel',
      );
    } catch (e) {
      print('Error sending notification to passenger: $e');
    }
  }

  Stream<QuerySnapshot> getRideRequestsStream() {
    try {
      // Filter the ride requests based on the driver's ID
      return FirebaseFirestore.instance
          .collection('RideRequests')
          .where('driverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('status', isEqualTo: 'pending')
          .snapshots();
    } catch (e) {
      print("error getting ride requests , $e");
      return const Stream.empty();
    }
  }

  Future<String> getPassengerPhoneNumber(String passengerId) async {
    try {
      var passengerDoc = await FirebaseFirestore.instance
          .collection('Passengers')
          .doc(passengerId)
          .get();
      var passengerData = passengerDoc.data();

      if (passengerData != null && passengerData.containsKey('phone_number')) {
        return passengerData['phone_number'] ?? '';
      } else {
        return '';
      }
    } catch (e) {
      print('Error getting passenger phone number: $e');
      return '';
    }
  }

  Future<String> getPassDeviceToken(String passengerId) async {
    try {
      var passengerDoc = await FirebaseFirestore.instance
          .collection('Passengers')
          .doc(passengerId)
          .get();
      var passengerData = passengerDoc.data();

      if (passengerData != null && passengerData.containsKey('phone_number')) {
        return passengerData['deviceToken'] ?? '';
      } else {
        return '';
      }
    } catch (e) {
      print('Error getting passenger device token: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'HeyAuto',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.black,
          onPressed: () {
            _openDrawer();
          },
        ),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: Column(
            children: [
              Container(
                color: Colors.green.shade400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                      onPressed: _closeDrawer,
                    ),
                  ],
                ),
              ),
              UserAccountsDrawerHeader(
                accountName: const Text('My Profile'),
                accountEmail: Text(phoneNumber!),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: const Text('Upload Documents'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DrvrRegistration()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: _closeDrawer,
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Ride History'),
                onTap: () {
                  //
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Payment'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  //
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
                  //
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('support'),
                onTap: () {
                  //
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    print("Driver Signed Out");
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChooseRole()));
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Driver Availability',
                    style: TextStyle(fontSize: 26),
                  ),
                  const SizedBox(width: 100),
                  Switch(
                    value: _isAvailable,
                    onChanged: (bool value) {
                      _updateDriverAvailability(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getRideRequestsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<QueryDocumentSnapshot> rideRequests =
                        snapshot.data!.docs;

                    if (rideRequests.isEmpty) {
                      return const Center(
                        child: Text('No ride requests available.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: rideRequests.length,
                      itemBuilder: (context, index) {
                        var rideRequest = rideRequests[index];
                        var requestId = rideRequest.id;
                        var passengerId = rideRequest['passengerId'];
                        var start = rideRequest['startLocation'];
                        var destination = rideRequest['destinationLocation'];

                        //var passengerName = rideRequest['passengerName'];

                        return FutureBuilder<String>(
                          future: getPassengerPhoneNumber(passengerId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var passengerPhoneNumber = snapshot.data!;
                              return ListTile(
                                title: Text(
                                    'Ride Request from: $passengerPhoneNumber'),
                                subtitle: Text(
                                    'Phone Number: $passengerPhoneNumber\nStatus: Pending\npick up: $start\nDestination: $destination'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FloatingActionButton(
                                      onPressed: () async {
                                        sendNotificationToPassenger(
                                            await getPassDeviceToken(
                                                passengerId),
                                            'Your ride Request has been accepted!Enjoy your ride!',
                                            'Request Accepted');
                                      },
                                      backgroundColor: Colors.green,
                                      child: const Icon(Icons.check),
                                    ),
                                    const SizedBox(width: 10),
                                    FloatingActionButton(
                                      onPressed: () async {
                                        sendNotificationToPassenger(
                                            await getPassDeviceToken(
                                                passengerId),
                                            'Your ride Request has been Declined! Looks Like the Driver is on another Ride!',
                                            'Request Declined');
                                        declineRideRequest(requestId);
                                      },
                                      backgroundColor: Colors.red,
                                      child: const Icon(Icons.close),
                                    ),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasError) {
                              print("Error in snapshot");
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return const Text('loading...');
                            }
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const Text('No Ride Requests for now');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendNotificationToPassenger(
      String passengerToken, String message, String title) async {
    try {
      final url = 'https://fcm.googleapis.com/fcm/send';
      final serverKey =
          'AAAADBzO3G0:APA91bH8W5aIKxbtOASlgJkKx0IgkE8MYsRr-9LMoOHMaYd2BdFP7iI2H4rDfXvXaBbZAEduIsDgsEpAoCV2Z4i9Tv1_nN36DR7jY21Xbwcf3UqzHrxrIGdZxmYNMkufmYaZOh9D_6IU';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: json.encode({
          'to': passengerToken,
          'notification': {
            'body': message,
            'title': title,
          },
        }),
      );

      if (response.statusCode == 200) {
        // Notification sent successfully
        print('Notification sent to the passenger');
      } else {
        // Error occurred while sending the notification
        print('Error sending notification to the passenger');
      }
    } catch (e) {
      // Exception occurred during the HTTP request
      print('Exception sending notification to the passenger: $e');
    }
  }

  Future<void> declineRideRequest(String requestId) async {
    try {
      final rideRequestRef =
          FirebaseFirestore.instance.collection('RideRequests').doc(requestId);
      await rideRequestRef.delete();
      print('Ride request declined and removed successfully');
    } catch (e) {
      print('Error declining ride request: $e');
    }
  }
}
