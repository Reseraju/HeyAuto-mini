import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newheyauto/authentication/phone_verification/verify.dart';
import 'package:newheyauto/driver/drvr_home.dart';
import 'package:newheyauto/passenger/Pass_welcome.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MyVerify extends StatefulWidget {
  final int selectedRoleIndex;
  const MyVerify({Key? key, required this.selectedRoleIndex}) : super(key: key);

  static String verify = "";

  @override
  State<MyVerify> createState() => _MyVerifyState();
}

class _MyVerifyState extends State<MyVerify> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late SharedPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  void _initializeSharedPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> _storeUserRole(String role) async {
    await _preferences.setString('userRole', role);
    // Determine the role and navigate accordingly
  switch (role) {
    case 'Passenger':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PassWelcome()),
      );
      break;
    case 'Driver':
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DriverHomePage()),
      );
      break;
    // Add more cases for other roles
    
    default:
      break;
  }
  }

  @override
  Widget build(BuildContext context) {
    String code = "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify"),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Verify",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Enter the 6-digit code sent to your phone",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Pinput(
                length: 6,
                onChanged: (value) {
                  code = value;
                },
                showCursor: true,
                onCompleted: (pin) async {
                  try {
                    final PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                      verificationId: MyVerify.verify,
                      smsCode: code,
                    );

                    await auth.signInWithCredential(credential);
                    await _storeUserRole(_getUserRole());

                    String role=_getUserRole();
                    if(role=='Passenger'){
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const PassWelcome()),
                          (route) => false,
                        );
                    }else{
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DriverHomePage()),
                          (route) => false,
                        );
                    }

                  } catch (e) {
                    print("Verification failed: $e");
                  }
                },
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Didn't receive the code?",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  // Resend the verification code
                  // ...
                },
                child: const Text(
                  "Resend",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getUserRole() {
    switch (widget.selectedRoleIndex) {
      case 0:
        return 'Passenger';
      case 1:
        return 'Driver';
      default:
        return '';
    }
  }
}