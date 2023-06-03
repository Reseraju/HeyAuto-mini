import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:newheyauto/passenger/pages/driverDetails.dart';


class ChooseDrvr extends StatefulWidget {
  final String startLocation;
  final String destinationLocation;

  const ChooseDrvr({
    Key? key,
    required this.startLocation,
    required this.destinationLocation,
  }) : super(key: key);

  @override
  State<ChooseDrvr> createState() => _ChooseDrvrState();
}

class _ChooseDrvrState extends State<ChooseDrvr> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getAvailableDriversStream() {
    return _firestore
        .collection('Drvr_Availability')
        .where('avail_status', isEqualTo: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getDriverDetails(String driverId) {
    return _firestore.collection('Drivers').doc(driverId).get();
  }

  Future<List<DocumentSnapshot>> fetchDriversDetails(
      List<QueryDocumentSnapshot> drivers) async {
    List<Future<DocumentSnapshot>> futures = [];
    for (var driver in drivers) {
      futures.add(getDriverDetails(driver.id));
    }
    return await Future.wait(futures);
  }

  double calculateEstimatedFare(String destLocation) {
    String destinationLocation = destLocation.trim();
    if (destinationLocation == 'bharananganam' ||
        destinationLocation == 'Bharananganam' ||
        destinationLocation == 'bharanaganam' ||
        destinationLocation == 'baranaganam') {
      return 120.0;
    } else if (destinationLocation == 'pravithanam' ||
        destinationLocation == 'Pravithanam') {
      return 150.0;
    } else {
      // Return a default fare if the destination is not recognized
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Your Driver',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.green.shade400,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Text(
              'Estimated Fare: ${calculateEstimatedFare(widget.destinationLocation)}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Start Location: ${widget.startLocation}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Destination Location: ${widget.destinationLocation}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Choose your Driver',
              style: TextStyle(fontSize: 30),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getAvailableDriversStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<QueryDocumentSnapshot> drivers = snapshot.data!.docs;

                    if (drivers.isEmpty) {
                      return const Center(
                        child: Text(
                            'No available drivers. Please wait for some time.'),
                      );
                    }

                    return FutureBuilder<List<DocumentSnapshot>>(
                      future: fetchDriversDetails(drivers),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('loading...');
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<DocumentSnapshot> driverDetails = snapshot.data!;
                          return ListView.builder(
                            itemCount: drivers.length,
                            itemBuilder: (context, index) {
                              var driver = drivers[index];
                              var driverDetail = driverDetails[index];
                              return ListTile(
                                title: Text(driverDetail.get('name')),
                                subtitle: const Text('Availability: Available'),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    print(driver.id);
                                    // checkNotificationPermission(
                                    //     _auth.currentUser!.uid);
                                    print(_auth.currentUser);
                                    //sendRideRequest(driver.id);

                                    // Navigate to the next page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DriverDetails(
                                                driverId: driver.id,
                                                start: widget.startLocation,
                                                destination:
                                                    widget.destinationLocation,
                                              )),
                                    );
                                  },
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DriverDetails(
                                              driverId: driver.id,
                                              start: widget.startLocation,
                                              destination:
                                                  widget.destinationLocation,
                                            )),
                                  );
                                },
                              );
                            },
                          );
                        }
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const Text('No drivers found');
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
