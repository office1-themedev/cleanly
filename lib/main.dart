import 'package:cleanly_dashboard/pages/login.dart';
import 'package:cleanly_dashboard/pages/home.dart';
import 'package:cleanly_dashboard/service/auth.dart';
import 'package:cleanly_dashboard/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // dot env
  await dotenv.load();

  // run app
  runApp(const CleanlyApp());
}

class CleanlyApp extends StatefulWidget {
  const CleanlyApp({ Key ? key}) : super(key: key);

  @override
  _CleanlyAppState createState() => _CleanlyAppState();
}

class _CleanlyAppState extends State<CleanlyApp> {

  CleanlyAuth authClass = CleanlyAuth();
  Widget currentPage = const ApiScreen();

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  checkLogin() async {
    String token = await authClass.getStorage('base_url');
    String api_key = await authClass.getStorage('api_key');
    if (token != null && api_key != null) {
        setState(() {
          currentPage = const CleanlyHome();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

}
