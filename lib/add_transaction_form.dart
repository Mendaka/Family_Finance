import 'package:family_finance/language/app_translations.dart';
import 'package:family_finance/language/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';

class AddTransactionForm extends StatefulWidget {
  final Function onTransactionAdded;

  const AddTransactionForm({super.key, required this.onTransactionAdded});

  @override
  _AddTransactionFormState createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  String _transactionType = 'ငိုၼ်းၶဝ်ႈ'; // ค่าเริ่มต้น
  String _category = 'ၶဝ်ႈၽၵ်း'; // ค่าเริ่มต้น
  String _title = '';
  double _amount = 0.0;
  DateTime? _selectedDate; // วันที่ที่เลือก
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ฟังก์ชันแปลประเภท (รายรับ/รายจ่าย)
  String _getTranslatedTransactionType(String type, String languageCode) {
    switch (type) {
      case "ငိုၼ်းၶဝ်ႈ":
        return {
          "shn": "ငိုၼ်းၶဝ်ႈ",
          "th": "รายรับ",
          "en": "Income",
          "mm": "ဝင်ငွေ",
        }[languageCode]!;
      case "ငိုၼ်းဢွၵ်ႇ":
        return {
          "shn": "ငိုၼ်းဢွၵ်ႇ",
          "th": "รายจ่าย",
          "en": "Expense",
          "mm": "ကုန်ကျစရိတ်",
        }[languageCode]!;
      default:
        return type;
    }
  }

