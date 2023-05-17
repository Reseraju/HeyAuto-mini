import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PassHome extends StatefulWidget {
  const PassHome({Key? key}) : super(key: key);

  @override
  _PassHomeState createState() => _PassHomeState();
}

class _PassHomeState extends State<PassHome> {
  @override
  void initState() {
    super.initState();
    checkLocationEnabled();
  }

  Future<void> checkLocationEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showLocationAlertDialog(context);
    }
  }

  void showLocationAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Service Required"),
          content: const Text(
            "Please turn on the device location to continue.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
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
        title: const Text("PassHome"),
      ),
      body: const Center(
        child: Text("PassHome Page"),
      ),
    );
  }
}
