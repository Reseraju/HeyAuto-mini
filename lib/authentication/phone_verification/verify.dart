import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newheyauto/authentication/phone_verification/phone.dart';
import 'package:newheyauto/driver/drvr_home.dart';
import 'package:newheyauto/passenger/pass_welcome.dart';
import 'package:pinput/pinput.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyVerify extends StatefulWidget {
  final int selectedRoleIndex;
  const MyVerify({Key? key, required this.selectedRoleIndex}) : super(key: key);

  @override
  State<MyVerify> createState() => _MyVerifyState();
}

class _MyVerifyState extends State<MyVerify> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    var code = "";
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/verify.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "We need to register your phone before getting started!",
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
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                      verificationId: MyPhone.verify,
                      smsCode: code,
                    );

                    // Sign in (or link) the user with the credential
                    await auth.signInWithCredential(credential);

                    // Determine the role based on user selection
                    int roleIndex = widget
                        .selectedRoleIndex; // Get the role index based on user selection;
                    switch (roleIndex) {
                      case 0:
                        // Store phone number in Passenger collection
                        final user = FirebaseAuth.instance.currentUser;
                        final phoneNumber = user?.phoneNumber;
                        final passengers = FirebaseFirestore.instance.collection('Passengers');
                        await passengers.doc(user?.uid).set({
                          'phone_number': phoneNumber,
                        });

                        // Navigate to passenger home page
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const PassWelcome()),
                          (route) => false,
                        );
                        break;
                      case 1:
                        // Store phone number in Driver collection
                        final user = FirebaseAuth.instance.currentUser;
                        final phoneNumber = user?.phoneNumber;
                        final drivers =
                            FirebaseFirestore.instance.collection('Drivers');
                        await drivers.doc(user?.uid).set({
                          'phone_number': phoneNumber,
                        });
                        // Navigate to driver home page
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DrvrHome()),
                          (route) => false,
                        );
                        break;
                      // Add more cases for other roles

                      default:
                        break;
                    }
                  } catch (e) {
                    print("Verification failed: $e");
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    // Verification completed button (optional)
                  },
                  child: const Text("Verify Phone Number"),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  MyPhone(selectedRoleIndex: widget.selectedRoleIndex,)),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Edit Phone Number?",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
