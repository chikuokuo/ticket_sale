import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/colors.dart';
import 'train_search_tab.dart';
import 'train_bundle_tab.dart';

class TrainTicketScreen extends StatefulWidget {
  const TrainTicketScreen({super.key});

  @override
  State<TrainTicketScreen> createState() => _TrainTicketScreenState();
}

class _TrainTicketScreenState extends State<TrainTicketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: const Text('Train Tickets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTheme.headlineSmall.copyWith(
          color: AppColorScheme.neutral900,
          fontWeight: FontWeight.w600,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.search),
              text: 'Search Tickets',
            ),
            Tab(
              icon: Icon(Icons.card_giftcard),
              text: 'Bundle Packages',
            ),
          ],
          labelColor: AppColorScheme.primary,
          unselectedLabelColor: AppColorScheme.neutral500,
          indicatorColor: AppColorScheme.primary,
          indicatorWeight: 3,
          labelStyle: AppTheme.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTheme.labelLarge.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TrainSearchTab(),
          TrainBundleTab(),
        ],
      ),
    );
  }
}