import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newheyauto/choose_role.dart';
import 'package:newheyauto/driver/pages/PreBook_requests.dart';
import 'package:newheyauto/driver/pages/drvr_home.dart';
import 'package:newheyauto/driver/pages/drvr_ratings.dart';
import 'package:newheyauto/driver/pages/drvr_reg.dart';
import 'package:newheyauto/driver/pages/ride_history.dart';
import 'package:newheyauto/driver/pages/support_page.dart';

import 'drvr_about.dart';
import '../../passenger/pages/pass_about.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({super.key});

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FirebaseAuth auth;
  String? phoneNumber;
  String? userName;
  late CollectionReference _availabilityCollection;
  bool _isAvailable = false;

  int _selectedIndex = 0;  
  static const List<Widget> _widgetOptions = <Widget>[  
    DriverHomePage(),  
    PreBookRequests()  
  ];  
  
  void _onItemTapped(int index) {  
    setState(() {  
      _selectedIndex = index;  
    }); 
  } 

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  void getPhoneNumber() async {
    try {
      auth = FirebaseAuth.instance;
      phoneNumber = auth.currentUser?.phoneNumber;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final driverDoc = _availabilityCollection.doc(currentUser.uid);

        final documentSnapshot = await driverDoc.get();
        if (mounted && documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            _isAvailable = data['avail_status'] ?? false;
          });
        }
      }
    } catch (e) {
      print('Error getting driver availability: $e');
    }
  }

  Future<String> getPassengerPhoneNumber(String passengerId) async {
    try {
      var passengerDoc = await FirebaseFirestore.instance
          .collection('Passengers')
          .doc(passengerId)
          .get();
      var passengerData = passengerDoc.data();

      if (passengerData != null && passengerData.containsKey('phone_number')) {
        return passengerData['phone_number'] ?? '';
      } else {
        return '';
      }
    } catch (e) {
      print('Error getting passenger phone number: $e');
      return '';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPhoneNumber();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'HeyAuto',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.green.shade400,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.black,
          onPressed: () {
            _openDrawer();
          },
        ),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.green.shade400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        onPressed: _closeDrawer,
                      ),
                    ],
                  ),
                ),
                UserAccountsDrawerHeader(
                  accountName: const Text('My Profile'),
                  accountEmail: Text(phoneNumber!),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: const Text('Upload Documents'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DrvrRegistration()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: _closeDrawer,
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Ride History'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RideHistoryPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.reviews_outlined),
                  title: const Text('Your Ratings'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DriverRatingsPage(driverId: _auth.currentUser!.uid),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Payment'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Earnings'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    //
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DriverAboutPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('support'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SupportPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    FirebaseAuth.instance.signOut().then((value) {
                      print("Driver Signed Out");
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChooseRole()));
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(  
        child: _widgetOptions.elementAt(_selectedIndex),  
      ),
      bottomNavigationBar: BottomNavigationBar(  
        items: const <BottomNavigationBarItem>[  
          BottomNavigationBarItem(  
            icon: Icon(Icons.directions_car),  
            label: 'Current Ride Request', 
            backgroundColor: Colors.green 
          ),  
          BottomNavigationBarItem(  
            icon: Icon(Icons.directions_car),  
            label: 'Pre-Booked Ride Requests',  
            backgroundColor: Colors.green  
          ),    
        ],  
        type: BottomNavigationBarType.shifting,  
        currentIndex: _selectedIndex,  
        //selectedItemColor: Colors.black,  
        iconSize: 20,  
        onTap: _onItemTapped,  
        elevation: 5  
      ),  
    );
  }
}