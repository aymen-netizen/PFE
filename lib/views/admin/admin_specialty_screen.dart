import 'package:flutter/material.dart';
import '../../services/firebase_specialty_service.dart';

class AdminSpecialtyScreen extends StatefulWidget {
  const AdminSpecialtyScreen({super.key});

  @override
  State<AdminSpecialtyScreen> createState() => _AdminSpecialtyScreenState();
}

class _AdminSpecialtyScreenState extends State<AdminSpecialtyScreen> {
  final FirebaseSpecialtyService _specialtyService = FirebaseSpecialtyService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  Future<void> _createSpecialty() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _specialtyService.createSpecialty(_nameController.text);
      _nameController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Specialty added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _deleteSpecialty(String uid, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete specialty'),
        content: Text('Delete "$name" from specialties?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _specialtyService.deleteSpecialty(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Specialties'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'New specialty',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _createSpecialty,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _specialtyService.streamSpecialtyCollection(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No specialties added yet'));
                  }
                  final specialties = snapshot.data!;
                  return ListView.builder(
                    itemCount: specialties.length,
                    itemBuilder: (context, index) {
                      final specialty = specialties[index];
                      final name = specialty['name'] ?? '';
                      final docId = specialty['docId'] as String?;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(name),
                          trailing: docId != null
                              ? IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteSpecialty(docId, name),
                                  tooltip: 'Delete specialty',
                                )
                              : null,
                        ),
                      );
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
