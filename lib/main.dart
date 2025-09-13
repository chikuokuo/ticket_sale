import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/ticket_order_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Stripe
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

  runApp(
    // To enable Riverpod for the entire project,
    // we wrap the root widget in a "ProviderScope".
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neuschwanstein Castle Ticket',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // 自動根據系統設定切換主題
      home: const TicketOrderScreen(),
    );
  }
}
