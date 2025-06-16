import 'package:flutter/material.dart';

// TODO: Make sure to import your page files
import 'inventory/view_inventory.dart';
import 'schedule/schedule_dashboard.dart'; // Example page 2
import '../pages/Payment/PaymentList.dart'; // Example page 3
import 'auth/signup_page.dart';
import 'rating/rating_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1. State variable to track login status
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title changes based on login state
        title: Text(_isLoggedIn ? 'Dashboard' : 'Login'),
      ),
      // 2. Body conditionally renders a widget based on login state
      body: Center(
      child: _isLoggedIn
          ? _buildDashboardButtons() // If TRUE, show the dashboard
          : Column(                  // If FALSE, show a Column with two buttons
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLoginButton(),
                const SizedBox(height: 12), // Adds some space between buttons
                _buildRegisterButton(),
              ],
            ),
    ),
    );
  
  }

  // Widget for the initial Login Button
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        // 3. Set state to true, which rebuilds the widget
        // In a real app, this would be after successful authentication
        setState(() {
          _isLoggedIn = true;
        });
      },
      child: const Text('Login'),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignUpPage()),
            );
          },
      child: const Text('Sign Up'),
    );
  }

  // Widget for the 3 navigation buttons shown after login
  Widget _buildDashboardButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Button 1: Navigates to Inventory
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ViewInventoryPage()),
            );
          },
          child: const Text('View Inventory'),
        ),
        const SizedBox(height: 16),

        // Button 2: Navigates to a different page (e.g., Reports)
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScheduleDashboard()),
            );
          },
          child: const Text('View Schedule Dashboard'),
        ),
        const SizedBox(height: 16),

        // Button 3: Navigates to another page (e.g., Settings)
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentList()),
            );
          },
          child: const Text('Payments'),
        ),
        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RatingDashboard()),
            );
          },
          child: const Text('Ratings'),
        ),
      ],
    );
  }
}
