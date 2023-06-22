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

    } catch (error) {
      // Handle any errors that occur during the submission
      print('Error submitting rating and review: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    var ride = widget.driverId;
    var driverName = ride['driverName'];
    var startLocation = ride['startLocation'];
    var destination = ride['destinationLocation'];
    //var estimatedFare = ride['estimatedFare'];

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
            Text('Driver Name: $driverName'),
            Text('Start Location: $startLocation'),
            Text('Destination: $destination'),
            //Text('Estimated Fare: $estimatedFare'),
            const SizedBox(height: 24.0),
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
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your review',
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _submitRatingAndReview,
              child: const Text('Submit'),
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
