import 'package:flutter/material.dart';
import 'package:newheyauto/authentication/phone_verification/phone.dart';
import '../styles.dart';

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choose Your Role',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 50),
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
                    width: 200,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/$index.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: TextButton(
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
                                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                                overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
                              ),
                              child: Text(
                                rolesList[index],
                                style: const TextStyle(
                                  color: Colors.white, // Set the text color
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
