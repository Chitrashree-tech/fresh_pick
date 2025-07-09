// lib/pages/admin_home_page.dart

import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Welcome, Admin!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            AdminHomeCard(
              title: "Manage Fruits",
              icon: Icons.apple,
              onTap: () => Navigator.pushNamed(context, '/manage-fruits'),
            ),
            AdminHomeCard(
              title: "Manage Vegetables",
              icon: Icons.eco,
              onTap: () => Navigator.pushNamed(context, '/manage-vegetables'),
            ),
            AdminHomeCard(
              title: "Manage Flowers",
              icon: Icons.local_florist,
              onTap: () => Navigator.pushNamed(context, '/manage-flowers'),
            ),
            AdminHomeCard(
              title: "View Orders",
              icon: Icons.receipt_long,
              onTap: () => Navigator.pushNamed(context, '/orders'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(50),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AdminHomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const AdminHomeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrange),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
