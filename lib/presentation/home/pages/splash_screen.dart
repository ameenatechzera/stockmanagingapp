import 'package:flutter/material.dart';
import 'package:stockapp/core/colors/colors.dart';
import 'dart:async';

import 'package:stockapp/presentation/home/pages/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xff0A192F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C1243), Color.fromARGB(255, 10, 6, 20)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.inventory_2_outlined, size: 80, color: kwhite),
              SizedBox(height: 20),
              Text(
                'Stock Manager',
                style: TextStyle(
                  color: kwhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
