import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventMy extends StatelessWidget {
  final String userId = '2CGHtfZZ2USbD0TfuUMMwKgwxAB2'; // Replace with the actual user ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Events'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('EVENTS')
            .where('addedby', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No events found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var event = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(event['eventName'] ?? 'No title'),
                subtitle: Text(event['description'] ?? 'No description'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(event['date'] ?? 'No date'),
                    IconButton(
                      icon: Icon(Icons.people),
                      onPressed: () {
                        // Navigate to Registrants Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrantsPage(eventId: doc.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class RegistrantsPage extends StatelessWidget {
  final String eventId;

  RegistrantsPage({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrants'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('EVENT')
            .doc(eventId)
            .collection('registrants')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No registrants found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var registrant = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(registrant['name'] ?? 'No name'),
                subtitle: Text(registrant['email'] ?? 'No email'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
