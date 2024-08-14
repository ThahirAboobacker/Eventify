import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:universe2024/pages/Eventdetails.dart';

class CommunityPage extends StatefulWidget {
  final String communityId;

  const CommunityPage({Key? key, required this.communityId}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool isFollowed = false;
  late String communityName = "";
  late String communityEmail = "";
  late String communityPhone = "No Phone Provided";
  late String communityCollege = "";
  late String profileImageUrl = ""; // Fetch profile image URL
  int followersCount = 0;
  int eventsCount = 0;  // Variable to store the number of events
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late Stream<DocumentSnapshot> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.communityId)
        .snapshots();
    fetchCommunityDetails();
    checkIfFollowed();
    fetchFollowersCount();
    fetchEventsCount();  // Fetch the number of events
  }

  void toggleFollow() async {
    setState(() {
      isFollowed = !isFollowed;
      followersCount += isFollowed ? 1 : -1;
    });

    if (isFollowed) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.communityId)
          .collection('followers')
          .doc(currentUserId)
          .set({});
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.communityId)
          .collection('followers')
          .doc(currentUserId)
          .delete();
    }
  }

  void fetchCommunityDetails() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.communityId)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
        print('Document Data: $data');  // Debugging output

        setState(() {
          communityName = data?['name'] ?? 'Unknown Community';
          communityEmail = data?['email'] ?? 'No Email Provided';
          communityCollege = data?['collegeName'] ?? 'No College Provided';
          communityPhone = data?['phone'] ?? 'No Phone Provided';
          profileImageUrl = data?['imageUrl'] ?? ''; // Fetch image URL
        });
      } else {
        setState(() {
          communityName = "Community not found";
        });
      }
    } catch (e) {
      setState(() {
        communityName = "Error loading community details: ${e.toString()}";
      });
      print("Error fetching community details: $e");
    }
  }

  void checkIfFollowed() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.communityId)
        .collection('followers')
        .doc(currentUserId)
        .get();

    setState(() {
      isFollowed = doc.exists;
    });
  }

  void fetchFollowersCount() async {
    QuerySnapshot followersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.communityId)
        .collection('followers')
        .get();

    setState(() {
      followersCount = followersSnapshot.docs.length;
    });
  }

  void fetchEventsCount() async {
    QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
        .collection('EVENTS')
        .where('addedBy', isEqualTo: widget.communityId)
        .get();

    setState(() {
      eventsCount = eventsSnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Add your notification navigation here
            },
          ),
          SizedBox(width: 10),
          Image.asset('assets/EventOn.png', height: 32),
          SizedBox(width: 10),
        ],
        title: Text(
          communityName,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Community not found'));
          }

          DocumentSnapshot communityDoc = snapshot.data!;
          Map<String, dynamic> communityData = communityDoc.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 16,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : AssetImage('assets/ieeeprofile.jpeg') as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 140,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              communityName,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '$followersCount followers • $eventsCount events',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.black),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              communityEmail,
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.black),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              communityPhone,
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.school, color: Colors.black),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              communityCollege,
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowed ? Colors.grey[300] : Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          isFollowed ? 'Following' : 'Follow',
                          style: TextStyle(
                            color: isFollowed ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 16),
                      Text(
                        'Events',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('EVENTS')
                            .where('addedBy', isEqualTo: widget.communityId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          var events = snapshot.data!.docs;

                          const int columns = 2;
                          int rows = (events.length / columns).ceil();

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              var event = events[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventDetails(eventKey: event.id),
                                    ),
                                  );
                                },
                                child: Container(
                                  color: Colors.grey[300],
                                  child: Image.network(
                                    event['imageUrl'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
