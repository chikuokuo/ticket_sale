import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'providers/bundle_provider.dart'; // Import the provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe with a hardcoded key
  Stripe.publishableKey = 'pk_test_51PFe4sRxH7bTG8bM636XAAo3w1Y21pY23t9FXu8219uJb1n2Xy5E0f3X4qY5Z6a7B8c9D0eF1gH2iJ3kL4mN5oP6qR7s'; // Replace with your actual test key

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
