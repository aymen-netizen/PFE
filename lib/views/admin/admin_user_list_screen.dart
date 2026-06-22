import 'package:flutter/material.dart';
import '../../services/firebase_admin_service.dart';
import '../../widgets/admin/admin_user_tile.dart';
import '../../core/constants/app_Color.dart';

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
    final isPatient = widget.role == 'patient';
    final isDoctor = widget.role == 'doctor';
    final String roleTitle = isPatient
        ? 'Patients'
        : isDoctor
            ? 'Médecins'
            : 'Assistants';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Gestion des $roleTitle'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Container
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextFormField(
                onChanged: (value) {
                  setState(() => _search = value.trim());
                },
                decoration: InputDecoration(
                  labelText: 'Rechercher par nom ou email',
                  labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),

            // User List Stream Builder
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _adminService.streamUsersByRole(widget.role),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                    );
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun utilisateur enregistré',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ],
                      ),
                    );
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun résultat pour "$_search"',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      ),
    );
  }
}