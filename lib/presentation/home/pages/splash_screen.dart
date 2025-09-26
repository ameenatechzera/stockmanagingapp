import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockapp/presentation/home/pages/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // after 2 seconds, navigate on
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(_createFadeRoute());
      // context,
      // MaterialPageRoute(builder: (_) => HomeScreen()),
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1) The background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/freepik__the-style-is-candid-image-photography-with-natural__25112.jpeg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0xFF1C1243).withOpacity(0.8),
                  BlendMode.srcOver,
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icons/inventory (1).png', width: 100),

                Text(
                  'StockEase',
                  style: GoogleFonts.libreBaskerville(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                //const SizedBox(height: 10),
                Text(
                  'Effortless Stock tracking',
                  style: GoogleFonts.slabo27px(
                    fontSize: 16,
                    //fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PageRouteBuilder _createFadeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 800),
    );
  }
}
