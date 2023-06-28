import 'package:flutter/material.dart';

class DriverAboutPage extends StatelessWidget {
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
              'Are you ready to embark on a journey filled with opportunities? Look no further! HeyAuto is your gateway to connecting with more passengers and unlocking an extra source of income like never before.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24.0),
            Text(
              'Why drive with HeyAuto?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              '• Connect with a vibrant community of students from SJCET college\n'
              '• Increase your passenger base and earn more\n'
              '• Flexible hours to suit your schedule\n'
              '• Seamless booking system with real-time ride requests\n'
              '• Track your earnings and performance\n'
              '• Transparent fare calculations for hassle-free payments\n'
              '• Receive ratings and feedback to improve your service\n'
              '• 24/7 support for any assistance you need',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24.0),
            Text(
              'At HeyAuto, we believe in empowering drivers like you by providing a platform that connects you with countless opportunities. Be part of the HeyAuto community and experience the joy of driving, earning, and connecting with passengers in a whole new way.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24.0),
            Text(
              'Join us on this exciting ride today!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
