import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';

import '../screens/tickets_home_screen.dart';
import '../screens/bundle_screen.dart';
import '../screens/train_ticket_screen.dart';
import '../screens/treasure_hunt_screen.dart';
import '../screens/settings_screen.dart';
import '../theme/colors.dart';
import '../widgets/jackpot_floating_button.dart';
import '../widgets/italy_trip_dice.dart';
import '../providers/ticket_order_provider.dart';
import '../models/italy_trip.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const MainNavigationScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  static const List<Widget> _pages = <Widget>[
    TicketsHomeScreen(),
    BundleScreen(),
    TrainTicketScreen(),
    TreasureHuntScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Calculate total participant count from all ticket providers
    final neuschwansteinOrder = ref.watch(ticketOrderProvider(TicketType.neuschwanstein));
    final museumOrder = ref.watch(ticketOrderProvider(TicketType.museum));

    final totalParticipants = neuschwansteinOrder.attendees.length + museumOrder.attendees.length;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          // Jackpot floating button - 只在首頁（票券頁面）顯示
          if (_selectedIndex == 0) // 只在首頁（TicketsHomeScreen）顯示
            JackpotFloatingButton(
              participantCount: totalParticipants,
              // Uses default onTap behavior to show MegaJackpotDialog
            ),
           // Italy Trip Dice - 只在首頁（票券頁面）顯示，放在右下角 Jackpot 按鈕上方
           if (_selectedIndex == 0) 
             ItalyTripDice(
               alignment: Alignment.bottomRight,
               onPick: (ItalyTrip trip) {
                 // Optional: Add any custom logic when trip is selected
                 debugPrint('Selected Italy trip: ${trip.nameEn}');
               },
             ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.confirmation_number_outlined),
            activeIcon: const Icon(Icons.confirmation_number),
            label: l10n.tickets,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.card_giftcard_outlined),
            activeIcon: const Icon(Icons.card_giftcard),
            label: l10n.bundles,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.train_outlined),
            activeIcon: const Icon(Icons.train),
            label: l10n.trains,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.star_outline),
            activeIcon: const Icon(Icons.star),
            label: l10n.treasureHunt,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColorScheme.primary,
        unselectedItemColor: AppColorScheme.neutral500,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

