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
  String locality = '';

  @override
  void initState() {
    super.initState();
    List<String> addressParts = widget.startLocation.split(',');
    locality = addressParts[1].trim();

    setState(() {}); // Update the UI after setting the value of locality
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
        backgroundColor: Colors.white,
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
              'Start Location: $locality',
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
          ],
        ),
      ),
    );
  }
}
