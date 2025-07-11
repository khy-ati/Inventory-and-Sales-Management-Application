// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_tracker_application/providers/settings_provider.dart'; // Will create this next

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // TextEditingController for the low stock threshold input
  final TextEditingController _lowStockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controller with current value from provider after build
    // This ensures context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = context.read<SettingsProvider>();
      _lowStockController.text =
          settingsProvider.settings.lowStockThreshold.toString();
    });
  }

  @override
  void dispose() {
    _lowStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the SettingsProvider to react to changes in settings
    final settingsProvider = context.watch<SettingsProvider>();
    final currentSettings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SwitchListTile(
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Toggle between light and dark themes'),
                  value: currentSettings.isDarkMode,
                  onChanged: (bool value) {
                    // Update the settings via the provider
                    settingsProvider.updateIsDarkMode(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Low Stock Alert Threshold',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _lowStockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Threshold Quantity',
                        hintText: 'e.g., 10',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.warning_amber),
                      ),
                      onChanged: (value) {
                        final int? newThreshold = int.tryParse(value);
                        if (newThreshold != null && newThreshold >= 0) {
                          // Update the settings via the provider as the user types
                          settingsProvider
                              .updateLowStockThreshold(newThreshold);
                        }
                        // You might want to add validation feedback here
                      },
                      validator: (value) {
                        final int? val = int.tryParse(value ?? '');
                        if (val == null || val < 0) {
                          return 'Please enter a valid non-negative number.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            // No explicit save button needed if changes are applied on onChanged
            // If you prefer a save button, you'd move settingsProvider.update... calls
            // into an onPressed for a button and add form validation.
          ],
        ),
      ),
    );
  }
}
