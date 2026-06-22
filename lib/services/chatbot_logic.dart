// ============================================================
//  TBIBI - Advanced Medical Chatbot Logic
//  Multi-turn, symptom-aware, specialty-recommending AI engine
// ============================================================

enum ChatbotStep {
  greeting,
  awaitingSymptoms,
  awaitingMoreInfo,
  specialtyDetected,
  done,
}

class ChatMessage {
  final String text;
  final bool isBot;
  final List<String> quickReplies;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    this.quickReplies = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotReply {
  final String text;
  final List<String> quickReplies;
  final String? detectedSpecialty;
  final bool showBookingFlow;

  const ChatbotReply({
    required this.text,
    this.quickReplies = const [],
    this.detectedSpecialty,
    this.showBookingFlow = false,
  });
}

class ChatbotLogic {
  // ─── Specialty keyword maps ───────────────────────────────
  static const Map<String, List<String>> _specialtyKeywords = {
    'cardiologue': [
      'chest', 'heart', 'palpitation', 'breath', 'breathe', 'breathing',
      'heartbeat', 'irregular', 'blood pressure', 'cardiac', 'cardio',
      'arrhythmia', 'angina', 'tachycardia', 'fainting', 'syncope',
      'douleur poitrine', 'coeur', 'essoufflement', 'palpitations',
    ],
    'dentiste': [
      'tooth', 'teeth', 'dental', 'gum', 'mouth', 'jaw', 'cavity',
      'toothache', 'wisdom', 'bleeding gum', 'sensitivity', 'denture',
      'dent', 'gencive', 'bouche', 'molaire', 'carie', 'sensibilité',
    ],
    'dermatologie': [
      'skin', 'rash', 'itch', 'acne', 'pimple', 'spot', 'dry skin',
      'eczema', 'psoriasis', 'hives', 'allergy', 'burn', 'wound',
      'peau', 'bouton', 'éruption', 'démangeaison', 'allergie',
    ],
    'medecine generale': [
      'fever', 'flu', 'cold', 'cough', 'fatigue', 'tired', 'headache',
      'head', 'nausea', 'vomit', 'diarrhea', 'stomach', 'back pain',
      'muscle', 'joint', 'dizzy', 'dizziness', 'weight', 'sleep',
      'fièvre', 'grippe', 'rhume', 'toux', 'fatigue', 'maux de tête',
      'nausée', 'vomissement', 'douleur', 'mal', 'général',
    ],
    'pediatre': [
      'child', 'baby', 'infant', 'kid', 'toddler', 'children', 'newborn',
      'enfant', 'bébé', 'nourrisson', 'pédiatre',
    ],
    'ophtalmologie': [
      'eye', 'vision', 'blur', 'sight', 'glasses', 'contact lens',
      'red eye', 'itchy eye', 'oeil', 'yeux', 'vue', 'vision floue',
    ],
    'orthopédie': [
      'bone', 'fracture', 'joint', 'knee', 'ankle', 'hip', 'shoulder',
      'spine', 'back', 'orthopedic', 'muscle pain', 'sport injury',
      'os', 'genou', 'cheville', 'hanche', 'épaule', 'colonne',
    ],
  };

  // ─── Specialty icons & display names ─────────────────────
  static const Map<String, String> _specialtyIcons = {
    'cardiologue': '❤️',
    'dentiste': '🦷',
    'dermatologie': '🧴',
    'medecine generale': '🩺',
    'pediatre': '👶',
    'ophtalmologie': '👁️',
    'orthopédie': '🦴',
  };

  static const Map<String, String> _specialtyDisplayNames = {
    'cardiologue': 'Cardiologist',
    'dentiste': 'Dentist',
    'dermatologie': 'Dermatologist',
    'medecine generale': 'General Practitioner',
    'pediatre': 'Pediatrician',
    'ophtalmologie': 'Ophthalmologist',
    'orthopédie': 'Orthopedist',
  };

  // ─── Emergency keywords ───────────────────────────────────
  static const List<String> _emergencyKeywords = [
    "can't breathe", "cannot breathe", "chest crushing", "heart attack",
    "stroke", "unconscious", "dying", "severe chest pain", "collapse",
    "15", "ambulance", "urgence", "je meurs", "smur",
  ];

