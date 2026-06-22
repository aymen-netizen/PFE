import 'package:flutter/material.dart';
import '../../../widget/input/customertextfield.dart';
import '../auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_Color.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;
  Map<String, dynamic>? userData;

  // ✅ CARD
  bool _showCardForm = false;
  final _cardNumberCtrl = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

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

        _cardNumberCtrl.text = data['cardNumber'] ?? '';
        _cardExpiryCtrl.text = data['cardExpiry'] ?? '';
      });
    }
  }

  String maskCard(String number) {
    if (number.length < 4) return "**** **** **** ****";
    return "**** **** **** ${number.substring(number.length - 4)}";
  }

  // ✅ PREMIUM PHYSICAL-LOOKING CARD
  Widget buildAnimatedCard(String cardNumber, String expiry) {
    // Format card number to space it every 4 digits
    String displayCardNumber = "••••  ••••  ••••  ••••";
    if (cardNumber.isNotEmpty) {
      final clean = cardNumber.replaceAll(RegExp(r'\s+\b|\b\s+'), '');
      final segments = <String>[];
      for (int i = 0; i < clean.length; i += 4) {
        final end = (i + 4 < clean.length) ? i + 4 : clean.length;
        segments.add(clean.substring(i, end));
      }
      displayCardNumber = segments.join("  ");
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      transform: Matrix4.diagonal3Values(
        _showCardForm ? 0.96 : 1.0,
        _showCardForm ? 0.96 : 1.0,
        1.0,
      ),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B), // Deep slate gray
            Color(0xFF0F172A), // Very dark blue/black slate
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background subtle design elements
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.02),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: Chip and Contactless
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Gold Chip Graphic
                    Container(
                      width: 45,
                      height: 35,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Inner lines of the chip
                          Center(
                            child: Container(
                              width: 33,
                              height: 23,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.15),
                                  width: 0.8,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 12,
                              height: 1,
                              color: Colors.black.withOpacity(0.15),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 12,
                              height: 1,
                              color: Colors.black.withOpacity(0.15),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 1,
                              height: 10,
                              color: Colors.black.withOpacity(0.15),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 1,
                              height: 10,
                              color: Colors.black.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Contactless Symbol and Brand text
                    Row(
                      children: [
                        Transform.rotate(
                          angle: 1.5708, // 90 degrees
                          child: Icon(
                            Icons.wifi,
                            color: Colors.white.withOpacity(0.6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "PREMIUM SECURE",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Middle row: Card Number
                Text(
                  displayCardNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                    fontFamily: 'monospace',
                  ),
                ),
                
                // Bottom row: Holder details and Expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TITULAIRE DE CARTE",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _nameController.text.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "EXPIRE FIN",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expiry.isNotEmpty ? expiry : "MM/AA",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le nom complet ne peut pas être vide")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    });

    if (!mounted) return;
    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil mis à jour ✅")),
    );
  }

  Future<void> _saveCard() async {
    if (_cardNumberCtrl.text.isEmpty || _cardExpiryCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs de la carte")),
      );
      return;
    }

    final cleanCardNumber = _cardNumberCtrl.text.replaceAll(RegExp(r'\s+'), '');
    if (cleanCardNumber.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le numéro de carte doit contenir 16 chiffres")),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'cardNumber': cleanCardNumber,
      'cardExpiry': _cardExpiryCtrl.text.trim(),
    });

    if (!mounted) return;
    setState(() {
      _showCardForm = false;
      userData!['cardNumber'] = cleanCardNumber;
      userData!['cardExpiry'] = _cardExpiryCtrl.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Carte de paiement enregistrée ✅")),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final cardNumber = userData!['cardNumber'] ?? '';
    final expiry = userData!['cardExpiry'] ?? '';

    // Calculate avatar initials
    final String initial = _nameController.text.isNotEmpty
        ? _nameController.text.trim()[0].toUpperCase()
        : "?";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ HEADER SECTION (Avatar and Username)
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryColor,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nameController.text,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _emailController.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user,
                            color: AppColors.primaryColor,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Membre Vérifié",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ✅ CARD 1: PERSONAL INFORMATION
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, color: AppColors.primaryColor),
                          const SizedBox(width: 10),
                          Text(
                            "Informations Personnelles",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Customertextfield(
                        hintText: "Nom complet",
                        controller: _nameController,
                        isPassword: false,
                        enabled: _isEditing,
                        perfixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Customertextfield(
                        hintText: "Adresse e-mail",
                        controller: _emailController,
                        isPassword: false,
                        enabled: false,
                        perfixIcon: const Icon(Icons.mail_outline, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Customertextfield(
                        hintText: "Téléphone",
                        controller: _phoneController,
                        isPassword: false,
                        enabled: _isEditing,
                        perfixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      if (_isEditing)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    loadUserData();
                                  });
                                },
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text("Annuler"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  foregroundColor: Colors.grey.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveProfile,
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text("Sauvegarder"),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text("Modifier le Profil"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ CARD 2: PAYMENT CARD SECTION
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.credit_card_outlined, color: AppColors.primaryColor),
                              const SizedBox(width: 10),
                              Text(
                                "Moyen de Paiement",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          if (cardNumber.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showCardForm = !_showCardForm;
                                });
                              },
                              icon: Icon(_showCardForm ? Icons.close : Icons.edit, size: 16),
                              label: Text(_showCardForm ? "Annuler" : "Modifier"),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryColor,
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 24),
                      if (cardNumber.isNotEmpty) ...[
                        buildAnimatedCard(cardNumber, expiry),
                        const SizedBox(height: 16),
                      ] else if (!_showCardForm) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.add_card_outlined, size: 40, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                "Aucune carte de paiement configurée",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showCardForm = true;
                                  });
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Ajouter une carte"),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _showCardForm
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Numéro de Carte",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _cardNumberCtrl,
                                    keyboardType: TextInputType.number,
                                    maxLength: 16,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      hintText: "1234567812345678",
                                      prefixIcon: const Icon(Icons.credit_card, size: 20),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Date d'expiration",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _cardExpiryCtrl,
                                    keyboardType: TextInputType.datetime,
                                    maxLength: 5,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      hintText: "MM/AA",
                                      prefixIcon: const Icon(Icons.calendar_today, size: 18),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      if (cardNumber.isEmpty)
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                _showCardForm = false;
                                              });
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text("Annuler"),
                                          ),
                                        ),
                                      if (cardNumber.isEmpty) const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _saveCard,
                                          icon: const Icon(Icons.save_outlined, size: 18),
                                          label: const Text("Enregistrer"),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            backgroundColor: AppColors.primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ CARD 3: SECURITY & SETTINGS
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.settings_outlined, color: AppColors.primaryColor),
                          const SizedBox(width: 10),
                          Text(
                            "Paramètres & Sécurité",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text("Se Déconnecter", style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.red, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}