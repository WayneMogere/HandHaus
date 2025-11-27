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
    Future.delayed(Duration(seconds: 5),(){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(248, 243, 236, 1),
      body: Image.asset('images/handhaus_logo.png',
      width: double.infinity,
      height: double.infinity,
      ),
    );
  }
}