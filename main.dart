import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/splash_screen.dart';
import 'pages/home_page.dart';
import 'pages/fruits_page.dart';
import 'pages/vegetables_page.dart';
import 'pages/flowers_page.dart';
import 'pages/cart_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/subscription_page.dart';

// ✅ Supabase credentials
const supabaseUrl = 'https://myzbdgicqvvlrilbnmzq.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im15emJkZ2ljcXZ2bHJpbGJubXpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2MTk1MDgsImV4cCI6MjA2NzE5NTUwOH0.D-OQ6HaawRVKtxEdBLxLx2ruWIB_Qb5w4jApJPWumEA';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const FruitShoppingApp());
}

class FruitShoppingApp extends StatelessWidget {
  const FruitShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Salad App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/fruits': (context) => const FruitsPage(),
        '/vegetables': (context) => const VegetablesPage(),
        '/flowers': (context) => const FlowersPage(),
        '/profile': (context) => const ProfilePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/subscription': (context) => const SubscriptionPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/cart') {
          return MaterialPageRoute(
            builder: (context) => const CartPage(),
          );
        }
        return null;
      },
    );
  }
}
