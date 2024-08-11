import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universe2024/org/attendee.dart';

class EventMy extends StatelessWidget {
  final String userId;

  EventMy({required this.userId});

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
                            builder: (context) => Attendee(eventId: doc.id),
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
