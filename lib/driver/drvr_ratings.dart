import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DriverRatingsPage extends StatelessWidget {
  final String driverId;

  const DriverRatingsPage({Key? key, required this.driverId}) : super(key: key);

  Future<List<Map<String, dynamic>>> getDriverRatings(String driverId) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('DriverRatings')
        .doc(driverId)
        .collection('Ratings')
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Driver Ratings',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 1,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getDriverRatings(driverId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.hasData) {
            final List<Map<String, dynamic>> ratings = snapshot.data!;

            if (ratings.isEmpty) {
              return const Center(
                child: Text('No ratings available.'),
              );
            }

            return ListView.builder(
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
                    itemSize: 24,
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
            );
          }

          return const Center(
            child: Text('No ratings available.'),
          );
        },
      ),
    );
  }
}
