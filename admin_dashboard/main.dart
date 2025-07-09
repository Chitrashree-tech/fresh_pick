import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/admin_login_page.dart';
import 'pages/admin_home_page.dart';
import 'pages/manage_fruits_page.dart';
import 'pages/manage_vegetables_page.dart';
import 'pages/manage_flowers_page.dart';
import 'pages/orders_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://myzbdgicqvvlrilbnmzq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im15emJkZ2ljcXZ2bHJpbGJubXpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2MTk1MDgsImV4cCI6MjA2NzE5NTUwOH0.D-OQ6HaawRVKtxEdBLxLx2ruWIB_Qb5w4jApJPWumEA',
  );

  runApp(const FruitAdminApp());
}

class FruitAdminApp extends StatelessWidget {
  const FruitAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const AdminLoginPage(),
        '/dashboard': (context) => const AdminHomePage(),
        '/manage-fruits': (context) => const ManageFruitsPage(),
        '/manage-vegetables': (context) => const ManageVegetablesPage(),
        '/manage-flowers': (context) => const ManageFlowersPage(),
        '/orders': (context) => const OrdersPage(),
      },
    );
  }
}
