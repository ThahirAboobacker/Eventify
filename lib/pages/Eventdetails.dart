import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readmore/readmore.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/org/EditEventScreen.dart';
import 'package:universe2024/org/qrscanner.dart';
import 'package:universe2024/pages/qrcode.dart';

class EventDetails extends StatefulWidget {
  final String eventKey;

  const EventDetails({Key? key, required this.eventKey}) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  late Stream<DocumentSnapshot> _stream;
  bool _isRegistrationOpen = true;
  var _userRole = ['student'];
  bool _isRegistered = false;
  String _paymentStatus = '';

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('EVENTS')
        .doc(widget.eventKey)
        .snapshots();
    _fetchUserRole();
    _checkRegistrationStatus();
  }

  void _fetchUserRole() async {
    String userId = getCurrentUserId();
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    setState(() {
      _userRole = userDoc['roll'];
    });
  }

  void _checkRegistrationStatus() async {
    String userId = getCurrentUserId();
    QuerySnapshot registrationDocs = await FirebaseFirestore.instance
        .collection('REGISTRATIONS')
        .where('eventId', isEqualTo: widget.eventKey)
        .where('userId', isEqualTo: userId)
        .get();

    if (registrationDocs.docs.isNotEmpty) {
      DocumentSnapshot registrationDoc = registrationDocs.docs.first;
      setState(() {
        _isRegistered = true;
        _paymentStatus = registrationDoc['PaymentStatus'];
      });
    } else {
      setState(() {
        _isRegistered = false;
        _paymentStatus = '';
      });
    }
  }

  String getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }

  void _editEvent(DocumentSnapshot eventDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventScreen(eventKey: widget.eventKey),
      ),
    );
  }

  void _deleteEvent() async {
    await FirebaseFirestore.instance
        .collection('EVENTS')
        .doc(widget.eventKey)
        .delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Event not found'));
          }

          DocumentSnapshot eventDoc = snapshot.data!;
          Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;

          _isRegistrationOpen = eventData['isRegistrationOpen'];

          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildEventHeader(eventData),
                _buildEventDetails(eventData),
                _buildActionButtons(snapshot.data!),
                if (_isRegistered && _paymentStatus == 'pending')
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                    child: Text(
                      "Waiting for payment verification",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventHeader(Map<String, dynamic> eventData) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Image.asset('assets/13.jpg'),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.grey,
                image: DecorationImage(
                  image: AssetImage('assets/13.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 325,
            left: MediaQuery.of(context).size.width / 8,
            right: MediaQuery.of(context).size.width / 8,
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    spreadRadius: 3,
                    blurRadius: 15,
                    offset: Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Styles.yellowColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      eventData['eventName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Styles.blueColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "- ${eventData['eventType']}  :  ${eventData['eventTime']}",
                          style: TextStyle(
                            color: Styles.blueColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "- ${eventData['eventDate']}  :  ${eventData['eventTime']}",
                          style: TextStyle(
                            color: Styles.blueColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "- For queries:  ${eventData['eventContact']}",
                          style: TextStyle(
                            color: Styles.blueColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails(Map<String, dynamic> eventData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 35),
          child: Text(
            "Description",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Styles.blueColor,
              fontSize: 15,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 125,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ReadMoreText(
                eventData['description'],
                trimMode: TrimMode.Line,
                trimLines: 4,
                trimLength: 150,
                style: TextStyle(color: Styles.blueColor),
                colorClickableText: Colors.blue,
                trimCollapsedText: 'Read More',
                trimExpandedText: 'Read less',
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 35),
          child: Text(
            "Venue",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Styles.blueColor,
              fontSize: 15,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Styles.yellowColor, width: 0.75),
                bottom: BorderSide(color: Styles.yellowColor, width: 0.75),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(
                  eventData['eventLocation'],
                  style: TextStyle(color: Styles.blueColor),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTicketPrice(eventData['eventPrice']),
            _buildRegistrationButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketPrice(String price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
          child: Text(
            "Ticket Price",
            style: TextStyle(
              color: Styles.yellowColor,
              fontSize: 13.5,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 35),
          height: 34,
          child: Text(
            price,
            style: TextStyle(
              color: Styles.blueColor,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationButton() {
    if (_isRegistered) {
      if (_paymentStatus == 'approved') {
        // Navigate to QR generation page
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QrGenerationScreen(id: getCurrentUserId()),
            ),
          );
        });
        return Container();
      } else if (_paymentStatus == 'pending') {
        return Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              child: Text(
                "Waiting for payment verification",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }
    }

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
          child: Text(
            "Registration",
            style: TextStyle(
              color: Styles.yellowColor,
              fontSize: 13.5,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 35),
          height: 34,
          child: Row(
            children: [
              if (_isRegistrationOpen)
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Get the current user information
                      String userId = getCurrentUserId();
                      DocumentSnapshot userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .get();

                      // Get the current event information
                      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
                          .collection('EVENTS')
                          .doc(widget.eventKey)
                          .get();

                      // Create a new document in the REGISTRATIONS collection
                      DocumentReference registrationRef = FirebaseFirestore.instance.collection('REGISTRATIONS').doc();
                      await registrationRef.set({
                        'eventName': eventDoc['eventName'],
                        'eventId': widget.eventKey,
                        'userName': userDoc['name'],
                        'userId': userId,
                        'registrationId': registrationRef.id,
                        'PaymentStatus': 'pending',
                        'ScannedStatus': 'pending', // Store the registration ID
                      });

                      // Optionally, retrieve the registration ID if needed
                      String registrationId = registrationRef.id;
                      _buildRegistrationButton();
                    } catch (e) {
                      print('Error during registration: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Register'),
                )
              else
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Closed'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(DocumentSnapshot eventDoc) {
    if (_userRole == 'Community') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => _editEvent(eventDoc),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.blueColor,
              ),
              child: Text('Edit Event'),
            ),
            ElevatedButton(
              onPressed: _deleteEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Delete Event'),
            ),
          ],
        ),
      );
    }
    return Container();
  }
}
