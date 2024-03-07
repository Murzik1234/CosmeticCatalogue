import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/account_screen.dart';
import 'package:untitled/screens/home_screen.dart';
import 'package:untitled/screens/login_screen.dart';
import 'package:untitled/screens/reset_password_screen.dart';
import 'package:untitled/screens/signup_screen.dart';
import 'package:untitled/screens/verify_email_screen.dart';
import 'package:untitled/services/firebase_stream.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBbr7Ud8j-sZ7Sbm4tKWtR4l4c-iZvFIUc',
      appId: '1:525771353527:android:b619471d8483bbb66c8c32',
      messagingSenderId: '525771353527',
      projectId: 'lab1flutter',
      storageBucket: 'lab1flutter.appspot.com'
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab1',
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      routes: {
        '/': (context) => const FirebaseStream(),
        '/home': (context) => const HomeScreen(),
        '/account': (context) => const AccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
      },
      initialRoute: '/',
    );
  }
}

