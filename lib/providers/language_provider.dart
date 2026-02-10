import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _appLocale = const Locale('en');

  Locale get appLocale => _appLocale;

  Future<void> fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = const Locale('en');
      return;
    }
    _appLocale = Locale(prefs.getString('language_code')!);
    notifyListeners();
  }

  Future<void> changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type.languageCode == 'fr') {
      _appLocale = const Locale("fr");
      await prefs.setString('language_code', 'fr');
    } else {
      _appLocale = const Locale("en");
      await prefs.setString('language_code', 'en');
    }
    notifyListeners();
  }
}
