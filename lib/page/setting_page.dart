import 'package:family_finance/language/app_translations.dart';
import 'package:family_finance/language/locale_provider.dart';
import 'package:family_finance/page/currency_provider.dart';
import 'package:family_finance/page/profile_page_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedCurrency = '฿'; // ค่าเริ่มต้นของสกุลเงิน

  @override
  void initState() {
    super.initState();
    _loadSelectedCurrency();
  }

  Future<void> _loadSelectedCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString('selectedCurrency') ?? '฿';
    });
  }

  Future<void> _saveSelectedCurrency(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCurrency', currency);
  }

  Future<void> _clearData(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final batch = _firestore.batch();
        final snapshot = await _firestore
            .collection('transactions')
            .where('userId', isEqualTo: user.uid) // กรองตาม userId
            .get();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data cleared successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to clear data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing data: $e')),
      );
    }
  }

  Future<void> _confirmClearData(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final currentLanguage =
        Provider.of<LocaleProvider>(context).currentLanguage;
        return AlertDialog(
          title: Text(
            AppTranslations.getText('Confirm Data Clear', currentLanguage),
            style: const TextStyle(fontSize: 17),
          ),
          content: RichText(
            text: TextSpan(
              text:  AppTranslations.getText('Are you sure you wan to clear all data?', currentLanguage),
              style: const TextStyle(color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: AppTranslations.getText('Warning!This operation cannot be recovered', currentLanguage),
                  style: const TextStyle(color: Colors.red),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text( AppTranslations.getText('Cancel', currentLanguage),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearData(context);
              },
              child: Text(
                 AppTranslations.getText('Confirm', currentLanguage),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToTransactionPage(String filterType, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionListPage(
          firestore: _firestore,
          filterType: filterType,
          title: title,
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('isLoggedIn'); // ลบสถานะการล็อกอินออกจาก SharedPreferences
  Navigator.pushReplacementNamed(context, '/login'); // ย้อนกลับไปที่หน้า Login
}

Future<Map<String, dynamic>> _getUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return snapshot.data() ?? {};
  }
  return {};
}


  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currentLanguage =
        Provider.of<LocaleProvider>(context).currentLanguage;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppTranslations.getText('Settings', currentLanguage),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                 fontFamily: "RobotoMono",
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text( AppTranslations.getText('Select currency', currentLanguage),style: TextStyle( fontFamily: "RobotoMono",),),
            trailing: DropdownButton<String>(
              value: _selectedCurrency,
              items: ['฿', '\$', 'K', '¥'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value,style: TextStyle( fontFamily: "RobotoMono",),),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  currencyProvider.setCurrencySymbol(newValue);
                }
              },
            ),
          ),
          const Divider(),
       

          ListTile(
            title: Text(
              AppTranslations.getText('clear all data', currentLanguage),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: "RobotoMono",
              ),
            ),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () => _confirmClearData(context),
          ),
          ListTile(
            title: Text(
              AppTranslations.getText(
                  'show all income transactions', currentLanguage),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: "RobotoMono",
              ),
            ),
            trailing: const Icon(Icons.attach_money, color: Colors.green),
            onTap: () => _navigateToTransactionPage(
                'ငိုၼ်းၶဝ်ႈ', 'All Income Transactions'),
          ),
          ListTile(
            title: Text(
              AppTranslations.getText(
                  'show all expense transactions', currentLanguage),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: "RobotoMono",
              ),
            ),
            trailing: const Icon(Icons.money_off, color: Colors.red),
            onTap: () => _navigateToTransactionPage(
                'ငိုၼ်းဢွၵ်ႇ', 'All Expense Transactions'),
          ),
        ],
      ),
    );
  }
}

class TransactionListPage extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String filterType;
  final String title;

  const TransactionListPage({
    super.key,
    required this.firestore,
    required this.filterType,
    required this.title,
  });

  Future<void> _deleteTransaction(BuildContext context, String docId) async {
    try {
      await firestore.collection('transactions').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting transaction: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currentLanguage =
        Provider.of<LocaleProvider>(context).currentLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view transactions'))
          : StreamBuilder(
  stream: firestore
      .collection('transactions')
      .where('userId', isEqualTo: user.uid) // กรอง userId
      .where('type.shn', isEqualTo: filterType) // ระบุ key ของภาษา shn
      .snapshots(),
  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.data!.docs.isEmpty) {
      print('No documents found for filterType: $filterType');
      return Center(
        child: Text(
          AppTranslations.getText('No data to display', currentLanguage),
          style: const TextStyle(fontSize: 16, fontFamily: "Raleway"),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: snapshot.data!.docs.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        var doc = snapshot.data!.docs[index];
        final category = (doc['category'][currentLanguage] ?? 'Unknown Category').toString();
        final title = (doc['title'][currentLanguage] ?? 'No Title').toString();
        final amount = doc['amount'] ?? 0;

        return GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(AppTranslations.getText('Confirm Delete', currentLanguage)),
                  content: Text(
                      AppTranslations.getText('Are you sure you want to delete this transaction?', currentLanguage)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppTranslations.getText('Cancel', currentLanguage)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteTransaction(context, doc.id);
                      },
                      child: Text(
                        AppTranslations.getText('Delete', currentLanguage),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
               fontFamily: "RobotoMono",
              ),
            ),
            subtitle: Text(
              '$title - $amount',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
               fontFamily: "RobotoMono",
              ),
            ),
          ),
        );
      },
    );
  },
)

    );
  }
}
