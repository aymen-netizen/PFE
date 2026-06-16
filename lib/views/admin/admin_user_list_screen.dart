import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_admin_service.dart';
import '../../widgets/admin/admin_user_tile.dart';

class AdminUserListScreen extends StatefulWidget {
  final String role;
  const AdminUserListScreen({super.key, required this.role});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final FirebaseAdminService _adminService = FirebaseAdminService();
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role[0].toUpperCase()}${widget.role.substring(1)} Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _search = value.trim());
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _adminService.streamUsersByRole(widget.role),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                final users = snapshot.data!
                    .where((user) {
                      if (_search.isEmpty) return true;
                      final lowerSearch = _search.toLowerCase();
                      final name = (user['name'] ?? '').toString().toLowerCase();
                      final email = (user['email'] ?? '').toString().toLowerCase();
                      return name.contains(lowerSearch) || email.contains(lowerSearch);
                    })
                    .toList();

                if (users.isEmpty) {
                  return const Center(child: Text('No matching users found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return AdminUserTile(user: users[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}