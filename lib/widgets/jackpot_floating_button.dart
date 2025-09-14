import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'mega_jackpot_dialog.dart';

class JackpotFloatingButton extends StatefulWidget {
  final double amount;
  final VoidCallback? onTap;

  const JackpotFloatingButton({
    super.key,
    this.amount = 9.0,
    this.onTap,
  });

  @override
  State<JackpotFloatingButton> createState() => _JackpotFloatingButtonState();
}

class _JackpotFloatingButtonState extends State<JackpotFloatingButton>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _glowController;
  late AnimationController _sparkleController;
  late AnimationController _buttonBounceController;
  
  late Animation<double> _bounceAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _buttonBounceAnimation;

  // Position state for dragging
  double _xPosition = 0.0;
  double _yPosition = 100.0; // Default bottom position

  @override
  void initState() {
    super.initState();
    
    // Initialize position based on screen size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _xPosition = screenSize.width - 160; // Default to right side
      });
    });
    
    // Flip animation for the amount
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.linear,
    ));

    // Button bounce animation
    _buttonBounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _buttonBounceController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    // Flip animation repeats every 1.5 seconds (faster)
    _bounceController.repeat(period: const Duration(milliseconds: 1500));
    
    // Glow animation repeats continuously
    _glowController.repeat(reverse: true);
    
    // Sparkle animation repeats continuously
    _sparkleController.repeat();
    
    // Button bounce animation repeats every 2.5 seconds
    _buttonBounceController.repeat(period: const Duration(milliseconds: 2500));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _glowController.dispose();
    _sparkleController.dispose();
    _buttonBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Positioned(
      left: _xPosition,
      bottom: _yPosition,
      child: Draggable(
        feedback: Material(
          color: Colors.transparent,
          child: _buildButtonContent(isDragging: true),
        ),
        childWhenDragging: Container(), // Hide original when dragging
        onDragEnd: (details) {
          setState(() {
            // Constrain position to screen bounds
            _xPosition = details.offset.dx.clamp(0.0, screenSize.width - 160);
            _yPosition = (screenSize.height - details.offset.dy).clamp(20.0, screenSize.height - 160);
          });
        },
        child: GestureDetector(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
              // Default behavior: show jackpot dialog
              showDialog(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.black.withOpacity(0.7),
                builder: (context) => MegaJackpotDialog(
                  jackpotAmount: widget.amount * 1000000, // Convert M to actual amount
                ),
              );
            }
          },
          child: _buildButtonContent(),
        ),
      ),
    );
  }

  Widget _buildButtonContent({bool isDragging = false}) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bounceAnimation,
        _glowAnimation,
        _sparkleAnimation,
        _buttonBounceAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: isDragging ? 1.1 : _buttonBounceAnimation.value, // Slightly larger when dragging
          child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    // Multiple layers of outer glow for stronger effect
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(_glowAnimation.value * 0.8),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(_glowAnimation.value * 0.6),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(_glowAnimation.value * 0.4),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                    // Inner shadow for depth
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2D2D2D),
                      Color(0xFF1A1A1A),
                      Color(0xFF000000),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Coin icon with rotation
                    Transform.rotate(
                      angle: _sparkleAnimation.value * 0.5,
                      child: const Icon(
                        Icons.monetization_on,
                        color: Color(0xFFFFD700),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // JACKPOT text
                        Text(
                          'JACKPOT',
                          style: TextStyle(
                            color: const Color(0xFFFFD700),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFFFD700).withOpacity(0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Amount with flip animation
                        SizedBox(
                          height: 20,
                          child: ClipRect(
                            child: Stack(
                              children: [
                                // Current amount
                                Transform.translate(
                                  offset: Offset(0, -20 * _bounceAnimation.value),
                                  child: Opacity(
                                    opacity: 1.0 - _bounceAnimation.value,
                                    child: Text(
                                      '€${widget.amount.toStringAsFixed(1)}M',
                                      style: TextStyle(
                                        color: const Color(0xFFFFD700),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        shadows: [
                                          Shadow(
                                            color: const Color(0xFFFFD700).withOpacity(0.8),
                                            blurRadius: 6,
                                          ),
                                          const Shadow(
                                            color: Colors.black,
                                            blurRadius: 2,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Next amount (slightly higher)
                                Transform.translate(
                                  offset: Offset(0, 20 - 20 * _bounceAnimation.value),
                                  child: Opacity(
                                    opacity: _bounceAnimation.value,
                                    child: Text(
                                      '€${(widget.amount + 0.1).toStringAsFixed(1)}M',
                                      style: TextStyle(
                                        color: const Color(0xFFFFD700),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        shadows: [
                                          Shadow(
                                            color: const Color(0xFFFFD700).withOpacity(0.8),
                                            blurRadius: 6,
                                          ),
                                          const Shadow(
                                            color: Colors.black,
                                            blurRadius: 2,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Sparkle icon with rotation and scale
                    Transform.rotate(
                      angle: _sparkleAnimation.value,
                      child: Transform.scale(
                        scale: 0.8 + (_glowAnimation.value * 0.4),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFFFD700),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              ),
            );
      },
    );
  }
}
