import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/ticket_order_screen.dart';

void main() {
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TicketOrderScreen(),
    );
  }
}
