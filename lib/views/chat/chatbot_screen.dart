import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/chatbot_logic.dart';
import '../payment/payment_screen.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  // ─── Controllers ─────────────────────────────────────────
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ─── State ───────────────────────────────────────────────
  List<ChatMessage>? _messagesBackingField;
  List<ChatMessage> get _messages {
    _messagesBackingField ??= <ChatMessage>[];
    return _messagesBackingField!;
  }
  set _messages(List<ChatMessage> value) {
    _messagesBackingField = value;
  }
  bool _isTyping = false;
  bool _isSending = false;

  // ─── Booking flow state ──────────────────────────────────
  String _currentStep = 'idle'; // idle | doctor | date | time
  String _selectedSpecialty = '';
  String _selectedDoctorId = '';
  String _selectedDoctorName = '';
  String _selectedDate = '';
  String _selectedTime = '';
  List<Map<String, dynamic>> _availableDoctors = [];

  static const List<String> _availableTimes = [
    '08:00', '09:00', '10:00', '11:00',
    '14:00', '15:00', '16:00', '17:00',
  ];

  // ─── Init ────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _addBotMessage(
      ChatbotLogic.getWelcomeMessage(),
      quickReplies: ChatbotLogic.getWelcomeQuickReplies(),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Message Helpers ─────────────────────────────────────
  void _addBotMessage(String text, {List<String> quickReplies = const []}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isBot: true,
        quickReplies: quickReplies,
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isBot: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Typing Indicator ────────────────────────────────────
  Future<void> _showTypingThenRespond(
    String botText, {
    List<String> quickReplies = const [],
    int delayMs = 900,
  }) async {
    setState(() => _isTyping = true);
    _scrollToBottom();
    await Future.delayed(Duration(milliseconds: delayMs));
    if (!mounted) return;
    setState(() => _isTyping = false);
    _addBotMessage(botText, quickReplies: quickReplies);
  }

  // ─── User send handler ───────────────────────────────────
  Future<void> _handleUserSend(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _inputController.clear();
    _addUserMessage(text);

    await _processInput(text);

    if (mounted) setState(() => _isSending = false);
  }

  // ─── Core AI Processing ──────────────────────────────────
  Future<void> _processInput(String text) async {
    final input = text.toLowerCase().trim();

    // If we're mid-booking flow, handle that first
    if (_currentStep != 'idle') {
      await _handleBookingFlow(input, original: text);
      return;
    }

    // Appointment quick-navigate
    if (input.contains('my appointments') || input.contains('appointments')) {
      await _showTypingThenRespond(
        '📅 **Your Appointments**\n\nYou can view all your appointments in the **RDV** section on the home screen.\n\nWould you like to book a new appointment instead?',
        quickReplies: ['Book new appointment', 'I have a symptom'],
      );
      return;
    }

    // Analyses quick-navigate
    if (input.contains('my analyses') || input.contains('analyses')) {
      await _showTypingThenRespond(
        '🧪 **Your Analyses**\n\nYour test results are in the **Medical Record** → **Tests** section.\n\nYou can upload images and track results there.\n\nIs there anything else I can help with?',
        quickReplies: ['Describe my symptoms', 'Book appointment'],
      );
      return;
    }

    // Get AI reply
    final reply = ChatbotLogic.getReply(text, currentStep: _currentStep);

    await _showTypingThenRespond(
      reply.text,
      quickReplies: reply.quickReplies,
    );

    // If specialty was detected and user wants to book, set up flow
    if (reply.detectedSpecialty != null) {
      _selectedSpecialty = reply.detectedSpecialty!;
    }
  }

  // ─── Booking flow ────────────────────────────────────────
  Future<void> _startDoctorBooking() async {
    if (_selectedSpecialty.isEmpty) {
      await _showTypingThenRespond(
        '🩺 Which specialty would you like to book with?',
        quickReplies: [
          'Cardiologist ❤️',
          'Dentist 🦷',
          'Dermatologist 🧴',
          'General Doctor 🩺',
          'Pediatrician 👶',
        ],
      );
      _currentStep = 'specialty';
      return;
    }
    await _loadDoctorsAndShow();
  }

  Future<void> _loadDoctorsAndShow() async {
    setState(() => _isTyping = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .get();

    _availableDoctors = snapshot.docs.where((doc) {
      final sp = (doc.data()['specialty'] ?? '').toString().toLowerCase().trim();
      return sp == _selectedSpecialty;
    }).map((doc) {
      return {
        'id': doc.id,
        'name': doc.data()['name'] ?? 'Doctor',
        'specialty': doc.data()['specialty'] ?? '',
      };
    }).toList();

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _currentStep = 'doctor';
    });

    if (_availableDoctors.isEmpty) {
      _addBotMessage(
        '😔 No doctors found for this specialty at the moment.\n\nWould you like to search another specialty?',
        quickReplies: ['Try another specialty', 'Back to home'],
      );
      _currentStep = 'idle';
    } else {
      _addBotMessage(
        '✅ Great! Here are the available doctors for you.\n\nPlease select one:',
      );
    }
    _scrollToBottom();
  }

  Future<void> _handleBookingFlow(String input, {required String original}) async {
    if (_currentStep == 'specialty') {
      // Map quick reply to specialty
      final Map<String, String> specialtyMap = {
        'cardiologist': 'cardiologue',
        'dentist': 'dentiste',
        'dermatologist': 'dermatologie',
        'general doctor': 'medecine generale',
        'general': 'medecine generale',
        'pediatrician': 'pediatre',
        'ophthalmologist': 'ophtalmologie',
        'orthopedist': 'orthopédie',
      };

      for (final entry in specialtyMap.entries) {
        if (input.contains(entry.key)) {
          _selectedSpecialty = entry.value;
          break;
        }
      }

      if (_selectedSpecialty.isNotEmpty) {
        await _loadDoctorsAndShow();
      } else {
        await _showTypingThenRespond(
          'Please choose a specialty from the options above.',
        );
      }
      return;
    }

    // Other steps handled by widget buttons, not text
    final reply = ChatbotLogic.getReply(original);
    await _showTypingThenRespond(reply.text, quickReplies: reply.quickReplies);
    _currentStep = 'idle';
  }

  void _onDoctorSelected(Map<String, dynamic> doctor) {
    _selectedDoctorId = doctor['id'];
    _selectedDoctorName = doctor['name'];
    _currentStep = 'date';

    _addUserMessage('I choose Dr. ${doctor['name']}');
    _addBotMessage(
      '👨‍⚕️ Great choice! **Dr. ${doctor['name']}** is available.\n\n📅 Please select a date for your appointment.',
    );
    _scrollToBottom();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1C8C8C),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    _selectedDate =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    _currentStep = 'time';

    _addUserMessage('Date: $_selectedDate');
    _addBotMessage(
      '🗓️ **$_selectedDate** selected!\n\nNow choose your preferred time slot:',
    );
    _scrollToBottom();
  }

  void _onTimeSelected(String time) {
    _selectedTime = time;
    _currentStep = 'confirm';

    _addUserMessage('Time: $time');
    _addBotMessage(
      '✅ **Appointment Summary:**\n\n'
      '👨‍⚕️ Doctor: Dr. $_selectedDoctorName\n'
      '📅 Date: $_selectedDate\n'
      '🕐 Time: $_selectedTime\n'
      '💊 Specialty: $_selectedSpecialty\n\n'
      'Ready to proceed to payment?',
      quickReplies: ['Confirm & Pay', 'Cancel'],
    );
    _scrollToBottom();
  }

  void _proceedToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          doctorId: _selectedDoctorId,
          doctorName: _selectedDoctorName,
          specialty: _selectedSpecialty,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          symptoms: '',
        ),
      ),
    ).then((_) => _resetBookingFlow());
  }

  void _resetBookingFlow() {
    setState(() {
      _currentStep = 'idle';
      _selectedSpecialty = '';
      _selectedDoctorId = '';
      _selectedDoctorName = '';
      _selectedDate = '';
      _selectedTime = '';
      _availableDoctors = [];
    });
    _addBotMessage(
      '😊 Is there anything else I can help you with?',
      quickReplies: ['Describe symptoms', 'Book another appointment', 'No, thanks'],
    );
  }

  // ─── Build ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildBookingWidgets(),
          _buildInputBar(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1C2B3A),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1C8C8C), Color(0xFF2FA0A0)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TBIBI Assistant',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C2B3A),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Online',
                    style: TextStyle(fontSize: 11, color: Color(0xFF2ECC71)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1C8C8C)),
          tooltip: 'New conversation',
          onPressed: () {
            setState(() {
              _messages.clear();
              _currentStep = 'idle';
              _selectedSpecialty = '';
              _availableDoctors = [];
            });
            _addBotMessage(
              ChatbotLogic.getWelcomeMessage(),
              quickReplies: ChatbotLogic.getWelcomeQuickReplies(),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessageList() {
    final List<ChatMessage> messages = _messages;
    final int count = messages.length + (_isTyping ? 1 : 0);
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: count,
      itemBuilder: (context, index) {
        if (index >= messages.length) {
          return _buildTypingIndicator();
        }
        final msg = messages[index];
        return _buildMessage(msg, index);
      },
    );
  }

  Widget _buildMessage(ChatMessage msg, int index) {
    final isBot = msg.isBot;
    return Column(
      crossAxisAlignment:
          isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment:
              isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isBot) ...[
              Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(right: 8, bottom: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1C8C8C), Color(0xFF2FA0A0)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.smart_toy_rounded,
                    color: Colors.white, size: 14),
              ),
            ],
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isBot ? Colors.white : const Color(0xFF1C8C8C),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isBot ? 4 : 18),
                    bottomRight: Radius.circular(isBot ? 18 : 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildMessageText(msg.text, isBot),
              ),
            ),
          ],
        ),
        // Quick replies
        if (isBot && (msg.quickReplies.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(left: 38, bottom: 10, top: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: msg.quickReplies.map((reply) {
                return _buildQuickReplyChip(reply, index);
              }).toList(),
            ),
          ),

        // Timestamp
        Padding(
          padding: EdgeInsets.only(
            bottom: 12,
            left: isBot ? 38 : 0,
            right: isBot ? 0 : 4,
          ),
          child: Text(
            _formatTime(msg.timestamp),
            style: const TextStyle(fontSize: 10, color: Color(0xFFADB5BD)),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageText(String text, bool isBot) {
    // Parse **bold** markdown
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int last = 0;

    final baseColor = isBot ? const Color(0xFF1C2B3A) : Colors.white;
    const baseSize = 14.0;

    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(
          text: text.substring(last, match.start),
          style: TextStyle(color: baseColor, fontSize: baseSize, height: 1.45),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          color: baseColor,
          fontSize: baseSize,
          fontWeight: FontWeight.bold,
          height: 1.45,
        ),
      ));
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(
        text: text.substring(last),
        style: TextStyle(color: baseColor, fontSize: baseSize, height: 1.45),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildQuickReplyChip(String label, int messageIndex) {
    // Only the last bot message's chips are active
    final isLastBotMessage = messageIndex == _messages.length - 1 ||
        (messageIndex == _messages.length - 2 && _isTyping);

    return GestureDetector(
      onTap: isLastBotMessage
          ? () async {
              // Handle special quick replies
              if (label == 'Yes, find a doctor' ||
                  label == 'Book appointment' ||
                  label == 'Book new appointment' ||
                  label == 'Book another appointment') {
                _addUserMessage(label);
                await _startDoctorBooking();
              } else if (label == 'Confirm & Pay') {
                _addUserMessage(label);
                _proceedToPayment();
              } else if (label == 'Cancel') {
                _addUserMessage(label);
                _resetBookingFlow();
              } else if (label == 'No, that\'s all' || label == 'No, thanks') {
                _addUserMessage(label);
                await _showTypingThenRespond(
                  '😊 Take good care of yourself! Remember, I\'m here anytime you need health guidance. Stay healthy! 💙',
                );
              } else {
                await _handleUserSend(label);
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isLastBotMessage
              ? const Color(0xFF1C8C8C).withOpacity(0.06)
              : Colors.grey.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLastBotMessage
                ? const Color(0xFF1C8C8C)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: isLastBotMessage
                ? const Color(0xFF1C8C8C)
                : Colors.grey.shade500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 38, bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return _TypingDot(delay: i * 200);
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Booking Widgets ─────────────────────────────────────
  Widget _buildBookingWidgets() {
    if (_currentStep == 'doctor' && _availableDoctors.isNotEmpty) {
      return _buildDoctorChips();
    }
    if (_currentStep == 'date') {
      return _buildDateButton();
    }
    if (_currentStep == 'time') {
      return _buildTimeChips();
    }
    return const SizedBox.shrink();
  }

  Widget _buildDoctorChips() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a Doctor',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1C2B3A),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableDoctors.map((doc) {
                return GestureDetector(
                  onTap: () => _onDoctorSelected(doc),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1C8C8C), Color(0xFF2FA0A0)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1C8C8C).withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Dr. ${doc['name']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _pickDate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C8C8C),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.calendar_today_rounded, size: 18),
        label: const Text(
          'Pick Appointment Date',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildTimeChips() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Time Slot',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF1C2B3A),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _availableTimes.map((time) {
              return GestureDetector(
                onTap: () => _onTimeSelected(time),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C8C8C).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1C8C8C)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: Color(0xFF1C8C8C)),
                      const SizedBox(width: 5),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Color(0xFF1C8C8C),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Input Bar ───────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _inputController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1C2B3A),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Describe your symptoms...',
                    hintStyle: TextStyle(
                        color: Color(0xFFADB5BD), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                  onSubmitted: _handleUserSend,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isSending
                  ? null
                  : () => _handleUserSend(_inputController.text),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: _isSending
                      ? const LinearGradient(
                          colors: [Colors.grey, Colors.grey])
                      : const LinearGradient(
                          colors: [Color(0xFF1C8C8C), Color(0xFF2FA0A0)],
                        ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1C8C8C).withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── Typing Dot Animation ────────────────────────────────────
class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Transform.translate(
          offset: Offset(0, _anim.value),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1C8C8C),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
