// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_tracker_application/screens/dashboard.dart';
import '../services/isar_instance.dart';
import 'package:vendor_tracker_application/models/product.dart';
import 'package:vendor_tracker_application/models/sale.dart';
import 'package:vendor_tracker_application/models/settings_model.dart';
import 'package:vendor_tracker_application/providers/product_provider.dart';
import 'package:vendor_tracker_application/providers/sale_provider.dart';
import 'package:vendor_tracker_application/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Isar database
    await IsarDatabase.instance.database;
   // print('Isar database initialized successfully');
  } catch (e) {
    //print('Failed to initialize database: $e');
    // You might want to show an error dialog or use a fallback
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final isDarkMode = settingsProvider.settings.isDarkMode;

    return MaterialApp(
      title: 'Vendor Tracker App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData( // Define a dark theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark, // Dark brightness
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // Darker app bar for dark mode
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
       themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const Dashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
