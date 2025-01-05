import 'package:family_finance/language/locale_provider.dart';
import 'package:family_finance/page/admin_page.dart';
import 'package:family_finance/page/currency_provider.dart';
import 'package:family_finance/page/login_screen.dart';
import 'package:family_finance/page/singup_screen.dart';
import 'package:family_finance/page/splash_screen.dart';
import 'package:family_finance/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dashboard.dart';

Future<bool> checkLoginStatus() async {
  // ใช้ Firebase Authentication เพื่อตรวจสอบสถานะผู้ใช้
  User? user = FirebaseAuth.instance.currentUser;
  return user != null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Mark Mee',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (context) => SplashScreen());
          case '/signup':
            return MaterialPageRoute(builder: (context) => const SignupScreen());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/admin':
            return MaterialPageRoute(builder: (context) => AdminPage());
          default:
            return MaterialPageRoute(builder: (context) => const LoginScreen());
        }
      },
    );
  }
}