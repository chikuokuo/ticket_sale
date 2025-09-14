import 'package:flutter/material.dart';
import 'dart:math' as math;

class MegaJackpotDialog extends StatefulWidget {
  final double jackpotAmount;

  const MegaJackpotDialog({
    super.key,
    this.jackpotAmount = 9008646,
  });

  @override
  State<MegaJackpotDialog> createState() => _MegaJackpotDialogState();
}

class _MegaJackpotDialogState extends State<MegaJackpotDialog>
    with TickerProviderStateMixin {
  late AnimationController _dialogBounceController;
  late AnimationController _glowController;
  late AnimationController _flipController;
  late AnimationController _blinkController;
  
  late Animation<double> _dialogBounceAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _flipAnimation;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    
    // Dialog bounce animation
    _dialogBounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _dialogBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _dialogBounceController,
      curve: Curves.elasticOut,
    ));

    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Amount flip animation
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    // Blinking dot animation
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    // Dialog bounce every 3 seconds
    _dialogBounceController.repeat(period: const Duration(seconds: 3));
    
    // Glow animation
    _glowController.repeat(reverse: true);
    
    // Flip animation every 2 seconds
    _flipController.repeat(period: const Duration(seconds: 2));
    
    // Blinking animation
    _blinkController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _dialogBounceController.dispose();
    _glowController.dispose();
    _flipController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _dialogBounceAnimation,
          _glowAnimation,
          _flipAnimation,
          _blinkAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _dialogBounceAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  // Multiple layers of yellow glow
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(_glowAnimation.value * 0.8),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(_glowAnimation.value * 0.6),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(_glowAnimation.value * 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  // Shadow for depth
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2D2D2D),
                      Color(0xFF1A1A1A),
                      Color(0xFF000000),
                      Color(0xFF3D2914), // Dark brown
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.6),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: const Color(0xFFFFD700),
                              size: 28,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.8),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'MEGA JACKPOT',
                              style: TextStyle(
                                color: const Color(0xFFFFD700),
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFFFFD700).withOpacity(0.8),
                                    blurRadius: 8,
                                  ),
                                  const Shadow(
                                    color: Colors.black,
                                    blurRadius: 2,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Big jackpot amount with flip animation
                    SizedBox(
                      height: 60,
                      child: ClipRect(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Current amount
                            Transform.translate(
                              offset: Offset(0, -60 * _flipAnimation.value),
                              child: Opacity(
                                opacity: 1.0 - _flipAnimation.value,
                                child: _buildAmountText(widget.jackpotAmount),
                              ),
                            ),
                            // Next amount (slightly higher)
                            Transform.translate(
                              offset: Offset(0, 60 - 60 * _flipAnimation.value),
                              child: Opacity(
                                opacity: _flipAnimation.value,
                                child: _buildAmountText(widget.jackpotAmount + 1000 + (math.Random().nextInt(999))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Subtext with blinking dot
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Jackpot Rising',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(_blinkAnimation.value),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(_blinkAnimation.value * 0.6),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // CTA Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFD700),
                            Color(0xFFFFA500),
                            Color(0xFFFF8C00),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () {
                            // Handle jackpot participation
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'GET TICKETS NOW',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Footer text
                    Text(
                      'Spend €10 = 1 Entry Ticket',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmountText(double amount) {
    return Text(
      '€${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
      style: TextStyle(
        color: const Color(0xFFFFD700),
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        shadows: [
          Shadow(
            color: const Color(0xFFFFD700).withOpacity(0.8),
            blurRadius: 12,
          ),
          Shadow(
            color: const Color(0xFFFFD700).withOpacity(0.6),
            blurRadius: 8,
          ),
          const Shadow(
            color: Colors.black,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
  }
}
