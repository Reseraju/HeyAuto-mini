import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverDetails extends StatefulWidget {
  final String driverId;

  const DriverDetails({Key? key, required this.driverId}) : super(key: key);

  @override
  State<DriverDetails> createState() => _DriverDetailsState();
}

class _DriverDetailsState extends State<DriverDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      body: Column(
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
                          // TableRow(
                          //   children: [
                          //     const TableCell(
                          //       child: Padding(
                          //         padding: EdgeInsets.all(8.0),
                          //         child: Text('Location:',style: TextStyle(fontSize: 18)),
                          //       ),
                          //     ),
                          //     TableCell(
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: Text(location,style: const TextStyle(fontSize: 18)),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // TableRow(
                          //   children: [
                          //     const TableCell(
                          //       child: Padding(
                          //         padding: EdgeInsets.all(8.0),
                          //         child: Text('Vehicle No:',style: TextStyle(fontSize: 18)),
                          //       ),
                          //     ),
                          //     TableCell(
                          //       child: Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: Text(vehicleNo,style: const TextStyle(fontSize: 18)),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    );
                  }
                  // No data found
                  return const Text('No driver details available.');
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
