import 'dart:convert';

/// Utility class to decode JWT tokens and check expiration
class JwtDecoder {
  /// Decode a JWT token and return its payload
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      // Add padding if necessary
      var normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Check if a JWT token is expired
  static bool isExpired(String token) {
    final payload = decode(token);
    if (payload == null) {
      return true; // Invalid token is considered expired
    }

    final exp = payload['exp'];
    if (exp == null) {
      return true; // No expiration means expired
    }

    final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expirationDate);
  }

  /// Check if a JWT token will expire within the specified duration
  /// Useful for proactive token refresh
  static bool willExpireSoon(String token, Duration duration) {
    final payload = decode(token);
    if (payload == null) {
      return true;
    }

    final exp = payload['exp'];
    if (exp == null) {
      return true;
    }

    final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final threshold = DateTime.now().add(duration);
    return threshold.isAfter(expirationDate);
  }

  /// Get the expiration date of a JWT token
  static DateTime? getExpirationDate(String token) {
    final payload = decode(token);
    if (payload == null) {
      return null;
    }

    final exp = payload['exp'];
    if (exp == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }

  /// Get the remaining time until token expiration
  static Duration? getTimeUntilExpiration(String token) {
    final expirationDate = getExpirationDate(token);
    if (expirationDate == null) {
      return null;
    }

    final now = DateTime.now();
    if (now.isAfter(expirationDate)) {
      return Duration.zero;
    }

    return expirationDate.difference(now);
  }

  /// Get a claim from the JWT token payload
  static dynamic getClaim(String token, String claimName) {
    final payload = decode(token);
    return payload?[claimName];
  }
}
