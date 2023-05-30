import 'package:flutter/material.dart';
import 'package:newheyauto/choose_role.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin{
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationController.forward();

    // _animationController.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     // Animation completed, navigate to the next screen
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (context) => NextScreen()),
    //     );
    //   }
    // });
    navigateToNextScreen(); // Start the delay and navigation process
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      // Replace the duration with your desired delay time
      
      // Navigate to your main screen or any other screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChooseRole()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/videos/Auto_GIF.gif', 
              width: 400,
              height: 400,
            ),
            const Text(
              'HEYAUTO🖐️',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
