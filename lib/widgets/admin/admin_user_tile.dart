import 'package:flutter/material.dart';
import '../../services/firebase_admin_service.dart';
import '../../views/admin/admin_user_form_screen.dart';
import '../../core/constants/app_Color.dart';

class AdminUserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  const AdminUserTile({super.key, required this.user});

  void _confirmDelete(BuildContext context) {
    final adminService = FirebaseAdminService();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'utilisateur'),
        content: Text('Voulez-vous vraiment supprimer "${user['name']}" ? Cette action est irréversible.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              await adminService.deleteUser(user['uid']);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = user['role'] ?? 'user';
    final isDoctor = role == 'doctor';
    final isAssistant = role == 'assistant';
    final hasSpecialty = (isDoctor || isAssistant) && (user['specialty'] != null && user['specialty'].toString().trim().isNotEmpty);

    final String initial = (user['name'] ?? '')
        .toString()
        .trim()
        .isNotEmpty
        ? user['name'].toString().trim()[0].toUpperCase()
        : '?';

    Color avatarBgColor = Colors.blue.shade50;
    Color avatarTextColor = Colors.blue.shade700;

    if (isDoctor) {
      avatarBgColor = AppColors.primaryColor.withOpacity(0.1);
      avatarTextColor = AppColors.primaryColor;
    } else if (isAssistant) {
      avatarBgColor = Colors.purple.shade50;
      avatarTextColor = Colors.purple.shade700;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: avatarBgColor,
              child: Text(
                initial,
                style: TextStyle(
                  color: avatarTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'Inconnu',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user['email'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (user['phone'] != null && user['phone'].toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user['phone'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                  if (hasSpecialty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.shade200, width: 0.8),
                      ),
                      child: Text(
                        user['specialty'],
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Actions Wrap
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: Colors.blue.shade600,
                  tooltip: 'Modifier',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminUserFormScreen(
                          role: role.toString(),
                          uid: user['uid'],
                          initialData: user,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: Colors.red.shade600,
                  tooltip: 'Supprimer',
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}