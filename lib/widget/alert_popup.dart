import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertPopup {
  static Future<void> showAlertIfFirstLaunch(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      _showAlertDialog(context);
      prefs.setBool('isFirstLaunch', false);
    }
  }

  static void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "⚠️ คำเตือน / Warning",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'ภาษาไทย',
                  description:
                      'แอปนี้ไม่ใช่แอปปล่อยกู้เงินใดๆ ทั้งสิ้น\nนักพัฒนาพัฒนาเพื่อการจัดการหรือบันทึกรายรับรายจ่ายเท่านั้น',
                ),
                SizedBox(height: 10),
                _buildSection(
                  title: 'English',
                  description:
                      'This app is not a money lending app of any kind.\nThe developer developed it for managing or recording income and expenses only.',
                ),
                SizedBox(height: 10),
                _buildSection(
                  title: 'ၽႃႇသႃႇတႆး',
                  description:
                      'ဢႅပ်ႉၼႆႉ ဢမ်ႇၸႂ်ႈဢႅပ်ႉတႃႇပၼ်ယိမ်ငိုၼ်းၵူႈငိုၼ်းလႃးလႃး၊\nၽူႈၶူင်သၢင်ႈမၼ်းႁဵတ်းဢွၵ်ႇမႃး တႃႇၸတ်းၵၢၼ်ဢမ်ႇၼၼ် ႁဵတ်းမၢႆတွင်းငိုၼ်းၶဝ်ႈငိုၼ်းဢွၵ်ႇလွင်ႈလဵဝ်ၵူၺ်း။',
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('ตกลง / OK'),
              ),
            )
          ],
        );
      },
    );
  }

  static Widget _buildSection({required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 5),
        Text(
          description,
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}
