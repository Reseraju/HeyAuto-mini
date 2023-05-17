import 'package:flutter/material.dart';
import 'package:newheyauto/passenger/pass_home.dart';
import 'package:permission_handler/permission_handler.dart';
import '../styles.dart';
import 'package:geolocator/geolocator.dart';

class PassWelcome extends StatefulWidget {
  const PassWelcome({super.key});

  @override
  State<PassWelcome> createState() => _PassWelcomeState();
}

class _PassWelcomeState extends State<PassWelcome> {
  @override
  void initState() {
    super.initState();
    requestPermissions(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(241, 241, 241, 1),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/phome.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  height: 0,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Welcome to HeyAuto\n",
                        style: TextStyle(
                            color: Color.fromARGB(255, 48, 46, 46),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      TextSpan(text: "\n"),
                      TextSpan(
                        text:
                            "Have a hustle-free booking experience by giving us the following permissions.\n",
                        style: TextStyle(
                            color: Color.fromARGB(255, 55, 51, 51),
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(text: "\n"),
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(Icons.location_on, size: 16),
                          ),
                          TextSpan(text: "  "),
                          TextSpan(
                            text: "Location\n",
                            style: TextStyle(
                              color: Color.fromARGB(255, 55, 51, 51),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          WidgetSpan(
                            child: Icon(Icons.phone, size: 16),
                          ),
                          TextSpan(text: "  "),
                          TextSpan(
                            text: "Phone",
                            style: TextStyle(
                              color: Color.fromARGB(255, 55, 51, 51),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                FittedBox(
                  child: GestureDetector(
                    onTap: () {
                      requestPermissions(context);
                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: (context) {
                      //     return const PassHome();
                      //   },
                      // ));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 45),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: kPrimaryColor,
                      ),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "NEXT",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: Colors.black,
                                ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Future<void> requestPermissions(BuildContext context) async {
    final permissions = [
      Permission.location,
      Permission.phone,
    ];

    final status = await permissions.request();

    if (status[Permission.location]!.isGranted &&
        status[Permission.phone]!.isGranted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PassHome()),
      );
    } else {
      final isLocationGranted = status[Permission.location]!.isGranted;
      final isPhoneGranted = status[Permission.phone]!.isGranted;

      if (isLocationGranted && !await Geolocator.isLocationServiceEnabled()) {
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
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                ),
                TextButton(
                  child: const Text("Turn On"),
                  onPressed: () async {
                    // Open device settings
                    await Geolocator.openAppSettings();
                    Navigator.pop(context); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      } else if (!isLocationGranted || !isPhoneGranted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Permissions Required"),
              content: const Text(
                "Please enable location and phone permissions to continue.",
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                ),
                TextButton(
                  child: const Text("Go to Settings"),
                  onPressed: () {
                    openAppSettings(); // Navigate to app settings
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  
}