  // ฟังก์ชันแปลหมวดหมู่
  Map<String, String> _getTranslatedCategory(String category) {
    switch (category) {
      case "ၶဝ်ႈၽၵ်း":
        return {
          "shn": "ၶဝ်ႈၽၵ်း",
          "th": "อาหาร",
          "en": "Food",
          "mm": "အစားအသောက်"
        };
      case "ၶွင်ၸႂ်ႉ":
        return {
          "shn": "ၶွင်ၸႂ်ႉ",
          "th": "ของใช้",
          "en": "Items",
          "mm": "ပစ္စည်းများ"
        };
      case "ၼူမ်းလုၵ်ႈလႄႈၶွင်ၸႂ်ႉ":
        return {
          "shn": "ၼူမ်းလုၵ်ႈလႄႈၶွင်ၸႂ်ႉ",
          "th": "นมเด็กและของใช้",
          "en": "Baby",
          "mm": "ကလေးနို့နှင့် အသုံးအဆောင်များ"
        };
      case "သိူဝ်ႈၽႃႈ":
        return {"shn": "သိူဝ်ႈၽႃႈ", "th": "เสื้อผ้า", "en": "Clothes","mm":"အဝတ်"};
      case "တၢင်းၵိၼ်လဵၼ်ႈ":
        return {"shn": "တၢင်းၵိၼ်လဵၼ်ႈ", "th": "ของว่าง", "en": "Snacks","mm":"အဆာပြေ"};
      case "ငိုၼ်းႁွမ်ၸူႉ":
        return {"shn": "ငိုၼ်းႁွမ်ၸူႉ", "th": "เงินออม", "en": "Savings","mm":"စုဆောင်းငွေ"};
      case "ၵႃႈၼဵတ်ႇ":
        return {"shn": "ၵႃႈၼဵတ်ႇ", "th": "ค่าเน็ต", "en": "Internet","mm":"အင်တာနက်"};
      case "ၵႃႈႁဵၼ်း":
        return {"shn": "ၵႃႈႁဵၼ်း", "th": "การศึกษา", "en": "Education","mm":"ပညာရေး"};
      case "ထီႇ":
        return {"shn": "ထီႇ", "th": "หวย", "en": "Lottery","mm":"ထီ"};
      case "ပၢႆးယူႇလီ":
        return {"shn": "ပၢႆးယူႇလီ", "th": "สุขภาพ", "en": "Health","mm":"ကျန်းမာရေး"};
      case "ၵႃႈဢွၵ်ႇတၢင်း":
        return {"shn": "ၵႃႈဢွၵ်ႇတၢင်း", "th": "ค่าเดินทาง", "en": "Transport","mm":"ခရီးစရိတ်"};
      case "ၽွၼ်ႇလူတ်ႉ":
        return {"shn": "ၽွၼ်ႇလူတ်ႉ", "th": "ค่าผ่อนรถ", "en": "Installment","mm":"ကားခများ"};
      case "ၶွင်ၶႂၼ်":
        return {"shn": "ၶွင်ၶႂၼ်", "th": "ของขวัญ", "en": "Gift","mm":"လက်ဆောင်"};
      case "ၵႃႈႁိူၼ်း":
        return {"shn": "ၵႃႈႁိူၼ်း", "th": "ค่าบ้าน", "en": "Housing","mm":"အိမ်စရိတ်"};
      case "ၵႃႈၾႆးၾႃႉ":
        return {"shn": "ၵႃႈၾႆးၾႃႉ", "th": "ค่าไฟฟ้า", "en": "Electricity","mm":"လျှပ်စစ်မီတာခ"};
      case "ၵႃႈၼမ်ႉ":
        return {"shn": "ၵႃႈၼမ်ႉ", "th": "ค่าน้ำ", "en": "Water","mm":"ရေမီတာခ"};
      case "ၵႃႈႁႅင်း":
        return {"shn": "ၵႃႈႁႅင်း", "th": "ค่าแรง", "en": "Wages","mm":"လုပ်အားခ"};
      case "ၵႃႈၶၢတ်ႈႁိူၼ်း":
        return {
          "shn": "ၵႃႈၶၢတ်ႈႁိူၼ်း",
          "th": "ค่าเช่าบ้าน",
          "en": "House rent","mm":"အိမ်ငှားခ"
        };
      case "သႂ်ႇငိုၼ်းၽူင်း":
        return {
          "shn": "သႂ်ႇငိုၼ်းၽူင်း",
          "th": "บัตรเติมเงิน",
          "en": "prepaid card","mm":"ငွေဖြည့်ကတ်"
        };
      case "ၼမ်ႉမၼ်းလူတ်ႉ":
        return {"shn": "ၼမ်ႉမၼ်းလူတ်ႉ", "th": "น้ำมันรถ", "en": "diesel","mm":"ဒီဇယ်"};
      case "မႄးလူတ်ႉၶိူင်ႈ/ၵႃး":
        return {
          "shn": "မႄးလူတ်ႉၶိူင်ႈ/ၵႃး",
          "th": "ซ่อมรถ",
          "en": "Car repair","mm":"ကားပြုပြင်ခြင်း။"
        };
          case "ႁဵတ်းၵုသူဝ်ႇ":
        return {
          "shn": "ႁဵတ်းၵုသူဝ်ႇ",
          "th": "ทำบุญ/บริจาก",
          "en": "donate","mm":"ကုသိုလ်/လှူဒါန်း"
        };
      default:
        return {"shn": category, "th": "อื่นๆ", "en": "Other","mm":"တခြား"};
    }
  }

  // ฟังก์ชันเลือกวันที่
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // ฟังก์ชันบันทึกข้อมูล
  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('transactions').add({
          'userId': user.uid,
          'type': {
            "shn": _transactionType,
            "th": _transactionType == "ငိုၼ်းၶဝ်ႈ" ? "รายรับ" : "รายจ่าย",
            "en": _transactionType == "ငိုၼ်းၶဝ်ႈ" ? "Income" : "Expense",
            "mm": _transactionType == "ငိုၼ်းၶဝ်ႈ" ? "ဝင်ငွေ" : "ကုန်ကျစရိတ်"
          },
          'category': _getTranslatedCategory(_category),
          'title': {
            "shn": _title,
            "th": _title,
            "en": _title,
            "mm": _title,
          },
          'amount': _amount,
          'date': _selectedDate ?? DateTime.now(), // ใช้วันที่ปัจจุบันหากไม่ได้เลือกวันที่
        });

