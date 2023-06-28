import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About HeyAuto'),
        backgroundColor: Colors.green.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Welcome to HeyAuto!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'HeyAuto is a convenient ride booking app designed specifically for the students of SJCET college. We connect you with nearby autorickshaw drivers, making it easier for you to commute within the campus and nearby areas.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24.0),
            Text(
              'Features:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              '• Book autorickshaw rides within the college campus\n'
              '• Connect with nearby autorickshaw drivers\n'
              '• Real-time tracking of your ride\n'
              '• Estimated fares for transparent pricing\n'
              //'• Secure and cashless payments\n'
              '• Rate and provide feedback on drivers\n'
              '• 24/7 customer support',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24.0),
            Text(
              'HeyAuto provides you with a reliable and efficient way to travel.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24.0),
            Text(
              'Thank you for choosing HeyAuto!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
