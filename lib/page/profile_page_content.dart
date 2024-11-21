import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePageContent extends StatelessWidget {
  final Future<Map<String, dynamic>> Function() getUserData;
  final Future<void> Function(BuildContext) logout;

  const ProfilePageContent(this.getUserData, this.logout, {super.key});

  Future<bool> _isAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null &&
        (user.email == 'mendaka@gmail.com' || user.email == '[YOUR_ADMIN_EMAIL]');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No user data found'));
        }

        final userData = snapshot.data!;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userData['name'] ?? 'No Name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Raleway",
                  color: Colors.white,
                ),
              ),
              Text(
                userData['email'] ?? 'No Email',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                icon: const Icon(Icons.logout,color: Colors.white,),
                label: const Text('Logout',style: TextStyle(color: Colors.white
                ),),
              ),
              const SizedBox(height: 20),
              // แสดงปุ่ม Admin เฉพาะเมื่อผู้ใช้เป็น Admin
              FutureBuilder<bool>(
                future: _isAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(); // ไม่แสดงอะไรระหว่างโหลด
                  }
                  if (snapshot.hasData && snapshot.data == true) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/admin');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      icon: const Icon(Icons.admin_panel_settings,color: Colors.white,),
                      label: const Text('Admin',style: TextStyle(color: Colors.white),),
                    );
                  }
                  return const SizedBox(); // ถ้าไม่ใช่ Admin จะไม่แสดงปุ่มนี้
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
