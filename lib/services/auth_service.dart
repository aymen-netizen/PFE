import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';

  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<void> setToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  bool isLoggedIn() {
    return getToken() != null;
  }
}

// Register with GetIt
// GetIt registration moved to di.dart


