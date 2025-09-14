import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'providers/bundle_provider.dart'; // Import the provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe with a hardcoded key
  Stripe.publishableKey = 'pk_test_51S6oar2Z7txq4ZPOJ5dfijly6A17SUoXDsx9nK0JheaNo8XjLAMsLqLbm4fodqNdnD3XpB7S7c9TPFMlb8ZoXz9000Z5Wj34b6'; // Replace with your actual test key
  await Stripe.instance.applySettings();

  // Create a ProviderContainer to interact with providers before runApp
  final container = ProviderContainer();

  // Pre-warm the bundlesProvider.
  // This will load the JSON data into memory.
  // If there's an error, it will be thrown here.
  await container.read(bundlesProvider.future);

  runApp(
    // To enable Riverpod for the entire project,
    // we wrap the root widget in a "ProviderScope".
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'future dream',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Auto switch theme based on system setting
      home: const MainNavigationScreen(),
    );
  }
}
