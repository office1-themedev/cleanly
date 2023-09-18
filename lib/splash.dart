import 'package:cleanly_dashboard/backup.dart';
import 'package:cleanly_dashboard/pages/home.dart';
import 'package:cleanly_dashboard/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:page_transition/page_transition.dart';
//import 'package:js/js_util.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(splash:
        Image.asset('assets/images/logo-transparent.png',),
        splashIconSize: 300,duration: 3000,splashTransition: SplashTransition.fadeTransition,pageTransitionType: PageTransitionType.bottomToTop,backgroundColor: Colors.white, nextScreen: ApiScreen());
  }
}
