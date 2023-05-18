import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:newheyauto/styles.dart';

import 'authentication/phone_verification/phone.dart';
import 'authentication/phone_verification/verify.dart';
import 'choose_role.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  theme:
  ThemeData(
    brightness: Brightness.dark,
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: kBackgroundColor,
    textTheme: const TextTheme(
      //display1: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: kPrimaryColor),
      //headline:
      //TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white.withOpacity(.2),
        ),
      ),
    ),
  );

  //WidgetsFlutterBinding.ensureInitialized();
  //FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  runApp(
    MaterialApp(
      initialRoute: 'phone',
      debugShowCheckedModeBanner: false,
      routes: {
        'phone': (context) => const MyPhone(),
        'verify': (context) => const MyVerify(),
        'role': (context) => const ChooseRole(),
      },
    ),
  );
}
