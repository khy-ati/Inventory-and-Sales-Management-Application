import 'package:flutter/material.dart';
import 'package:vendor_tracker_application/models/settings_model.dart'; // Import your Settings model
import 'package:vendor_tracker_application/services/isar_service.dart'; // Import IsarService

class SettingsProvider with ChangeNotifier {
  final IsarService _isarService = IsarService();

  // The single instance of user settings
  Settings _settings = Settings(); // Initialize with default values

  Settings get settings => _settings;

  SettingsProvider() {
    _loadSettings(); // Load settings when the provider is created
  }

  // Load settings from Isar
  Future<void> _loadSettings() async {
    try {
      final loadedSettings = await _isarService.getSettings();
      if (loadedSettings != null) {
        _settings = loadedSettings;
      } else {
        // If no settings exist (first launch), save the default settings
        await _isarService.saveSettings(_settings);
      }
      notifyListeners(); // Notify listeners after loading
    } catch (e) {
      print('Error loading settings: $e');
      // Optionally show a snackbar or log error
    }
  }

  // Update dark mode preference
  Future<void> updateIsDarkMode(bool isDarkMode) async {
    _settings = _settings.copyWith(isDarkMode: isDarkMode);
    await _isarService.saveSettings(_settings);
    notifyListeners(); // Notify listeners to rebuild widgets that depend on this
  }

  // Update low stock threshold preference
  Future<void> updateLowStockThreshold(int threshold) async {
    _settings = _settings.copyWith(lowStockThreshold: threshold);
    await _isarService.saveSettings(_settings);
    notifyListeners(); // Notify listeners
  }

  @override
  void dispose() {
    // No specific resources to dispose for SettingsProvider beyond ChangeNotifier
    super.dispose();
  }
}
