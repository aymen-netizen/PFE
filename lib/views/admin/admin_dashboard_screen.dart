import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_user_form_screen.dart';
import 'admin_user_list_screen.dart';
import 'admin_specialty_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: Colors.green.shade700),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'TBIBI Administration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage doctors, assistants, specialties and patient records from one professional dashboard.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildCard(context, 'Manage Patients', Icons.people, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminUserListScreen(role: 'patient'),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                _buildCard(context, 'Manage Doctors', Icons.medical_services, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminUserListScreen(role: 'doctor'),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCard(context, 'Manage Assistants', Icons.support_agent, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminUserListScreen(role: 'assistant'),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                _buildCard(context, 'Manage Specialties', Icons.category, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminSpecialtyScreen(),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Add Doctor'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUserFormScreen(role: 'doctor'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Assistant'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUserFormScreen(role: 'assistant'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}