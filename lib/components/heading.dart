import 'package:flutter/material.dart';
import '../styles.dart';

class HeadingSection extends StatelessWidget {
  const HeadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/naruto.jpg'),
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome',
                  
                ), //fs14
                Text(
                  'Uzumaki Naruto',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          ],
        ),
        Icon(Icons.notifications, color: icon, size: 28)
      ],
    );
  }
}