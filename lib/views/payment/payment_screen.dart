import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_success_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String selectedDate;
  final String selectedTime;
  final String symptoms;

  const PaymentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.selectedDate,
    required this.selectedTime,
    required this.symptoms,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  String cardNumber = '';
  String expiry = '';
  String holderName = '';
  bool _isLoading = false;
  bool _isPaying = false;

  late AnimationController _cardController;
  late Animation<double> _cardAnim;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardAnim = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    );
    _loadCard();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _loadCard() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data != null) {
      final number = data['cardNumber'] ?? '';
      final exp = data['cardExpiry'] ?? '';
      final name = data['name'] ?? '';

      if (number.isEmpty && mounted) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1C2B3A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            content: const Row(
              children: [
                Icon(Icons.credit_card_off, color: Colors.amber, size: 18),
                SizedBox(width: 10),
                Text('Please add a card in your profile first'),
              ],
            ),
          ),
        );
        if (mounted) {
          Navigator.pushNamed(context, '/profile').then((_) => _loadCard());
        }
        return;
      }

      setState(() {
        cardNumber = number;
        expiry = exp;
        holderName = name;
        _isLoading = false;
      });
      _cardController.forward();
    }
  }

  String _maskCard(String number) {
    if (number.length < 4) return '**** **** **** ****';
    final last4 = number.substring(number.length - 4);
    return '**** **** **** $last4';
  }

  Future<void> _pay() async {
    if (_isPaying) return;
    setState(() => _isPaying = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser!;

      // Load patient name from Firestore users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final patientName = userDoc.data()?['name'] ?? currentUser.displayName ?? currentUser.email ?? "Patient";

      // Create appointment
      final doc = await FirebaseFirestore.instance
          .collection('appointments')
          .add({
        'doctorId': widget.doctorId,
        'doctorName': widget.doctorName,
        'specialty': widget.specialty,
        'date': widget.selectedDate,
        'time': widget.selectedTime,
        'symptoms': widget.symptoms,
        'price': 50,
        'userId': currentUser.uid,
        'patientName': patientName,
        'status': 'pending',
        'paymentMethod': 'Card',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create dossier entry
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(currentUser.uid)
          .collection('dossier')
          .add({
        'appointmentId': doc.id,
        'doctorName': widget.doctorName,
        'date': widget.selectedDate,
        'medications': [],
        'analyses': [],
        'recommendations': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      final qrData = {
        'id': doc.id,
        'doctor': widget.doctorName,
        'date': widget.selectedDate,
        'time': widget.selectedTime,
      };

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            appointmentId: doc.id,
            qrData: qrData,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade600,
          content: Text('Payment failed: $e'),
        ),
      );
      setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1C2B3A),
        title: const Text(
          'Secure Payment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1C8C8C),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Appointment Summary Card ─────────────
                  _buildSummaryCard(),
                  const SizedBox(height: 24),

                  // ─── Payment Method Header ────────────────
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1C2B3A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Only card payments accepted',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFADB5BD),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Card Visual ──────────────────────────
                  ScaleTransition(
                    scale: _cardAnim,
                    child: _buildCreditCard(),
                  ),
                  const SizedBox(height: 20),

                  // ─── No card warning ──────────────────────
                  if (cardNumber.isEmpty) _buildNoCardWarning(),
                  const SizedBox(height: 30),

                  // ─── Security badges ──────────────────────
                  _buildSecurityRow(),
                  const SizedBox(height: 28),

                  // ─── Pay Button ───────────────────────────
                  _buildPayButton(),
                  const SizedBox(height: 16),

                  // ─── Total ────────────────────────────────
                  Center(
                    child: Text(
                      'Total amount: 50.00 DT',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C8C8C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: Color(0xFF1C8C8C), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Appointment Summary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1C2B3A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _summaryRow(Icons.person_rounded, 'Doctor', 'Dr. ${widget.doctorName}'),
          const SizedBox(height: 8),
          _summaryRow(Icons.medical_services_rounded, 'Specialty',
              widget.specialty),
          const SizedBox(height: 8),
          _summaryRow(Icons.calendar_today_rounded, 'Date', widget.selectedDate),
          const SizedBox(height: 8),
          _summaryRow(Icons.access_time_rounded, 'Time', widget.selectedTime),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Consultation Fee',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1C2B3A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C8C8C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '50 DT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1C8C8C),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1C8C8C)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Color(0xFFADB5BD), fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1C2B3A),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCard() {
    return Container(
      width: double.infinity,
      height: 190,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C2B3A), Color(0xFF2D4A6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C2B3A).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MASTERCARD',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Mastercard circles
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.8),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-10, 0),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Chip icon
              Container(
                width: 40,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFFAD65A)],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              const SizedBox(height: 14),

              // Card number
              Text(
                cardNumber.isEmpty
                    ? '**** **** **** ****'
                    : _maskCard(cardNumber),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CARD HOLDER',
                        style: TextStyle(color: Colors.white38, fontSize: 9),
                      ),
                      Text(
                        holderName.isNotEmpty
                            ? holderName.toUpperCase()
                            : '— — — —',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'EXPIRES',
                        style:
                            TextStyle(color: Colors.white38, fontSize: 9),
                      ),
                      Text(
                        expiry.isNotEmpty ? expiry : '-- / --',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoCardWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.amber, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'No card found. Please add a card in your Profile settings to proceed.',
              style: TextStyle(fontSize: 13, color: Color(0xFF7D6200)),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/profile').then((_) => _loadCard()),
            child: const Text(
              'Add',
              style: TextStyle(
                color: Color(0xFF1C8C8C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _securityBadge(Icons.lock_rounded, 'Secure'),
        const SizedBox(width: 16),
        _securityBadge(Icons.verified_rounded, 'Encrypted'),
        const SizedBox(width: 16),
        _securityBadge(Icons.shield_rounded, 'Protected'),
      ],
    );
  }

  Widget _securityBadge(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1C8C8C), size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFADB5BD),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (cardNumber.isEmpty || _isPaying) ? null : _pay,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C8C8C),
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isPaying
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_rounded, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Pay Securely — 50 DT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
