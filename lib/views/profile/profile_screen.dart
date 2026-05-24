import 'package:flutter/material.dart';
import '../../../widget/input/customertextfield.dart';
import '../auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
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

        _cardNumberCtrl.text =
            data['cardNumber'] ?? '';
        _cardExpiryCtrl.text =
            data['cardExpiry'] ?? '';
      });
    }
  }

  String maskCard(String number) {
    if (number.length < 4) return "****";
    return "**** **** **** ${number.substring(number.length - 4)}";
  }

  // ✅ PREMIUM CARD
  Widget buildAnimatedCard(String cardNumber, String expiry) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),

      transform: Matrix4.identity()
        ..scale(_showCardForm ? 0.95 : 1.0),

      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A5FC1), Color(0xFF6A82FB)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text("MASTER CARD",
              style: TextStyle(color: Colors.white70)),

          const SizedBox(height: 20),

          Text(
            maskCard(cardNumber),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text("CARD HOLDER",
                  style: TextStyle(color: Colors.white70)),
              Text(expiry,
                  style:
                      const TextStyle(color: Colors.white70)),
            ],
          ),

          const SizedBox(height: 6),

          Text(_nameController.text,
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({
      'name': _nameController.text,
      'phone': _phoneController.text,
    });

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated ✅")),
    );
  }

  Future<void> _saveCard() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'cardNumber': _cardNumberCtrl.text,
      'cardExpiry': _cardExpiryCtrl.text,
    });

    setState(() {
      _showCardForm = false;

      userData!['cardNumber'] =
          _cardNumberCtrl.text;
      userData!['cardExpiry'] =
          _cardExpiryCtrl.text;
    });
  }

  Future<void> _logout() async {

    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (_) => const LoginScreen()),
      (route) => false,
    );
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 20),

            Text(
              _nameController.text,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // ✅ ✅ ✅ PROFILE EDIT SECTION
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  Customertextfield(
                    hintText: "Nom complet",
                    controller: _nameController,
                    isPassword: false,
                    enabled: _isEditing,
                  ),

                  const SizedBox(height: 10),

                  Customertextfield(
                    hintText: "Email",
                    controller: _emailController,
                    isPassword: false,
                    enabled: false,
                  ),

                  const SizedBox(height: 10),

                  Customertextfield(
                    hintText: "Téléphone",
                    controller: _phoneController,
                    isPassword: false,
                    enabled: _isEditing,
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {
                      if (_isEditing) {
                        _saveProfile();
                      } else {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    },
                    child:
                        Text(_isEditing ? "Save" : "Edit Profile"),
                  ),
                ],
              ),
            ),

            const Divider(),

            // ✅ CARD SECTION
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Payment Method",
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showCardForm =
                                !_showCardForm;
                          });
                        },
                        child: Text(
                            _showCardForm ? "Cancel" : "Edit"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (cardNumber.isNotEmpty)
                    buildAnimatedCard(cardNumber, expiry),

                  const SizedBox(height: 15),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _showCardForm
                        ? Column(
                            children: [

                              TextField(
                                controller:
                                    _cardNumberCtrl,
                              ),

                              TextField(
                                controller:
                                    _cardExpiryCtrl,
                              ),

                              const SizedBox(height: 10),

                              ElevatedButton(
                                onPressed: _saveCard,
                                child: const Text("Save Card"),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),

            const Divider(),

            OutlinedButton(
              onPressed: _logout,
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}