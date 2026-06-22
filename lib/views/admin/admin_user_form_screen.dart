import 'package:flutter/material.dart';
import '../../services/firebase_admin_service.dart';
import '../../services/firebase_specialty_service.dart';
import '../../core/constants/app_Color.dart';
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
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  bool get _requiresSpecialty => widget.role == 'doctor' || widget.role == 'assistant';

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.uid != null;
    final String roleLabel = widget.role == 'doctor'
        ? 'Médecin'
        : widget.role == 'assistant'
            ? 'Assistant'
            : 'Patient';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier le $roleLabel' : 'Ajouter un $roleLabel'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Header Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Rôle: $roleLabel',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200, width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Coordonnées',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Divider(height: 24),

                        // Full Name Input
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nom complet',
                            prefixIcon: const Icon(Icons.person_outline, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Nom obligatoire' : null,
                        ),
                        const SizedBox(height: 16),

                        // Email Input (disabled in edit mode)
                        TextFormField(
                          controller: _emailController,
                          enabled: !isEdit,
                          decoration: InputDecoration(
                            labelText: 'Adresse e-mail',
                            prefixIcon: const Icon(Icons.mail_outline, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: isEdit,
                            fillColor: isEdit ? Colors.grey.shade50 : null,
                            helperText: isEdit ? 'L\'email ne peut pas être modifié' : null,
                            helperStyle: TextStyle(color: Colors.grey.shade500),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Email obligatoire';
                            if (!value.contains('@')) return 'Email invalide';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone Input
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Téléphone',
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Téléphone obligatoire' : null,
                        ),

                        // Password Input (Only when creating)
                        if (!isEdit) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Mot de passe obligatoire';
                              if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
                              return null;
                            },
                          ),
                        ],

                        // Specialty Dropdown section (if doctor or assistant)
                        if (_requiresSpecialty) ...[
                          const SizedBox(height: 16),
                          _isLoadingSpecialties
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                                  ),
                                )
                              : Builder(
                                  builder: (context) {
                                    final specialtyNames = _specialties
                                        .where((s) => s['name'] != null)
                                        .map((s) => s['name'] as String)
                                        .toList();

                                    final validValue = specialtyNames.contains(_selectedSpecialty) ? _selectedSpecialty : null;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        DropdownButtonFormField<String>(
                                          value: validValue,
                                          decoration: InputDecoration(
                                            labelText: 'Spécialité médicale',
                                            prefixIcon: const Icon(Icons.category_outlined, size: 20),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
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
                                              return specialtyNames.isEmpty ? 'Aucune spécialité disponible' : 'Veuillez sélectionner une spécialité';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => const AdminSpecialtyScreen(),
                                                ),
                                              );
                                              await _loadSpecialties();
                                            },
                                            icon: const Icon(Icons.settings_outlined, size: 14, color: AppColors.primaryColor),
                                            label: const Text('Gérer les spécialités', style: TextStyle(fontSize: 12, color: AppColors.primaryColor)),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save/Create Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLoading
                        ? 'Enregistrement...'
                        : isEdit
                            ? 'Enregistrer les Modifications'
                            : 'Créer le Compte',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
