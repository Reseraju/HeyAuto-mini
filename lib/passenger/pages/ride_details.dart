import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RideDetailsPage extends StatefulWidget {
  final Map<String, dynamic> driverId;

  const RideDetailsPage({required this.driverId});

  @override
  _RideDetailsPageState createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  double _rating = 0.0;
  String _review = '';
  String _driverName = ''; // Add a variable to store the driver's name

  @override
  void initState() {
    super.initState();
    // Fetch the driver's name from Firestore when the widget initializes
    _fetchDriverName();
  }

  void _submitRatingAndReview() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final driverId = widget.driverId['driverId']; 

    try {
      // Add the rating and review to the Ratings subcollection
      await _firestore
          .collection('DriverRatings')
          .doc(driverId)
          .collection('Ratings')
          .add({
        'rating': _rating,
        'review': _review,
      });

      // Show a success message or perform any other desired actions

      // Show the "Thank you for your review" dialog box
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thank you for your review!'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      // Reset the rating and review fields
      setState(() {
        _rating = 0.0;
        _review = '';
      });

    } catch (error) {
      // Handle any errors that occur during the submission
      print('Error submitting rating and review: $error');
    }
  }


  void _fetchDriverName() async {
    final driverId = widget.driverId['driverId'];
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      final driverSnapshot = await _firestore.collection('Drivers').doc(driverId).get();
      if (driverSnapshot.exists) {
        setState(() {
          _driverName = driverSnapshot.get('name');
        });
      }
    } catch (error) {
      print('Error fetching driver name: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    var ride = widget.driverId;
    

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ride Details',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.green.shade400,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top:20.0),
              child: Center(
                child: Text(
                  'Driver Name: $_driverName',
                  style: const TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 71, 47, 17)),
                ),
              ),
            ),
            //Text('Estimated Fare: $estimatedFare'),
            const SizedBox(height: 25.0),
            const Text(
              'Rate the Ride:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            RatingBar(
              onChanged: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Add a Review:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  _review = value;
                });
              },
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your review',
              ),
            ),
            const SizedBox(height: 24.0),
            Center(
              child: ElevatedButton(
                onPressed: _submitRatingAndReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Set your desired color here
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RatingBar extends StatefulWidget {
  final ValueChanged<double> onChanged;

  const RatingBar({required this.onChanged});

  @override
  _RatingBarState createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  double _rating = 0.0;

  void _updateRating(double newRating) {
    setState(() {
      _rating = newRating;
    });

    widget.onChanged(newRating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => IconButton(
          onPressed: () => _updateRating(index + 1),
          icon: Icon(
            index < _rating.floor() ? Icons.star : Icons.star_outline,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }
}