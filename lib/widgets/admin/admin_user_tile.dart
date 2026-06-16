import 'package:flutter/material.dart';
import '../../services/firebase_admin_service.dart';
import '../../views/admin/admin_user_form_screen.dart';

class AdminUserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  const AdminUserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final role = user['role'] ?? 'user';
    final status = user['status'] ?? 'active';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(user['name'] ?? 'Unknown'),
        subtitle: Text('${user['email'] ?? ''} • ${role.toString().toUpperCase()}'),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminUserFormScreen(
                      role: user['role']?.toString() ?? 'doctor',
                      uid: user['uid'],
                      initialData: user,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final adminService = FirebaseAdminService();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete user'),
        content: Text('Delete ${user['name']} from ${user['role']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await adminService.deleteUser(user['uid']);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}