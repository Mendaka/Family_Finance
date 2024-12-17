import 'dart:async';

import 'package:family_finance/main.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () async {
      // ตรวจสอบสถานะการล็อกอิน
      bool isLoggedIn = await checkLoginStatus();

      // นำทางไปยังหน้าที่เหมาะสม
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
        backgroundColor: Colors.blueAccent,
        body: Container(
          decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center, // จุดศูนย์กลาง
            radius: 0.8, // รัศมีของวงกลม
            colors: [
              Color(0xFFFFF9C4), // สีเหลืองจาง (ตรงกลาง)
              Color(0xFFFFF176), // สีเหลืองสด (รอบนอก)
              Color(0xFFFFEE58), // สีเหลืองเข้ม (รอบนอกสุด)
            ],
            stops: [0.3, 0.7, 1.0], // กำหนดตำแหน่งของแต่ละสี
          ),
        ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon/splash_icon.png',
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 20),
                Text(
                  'Family Finance',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ));
  }
}
