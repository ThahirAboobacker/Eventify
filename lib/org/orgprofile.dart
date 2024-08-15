import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/org/editdetails.dart';
import '../pages/Eventdetails.dart';
import '../pages/loginpage.dart';
// Import EventDetails page

class OrgProfile extends StatefulWidget {
  const OrgProfile({Key? key}) : super(key: key);

  @override
  State<OrgProfile> createState() => _OrgProfileState();
}

class _OrgProfileState extends State<OrgProfile> {
  late Stream<DocumentSnapshot> _userStream;
  late Stream<List<Map<String, dynamic>>> _eventsStream;
  int followersCount = 0;

  @override
  void initState() {
    super.initState();
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .snapshots();
    _eventsStream = _fetchEventsForCommunity(currentUserUid);

    if (currentUserUid != null) {
      fetchFollowersCount(currentUserUid);
    }
  }

  // Fetching followers count
  void fetchFollowersCount(String communityId) async {
    try {
      QuerySnapshot followersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(communityId)
          .collection('followers')
          .get();

      setState(() {
        followersCount = followersSnapshot.docs.length;
      });
    } catch (e) {
      print("Error fetching followers count: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchEventsForCommunity(String? userId) async* {
    if (userId == null) {
      yield [];
      return;
    }

    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('EVENTS')
        .where('addedBy', isEqualTo: userId)
        .get();

    final events = eventsSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'eventName': data['eventName'],
        'imageUrl': data['imageUrl'],
        'eventDate': data['eventDate'],
        'eventLocation': data['eventLocation'],
        'documentID': doc.id,
      };
    }).toList();

    yield events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _userStream,
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
            if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final userData = userSnapshot.data?.data() as Map<String, dynamic>;
            final collegeName = userData['collegeName'] ?? '';
            final email = userData['email'] ?? '';
            final mobileNumber = userData['mobileNumber'] ?? '';
            final name = userData['name'] ?? '';
            final imageUrl = userData['imageUrl'] ?? 'assets/default_profile.png'; // Default image if none provided
            final isCommunity = userData['roll'] == 'Community';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: imageUrl.startsWith('http')
                            ? NetworkImage(imageUrl)
                            : AssetImage(imageUrl) as ImageProvider,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '$name',
                        style: TextStyle(
                          color: Styles.blueColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '$followersCount followers',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isCommunity
                              ? ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditDetailsForm(userData: userData),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Styles.blueColor,
                            ),
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                              : Container(),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut().then((_) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => loginpage()),
                                );
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Styles.blueColor,
                            ),
                            child: Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(10),
                      Row(
                        children: [
                          Icon(Icons.school, color: Styles.blueColor),
                          Gap(8),
                          Text(
                            'College: $collegeName',
                            style: TextStyle(
                              fontSize: 15,
                              color: Styles.blueColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, color: Styles.blueColor),
                          Gap(8),
                          Text(
                            'Email: $email',
                            style: TextStyle(
                              fontSize: 15,
                              color: Styles.blueColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, color: Styles.blueColor),
                          Gap(8),
                          Text(
                            'Phone: $mobileNumber',
                            style: TextStyle(
                              fontSize: 15,
                              color: Styles.blueColor,
                            ),
                          ),
                        ],
                      ),
                      Gap(30),
                      Divider(),
                      Gap(10),
                      Text(
                        'Events',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Styles.blueColor,
                        ),
                      ),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _eventsStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Map<String, dynamic>>> eventsSnapshot) {
                          if (eventsSnapshot.hasError) {
                            return Center(
                                child: Text('Error: ${eventsSnapshot.error}'));
                          }
                          if (eventsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final events = eventsSnapshot.data ?? [];
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: events.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.8,
                            ),
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventDetails(eventKey: event['documentID']),
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        event['imageUrl'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 120,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event['eventName'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Gap(5),
                                            Row(
                                              children: [
                                                Icon(Icons.date_range, size: 12, color: Colors.grey),
                                                Gap(4),
                                                Text(
                                                  event['eventDate'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Gap(5),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on, size: 12, color: Colors.grey),
                                                Gap(4),
                                                Text(
                                                  event['eventLocation'],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Gap(30),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}