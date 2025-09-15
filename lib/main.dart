import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'providers/bundle_provider.dart'; // Import the provider
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style to remove white status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar transparent
      statusBarIconBrightness: Brightness.dark, // Dark icons on light background
      statusBarBrightness: Brightness.light, // For iOS
      systemNavigationBarColor: Colors.white, // Navigation bar color
      systemNavigationBarIconBrightness: Brightness.dark, // Dark nav icons
    ),
  );

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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    
    return MaterialApp(
      title: 'future dream',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Auto switch theme based on system setting
      
      // Internationalization support
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ko'), // Korean
        Locale('fr'), // French
        Locale('de'), // German
        Locale('ja'), // Japanese
        Locale('vi'), // Vietnamese
      ],
      locale: currentLocale, // Use the current locale from provider
      
      home: const MainNavigationScreen(),
    );
  }
}
