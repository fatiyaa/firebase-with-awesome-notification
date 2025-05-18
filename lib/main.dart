import 'package:crud_firebase/pages/home_page.dart';
import 'package:crud_firebase/pages/login.dart';
import 'package:crud_firebase/pages/register.dart';
import 'package:crud_firebase/pages/second.dart';
import 'package:crud_firebase/services/notification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'login',
      routes: {
        'home': (context) => const HomePage(),
        'second': (context) => const SecondScreen(),
        'login': (context) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
      },
      navigatorKey: navigatorKey,
    );
  }
}
