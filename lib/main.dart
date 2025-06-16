import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Your Imports
import 'Repositories/PaymentInfo.dart';
import 'providers/inventory_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/rating_provider.dart';
import 'providers/user_provider.dart';
import 'pages/Payment/PaymentList.dart';
import 'screens/login_page.dart';

void main() async {
  // This function is the one that will solve the problem.
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // --- THE REST OF YOUR CODE REMAINS THE SAME ---

  Stripe.publishableKey = 'pk_test_51RZTlhELyXHhdRCoPA5COMaHxcQ338EyeIUJuzJHl295KrgoUJHs53c6ZXXzYiQnDsJobMSTswu9hD1sjfq2MtJO006AIYDNoo';
  await Stripe.instance.applySettings();

  await FirebaseAuth.instance.signInAnonymously();

  // Use MultiProvider to provide all your providers at once
  runApp(
    MultiProvider(
      providers: [
        // Your providers are configured correctly here.
        Provider<PaymentInfo>(
          create: (_) => PaymentInfo(),
        ),
        ChangeNotifierProvider<InventoryProvider>(
          create: (_) => InventoryProvider(),
        ),
        ChangeNotifierProvider<ScheduleProvider>(
          create: (_) => ScheduleProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider<RatingProvider>(
          create: (_) => RatingProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
