import 'package:cloud_firestore/cloud_firestore.dart';
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

  Stream<QuerySnapshot> getAvailableDriversStream() {
    return _firestore.collection('Drivers').where('avail_status', isEqualTo: true).snapshots();
  }

  @override
  void initState() {
    super.initState();
    

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
            const SizedBox(height: 30,),
            const Text('Choose your Driver',style: TextStyle(fontSize: 30),),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getAvailableDriversStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<QueryDocumentSnapshot> drivers = snapshot.data!.docs;

                    if (drivers.isEmpty) {
                      return const Center(
                        child: Text('No available drivers. Please wait for some time.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: drivers.length,
                      itemBuilder: (context, index) {
                        var driver = drivers[index];
                        return ListTile(
                          title: Text(driver.get('name')),
                          subtitle: const Text('Availability: Available'),
                          trailing: ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green.shade400),),
                            onPressed: () {
                              // Handle requesting a ride to the selected driver
                              // Implement your ride request logic here
                            },
                            child: const Text('Request Ride',style: TextStyle(color: Colors.white),),
                          ),
                        );
                      },
                    );
                  }else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
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
