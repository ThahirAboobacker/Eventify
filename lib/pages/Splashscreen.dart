import 'dart:async';
import 'package:flutter/material.dart';
import 'package:EventON/pages/loginpage.dart';
import 'package:gap/gap.dart';
import 'package:EventON/pages/homepage.dart'; // Import the HomePage library
import 'package:EventON/org/home.dart'; // Import the SocHomePage library
import 'package:shared_preferences/shared_preferences.dart'; // Import the SharedPreferences library
import 'package:EventON/admin/admhome.dart'; // Import the Admhome library
import 'package:cloud_firestore/cloud_firestore.dart'; // Import the Cloud Firestore library
import 'package:firebase_auth/firebase_auth.dart'; // Import the Firebase Auth library

class Splashscreen extends StatefulWidget {
  @override
  State<Splashscreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<Splashscreen> {

  static const String KEYLOGIN = "Login";
  @override
  void initState() {
    super.initState();
    whereToGo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/EventOn.png',
                  width: 150, // Adjust size as needed

                ),
                Gap(10),
                Text(
                  'Lead with EventOn',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic,color: Colors.black,),
                )// Add spacing between logo and text
              ],
            ),
// Add spacing between logo and text

          ],
        ),
      ),
    );
  }
  void whereToGo() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    var isLoggedIn = sharedPref.getBool(KEYLOGIN);

    Timer(Duration(seconds: 3), () {
      if (isLoggedIn == null || isLoggedIn == false) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => loginpage(),
            ));
      } else {
        void route() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('roll') == 'Community' &&
            documentSnapshot.get('status') == 'pending') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Admin not approved yet, Please contact the admin'),
            ),
          );
        } else if (documentSnapshot.get('roll') == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userId: documentSnapshot.id,),
            ),
          );
        } else if (documentSnapshot.get('roll') == 'Admin'){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Admhome(),
            ),
          );
        }
        else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SocHomePage(
                userId: documentSnapshot.id,
              ),
            ),
          );
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }
      }
    });
  }
}