import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/tickets_home_screen.dart';
import '../screens/bundle_screen.dart';
import '../screens/train_ticket_screen.dart';
import '../screens/treasure_hunt_screen.dart';
import '../theme/colors.dart';
import '../widgets/jackpot_floating_button.dart';
import '../providers/ticket_order_provider.dart';

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
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // Jackpot floating button - 在寶藏獵人頁面不顯示
          if (_selectedIndex != 3) // 3 是 TreasureHuntScreen 的索引
            JackpotFloatingButton(
              participantCount: totalParticipants,
              // Uses default onTap behavior to show MegaJackpotDialog
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Tickets'),
            BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined),
            activeIcon: Icon(Icons.card_giftcard),
            label: 'Bundle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.train_outlined),
            activeIcon: Icon(Icons.train),
            label: 'Train',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'Treasure',
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

