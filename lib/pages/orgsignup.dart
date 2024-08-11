import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/pages/firebase.dart';
import 'package:universe2024/pages/loginpage.dart';

class orgsignup extends StatefulWidget {
  const orgsignup({Key? key});

  @override
  State<orgsignup> createState() => _orgsignupState();
}

class _orgsignupState extends State<orgsignup> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _collegeNameController = TextEditingController();
  TextEditingController _roll = TextEditingController();

  String _errorText = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _collegeNameController.dispose();
    _roll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(20, -1.2),
                child: Container(
                  height: MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Styles.yellowColor,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-2.7, -1.2),
                child: Container(
                  height: MediaQuery.of(context).size.width / 1.3,
                  width: MediaQuery.of(context).size.width / 1.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Styles.blueColor,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(2.7, -1.2),
                child: Container(
                  height: MediaQuery.of(context).size.width / 1.3,
                  width: MediaQuery.of(context).size.width / 1.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Styles.lblueColor,
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                child: Container(),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      children: [
                        const Gap(70),
                        Text(
                          "Sign-Up",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(30),
                        _buildTextField("Organization Name", _nameController),
                        const Gap(10),
                        _buildTextField("Organization Email", _emailController),
                        const Gap(10),
                        _buildTextField("Password", _passwordController),
                        const Gap(10),
                        _buildTextField(
                            "Confirm Password", _passwordController),
                        const Gap(10),
                        _buildTextField("College Name", _collegeNameController),
                        const Gap(50),
                        ElevatedButton(
                          onPressed: _signUp,
                          child: Text(
                            'Submit',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Styles.blueColor,
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        Gap(60),
                        Text("Already have an Account??"),
                        Gap(10),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the signup page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => loginpage()),
                            );
                          },
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: Styles.blueColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 10,
                  offset: Offset(2, 2),
                )
              ],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: label == 'Password' || label == 'Confirm Password',
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                contentPadding:
                const EdgeInsets.symmetric(vertical: 17, horizontal: 10),
                border: InputBorder.none,
                hintText: label,
                hintStyle: TextStyle(fontSize: 13),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _signUp() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();
  String confirmPassword = _passwordController.text.trim();
  String name = _nameController.text.trim();
  String collegeName = _collegeNameController.text.trim();

  // Check if any of the fields are empty
  if (email.isEmpty || password.isEmpty || name.isEmpty || collegeName.isEmpty) {
    setState(() {
      _errorText = 'All fields are required';
    });
    return;
  }

  // Check if passwords match
  if (password != confirmPassword) {
    setState(() {
      _errorText = 'Passwords do not match';
    });
    return;
  }

  try {
    // Perform sign up
    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      // Save the user details to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'userId': user.uid, // Add the userId to Firestore
        'name': name,
        'email': email,
        'collegeName': collegeName,
        'roll': 'Community',
        'status': 'pending',
      });

      // Navigate to login page after successful sign-up
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => loginpage()),
      );
    } else {
      setState(() {
        _errorText = 'Failed to create user. Please try again.';
      });
    }
  } catch (e) {
    // Handle specific FirebaseAuth errors
    String errorMessage;

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An unknown error occurred. Please try again.';
      }
    } else {
      errorMessage = 'An error occurred. Please check your internet connection and try again.';
    }

    // Update error message
    setState(() {
      _errorText = errorMessage;
    });
    print("Error during sign up: $e");
  }
}
}