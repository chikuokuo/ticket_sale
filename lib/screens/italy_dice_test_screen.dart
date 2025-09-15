import 'package:flutter/material.dart';
import '../widgets/italy_trip_dice.dart';
import '../models/italy_trip.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

class ItalyDiceTestScreen extends StatefulWidget {
  const ItalyDiceTestScreen({super.key});

  @override
  State<ItalyDiceTestScreen> createState() => _ItalyDiceTestScreenState();
}

class _ItalyDiceTestScreenState extends State<ItalyDiceTestScreen> {
  ItalyTrip? _lastSelectedTrip;
  int _rollCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Italy Trip Dice Test'),
        backgroundColor: AppColorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background with Italian theme
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8F9FA),
                  Color(0xFFE8F5E8),
                ],
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    '義大利隨機行程骰子測試',
                    style: AppTheme.displayMedium.copyWith(
                      color: AppColorScheme.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.shadowSoft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '使用說明：',
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• 點擊右下角的骰子來獲得隨機義大利行程建議\n'
                          '• 骰子會漂浮並微微旋轉\n'
                          '• 點擊後會有震動反饋和搖骰動畫\n'
                          '• 可以拖曳骰子到任何位置\n'
                          '• 結果會以精美的彈窗顯示',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppColorScheme.neutral700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Statistics
                  if (_lastSelectedTrip != null) ...[
                    Text(
                      '最後選中的行程：',
                      style: AppTheme.titleLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.shadowSoft,
                        border: Border.all(
                          color: AppColorScheme.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _lastSelectedTrip!.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _lastSelectedTrip!.nameEn,
                                  style: AppTheme.titleLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _lastSelectedTrip!.nameZh,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppColorScheme.neutral600,
                                  ),
                                ),
                                Text(
                                  '📍 ${_lastSelectedTrip!.cityZh}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '總共擲骰次數: $_rollCount',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppColorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Available attractions list
                  Text(
                    '可用景點 (${ItalyTrip.attractions.length} 個):',
                    style: AppTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.shadowSoft,
                      ),
                      child: ListView.builder(
                        itemCount: ItalyTrip.attractions.length,
                        itemBuilder: (context, index) {
                          final trip = ItalyTrip.attractions[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(trip.emoji, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${trip.nameEn} (${trip.nameZh})',
                                    style: AppTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Italy Trip Dice
          ItalyTripDice(
            alignment: Alignment.bottomRight,
            onPick: (ItalyTrip trip) {
              setState(() {
                _lastSelectedTrip = trip;
                _rollCount++;
              });
            },
          ),
        ],
      ),
    );
  }
}
