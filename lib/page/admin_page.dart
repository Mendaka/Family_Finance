import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   AdminPage({super.key});

  Future<bool> _isAdmin() async {
    User? user = _auth.currentUser;
    return user != null &&
        (user.email == 'mendaka@gmail.com' || user.email == 'mendaka@gmail.com');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data == true) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Admin Dashboard'),
              backgroundColor: Colors.purple,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    color: Colors.purple[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Admin Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[800],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                            ),
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text('Clear All Data'),
                            onPressed: () async {
                              bool confirm = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Data Clearance'),
                                  content: const Text(
                                      'Are you sure you want to clear data for all users? This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm) {
                                QuerySnapshot snapshot = await _firestore.collection('users').get();
                                for (var doc in snapshot.docs) {
                                  await doc.reference.delete();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('All user data cleared')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: UsersList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text(
                'Access Denied',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      },
    );
  }
}

class UsersList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   UsersList({super.key});

  Stream<List<Map<String, dynamic>>> _getUsersData() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getUsersData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        final users = snapshot.data!;
        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
          itemBuilder: (context, index) {
            return UserProgressWidget(user: users[index]);
          },
        );
      },
    );
  }
}

class UserProgressWidget extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserProgressWidget({super.key, required this.user});

  int _calculateUsagePercentage(Timestamp startDate) {
    final start = startDate.toDate();
    final now = DateTime.now();
    final difference = now.difference(start).inDays;
    final percentage = ((difference / (5 * 30)).clamp(0.0, 1.0) * 100).toInt();
    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    final startDate = user['startDate'] != null ? user['startDate'] as Timestamp : Timestamp.now();
    final percentage = _calculateUsagePercentage(startDate);
    final progressValue = percentage / 100;
    final progressColor = percentage == 100 ? Colors.red : Colors.green;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: progressColor,
        child: Text(
          '$percentage%',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(user['name'] ?? 'Unknown User'),
      subtitle: LinearProgressIndicator(
        value: progressValue,
        color: progressColor,
        backgroundColor: Colors.grey[200],
      ),
      trailing: percentage >= 100
          ? ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user['id'])
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User data cleared')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Clear Data'),
            )
          : null,
    );
  }
}
