import '../models/user.model.dart';

class ProfileValidator {
  /// Check if user profile has all required fields for creating an order
  /// Returns a map with 'isComplete' boolean and 'missingFields' list
  static Map<String, dynamic> validateUserProfile(UserModel? user) {
    if (user == null) {
      return {
        'isComplete': false,
        'missingFields': ['User not logged in'],
      };
    }

    List<String> missingFields = [];

    // Check required fields
    if (user.fullName == null || user.fullName!.trim().isEmpty) {
      missingFields.add('Full Name');
    }

    if (user.email == null || user.email!.trim().isEmpty) {
      missingFields.add('Email');
    }

    if (user.phoneNumber == null || user.phoneNumber!.trim().isEmpty) {
      missingFields.add('Phone Number');
    }

    if (user.currentAddress == null || user.currentAddress!.trim().isEmpty) {
      missingFields.add('Address');
    }

    if (user.postalCode == null) {
      missingFields.add('Postal Code');
    }

    if (user.wilaya == null || user.wilaya!.trim().isEmpty) {
      missingFields.add('Wilaya');
    }

    return {
      'isComplete': missingFields.isEmpty,
      'missingFields': missingFields,
    };
  }

  /// Get a user-friendly message about missing fields
  static String getMissingFieldsMessage(List<String> missingFields) {
    if (missingFields.isEmpty) {
      return '';
    }

    if (missingFields.length == 1) {
      return 'Missing: ${missingFields[0]}';
    }

    return 'Missing: ${missingFields.join(', ')}';
  }
}
