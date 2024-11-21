import 'package:family_finance/language/locale_provider.dart';
import 'package:family_finance/page/admin_page.dart';
import 'package:family_finance/page/currency_provider.dart';
import 'package:family_finance/page/login_screen.dart';
import 'package:family_finance/page/singup_screen.dart';
import 'package:family_finance/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  bool isLoggedIn = await checkLoginStatus();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()), // เพิ่ม ThemeProvider
      ChangeNotifierProvider(create: (_) => LocaleProvider()), // เพิ่ม LocaleProvider
    ],
    child: MyApp(isLoggedIn: isLoggedIn),
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return 
    MaterialApp(
      title: 'Family Finance',
     theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode, // ใช้ ThemeMode จาก ThemeProvider
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const HomeScreen(),
        '/admin': (context) => AdminPage(), // เส้นทางสำหรับหน้า Admin
      },
    );
  }
}
