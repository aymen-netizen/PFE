import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/card_service.dart';
import '../../../widget/buttons/primary_button.dart';
import '../../../widget/input/customertextfield.dart';
import '../auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  Map<String, dynamic>? userData;

  Map<String, String>? _savedCard;
  bool _showCardForm = false;

  final _cardNameCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();
  final _cardFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadUserData();
    _loadCard();
  }

  // ✅ LOAD USER FROM FIRESTORE
  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();

    if (mounted && data != null) {
      setState(() {
        userData = data;

        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      });
    }
  }

  Future<void> _loadCard() async {
    final card = await CardService.getCard();
    if (mounted) setState(() => _savedCard = card);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cardNameCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
    }

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil mis à jour !'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ LOADING STATE
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          TextButton(
            onPressed: () {
              if (_isEditing) _saveProfile();
              else setState(() => _isEditing = true);
            },
            child: Text(
              _isEditing ? 'Sauvegarder' : 'Modifier',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08)),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        Colors.green.withOpacity(0.15),
                    child: const Icon(Icons.person,
                        size: 50, color: Colors.green),
                  ),
                  const SizedBox(height: 12),

                  // ✅ REAL NAME
                  Text(
                    _nameController.text,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  // ✅ REAL EMAIL
                  Text(
                    _emailController.text,
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Customertextfield(
                      hintText: 'Nom complet',
                      controller: _nameController,
                      isPassword: false,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),

                    Customertextfield(
                      hintText: 'Email',
                      controller: _emailController,
                      isPassword: false,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    Customertextfield(
                      hintText: 'Téléphone',
                      controller: _phoneController,
                      isPassword: false,
                      enabled: _isEditing,
                    ),

                    const SizedBox(height: 24),

                    if (_isEditing)
                      PrimaryButton(
                        text: _isSaving
                            ? 'Sauvegarde...'
                            : 'Sauvegarder',
                        onPressed:
                            _isSaving ? null : _saveProfile,
                      ),
                  ],
                ),
              ),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout,
                    color: Colors.red),
                label: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}