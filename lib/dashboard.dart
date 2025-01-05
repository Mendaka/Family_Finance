import 'package:family_finance/language/app_translations.dart';
import 'package:family_finance/language/locale_provider.dart';
import 'package:family_finance/page/custom_drawer.dart';
import 'package:family_finance/page/home_page_content.dart';
import 'package:family_finance/page/monthly_summart_page.dart';

import 'package:family_finance/page/profile_page_content.dart';
import 'package:family_finance/page/setting_page.dart';
import 'package:family_finance/page/transactions_bar_chart.dart';
import 'package:family_finance/theme/theme_provider.dart';
import 'package:family_finance/widget/alert_popup.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'add_transaction_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<Map<String, dynamic>> _getTotalAmounts(String currentLanguage) async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .get();

      double totalIncome = 0.0;
      double totalExpense = 0.0;
      Map<String, double> categories = {}; // เก็บหมวดหมู่

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // อ่านประเภท (type) และจำนวนเงิน (amount)
        final String type = (data['type'] ?? {})[currentLanguage]?.toString() ??
            (data['type'] ?? {})['en']?.toString() ??
            ''; // ใช้ en เป็นค่าพื้นฐาน
        final double amount = (data['amount'] ?? 0).toDouble();

        // ตรวจสอบว่าเป็นรายรับหรือรายจ่าย
        if (type == 'รายรับ' || type == 'Income' || type == 'ငိုၼ်းၶဝ်ႈ'|| type == 'ဝင်ငွေ') {
          totalIncome += amount;
        } else if (type == 'รายจ่าย' ||
            type == 'Expense' ||
            type == 'ငိုၼ်းဢွၵ်ႇ'|| type == 'ကုန်ကျစရိတ်') {
          totalExpense += amount;
        }

        // อ่านหมวดหมู่ (category)
        final String category =
            (data['category'] ?? {})[currentLanguage]?.toString() ??
                (data['category'] ?? {})['en']?.toString() ??
                'อื่นๆ'; // ใช้ en เป็นค่าพื้นฐาน
        categories[category] = (categories[category] ?? 0) + amount;
      }

      double balance = totalIncome - totalExpense;

      // Debug ค่า
      print('Total Income: $totalIncome');
      print('Total Expense: $totalExpense');
      print('Balance: $balance');
      print('Categories: $categories');

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'balance': balance,
        'categories': categories,
      };
    }
    return {};
  }

 Future<Map<String, dynamic>> _getMonthlySummary(
    String currentLanguage) async {
  final user = _auth.currentUser;
  if (user != null) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0);

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double lastMonthExpense = 0.0;

    // กำหนดช่วงเวลา
    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final yesterdayStart = todayStart.subtract(Duration(days: 1));
    final todayEnd = todayStart.add(Duration(days: 1));

    // ดึงข้อมูลวันนี้
    final todaySnapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: todayStart)
        .where('date', isLessThan: todayEnd)
        .get();

    double todayIncome = 0.0;
    double todayExpense = 0.0;

    for (var doc in todaySnapshot.docs) {
      final data = doc.data();
      final double amount = (data['amount'] ?? 0.0).toDouble();
      final String type = (data['type'] ?? {})[currentLanguage]?.toString() ??
          (data['type'] ?? {})['en']?.toString() ??
          '';

      if (type == 'รายรับ' || type == 'Income' || type == 'ငိုၼ်းၶဝ်ႈ'|| type == 'ဝင်ငွေ') {
        todayIncome += amount;
      } else if (type == 'รายจ่าย' ||
          type == 'Expense' ||
          type == 'ငိုၼ်းဢွၵ်ႇ'||type == 'ကုန်ကျစရိတ်') {
        todayExpense += amount;
      }
    }

    // ดึงข้อมูลเมื่อวาน
    final yesterdaySnapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: yesterdayStart)
        .where('date', isLessThan: todayStart)
        .get();

    double yesterdayIncome = 0.0;
    double yesterdayExpense = 0.0;

    for (var doc in yesterdaySnapshot.docs) {
      final data = doc.data();
      final double amount = (data['amount'] ?? 0.0).toDouble();
      final String type = (data['type'] ?? {})[currentLanguage]?.toString() ??
          (data['type'] ?? {})['en']?.toString() ??
          '';

      if (type == 'รายรับ' || type == 'Income' || type == 'ငိုၼ်းၶဝ်ႈ'|| type == 'ဝင်ငွေ') {
        yesterdayIncome += amount;
      } else if (type == 'รายจ่าย' ||
          type == 'Expense' ||
          type == 'ငိုၼ်းဢွၵ်ႇ'||type == 'ကုန်ကျစရိတ်') {
        yesterdayExpense += amount;
      }
    }

    print('Today Income: $todayIncome');
    print('Today Expense: $todayExpense');
    print('Yesterday Income: $yesterdayIncome');
    print('Yesterday Expense: $yesterdayExpense');

    // คำนวณข้อมูลของเดือนปัจจุบัน
    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final double amount = (data['amount'] ?? 0.0).toDouble();
      final String type = (data['type'] ?? {})[currentLanguage]?.toString() ??
          (data['type'] ?? {})['en']?.toString() ??
          '';

      if (type == 'รายรับ' || type == 'Income' || type == 'ငိုၼ်းၶဝ်ႈ'|| type == 'ဝင်ငွေ') {
        totalIncome += amount;
      } else if (type == 'รายจ่าย' ||
          type == 'Expense' ||
          type == 'ငိုၼ်းဢွၵ်ႇ'||type == 'ကုန်ကျစရိတ်') {
        totalExpense += amount;
      }
    }

    // คำนวณข้อมูลของเดือนที่แล้ว
    final lastMonthSnapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: startOfLastMonth)
        .where('date', isLessThanOrEqualTo: endOfLastMonth)
        .get();

    for (var doc in lastMonthSnapshot.docs) {
      final data = doc.data();
      final double amount = (data['amount'] ?? 0.0).toDouble();
      final String type = (data['type'] ?? {})[currentLanguage]?.toString() ??
          (data['type'] ?? {})['en']?.toString() ??
          '';

      if (type == 'รายจ่าย' || type == 'Expense' || type == 'ငိုၼ်းဢွၵ်ႇ'||type == 'ကုန်ကျစရိတ်') {
        lastMonthExpense += amount;
      }
    }

    double balance = totalIncome - totalExpense;

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'lastMonthExpense': lastMonthExpense, // ส่งค่ารายจ่ายเดือนที่แล้ว
      'todayIncome': todayIncome, // ส่งค่ารายรับวันนี้
      'todayExpense': todayExpense, // ส่งค่ารายจ่ายวันนี้
      'yesterdayIncome': yesterdayIncome, // ส่งค่ารายรับเมื่อวาน
      'yesterdayExpense': yesterdayExpense, // ส่งค่ารายจ่ายเมื่อวาน
    };
  }
  return {};
}


  Future<Map<String, dynamic>> _getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      return snapshot
              .data()
              ?.map((key, value) => MapEntry(key, value.toString())) ??
          {};
    }
    throw Exception('User not found');
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    Navigator.pushReplacementNamed(
        context, '/login'); // นำผู้ใช้กลับไปที่หน้าล็อกอิน
  }

  Future<void> _checkAdminStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail') ?? "";
    print("Dashboard - Current Email: $email"); // ตรวจสอบอีเมล
  }


   @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AlertPopup.showAlertIfFirstLaunch(context);
  });
}

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLanguage = localeProvider.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.getText('app_title', currentLanguage),
          style: const TextStyle(
              fontSize: 22, fontFamily: "RobotoMono", ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String languageCode) {
              localeProvider.changeLanguage(languageCode);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'en',
                child: Text('English'),
              ),
              const PopupMenuItem(
                value: 'th',
                child: Text('ภาษาไทย'),
              ),
              const PopupMenuItem(
                value: 'shn',
                child: Text('ၽႃႇသႃႇတႆး'),
              ),
               const PopupMenuItem(
                value: 'mm',
                child: Text('မြန်မာဘာသာ'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: SafeArea(
        child: _selectedIndex == 0
            ? HomePageContent(
                () => _getTotalAmounts(
                    Provider.of<LocaleProvider>(context).currentLanguage),
                _firestore)
            : _selectedIndex == 1
                ? FutureBuilder<Map<String, dynamic>>(
                    future: _getTotalAmounts(
                        Provider.of<LocaleProvider>(context).currentLanguage),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No data available'));
                      }

                      final totals = snapshot.data!;
                      final double totalIncome =
                          (totals['totalIncome'] ?? 0).toDouble();
                      final double totalExpense =
                          (totals['totalExpense'] ?? 0).toDouble();
                      final double balance =
                          (totals['balance'] ?? 0).toDouble();
                      final Map<String, double> categories =
                          totals['categories'] != null
                              ? Map<String, double>.from(totals['categories'])
                              : {};

                      return TransactionsBarChart(
                        income: totalIncome,
                        expense: totalExpense,
                        balance: balance,
                        categories: categories,
                      );
                    },
                  )
                : _selectedIndex == 2
                    ? FutureBuilder<Map<String, dynamic>>(
                        future: _getMonthlySummary(
                            Provider.of<LocaleProvider>(context)
                                .currentLanguage),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No data available'));
                          }

                          final totals = snapshot.data!;
                          final double totalIncome =
                              (totals['totalIncome'] ?? 0).toDouble();
                          final double totalExpense =
                              (totals['totalExpense'] ?? 0).toDouble();
                          final double balance =
                              (totals['balance'] ?? 0).toDouble();

                          // ตรวจสอบว่าได้ประกาศตัวแปรก่อนหน้านี้หรือยัง
                          double todayIncome = 0.0;
                          double todayExpense = 0.0;
                          double yesterdayIncome = 0.0;
                          double yesterdayExpense = 0.0;

                          return MonthlySummaryPage(
                            income: totals['totalIncome'],
                            expense: totals['totalExpense'],
                            balance: totals['balance'],
                            lastMonthExpense: totals['lastMonthExpense'],
                            todayIncome:
                                totals['todayIncome'], // ใช้ค่าที่คำนวณได้
                            todayExpense:
                                totals['todayExpense'], // ใช้ค่าที่คำนวณได้
                            yesterdayIncome:
                                totals['yesterdayIncome'], // ใช้ค่าที่คำนวณได้
                            yesterdayExpense:
                                totals['yesterdayExpense'], // ใช้ค่าที่คำนวณได้
                          );
                        },
                      )
                    : _selectedIndex == 3
                        ? SettingsPage()
                        : ProfilePageContent(_getUserData, logout),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AddTransactionForm(
                    onTransactionAdded: () => setState(() {}),
                  ),
                );
              },
              backgroundColor: Colors.purple,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CircleNavBar(
        activeIcons: const <Widget>[
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.analytics, color: Colors.white),
          Icon(Icons.calendar_today, color: Colors.white),
          Icon(Icons.settings, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        inactiveIcons: <Widget>[
          Icon(Icons.home, color: Colors.grey[400]),
          Icon(Icons.analytics, color: Colors.grey[400]),
          Icon(Icons.calendar_today, color: Colors.grey[400]),
          Icon(Icons.settings, color: Colors.grey[400]),
          Icon(Icons.person, color: Colors.grey[400]),
        ],
        onTap: _onItemTapped,
        activeIndex: _selectedIndex,
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.indigo, Colors.deepPurple],
        ),
        circleGradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.deepPurple, Colors.indigo],
        ),
        color: Colors.white,
        height: 60,
        circleWidth: 60,
        elevation: 10,
        shadowColor: Colors.transparent,
        circleShadowColor: Colors.deepPurple,
      ),
    );
  }
}
