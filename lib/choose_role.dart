import 'package:flutter/material.dart';
import 'package:newheyauto/driver/drvr_home.dart';
import 'package:newheyauto/passenger/Pass_welcome.dart';
import 'package:newheyauto/passenger/pass_home.dart';
import '../styles.dart';

class ChooseRole extends StatelessWidget {
  const ChooseRole({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Choose Role'),
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
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choose Your Role',
            style: TextStyle(
              fontWeight: FontWeight.bold,
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
                return Container(
                  decoration: BoxDecoration(
                    color: black,
                    borderRadius: BorderRadius.circular(26),
                    image: DecorationImage(
                      image: AssetImage('assets/images/$index.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  width: 200,
                  margin: const EdgeInsets.only(left :10 ,right: 10),
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
                              
                                  switch (index) {
                                    case 0:
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const PassWelcome()),
                                      );
                                      break;
                                    case 1:
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const DrvrHome()),
                                      );
                                      break;
                                    // Add more cases for other list items
                                    default:
                                      break;
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                      Colors.transparent),
                                  overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
                                ),
                                child:  Text(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}