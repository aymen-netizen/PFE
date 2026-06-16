import 'package:flutter/material.dart';
import '../../services/firebase_admin_service.dart';
import '../../services/firebase_specialty_service.dart';
import 'admin_specialty_screen.dart';

class AdminUserFormScreen extends StatefulWidget {
  final String role;
  final String? uid;
  final Map<String, dynamic>? initialData;

  const AdminUserFormScreen({super.key, required this.role, this.uid, this.initialData});

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedSpecialty = '';
  bool _isLoading = false;
  bool _isLoadingSpecialties = true;

  final FirebaseAdminService _adminService = FirebaseAdminService();
  final FirebaseSpecialtyService _specialtyService = FirebaseSpecialtyService();
  List<Map<String, dynamic>> _specialties = [];

  @override
  void initState() {
    super.initState();
    _loadSpecialties();

    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _emailController.text = widget.initialData!['email'] ?? '';
      _phoneController.text = widget.initialData!['phone'] ?? '';
      _selectedSpecialty = widget.initialData!['specialty'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecialties() async {
    setState(() => _isLoadingSpecialties = true);
    final specialties = await _specialtyService.getSpecialties();
    setState(() {
      _specialties = specialties;
      if (_selectedSpecialty.isEmpty && specialties.isNotEmpty) {
        _selectedSpecialty = specialties.first['name'] as String? ?? '';
      }
      _isLoadingSpecialties = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    try {
      if (widget.uid == null) {
        final password = _passwordController.text.trim();
        await _adminService.createUser(
          role: widget.role,
          name: name,
          email: email,
          phone: phone,
          password: password,
          specialty: _selectedSpecialty,
        );
      } else {
        await _adminService.updateUser(
          uid: widget.uid!,
          name: name,
          email: email,
          phone: phone,
          specialty: _selectedSpecialty,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  bool get _requiresSpecialty => widget.role == 'doctor' || widget.role == 'assistant';

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.uid != null;
    final roleLabel = '${widget.role[0].toUpperCase()}${widget.role.substring(1)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit $roleLabel' : 'Add $roleLabel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Role: $roleLabel',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email is required';
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) => value == null || value.isEmpty ? 'Phone is required' : null,
              ),
              if (!isEdit) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
              ],
              if (_requiresSpecialty) ...[
                const SizedBox(height: 16),
                _isLoadingSpecialties
                    ? const Center(child: CircularProgressIndicator())
                    : Builder(
                        builder: (context) {
                          final specialtyNames = _specialties
                              .where((s) => s['name'] != null)
                              .map((s) => s['name'] as String)
                              .toList();

                          final validValue = specialtyNames.contains(_selectedSpecialty) ? _selectedSpecialty : null;

                          return DropdownButtonFormField<String>(
                            value: validValue,
                            decoration: const InputDecoration(labelText: 'Specialty'),
                            items: specialtyNames
                                .map((name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(name),
                                ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedSpecialty = value);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return specialtyNames.isEmpty ? 'No specialties available' : 'Select a specialty';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                if (!_isLoadingSpecialties) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminSpecialtyScreen(),
                          ),
                        );
                        await _loadSpecialties();
                      },
                      child: const Text('Manage specialties'),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: Text(_isLoading ? 'Saving...' : isEdit ? 'Save Changes' : 'Create $roleLabel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
