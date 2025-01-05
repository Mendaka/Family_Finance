import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({Key? key}) : super(key: key);

  Future<void> _acceptPolicy(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isPolicyAccepted', true);
    Navigator.of(context).pushReplacementNamed('/home'); // ไปหน้า Home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App Policy')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              _buildSection(
                title: 'ၽႃႇသႃႇတႆး',
                description:
                    'ဢႅပ်ႉၼႆႉ ဢမ်ႇၸႂ်ႈဢႅပ်ႉတႃႇပၼ်ယိမ်ငိုၼ်းၵူႈငိုၼ်းလႃးလႃး၊\nၽူႈၶူင်သၢင်ႈမၼ်းႁဵတ်းဢွၵ်ႇမႃး တႃႇၸတ်းၵၢၼ်ဢမ်ႇၼၼ် ႁဵတ်းမၢႆတွင်းငိုၼ်းၶဝ်ႈငိုၼ်းဢွၵ်ႇလွင်ႈလဵဝ်ၵူၺ်း။',
              ),
               SizedBox(height: 10),
              _buildSection(
                title: 'မြန်မာ',
                description:
                    'ဤအက်ပ်သည် မည်သည့်ငွေချေးအက်ပ်မှမဟုတ်ပါ။\n developer သည် ဝင်ငွေနှင့် ကုန်ကျစရိတ်များကို စီမံခန့်ခွဲရန် သို့မဟုတ် မှတ်တမ်းတင်ရန်အတွက်သာ တီထွင်ခဲ့သည်။',
              ),
              SizedBox(height: 10),
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
              
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSection(
      {required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,fontFamily: "RobotoMono",
          ),
        ),
        SizedBox(height: 5),
        Text(
          description,
          style: TextStyle(fontSize: 14, color: Colors.black87,fontFamily: "RobotoMono",),
        ),
      ],
    );
  }
}
