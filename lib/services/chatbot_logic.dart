class ChatbotLogic {

  static String getReply(String message) {
    message = message.toLowerCase();

    // ✅ EMERGENCY
    if (message.contains("can't breathe") ||
        message.contains("severe pain") ||
        message.contains("dying")) {
      return "⚠️ This may be serious.\nPlease contact emergency services immediately.";
    }

    // ✅ HEART
    if (message.contains("chest") || message.contains("heart")) {
      return "❤️ This may be related to your heart.\n\nCan you tell me:\n• When did it start?\n• Is it constant?\n\n👉 I recommend a cardiologist.";
    }

    // ✅ DENTAL
    if (message.contains("tooth") || message.contains("teeth")) {
      return "🦷 Tooth pain detected.\n\n• Do you feel strong pain?\n• Sensitivity to cold?\n\n👉 You should consult a dentist.";
    }

    // ✅ SKIN
    if (message.contains("skin") || message.contains("rash")) {
      return "🧴 Skin issue detected.\n\n• Is it itchy?\n• Red or swollen?\n\n👉 A dermatologist can help.";
    }

    // ✅ HEAD
    if (message.contains("head") || message.contains("headache")) {
      return "🤕 Head pain detected.\n\n• How long has it lasted?\n• Is it frequent?\n\n👉 You may start with a general doctor.";
    }

    // ✅ APPOINTMENT
    if (message.contains("appointment") || message.contains("rdv")) {
      return "📅 You can view your appointments in the RDV section.";
    }

    // ✅ ANALYSES
    if (message.contains("analysis") || message.contains("test")) {
      return "🧪 Your analyses are available in the Analyses section.\n\nWould you like help understanding them?";
    }

    // ✅ DEFAULT
    return "I’m here to help 😊\n\n• Describe your symptoms\n• Ask about appointments\n• Ask about analyses";
  }
}