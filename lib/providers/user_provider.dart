import 'package:flutter/foundation.dart';
import '../models/User.model.dart';

class UserProvider extends ChangeNotifier {
  UserModel _user = UserModel();

  UserModel get user => _user;

  // Get formatted full phone number with country code
  String get fullPhoneNumber {
    if (_user.phoneNumber != null) {
      return _user.phoneNumber.toString();
    }
    return '';
  }

  // Update phone number (with country code)
  void setPhoneNumber(String phoneNumber) {
    _user = _user.copyWith(
      phoneNumber: int.tryParse(phoneNumber.replaceAll('+', '')),
    );
    notifyListeners();
  }

  // Update email
  void setEmail(String email) {
    _user = _user.copyWith(email: email);
    notifyListeners();
  }

  // Update full name
  void setFullName(String fullName) {
    _user = _user.copyWith(fullName: fullName);
    notifyListeners();
  }

  // Update current address
  void setCurrentAddress(String address) {
    _user = _user.copyWith(currentAddress: address);
    notifyListeners();
  }

  // Update code postal
  void setCodePostal(String codePostal) {
    _user = _user.copyWith(codePostal: int.tryParse(codePostal));
    notifyListeners();
  }

  // Update wilaya
  void setWilaya(String wilaya) {
    _user = _user.copyWith(wilaya: wilaya);
    notifyListeners();
  }

  // Update password
  void setPassword(String password) {
    _user = _user.copyWith(password: password);
    notifyListeners();
  }

  // Update entire user model
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  // Clear all user data
  void clearUser() {
    _user = UserModel();
    notifyListeners();
  }

  // Check if user has basic info
  bool get hasPhoneNumber => _user.phoneNumber != null;
  bool get hasEmail => _user.email != null && _user.email!.isNotEmpty;
  bool get hasFullName => _user.fullName != null && _user.fullName!.isNotEmpty;
}
