
import 'package:shared_preferences/shared_preferences.dart';

class CardService {
  static const _keyName = 'card_name';
  static const _keyNumber = 'card_number';
  static const _keyExpiry = 'card_expiry';
  static const _keyCvv = 'card_cvv';

  static Future<void> saveCard({
    required String name,
    required String number,
    required String expiry,
    required String cvv,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyNumber, number);
    await prefs.setString(_keyExpiry, expiry);
    await prefs.setString(_keyCvv, cvv);
  }

  static Future<Map<String, String>?> getCard() async {
    final prefs = await SharedPreferences.getInstance();
    final number = prefs.getString(_keyNumber);
    if (number == null || number.isEmpty) return null;
    return {
      'name': prefs.getString(_keyName) ?? '',
      'number': prefs.getString(_keyNumber) ?? '',
      'expiry': prefs.getString(_keyExpiry) ?? '',
      'cvv': prefs.getString(_keyCvv) ?? '',
    };
  }

  static Future<void> deleteCard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyNumber);
    await prefs.remove(_keyExpiry);
    await prefs.remove(_keyCvv);
  }

  static Future<bool> hasCard() async {
    final card = await getCard();
    return card != null;
  }
}
