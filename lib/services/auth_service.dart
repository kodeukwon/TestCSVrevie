import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/blogger',
      'https://www.googleapis.com/auth/blogger.readonly',
    ],
  );

  GoogleSignInAccount? _currentUser;
  auth.AccessToken? _accessToken;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  GoogleSignInAccount? get currentUser => _currentUser;
  auth.AccessToken? get accessToken => _accessToken;

  AuthService() {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
      _isAuthenticated = account != null;
      notifyListeners();
    });
    _googleSignIn.signInSilently();
  }

  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final authentication = await account.authentication;
        _accessToken = auth.AccessToken(
          'Bearer',
          authentication.accessToken ?? '',
          DateTime.now().add(const Duration(hours: 1)).toUtc(),
        );

        // 토큰 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', authentication.accessToken ?? '');

        return true;
      }
      return false;
    } catch (error) {
      debugPrint('로그인 오류: $error');
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    _accessToken = null;
    notifyListeners();
  }
}