        widget.onTransactionAdded();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนเพิ่มรายการ')),
        );
      }
    }else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกวันที่')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage =
        Provider.of<LocaleProvider>(context).currentLanguage;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 25.0,
      ),
      child: SingleChildScrollView(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      AppTranslations.getText('Add item', currentLanguage),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: "RobotoMono",
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _transactionType,
                    decoration: InputDecoration(
                      labelText: AppTranslations.getText(
                          'Income or expenses', currentLanguage),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      // fillColor: Colors.grey[200],
                    ),
                    items: ['ငိုၼ်းၶဝ်ႈ', 'ငိုၼ်းဢွၵ်ႇ',]
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                _getTranslatedTransactionType(
                                    type, currentLanguage),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _transactionType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: InputDecoration(
                      labelText:
                          AppTranslations.getText('Category', currentLanguage),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      // fillColor: Colors.grey[200],
                    ),
                    items: [
                      'ၶဝ်ႈၽၵ်း',
                      'ၶွင်ၸႂ်ႉ',
                      'ၼူမ်းလုၵ်ႈလႄႈၶွင်ၸႂ်ႉ',
                      'သိူဝ်ႈၽႃႈ',
                      'တၢင်းၵိၼ်လဵၼ်ႈ',
                      'ငိုၼ်းႁွမ်ၸူႉ',
                      'ၵႃႈၼဵတ်ႇ',
                      'ၵႃႈႁဵၼ်း',
                      'ထီႇ',
                      'ပၢႆးယူႇလီ',
                      'ၵႃႈဢွၵ်ႇတၢင်း',
                      'ၽွၼ်ႇလူတ်ႉ',
                      'ၶွင်ၶႂၼ်',
                      'ၵႃႈႁိူၼ်း',
                      'ၵႃႈၾႆးၾႃႉ',
                      'ၵႃႈၼမ်ႉ',
                      'ၵႃႈႁႅင်း',
                      'ၵႃႈၶၢတ်ႈႁိူၼ်း',
                      'သႂ်ႇငိုၼ်းၽူင်း',
                      'ၼမ်ႉမၼ်းလူတ်ႉ',
                      'မႄးလူတ်ႉၶိူင်ႈ/ၵႃး',
                      'ႁဵတ်းၵုသူဝ်ႇ',

                    ]
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                _getTranslatedCategory(
                                        category)[currentLanguage] ??
                                    category,
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText:
                          AppTranslations.getText('Item name', currentLanguage),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      // fillColor: Colors.grey[200],
                    ),
                    onChanged: (value) => _title = value,
                    validator: (value) =>
                        value!.isEmpty ? 'กรุณากรอกชื่อรายการ' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText:
                          AppTranslations.getText('Amount', currentLanguage),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      // fillColor: Colors.grey[200],
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        _amount = double.tryParse(value) ?? 0.0,
                    validator: (value) =>
                        value!.isEmpty ? 'กรุณากรอกจำนวนเงิน' : null,
                  ),
                  const SizedBox(height: 12),
                   // เพิ่มปุ่มเลือกวันที่
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.toLocal()}'.split(' ')[0]
                            : AppTranslations.getText(
                                'Date', currentLanguage),
                        style: TextStyle(fontSize: 16),
                      ),
                      ElevatedButton(
                        onPressed: _pickDate,
                        child: Text(AppTranslations.getText(
                            'Choose a date', currentLanguage)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .blue, // เปลี่ยนสีพื้นหลัง (ตัวอย่างใช้สีน้ำเงิน)
                        minimumSize: const Size(
                            200, 50), // ตั้งค่าความกว้างและความสูงขั้นต่ำ
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // ปรับขอบมน
                        ),
                      ),
                      onPressed: _saveTransaction,
                      child: Text(
                        AppTranslations.getText('Save', currentLanguage),
                        style: const TextStyle(
                          fontSize: 16, // ปรับขนาดตัวอักษร
                          color: Colors.white, // สีตัวอักษร (ตัวอย่างเป็นสีขาว)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
