import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DriverDetails extends StatefulWidget {
  final String driverId;
  final String destination;
  final String start;

  

  const DriverDetails({Key? key, required this.driverId, required this.start , required this.destination}) : super(key: key);

  @override
  State<DriverDetails> createState() => _DriverDetailsState();
}

class _DriverDetailsState extends State<DriverDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _rating;
  String? _review;

  Future<DocumentSnapshot> getDriverDetails(String driverId) {
    return _firestore.collection('Drivers').doc(driverId).get();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.driverId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Invalid driver ID'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Driver Details',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 80,
                ),
                //const SizedBox(height: 10,),
                FutureBuilder<DocumentSnapshot>(
                  future: getDriverDetails(widget.driverId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('');
                    }
      
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
      
                    if (snapshot.hasData) {
                      var driverData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      var name = driverData['name'] as String;
                      var phone = driverData['phone_number'] as String;
      
                      return Row(
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            name,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          const Icon(Icons.verified),
                          const SizedBox(
                            width: 160,
                          ),
                          const Icon(Icons.chat_outlined),
                        ],
                      );
                    }
                    // No data found
                    return const Text('No driver details available.');
                  },
                ),
              ],
            ),
            Row(
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: getDriverDetails(widget.driverId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('');
                    }
      
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
      
                    if (snapshot.hasData) {
                      var driverData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      var name = driverData['name'] as String;
                      var phone = driverData['phone_number'] as String;
                      var vehicleNo = driverData['vehicle_no'] as String;
                      var autoLocation = driverData['auto_location'] as String;
      
                      return Padding(
                        padding: const EdgeInsets.only(left:80.0,top: 30),
                        child: Table(
                          columnWidths: const <int, TableColumnWidth>{
                            0: IntrinsicColumnWidth(),
                            1: IntrinsicColumnWidth(),
                          },
                          children: [
                            TableRow(
                              children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Name:',style: TextStyle(fontSize: 18),),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(name,style: const TextStyle(fontSize: 18)),
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Phone:',style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(phone,style: const TextStyle(fontSize: 18)),
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Auto Location:',style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(autoLocation,style: const TextStyle(fontSize: 18)),
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                const TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Vehicle No:',style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(vehicleNo,style: const TextStyle(fontSize: 18)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                      );
                      
                    }
                    // No data found
                    return const Text('No driver details available.');
                  },
                ),
              ],
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(
                        Colors.green.shade400),
              ),
              onPressed: () {
                checkNotificationPermission(
                    _auth.currentUser!.uid);
                print(_auth.currentUser);
                sendRideRequest(widget.driverId);
              },
              child: const Text(
                'Request Ride',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20,),
            // Add RatingBar widget
            RatingBar(
              initialRating: double.parse(_rating ?? '0'),
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 24,
              ratingWidget: RatingWidget(
                full: const Icon(Icons.star, color: Colors.amber),
                half: const Icon(Icons.star_half, color: Colors.amber),
                empty: const Icon(Icons.star_border, color: Colors.amber),
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating.toString();
                });
              },
            ),
      
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _review = value;
                        });
                      },
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Enter your feedback...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: submitRatingAndReview,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green.shade400),
              ),
              child: const Text('Submit'),
            ),

            // Inside the build method
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getDriverRatings(widget.driverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
      
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
      
                if (snapshot.hasData) {
                  final List<Map<String, dynamic>> ratings = snapshot.data!;
                  
                  return Column(
                    children: [
                      // Existing code...
      
                      // Display the ratings and reviews
                      const Text(
                        'Ratings and Reviews:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: ratings.length,
                        itemBuilder: (context, index) {
                          final Map<String, dynamic> rating = ratings[index];
                          final double ratingValue = rating['rating'] as double;
                          final String review = rating['review'] as String;
      
                          return ListTile(
                            leading: RatingBar.builder(
                              initialRating: ratingValue,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemSize: 20,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (_) {},
                            ),
                            title: Text('Rating: $ratingValue'),
                            subtitle: Text('Review: $review'),
                          );
                        },
                      ),
      
                      // Rest of your code...
                    ],
                  );
                }
      
                // No data found
                return const Text('No ratings available.');
              },
            ),
      
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getDriverRatings(String driverId) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('DriverRatings')
        .where('driverId', isEqualTo: driverId)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  
  Future<void> checkNotificationPermission(String passengerId) async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final isGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized;

    _firebaseMessaging.requestPermission();

    if (isGranted) {
      // Permission has been granted
      print('Notification permission granted');

      // Retrieve the device token
      String? passDevicetoken = await FirebaseMessaging.instance.getToken();
      savePassengerDeviceToken(passengerId, passDevicetoken!);
      if (passDevicetoken != null) {
        // Device token is available
        print('Device token: $passDevicetoken');
        // Use the device token to send notifications to the passenger
      } else {
        // Device token is not available
        print('Device token is null');
      }
    } else {
      // Permission has not been granted
      print('Notification permission not granted');
    }
  }

  Future<void> submitRatingAndReview() async {
    if (_rating == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select a rating.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      final String userId = _auth.currentUser?.uid ?? '';

      await _firestore
          .collection('DriverRatings')
          .doc(widget.driverId)
          .collection('Ratings')
          .add({
        'rating': double.parse(_rating ?? '0'),
        'review': _review ?? '',
      });

      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Thank you for your feedback.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }




  Future<void> savePassengerDeviceToken(String passengerId, String deviceToken) async {
  try {
    final collection = FirebaseFirestore.instance.collection('Passengers');
    await collection.doc(passengerId).update({'deviceToken': deviceToken});
    print('Passenger device token saved in Firestore');
  } catch (e) {
    print('Error saving passenger device token in Firestore: $e');
  }
}


  Future<void> sendRideRequest(String driverId) async {
    // Store the temporary ride request in the database
    await _firestore.collection('RideRequests').add({
      'passengerId': _auth.currentUser!.uid,
      'driverId': driverId,
      'startLocation': widget.start,
      'destinationLocation': widget.destination,
      'status': 'pending',
      'rating': _rating,
      'review': _review,
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

}
