import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_model.dart';

class SavedServicesProvider extends ChangeNotifier {
  List<ServiceModel> _savedServices = [];
  bool _isLoading = false;

  List<ServiceModel> get savedServices => _savedServices;
  bool get isLoading => _isLoading;

  // Load saved services for a specific user
  Future<void> loadSavedServices(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = 'saved_services_$userId';
      final String? servicesJson = prefs.getString(key);

      if (servicesJson != null) {
        final List<dynamic> decodedList = json.decode(servicesJson);
        _savedServices = decodedList
            .map((item) => ServiceModel.fromJson(item))
            .toList();
      } else {
        _savedServices = [];
      }
    } catch (e) {
      print('Error loading saved services: $e');
      _savedServices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle save status (Save/Unsave)
  Future<void> toggleSave(String userId, ServiceModel service) async {
    final isAlreadySaved = isSaved(service.id);

    if (isAlreadySaved) {
      _savedServices.removeWhere((item) => item.id == service.id);
    } else {
      _savedServices.add(service);
    }

    notifyListeners();
    await _saveToStorage(userId);
  }

  // Check if a service is saved
  bool isSaved(String serviceId) {
    return _savedServices.any((item) => item.id == serviceId);
  }

  // Persist to shared_preferences
  Future<void> _saveToStorage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = 'saved_services_$userId';
      final String encodedList = json.encode(
        _savedServices.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(key, encodedList);
    } catch (e) {
      print('Error saving services to storage: $e');
    }
  }

  // Clear loaded services (e.g., on logout)
  void clear() {
    _savedServices = [];
    notifyListeners();
  }
}