  // ─── Greeting keywords ───────────────────────────────────
  static const List<String> _greetingKeywords = [
    'hello', 'hi', 'hey', 'bonjour', 'salut', 'salam', 'bonsoir',
    'good morning', 'good evening', 'marhaba',
  ];

  // ─── Thank you keywords ───────────────────────────────────
  static const List<String> _thankKeywords = [
    'thank', 'thanks', 'merci', 'shukran', 'thankyou',
  ];

  // ─── Appointment keywords ─────────────────────────────────
  static const List<String> _appointmentKeywords = [
    'appointment', 'book', 'rdv', 'rendez-vous', 'schedule', 'voir médecin',
    'consultation', 'réserver',
  ];

  // ─── Analysis keywords ───────────────────────────────────
  static const List<String> _analysisKeywords = [
    'analysis', 'analyse', 'test', 'blood test', 'result', 'lab',
    'examens', 'analyses', 'résultats',
  ];

  // ─── Main reply engine ────────────────────────────────────
  static ChatbotReply getReply(String message, {String? currentStep}) {
    final input = message.toLowerCase().trim();

    // 1. EMERGENCY
    for (final kw in _emergencyKeywords) {
      if (input.contains(kw)) {
        return const ChatbotReply(
          text:
              '🚨 **EMERGENCY DETECTED**\n\n'
              'This sounds like a medical emergency.\n\n'
              '📞 **Call emergency services immediately:**\n'
              '• Tunisia: **190** (SAMU)\n'
              '• General emergency: **197**\n\n'
              'Do NOT wait — please seek immediate help.',
          quickReplies: ['I\'m okay', 'Back to home'],
        );
      }
    }

    // 2. GREETING
    for (final kw in _greetingKeywords) {
      if (input.contains(kw)) {
        return const ChatbotReply(
          text:
              '👋 Hello! I\'m **TBIBI**, your personal medical assistant.\n\n'
              'I\'m here to help you:\n'
              '• 🩺 Identify the right specialist for your symptoms\n'
              '• 📅 Book appointments quickly\n'
              '• 📋 Answer health questions\n\n'
              'How can I help you today?',
          quickReplies: [
            'I have a symptom',
            'Book appointment',
            'My analyses',
            'My appointments',
          ],
        );
      }
    }

    // 3. THANK YOU
    for (final kw in _thankKeywords) {
      if (input.contains(kw)) {
        return const ChatbotReply(
          text:
              '😊 You\'re welcome! Take care of yourself.\n\n'
              'Is there anything else I can help you with?',
          quickReplies: ['Yes, I have another question', 'No, that\'s all'],
        );
      }
    }

    // 4. APPOINTMENT NAVIGATION
    for (final kw in _appointmentKeywords) {
      if (input.contains(kw)) {
        return const ChatbotReply(
          text:
              '📅 **Appointment Booking**\n\n'
              'I can help you book with the right doctor.\n\n'
              'First, let me know what\'s bothering you — describe your symptoms and I\'ll find the best specialist for you.',
          quickReplies: [
            'Chest pain',
            'Tooth pain',
            'Skin issue',
            'Headache',
            'Fever',
          ],
        );
      }
    }

    // 5. ANALYSIS NAVIGATION
    for (final kw in _analysisKeywords) {
      if (input.contains(kw)) {
        return const ChatbotReply(
          text:
              '🧪 **Medical Tests & Analyses**\n\n'
              'Your test results are available in the **Medical Record** section on your home screen.\n\n'
              'From there you can:\n'
              '• 📷 Upload your test images\n'
              '• 📋 View all prescribed analyses\n'
              '• 📊 Track your medical history',
          quickReplies: ['Describe symptoms instead', 'Book an appointment'],
        );
      }
    }

    // 6. SPECIALTY DETECTION
    final detected = _detectSpecialty(input);
    if (detected != null) {
      final icon = _specialtyIcons[detected] ?? '🩺';
      final name = _specialtyDisplayNames[detected] ?? detected;
      final followUp = _getFollowUpQuestions(detected);

      return ChatbotReply(
        text:
            '$icon **$name Detected**\n\n'
            'Based on your symptoms, I recommend consulting a **$name**.\n\n'
            '$followUp\n\n'
            'Would you like me to find available doctors for you?',
        quickReplies: ['Yes, find a doctor', 'Tell me more', 'Different symptom'],
        detectedSpecialty: detected,
      );
    }

    // 7. SHORT / UNCLEAR INPUT
    if (input.length < 4) {
      return const ChatbotReply(
        text:
            '🤔 Could you provide a bit more detail?\n\n'
            'Tell me about your symptoms and I\'ll guide you to the right specialist.',
        quickReplies: [
          'I have chest pain',
          'I have a headache',
          'I have tooth pain',
          'I have a fever',
          'Skin problem',
        ],
      );
    }

    // 8. GENERAL CATCH-ALL
    return const ChatbotReply(
      text:
          '🩺 I\'m here to help you find the right care.\n\n'
          'Please describe your symptoms in more detail — for example:\n'
          '• "I have chest pain and shortness of breath"\n'
          '• "My tooth hurts"\n'
          '• "I have a fever and headache"\n\n'
          'The more you tell me, the better I can help!',
      quickReplies: [
        'Chest / Heart',
        'Teeth / Mouth',
        'Skin issue',
        'Head / Fever',
        'Eyes',
        'Bone / Joint',
      ],
    );
  }

