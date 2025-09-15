import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'dart:math' as math;
import 'dart:async';

enum DigResult {
  success,
  cancelled,
}

class DigProgressResult {
  final DigResult result;
  final String treasureId;
  
  DigProgressResult({required this.result, required this.treasureId});
}

class DigProgressOverlay extends StatefulWidget {
  final String treasureId;
  final Duration duration;
  final Function(DigProgressResult)? onComplete;

  const DigProgressOverlay({
    super.key,
    required this.treasureId,
    this.duration = const Duration(seconds: 4),
    this.onComplete,
  });

  @override
  State<DigProgressOverlay> createState() => _DigProgressOverlayState();
}

class _DigProgressOverlayState extends State<DigProgressOverlay>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _cardController;
  late AnimationController _successController;
  late AnimationController _particleController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _successScaleAnimation;
  
  bool _isDigging = true;
  bool _isSuccess = false;
  late Duration _remainingDuration;
  
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _remainingDuration = widget.duration;
    _initializeAnimations();
    _startDigging();
  }

  void _initializeAnimations() {
    // 進度動畫
    _progressController = AnimationController(
      duration: _remainingDuration,
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // 卡片出現動畫
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );

    // 成功狀態動畫
    _successController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _successScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeOut),
    );

    // 粒子動畫
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isDigging) {
        _onDigComplete();
      }
    });
  }

  void _startDigging() {
    _cardController.forward();
    _progressController.forward();
    HapticFeedback.lightImpact();
  }

  void _onDigComplete() {
    setState(() {
      _isDigging = false;
      _isSuccess = true;
    });
    
    _generateParticles();
    _successController.forward();
    _particleController.forward();
    HapticFeedback.mediumImpact();
    
    // 1.2秒後自動關閉
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        widget.onComplete?.call(DigProgressResult(
          result: DigResult.success,
          treasureId: widget.treasureId,
        ));
      }
    });
  }

  void _generateParticles() {
    _particles.clear();
    final random = math.Random();
    
    for (int i = 0; i < 12; i++) {
      _particles.add(Particle(
        x: 0.0,
        y: 0.0,
        vx: (random.nextDouble() - 0.5) * 200,
        vy: -random.nextDouble() * 150 - 50,
        size: random.nextDouble() * 4 + 2,
        color: Color.lerp(
          const Color(0xFFFFD700),
          const Color(0xFFFF8C00),
          random.nextDouble(),
        )!,
        life: 1.0,
      ));
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    _successController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _cardController,
        _progressController,
        _successController,
        _particleController,
      ]),
      builder: (context, child) {
        return Stack(
          children: [
            // 半透明背景
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
            
            // 主卡片
            Center(
              child: Transform.scale(
                scale: _cardScaleAnimation.value * 
                       (_isSuccess ? _successScaleAnimation.value : 1.0),
                child: Opacity(
                  opacity: _cardFadeAnimation.value,
                  child: Container(
                    width: isTablet ? 320 : 280,
                    padding: EdgeInsets.all(isTablet ? 32 : 24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        const BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 標題
                        Text(
                          _isSuccess ? l10n.treasureFound : l10n.digging,
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        
                        SizedBox(height: isTablet ? 24 : 20),
                        
                        // 百分比數字
                        Text(
                          '${(_progressAnimation.value * 100).round()}%',
                          style: TextStyle(
                            fontSize: isTablet ? 48 : 42,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                            decoration: TextDecoration.none,
                            shadows: const [
                              Shadow(
                                color: Color(0xFFFF8C00),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: isTablet ? 20 : 16),
                        
                        // 進度條
                        Container(
                          height: isTablet ? 12 : 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.grey.shade800,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _progressAnimation.value,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFFD700),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: isTablet ? 32 : 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // 粒子效果
            if (_isSuccess)
              CustomPaint(
                size: screenSize,
                painter: ParticlePainter(
                  particles: _particles,
                  animation: _particleController,
                  center: Offset(screenSize.width / 2, screenSize.height / 2),
                ),
              ),
          ],
        );
      },
    );
  }

}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double life;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.life,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Animation<double> animation;
  final Offset center;

  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;
    
    final paint = Paint()..style = PaintingStyle.fill;
    final t = animation.value;
    
    for (final particle in particles) {
      final progress = t;
      final x = center.dx + particle.x + particle.vx * progress;
      final y = center.dy + particle.y + particle.vy * progress + 0.5 * 200 * progress * progress; // 重力
      
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      paint.color = particle.color.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1.0 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 顯示挖掘覆蓋層的輔助函數
Future<DigProgressResult?> showDigOverlay(
  BuildContext context, {
  required String treasureId,
  Duration duration = const Duration(seconds: 4),
}) {
  late OverlayEntry overlayEntry;
  
  final completer = Completer<DigProgressResult?>();
  
  overlayEntry = OverlayEntry(
    builder: (context) => DigProgressOverlay(
      treasureId: treasureId,
      duration: duration,
      onComplete: (result) {
        overlayEntry.remove();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      },
    ),
  );
  
  Overlay.of(context).insert(overlayEntry);
  
  return completer.future;
}
