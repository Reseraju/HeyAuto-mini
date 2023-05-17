import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newheyauto/authentication/phone_verification/phone.dart';
import 'package:newheyauto/choose_role.dart';


class DrvrHome extends StatefulWidget {
  const DrvrHome({Key? key}) : super(key: key);

  @override
  _DrvrHomeState createState() => _DrvrHomeState();
}

class _DrvrHomeState extends State<DrvrHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("Logout Driver"),
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              print("Signed Out");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ChooseRole()));
            });
            Navigator.pop(context);
          },
          
        ),
        
      ),
    );
    
  }
}
