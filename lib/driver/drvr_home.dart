import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newheyauto/driver/drvr_reg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../choose_role.dart';

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
    _availabilityCollection = FirebaseFirestore.instance.collection(
        'Drvr_Availability'); 
    getPhoneNumber();
    _getDriverAvailability();
  }

  Stream<QuerySnapshot> getRideRequestsStream() {
    try {
      // Filter the ride requests based on the driver's ID
      return FirebaseFirestore.instance
          .collection('RideRequests')
          .where('driverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('status',
              isEqualTo:
                  'pending') 
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
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Switch(
                    value: _isAvailable,
                    onChanged: (bool value) {
                      _updateDriverAvailability(value);
                    },
                  ),
                ],
              ),
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
                                      onPressed: () {
                                        
                                      },
                                      backgroundColor: Colors.green,
                                      child: const Icon(Icons.check),
                                    ),
                                    const SizedBox(width: 10),
                                    FloatingActionButton(
                                      onPressed: () {
                                        
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
                              return const CircularProgressIndicator();
                            }
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
