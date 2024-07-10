import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_uts/firebase_options.dart';
import 'package:flutter_application_uts/screen/splash_screen.dart';
import 'package:get/get.dart';
import 'auth/firebase_auth_service.dart';
import 'screen/home_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuthService _authService =
      FirebaseAuthService(FirebaseAuth.instance);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Aplikasi Laporan Kehilangan Barang Di Kampus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<User?>(
        future: _authService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasData) {
            return homepage();
          } else {
            return SplashScreen();
          }
        },
      ),
    );
  }
}
