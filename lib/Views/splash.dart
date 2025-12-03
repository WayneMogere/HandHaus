import 'package:flutter/material.dart';
import 'package:hand_haus_mobile/Auth/login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState(){
    super.initState();
    Future.delayed(Duration(seconds: 3),(){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 240, 233, 1),
      body: Center(
        child: CircleAvatar(
                radius: 90,
                backgroundImage: AssetImage('images/handhaus_logo.png'),
              ),
      ),
    );
  }
}