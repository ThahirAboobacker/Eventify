import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _emailSent = false;
  bool _error = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _error = true;
        _errorMessage = 'Please enter an email address.';
      });
      return;
    }

    try {
      // Attempt to send the password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Success
      setState(() {
        _emailSent = true;
        _error = false;
        _errorMessage = '';
      });
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      if (e.code == 'user-not-found') {
        // Email does not exist
        setState(() {
          _error = true;
          _errorMessage = 'No account found with this email address.';
        });
      } else if (e.code == 'invalid-email') {
        // Invalid email format
        setState(() {
          _error = true;
          _errorMessage = 'Invalid email address format.';
        });
      } else {
        // Other errors
        setState(() {
          _error = true;
          _errorMessage = 'Error sending email. Please try again.';
        });
      }
      print("Error sending password reset email: $e");
    } catch (e) {
      // General errors
      setState(() {
        _error = true;
        _emailSent = false;
        _errorMessage = 'Error sending email. Please try again.';
      });
      print("Error sending password reset email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(30),
              Icon(
                Icons.lock_open,
                color: Colors.black,
                size: 100.0,
              ),
              const Gap(20),
              Text(
                "Forgot Password?",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
              const Gap(20),
              Text(
                "We just need your email address to send your password reset code",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const Gap(100),
              if (_emailSent)
                Padding(
                  padding: const EdgeInsets.all(15), // Apply padding to all sides
                  child: Text(
                    'Password reset email sent. Please check your inbox.',
                    style: TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_error)
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const Gap(15),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  labelStyle: TextStyle(color: Colors.black),  // Label text color to black
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),  // Border color to black
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),  // Border color when focused
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _sendPasswordResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Updated to use backgroundColor
                ),
                child: Text(
                  'Send Reset Email',
                  style: TextStyle(color: Colors.white),  // Button text color to white
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
