import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Future<void> sendRideRequest(String driverId) async {
    // Store the temporary ride request in the database
    await _firestore.collection('RideRequests').add({
      'passengerId': _auth.currentUser!.uid,
      'driverId': driverId,
      'startLocation': widget.startLocation,
      'destinationLocation': widget.destinationLocation,
      'status': 'pending',
    });

    // Notify the selected driver
    

    // Show a success message to the passenger
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Ride request sent to the driver.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
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
            const Text(
              'Estimated Fare',
              style: TextStyle(
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
                          return  Container(
                            height: 10, // Specify the desired height
                            width: 10, // Specify the desired width
                            child: const CircularProgressIndicator(),
                          );
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
                                trailing: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.green.shade400),
                                  ),
                                  onPressed: () {
                                    sendRideRequest(driver.id);
                                  },
                                  child: const Text(
                                    'Request Ride',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return  Container(
                      height: 8, // Specify the desired height
                      width: 8, // Specify the desired width
                      child: const CircularProgressIndicator(),
                    );
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
