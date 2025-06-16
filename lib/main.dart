import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/splash_screen.dart';
import 'pages/main_navigation.dart'; // BottomNavigationBar: Home & Profile
import 'pages/login_page.dart';     // <- Tambahkan ini
import 'package:intl/date_symbol_data_local.dart';
import 'pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apa yang Bagus?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF4A45B1),
          background: const Color(0xFFF5F6FA),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6C63FF),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF6C63FF),
          unselectedItemColor: Color(0xFF2D3142),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
          elevation: 8,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),       // Splash screen
        '/login': (context) => const LoginPage(),     // Halaman login
        '/home': (context) => const MainNavigation(), // Berisi BottomNavigationBar
      },
    );
  }
}
