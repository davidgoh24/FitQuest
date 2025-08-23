import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile','https://www.googleapis.com/auth/calendar',],
  );

  Future<Map<String, String>?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      final authHeaders = await account?.authHeaders;
      if (account == null) return null;

      final String email = account.email;
      final String? fullName = account.displayName;
      final String firstName = fullName?.split(' ').first ?? '';
      final String lastName = fullName?.split(' ').skip(1).join(' ') ?? '';

      print('GoogleSignIn: $email | $firstName | $lastName');

      return {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      };
    } catch (e) {
      print('GoogleSignIn error: $e');
      return null;
    }
  }

  Future<Map<String, String>?> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();
        final String email = userData['email'] ?? '';
        final String fullName = userData['name'] ?? '';
        final String firstName = fullName.split(' ').first;
        final String lastName = fullName.split(' ').skip(1).join(' ');

        print('FacebookLogin: $email | $firstName | $lastName');

        return {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
        };
      } else {
        print('Facebook login failed: ${result.status}');
        return null;
      }
    } catch (e) {
      print('Facebook login error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
  }
}
