import 'package:flutter/material.dart';
import 'package:newheyauto/authentication/phone_verification/phone.dart';
import 'package:newheyauto/driver/pages/drvr_home.dart';
import 'package:newheyauto/passenger/Pass_welcome.dart';
import '../styles.dart';
import 'authentication/phone_verification/verify.dart';

class ChooseRole extends StatefulWidget {
  const ChooseRole({Key? key}) : super(key: key);

  @override
  _ChooseRoleState createState() => _ChooseRoleState();
}

class _ChooseRoleState extends State<ChooseRole> {
  int selectedRoleIndex = -1; // Variable to store selected role index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   title: const Text('HeyAuto',style: TextStyle(color: Colors.black),),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     icon: const Icon(
      //       Icons.arrow_back_ios_rounded,
      //       color: Colors.black,
      //     ),
      //   ),
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choose Your Role',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 250,
            child: ListView.builder(
              itemCount: rolesList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final item = rolesList[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRoleIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: black,
                      borderRadius: BorderRadius.circular(26),
                      image: DecorationImage(
                        image: AssetImage('assets/images/$index.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  width: 200,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Colors.grey[200],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedRoleIndex = index; // Set the selected role index
                                  });

                                  switch (selectedRoleIndex) {
                                    case 0:
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MyPhone(selectedRoleIndex: index)),
                                      );
                                      break;
                                    case 1:
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MyPhone(selectedRoleIndex: index)),
                                      );
                                      break;
                                    // Add more cases for other role indices
                                    default:
                                      break;
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                      Colors.transparent),
                                  overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
                                ),
                                child: Text(
                                  rolesList[index],
                                  style: const TextStyle(
                                    color: Colors.black, // Set the text color
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
