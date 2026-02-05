import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service to handle Google Sign-In authentication
/// Manages the Google OAuth flow and retrieves ID tokens
/// Uses google_sign_in package v7.2.0+ API
class GoogleAuthService {
  // Track initialization state
  bool _isInitialized = false;

  /// Initialize Google Sign-In with configuration from .env
  Future<void> initialize() async {
    // If already initialized, do nothing
    if (_isInitialized) return;

    try {
      // Get the web client ID from environment variables
      // This is the OAuth 2.0 Web Client ID from Google Cloud Console
      // It's used by the backend to validate the ID token
      final String? serverClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];

      if (serverClientId == null || serverClientId.isEmpty) {
        throw Exception(
          'GOOGLE_WEB_CLIENT_ID not found in .env file. '
          'Please add it to enable Google Sign-In.',
        );
      }

      // Initialize GoogleSignIn using the singleton instance
      // The serverClientId is the Web Client ID from Google Cloud Console
      // Android OAuth client must be configured in Google Cloud Console with correct SHA-1
      //
      // IMPORTANT: On Android, the google_sign_in package will automatically use
      // the Android OAuth client from Google Cloud Console that matches:
      // 1. Package name: com.example.buzz
      // 2. SHA-1 fingerprint: 81:97:F5:DC:E7:B2:E8:88:81:0D:58:D0:BE:AD:03:0B:4D:54:E1:80
      await GoogleSignIn.instance.initialize(serverClientId: serverClientId);

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with Google and return the ID token
  Future<String?> signInWithGoogle() async {
    try {
      // Ensure service is initialized
      if (!_isInitialized) {
        await initialize();
      }

      // Trigger the interactive sign-in using authenticate()
      // This will show the account picker and handle the OAuth flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      // Check if user cancelled the sign-in
      if (googleUser == null) {
        return null;
      }

      // Obtain auth details (ID Token)
      // In v7.2.0+, authentication is a synchronous getter
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      return idToken;
    } on GoogleSignInException catch (e) {
      // Handle Google Sign-In specific exceptions
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      if (!_isInitialized) {
        // Try to initialize to get the instance to sign out,
        // but if init fails (e.g. missing env), we silently ignore
        // because we can't sign out if we aren't configured.
        try {
          await initialize();
        } catch (_) {
          return;
        }
      }

      await GoogleSignIn.instance.signOut();
    } catch (e) {}
  }

  /// Disconnect (revoke access)
  Future<void> disconnect() async {
    try {
      if (!_isInitialized) {
        try {
          await initialize();
        } catch (_) {
          return;
        }
      }

      await GoogleSignIn.instance.disconnect();
    } catch (e) {}
  }
}
