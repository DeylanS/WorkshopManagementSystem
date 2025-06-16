import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Your Imports
import 'Repositories/PaymentInfo.dart';
import 'providers/inventory_provider.dart';
import 'providers/schedule_provider.dart';
import 'pages/Payment/PaymentList.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Stripe.publishableKey = 'pk_test_51RZTlhELyXHhdRCoPA5COMaHxcQ338EyeIUJuzJHl295KrgoUJHs53c6ZXXzYiQnDsJobMSTswu9hD1sjfq2MtJO006AIYDNoo';
  await Stripe.instance.applySettings();

  await FirebaseAuth.instance.signInAnonymously();

  // Use MultiProvider to provide all your providers at once
  runApp(
    MultiProvider(
      providers: [
        // Provider for your PaymentInfo repository.
        // Use Provider for objects that don't change/notify listeners.
        Provider<PaymentInfo>(
          create: (_) => PaymentInfo(),
        ),
        
        // ChangeNotifierProvider for Inventory management.
        ChangeNotifierProvider<InventoryProvider>(
          create: (_) => InventoryProvider(),
        ),

        // ChangeNotifierProvider for Schedule management.
        ChangeNotifierProvider<ScheduleProvider>(
          create: (_) => ScheduleProvider(),
        ),
      ],
      // The child of MultiProvider is your main App widget.
      // All widgets within MyApp can now access all three providers.
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