  // ─── Specialty detector ───────────────────────────────────
  static String? _detectSpecialty(String input) {
    int bestScore = 0;
    String? bestSpecialty;

    for (final entry in _specialtyKeywords.entries) {
      int score = 0;
      for (final kw in entry.value) {
        if (input.contains(kw)) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        bestSpecialty = entry.key;
      }
    }

    return bestScore > 0 ? bestSpecialty : null;
  }

  // ─── Follow-up questions per specialty ───────────────────
  static String _getFollowUpQuestions(String specialty) {
    switch (specialty) {
      case 'cardiologue':
        return '**A few follow-up questions:**\n'
            '• Is the pain constant or intermittent?\n'
            '• Do you experience shortness of breath?\n'
            '• Any family history of heart disease?';
      case 'dentiste':
        return '**A few follow-up questions:**\n'
            '• Is the pain sharp or dull?\n'
            '• Sensitivity to hot/cold foods?\n'
            '• Any swelling in the gums?';
      case 'dermatologie':
        return '**A few follow-up questions:**\n'
            '• Is it itchy or painful?\n'
            '• How long have you had this?\n'
            '• Any recent changes in products used?';
      case 'medecine generale':
        return '**A few follow-up questions:**\n'
            '• How long have you had these symptoms?\n'
            '• Do you have a fever?\n'
            '• Any recent illness?';
      case 'pediatre':
        return '**A few follow-up questions:**\n'
            '• How old is the child?\n'
            '• What symptoms are they showing?\n'
            '• Any fever or loss of appetite?';
      case 'ophtalmologie':
        return '**A few follow-up questions:**\n'
            '• Is your vision blurry?\n'
            '• Are your eyes red or watery?\n'
            '• Do you wear glasses or contacts?';
      case 'orthopédie':
        return '**A few follow-up questions:**\n'
            '• Was there an injury or accident?\n'
            '• Where exactly is the pain?\n'
            '• Does it worsen with movement?';
      default:
        return '**Could you describe more about your symptoms?**';
    }
  }

  // ─── Static helpers ───────────────────────────────────────
  static String getWelcomeMessage() {
    return '👋 **Welcome to TBIBI!**\n\n'
        'I\'m your AI-powered medical assistant.\n\n'
        'I can help you:\n'
        '• 🔍 Identify the right specialist\n'
        '• 📅 Book doctor appointments\n'
        '• 🧪 Navigate your test results\n\n'
        'How are you feeling today?';
  }

  static List<String> getWelcomeQuickReplies() {
    return [
      'I have a symptom',
      'Book appointment',
      'My analyses',
      'My appointments',
    ];
  }

  static String? detectSpecialtyFromInput(String input) {
    return _detectSpecialty(input.toLowerCase());
  }
}