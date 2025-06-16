import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_page.dart';
import 'login_page.dart';
import 'main_navigation.dart'; // ganti dari home_page.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startSplash();
  }

  void startSplash() async {
    await Future.delayed(const Duration(seconds: 2));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isOnboarded = prefs.getBool('isOnboarded') ?? false;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isOnboarded) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => OnboardingPage()));
    } else if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => MainNavigation()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/logo_kuisapp.png',
          width: 160,
        ),
      ),
    );
  }
}
