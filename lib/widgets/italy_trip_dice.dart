import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/italy_trip.dart';
import 'italy_trip_dialog.dart';

class ItalyTripDice extends StatefulWidget {
  final void Function(ItalyTrip trip)? onPick;
  final Alignment alignment;

  const ItalyTripDice({
    super.key,
    this.onPick,
    this.alignment = Alignment.bottomRight,
  });

  @override
  State<ItalyTripDice> createState() => _ItalyTripDiceState();
}

class _ItalyTripDiceState extends State<ItalyTripDice>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _sparkleController;
  late AnimationController _confettiController;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _confettiAnimation;

  bool _isRolling = false; // 改為數字切換狀態
  int _currentDots = 1;
  final List<int> _diceFaces = [1, 2, 3, 4, 5, 6];
  Offset _position = const Offset(0, 0);
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startFloatingAnimation();
  }

  void _initializeAnimations() {
    // Floating animation (2.2s cycle)
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Glow animation (3s cycle, independent)
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Sparkle animation (1.8s cycle for fast sparkles)
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));

    // Confetti animation (2.5s cycle for ribbons)
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeInOut,
    ));

    // 移除搖擺動畫，改為簡單的數字切換
  }

  void _startFloatingAnimation() {
    _floatController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    _sparkleController.repeat();
    _confettiController.repeat();
  }

  Future<void> _onDicePressed() async {
    if (_isRolling) return;

    setState(() {
      _isRolling = true;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Start dice face changing animation (原地數字切換)
    await _startDiceRolling();

    // Select random trip
    final random = math.Random();
    final selectedTrip = ItalyTrip.attractions[
        random.nextInt(ItalyTrip.attractions.length)];

    // Show result dialog
    if (mounted) {
      await showItalyTripDialog(context, selectedTrip);
      widget.onPick?.call(selectedTrip);
    }

    // Reset state
    setState(() {
      _isRolling = false;
    });
  }

  Future<void> _startDiceRolling() async {
    const rollDuration = Duration(milliseconds: 120);
    const maxRolls = 8;

    // 快速切換數字效果
    for (int i = 0; i < maxRolls; i++) {
      if (!_isRolling) break; // 如果狀態改變則停止
      
      setState(() {
        _currentDots = _diceFaces[math.Random().nextInt(_diceFaces.length)];
      });
      
      await Future.delayed(rollDuration);
    }
  }

  Widget _buildDice() {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowController, _sparkleController, _confettiController]),
      builder: (context, child) {
        return SizedBox(
          width: 64, // 從 84 縮小到 64
          height: 64,
          child: CustomPaint(
            painter: Dice3DPainter(
              dots: _currentDots,
              glowIntensity: _glowAnimation.value,
              sparkleIntensity: _sparkleAnimation.value,
              confettiIntensity: _confettiAnimation.value,
            ),
            size: const Size(64, 64), // 從 84 縮小到 64
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: widget.alignment == Alignment.bottomRight ? 20 + _position.dx : null,
      left: widget.alignment == Alignment.bottomLeft ? 20 + _position.dx : null,
      bottom: 180 + _position.dy, // 從 100 增加到 180，放在 Jackpot 按鈕上方
      child: GestureDetector(
        onPanStart: (details) {
          _isDragging = true;
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            setState(() {
              _position = Offset(
                _position.dx + details.delta.dx,
                _position.dy - details.delta.dy, // Invert Y axis
              );
            });
          }
        },
        onPanEnd: (details) {
          _isDragging = false;
        },
        onTap: _onDicePressed,
        child: AnimatedBuilder(
          animation: Listenable.merge([_floatController, _glowController, _sparkleController, _confettiController]),
          builder: (context, child) {
            final floatOffset = _isDragging ? 0.0 : _floatAnimation.value;
            final rotation = _isDragging ? 0.0 : _rotationAnimation.value;
            final shadowScale = _isDragging ? 1.0 : _shadowAnimation.value;

            // 簡化邊界計算，因為骰子變小了
            final glowRadius = 6.0; // 減小光暈半徑配合小骰子
            final requiredPadding = floatOffset.abs() + glowRadius + 8; // 減少安全邊界
            final safePadding = math.max(20.0, requiredPadding); // 最少 20 像素邊界
            
            return Container(
              // 簡化的安全邊界
              padding: EdgeInsets.all(safePadding),
              child: Transform.translate(
                offset: Offset(0, -floatOffset), // 只保留垂直漂浮
                child: Transform.rotate(
                  angle: rotation * math.pi / 180,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDice(),
                      const SizedBox(height: 4),
                      // Floating shadow
                      Transform.scale(
                        scale: shadowScale,
                        child: Container(
                          width: 48, // 從 60 縮小到 48 配合小骰子
                          height: 6, // 從 8 縮小到 6
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    _sparkleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}

class Dice3DPainter extends CustomPainter {
  final int dots;
  final double glowIntensity;
  final double sparkleIntensity;
  final double confettiIntensity;

  Dice3DPainter({
    required this.dots,
    required this.glowIntensity,
    required this.sparkleIntensity,
    required this.confettiIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // 添加剪裁以防止繪製超出邊界
    canvas.clipRect(rect.inflate(2));
    
    // 確保動畫值在有效範圍內
    final safeGlowIntensity = glowIntensity.clamp(0.0, 1.0);
    final safeSparkleIntensity = sparkleIntensity.clamp(0.0, 1.0);
    final safeConfettiIntensity = confettiIntensity.clamp(0.0, 1.0);
    
    // 繪製彩帶效果（最先繪製，在背景）
    _drawConfettiRibbons(canvas, rect, safeConfettiIntensity, safeGlowIntensity);
    
    // 繪製光暈效果（先繪製，避免覆蓋）
    _drawGlow(canvas, rect, safeGlowIntensity);
    
    // 繪製立體骰子的主體（紅色風格）
    _drawRedDiceCube(canvas, rect, safeGlowIntensity);
    
    // 繪製骰子點數（白色點數）
    _drawWhiteDots(canvas, rect, safeGlowIntensity);
    
    // 繪製閃亮效果
    _drawSparkles(canvas, rect, safeSparkleIntensity, safeGlowIntensity);
  }

  void _drawRedDiceCube(Canvas canvas, Rect rect, double safeGlowIntensity) {
    // 創建平面骰子 - 簡單的正方形，無立體效果
    final paint = Paint()..style = PaintingStyle.fill;
    
    // 主面 - 整個正方形，帶圓角
    final mainFace = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 4, rect.width - 8, rect.height - 8),
      const Radius.circular(8),
    );

    // 紅色填充 - 根據光暈強度調整亮度
    final baseRed = const Color(0xFFE53935); // 經典紅色
    final brightRed = const Color(0xFFFF5555); // 較亮的紅色
    
    paint.color = Color.lerp(baseRed, brightRed, safeGlowIntensity * 0.3) ?? baseRed;
    canvas.drawRRect(mainFace, paint);

    // 黑色邊框
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.black;

    canvas.drawRRect(mainFace, strokePaint);

    // 添加微妙的內部高光讓骰子看起來有光澤
    _drawFlatHighlight(canvas, mainFace, safeGlowIntensity);
  }

  void _drawFlatHighlight(Canvas canvas, RRect mainFace, double safeGlowIntensity) {
    // 簡單的漸層高光效果，讓平面骰子看起來有光澤
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3), // 光源來自左上
        radius: 0.8,
        colors: [
          Colors.white.withValues(alpha: 0.3 + (safeGlowIntensity * 0.2)), // 高光中心
          Colors.white.withValues(alpha: 0.1 + (safeGlowIntensity * 0.1)), // 中間過渡
          Colors.transparent, // 邊緣透明
      ],
      stops: const [0.0, 0.5, 1.0],
      ).createShader(mainFace.outerRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(mainFace.left + 2, mainFace.top + 2,
                     mainFace.width - 4, mainFace.height - 4),
        const Radius.circular(6),
      ),
      highlightPaint,
    );
  }

  void _drawShadowFaces(Canvas canvas, Rect rect, double depth, double perspectiveOffset) {
    final shadowPaint = Paint()..style = PaintingStyle.fill;

    // 右側深層陰影面 - 增強立體感
    final rightShadowPath = Path()
      ..moveTo(rect.width - 8, 8 + perspectiveOffset)
      ..lineTo(rect.width, perspectiveOffset)
      ..lineTo(rect.width, rect.height - 3)
      ..lineTo(rect.width - 8, rect.height - 8)
      ..close();

    shadowPaint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFF654321).withValues(alpha: 0.4),
        const Color(0xFF4A2C17).withValues(alpha: 0.7),
        const Color(0xFF2D1810).withValues(alpha: 0.9),
      ],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(rect);

    canvas.drawPath(rightShadowPath, shadowPaint);

    // 底部深層陰影面 - 增強立體感
    final bottomShadowPath = Path()
      ..moveTo(8 + perspectiveOffset, rect.height - 8)
      ..lineTo(perspectiveOffset, rect.height)
      ..lineTo(rect.width, rect.height)
      ..lineTo(rect.width - 8, rect.height - 8)
      ..close();

    shadowPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF654321).withValues(alpha: 0.4),
        const Color(0xFF4A2C17).withValues(alpha: 0.6),
        const Color(0xFF2D1810).withValues(alpha: 0.8),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);

    canvas.drawPath(bottomShadowPath, shadowPaint);

    // 添加深度陰影效果
    final deepShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(rightShadowPath, deepShadowPaint);
    canvas.drawPath(bottomShadowPath, deepShadowPaint);
  }

  void _drawLeftSideFace(Canvas canvas, Rect rect, double mainFaceInset, double sideDepth, Paint paint, double safeGlowIntensity) {
    // 左側面 - 創造額外的立體深度，較窄的暗色面

    // 主要左側面
    final leftFacePath = Path()
      ..moveTo(mainFaceInset, mainFaceInset) // 主面左上角
      ..lineTo(2, 2) // 左面左上角
      ..lineTo(2, rect.height - sideDepth + 2) // 左面左下角
      ..lineTo(mainFaceInset, rect.height - mainFaceInset) // 主面左下角
      ..close();

    // 額外的左側面深度層
    final leftFaceDeepPath = Path()
      ..moveTo(1, 1) // 最外層左上角
      ..lineTo(1, rect.height - sideDepth + 1) // 最外層左下角
      ..lineTo(2, rect.height - sideDepth + 2) // 連接到內層
      ..lineTo(2, 2) // 連接到內層上方
      ..close();

    // 繪製最深層的左側面 - 最暗
    paint.shader = LinearGradient(
      begin: Alignment.centerRight, // 從右側開始（背光面）
      end: Alignment.centerLeft,
      colors: [
        const Color(0xFF7A6B4A), // 與主面接觸處稍亮
        const Color(0xFF6B5C3B), // 中等暗色
        const Color(0xFF5D4E2D), // 最暗邊緣
      ],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(rect);

    canvas.drawPath(leftFaceDeepPath, paint);

    // 主要左側面 - 背光面，比右側面更暗
    paint.shader = LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
         Color.lerp(const Color(0xFFB8A889), const Color(0xFFC3B294), safeGlowIntensity * 0.1) ?? const Color(0xFFB8A889), // 與主面接觸處，受動態光影響較小
         Color.lerp(const Color(0xFFA0906D), const Color(0xFFAB9B78), safeGlowIntensity * 0.08) ?? const Color(0xFFA0906D), // 中等暗色
         Color.lerp(const Color(0xFF8B7A5A), const Color(0xFF96855F), safeGlowIntensity * 0.05) ?? const Color(0xFF8B7A5A), // 較暗
        const Color(0xFF7A6B4A), // 最暗邊緣，幾乎不受光暈影響
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ).createShader(rect);

    canvas.drawPath(leftFacePath, paint);

    // 添加左側面的邊緣高光 - 非常微妙
    final leftEdgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.1 + (safeGlowIntensity * 0.15)); // 比右側面更暗的高光

    canvas.drawPath(leftFacePath, leftEdgePaint);

    // 添加左側面的細微材質效果
    _addSideTextureEffects(canvas, rect, leftFacePath, 'left', safeGlowIntensity);
  }

  void _addSideTextureEffects(Canvas canvas, Rect rect, Path sidePath, String side, double safeGlowIntensity) {
    // 為側面添加細微的材質紋理和反射效果

    // 反射條紋效果 - 模擬象牙材質的紋理
    final texturePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    final isLeft = side == 'left';
    final textureIntensity = isLeft ? 0.08 : 0.12; // 左側面更暗，紋理更不明顯

    // 垂直紋理線
    for (int i = 0; i < 3; i++) {
      final opacity = (0.1 + (safeGlowIntensity * textureIntensity)) * (1 - i * 0.3);
      texturePaint.color = Colors.white.withValues(alpha: opacity);

      final xOffset = isLeft ? (2 + i * 1.5) : (rect.width - 2 - i * 1.5);
      final startY = isLeft ? 2.0 : 2.0;
      final endY = isLeft ? (rect.height - 28 + 2) : (rect.height - 28 + 2);

      canvas.drawLine(
        Offset(xOffset, startY),
        Offset(xOffset, endY),
        texturePaint,
      );
    }

    // 環境光反射 - 模擬從底部反射的光
    final reflectionPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFFFFFAF0).withValues(alpha: textureIntensity * 0.8),
          const Color(0xFFFFFAF0).withValues(alpha: textureIntensity * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(rect);

    // 為側面添加底部反射
    final reflectionPath = Path();
    if (isLeft) {
      reflectionPath
        ..moveTo(2, rect.height - 15)
        ..lineTo(6, rect.height - 10)
        ..lineTo(6, rect.height - 28 + 2)
        ..lineTo(2, rect.height - 28 + 2)
        ..close();
    } else {
      reflectionPath
        ..moveTo(rect.width - 6, rect.height - 15)
        ..lineTo(rect.width - 2, rect.height - 10)
        ..lineTo(rect.width - 2, rect.height - 28 + 2)
        ..lineTo(rect.width - 6, rect.height - 28 + 2)
        ..close();
    }

    canvas.drawPath(reflectionPath, reflectionPaint);
  }

  void _drawEdgeSharpening(Canvas canvas, Rect rect, RRect mainFace, Path rightFacePath, Path topFacePath, double safeGlowIntensity) {
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 主面邊緣高光 - 動態響應
    edgePaint.color = Colors.white.withValues(alpha: (0.4 + (safeGlowIntensity * 0.4)).clamp(0.0, 1.0));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(mainFace.left + 1, mainFace.top + 1,
                     mainFace.width - 2, mainFace.height - 2),
        const Radius.circular(11),
      ),
      edgePaint,
    );

    // 頂面邊緣高光 - 動態響應
    final topEdgePath = Path()
      ..moveTo(4, 4)
      ..lineTo(rect.width - 4, 4);

    edgePaint.color = Colors.white.withValues(alpha: (0.6 + (safeGlowIntensity * 0.3)).clamp(0.0, 1.0));
    canvas.drawPath(topEdgePath, edgePaint);

    // 右側面邊緣陰影 - 動態響應
    final rightEdgePath = Path()
      ..moveTo(rect.width - 4, 4)
      ..lineTo(rect.width - 4, rect.height - 20);

    edgePaint.color = const Color(0xFF654321).withValues(alpha: (0.6 + (safeGlowIntensity * 0.3)).clamp(0.0, 1.0));
    canvas.drawPath(rightEdgePath, edgePaint);

    // 面與面之間的分界線
    final faceDividerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0xFF8B4513).withValues(alpha: 0.6);

    // 主面與頂面的分界
    final topDividerPath = Path()
      ..moveTo(mainFace.left, mainFace.top)
      ..lineTo(mainFace.right, mainFace.top);
    canvas.drawPath(topDividerPath, faceDividerPaint);

    // 主面與右側面的分界
    final rightDividerPath = Path()
      ..moveTo(mainFace.right, mainFace.top)
      ..lineTo(mainFace.right, mainFace.bottom);
    canvas.drawPath(rightDividerPath, faceDividerPaint);
  }

  void _drawInnerHighlights(Canvas canvas, RRect mainFace, double safeGlowIntensity) {
    // 主高光 - 模擬強烈的點光源
    final primaryHighlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35), // 稍微調整位置
        radius: 0.45,
        colors: [
          Colors.white.withValues(alpha: 0.9 + (safeGlowIntensity * 0.1)), // 最亮點
          Colors.white.withValues(alpha: 0.6 + (safeGlowIntensity * 0.2)), // 中間亮度
          Colors.white.withValues(alpha: 0.2 + (safeGlowIntensity * 0.1)), // 邊緣亮度
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(mainFace.outerRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(mainFace.left + 3, mainFace.top + 3,
                     mainFace.width - 6, mainFace.height - 6),
        const Radius.circular(9),
      ),
      primaryHighlightPaint,
    );

    // 二級高光 - 更小更亮的光點
    final secondaryHighlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.6, -0.6),
        radius: 0.25,
        colors: [
          Colors.white.withValues(alpha: 1.0),
          Colors.white.withValues(alpha: 0.7),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(mainFace.outerRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(mainFace.left + 6, mainFace.top + 6,
                     mainFace.width * 0.25, mainFace.height * 0.25),
        const Radius.circular(6),
      ),
      secondaryHighlightPaint,
    );

    // 邊緣反射光 - 模擬環境光
    final ambientLightPaint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-1.0, -1.0),
        end: const Alignment(0.5, 0.5),
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(mainFace.outerRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(mainFace.left + 1, mainFace.top + 1,
                     mainFace.width * 0.4, mainFace.height * 0.4),
        const Radius.circular(7),
      ),
      ambientLightPaint,
    );

    // 底部反射光 - 模擬來自底面的反射
    final bottomReflectionPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFFFFFAF0).withValues(alpha: 0.3),
          const Color(0xFFFFFAF0).withValues(alpha: 0.1),
          const Color(0xFFFFFAF0).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(mainFace.outerRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(mainFace.left + 4, mainFace.bottom - mainFace.height * 0.3,
                     mainFace.width - 8, mainFace.height * 0.3),
        const Radius.circular(8),
      ),
      bottomReflectionPaint,
    );
  }

  void _drawGlow(Canvas canvas, Rect rect, double safeGlowIntensity) {
    // 多層白色光暈效果
    final glowPaint = Paint()..style = PaintingStyle.fill;

    // 最外層光暈 - 淡白色
    glowPaint
      ..color = Colors.white.withValues(alpha: safeGlowIntensity * 0.15)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + (safeGlowIntensity * 4));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(6 + (safeGlowIntensity * 3)),
        const Radius.circular(18),
      ),
      glowPaint,
    );

    // 外層光暈 - 中等白色
    glowPaint
      ..color = Colors.white.withValues(alpha: safeGlowIntensity * 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + (safeGlowIntensity * 3));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(4 + (safeGlowIntensity * 2)),
        const Radius.circular(16),
      ),
      glowPaint,
    );

    // 中層光暈 - 較亮白色
    glowPaint
      ..color = Colors.white.withValues(alpha: safeGlowIntensity * 0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + (safeGlowIntensity * 2));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(3 + (safeGlowIntensity * 1.5)),
        const Radius.circular(14),
      ),
      glowPaint,
    );

    // 內層光暈 - 明亮白色
    glowPaint
      ..color = Colors.white.withValues(alpha: safeGlowIntensity * 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + (safeGlowIntensity * 1.5));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(2 + safeGlowIntensity),
        const Radius.circular(12),
      ),
      glowPaint,
    );

    // 最內層光暈 - 最亮白色
    glowPaint
      ..color = Colors.white.withValues(alpha: safeGlowIntensity * 0.7)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 + safeGlowIntensity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(1 + (safeGlowIntensity * 0.5)),
        const Radius.circular(10),
      ),
      glowPaint,
    );

    // 邊緣銳化光暈 - 最細邊緣高光
    glowPaint
      ..color = Colors.white.withValues(alpha: safeGlowIntensity * 0.8)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 + (safeGlowIntensity * 0.3));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(0.5 + (safeGlowIntensity * 0.2)),
        const Radius.circular(8),
      ),
      glowPaint,
    );
  }

  void _drawWhiteDots(Canvas canvas, Rect rect, double safeGlowIntensity) {
    const dotRadius = 5.0; // 點數半徑
    final mainFaceRect = Rect.fromLTWH(12, 12, rect.width - 24, rect.height - 24); // 調整邊距

    // 白色點數畫筆
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 點數陰影畫筆 - 讓點數更立體
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    // 先繪製陰影
    _drawFlatDotsPattern(canvas, mainFaceRect, dotRadius, shadowPaint, const Offset(1, 1));
    
    // 再繪製主要的白色點數
    _drawFlatDotsPattern(canvas, mainFaceRect, dotRadius, dotPaint, Offset.zero);

    // 添加點數高光
    _drawFlatDotsHighlight(canvas, mainFaceRect, dotRadius, safeGlowIntensity);
  }

  void _drawFlatDotsPattern(Canvas canvas, Rect faceRect, double radius, Paint paint, Offset offset) {
    final center = faceRect.center + offset;
    
    switch (dots) {
      case 1:
        canvas.drawCircle(center, radius, paint);
        break;
      case 2:
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.3) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.7) + offset,
          radius,
          paint,
        );
        break;
      case 3:
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.25) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(center, radius, paint);
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.75) + offset,
          radius,
          paint,
        );
        break;
      case 4:
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.3) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.3) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.7) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.7) + offset,
          radius,
          paint,
        );
        break;
      case 5:
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.25) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.25) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(center, radius, paint);
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.75) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.75) + offset,
          radius,
          paint,
        );
        break;
      case 6:
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.25) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.25) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.5) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.5) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.75) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.75) + offset,
          radius,
          paint,
        );
        break;
    }
  }

  void _drawFlatDotsHighlight(Canvas canvas, Rect faceRect, double radius, double safeGlowIntensity) {
    // 為白色點數添加微妙的高光效果
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: (0.4 + (safeGlowIntensity * 0.3)).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final center = faceRect.center;

    // 為每個點數位置添加高光環
    switch (dots) {
      case 1:
        canvas.drawCircle(center, radius + 0.5, highlightPaint);
        break;
      case 2:
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.3), radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.7), radius + 0.5, highlightPaint);
        break;
      case 3:
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.25), radius + 0.5, highlightPaint);
        canvas.drawCircle(center, radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.75), radius + 0.5, highlightPaint);
        break;
      case 4:
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.3), radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.3), radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.7), radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.7), radius + 0.5, highlightPaint);
        break;
      case 5:
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.25), radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.25), radius + 0.5, highlightPaint);
        canvas.drawCircle(center, radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.75), radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.75), radius + 0.5, highlightPaint);
        break;
      case 6:
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.25), radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.25), radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.5), radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.5), radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.75), radius + 0.5, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.75), radius + 0.5, highlightPaint);
        break;
    }
  }

  void _drawSparkles(Canvas canvas, Rect rect, double sparkleIntensity, double glowIntensity) {
    // 創建閃亮星星效果
    final sparklePositions = [
      Offset(rect.width * 0.15, rect.height * 0.2),
      Offset(rect.width * 0.85, rect.height * 0.3),
      Offset(rect.width * 0.2, rect.height * 0.8),
      Offset(rect.width * 0.75, rect.height * 0.15),
      Offset(rect.width * 0.9, rect.height * 0.7),
      Offset(rect.width * 0.1, rect.height * 0.6),
    ];

    for (int i = 0; i < sparklePositions.length; i++) {
      // 每個星星有不同的閃爍時機
      final phase = (sparkleIntensity + (i * 0.3)) % 1.0;
      final sparkleAlpha = (math.sin(phase * math.pi * 2) * 0.5 + 0.5) * 0.8;
      
      if (sparkleAlpha > 0.2) {
        _drawSingleSparkle(canvas, sparklePositions[i], sparkleAlpha, glowIntensity);
      }
    }

    // 添加隨機閃爍的小星星
    _drawRandomSparkles(canvas, rect, sparkleIntensity, glowIntensity);
  }

  void _drawSingleSparkle(Canvas canvas, Offset position, double alpha, double glowIntensity) {
    final sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha * (0.8 + glowIntensity * 0.2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final size = 3.0 + (alpha * 2.0);
    
    // 繪製十字形星星
    canvas.drawLine(
      Offset(position.dx - size, position.dy),
      Offset(position.dx + size, position.dy),
      sparklePaint,
    );
    canvas.drawLine(
      Offset(position.dx, position.dy - size),
      Offset(position.dx, position.dy + size),
      sparklePaint,
    );
    
    // 添加對角線讓星星更亮
    final smallSize = size * 0.6;
    canvas.drawLine(
      Offset(position.dx - smallSize, position.dy - smallSize),
      Offset(position.dx + smallSize, position.dy + smallSize),
      sparklePaint,
    );
    canvas.drawLine(
      Offset(position.dx - smallSize, position.dy + smallSize),
      Offset(position.dx + smallSize, position.dy - smallSize),
      sparklePaint,
    );
  }

  void _drawRandomSparkles(Canvas canvas, Rect rect, double sparkleIntensity, double glowIntensity) {
    // 添加一些隨機位置的小閃光
    final random = math.Random(42); // 使用固定種子保持一致性
    
    for (int i = 0; i < 4; i++) {
      final x = rect.width * (0.1 + random.nextDouble() * 0.8);
      final y = rect.height * (0.1 + random.nextDouble() * 0.8);
      
      // 每個小閃光有不同的閃爍頻率
      final phase = (sparkleIntensity * (2.0 + i * 0.5)) % 1.0;
      final alpha = (math.sin(phase * math.pi * 4) * 0.5 + 0.5) * 0.4;
      
      if (alpha > 0.1) {
        final sparklePoint = Paint()
          ..color = Colors.white.withValues(alpha: alpha * (0.6 + glowIntensity * 0.3))
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), 1.0 + alpha, sparklePoint);
      }
    }
  }

  void _drawDotsPatternWithGradient(Canvas canvas, Rect faceRect, double radius) {
    final center = faceRect.center;

    switch (dots) {
      case 1:
        _drawSingleDot(canvas, center, radius);
        break;
      case 2:
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.3), radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.7), radius);
        break;
      case 3:
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.25), radius);
        _drawSingleDot(canvas, center, radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.75), radius);
        break;
      case 4:
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.3), radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.3), radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.7), radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.7), radius);
        break;
      case 5:
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.25), radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.25), radius);
        _drawSingleDot(canvas, center, radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.75), radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.75), radius);
        break;
      case 6:
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.25), radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.25), radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.5), radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.5), radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.75), radius);
        _drawSingleDot(canvas, Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.75), radius);
        break;
    }
  }

  void _drawSingleDot(Canvas canvas, Offset center, double radius) {
    // 凹陷基底 - 模擬深度凹陷的暗色底部
    final basePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, 0.3), // 光源來自左上，所以陰影在右下
        radius: 1.2,
        colors: [
          const Color(0xFF2D1810), // 最深的凹陷中心
          const Color(0xFF3D2418), // 中等深度
          const Color(0xFF4A2C17), // 較淺的邊緣
          const Color(0xFF5D3520), // 與面材質混合
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.1));

    canvas.drawCircle(center, radius, basePaint);

    // 內圈凹陷效果
    final innerPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.2), // 受光部分
        radius: 0.8,
        colors: [
          const Color(0xFF654321), // 受光的較亮部分
          const Color(0xFF4A2C17), // 中間過渡
          const Color(0xFF2D1810), // 最深的凹陷
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.8));

    canvas.drawCircle(center, radius * 0.85, innerPaint);

    // 凹陷邊緣高光 - 模擬邊緣受光反射
    final edgeHighlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.6, -0.6),
        radius: 0.4,
        colors: [
          const Color(0xFFA0522D).withValues(alpha: 0.8), // 明亮的邊緣
          const Color(0xFF8B4513).withValues(alpha: 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center + Offset(-radius * 0.3, -radius * 0.3), radius * 0.5, edgeHighlightPaint);
  }

  void _drawDotsHighlight(Canvas canvas, Rect faceRect, double radius, double safeGlowIntensity) {
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: (0.2 + (safeGlowIntensity * 0.3)).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = (0.6 + (safeGlowIntensity * 0.4)).clamp(0.1, 2.0);

    final center = faceRect.center;

    // 為每個點數位置添加細微的高光環
    switch (dots) {
      case 1:
        canvas.drawCircle(center, radius * 1.1, highlightPaint);
        break;
      case 2:
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.3), radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.7), radius * 1.1, highlightPaint);
        break;
      case 3:
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.25), radius * 1.1, highlightPaint);
        canvas.drawCircle(center, radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.75), radius * 1.1, highlightPaint);
        break;
      case 4:
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.3), radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.3), radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.7), radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.7), radius * 1.1, highlightPaint);
        break;
      case 5:
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.25), radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.25), radius * 1.1, highlightPaint);
        canvas.drawCircle(center, radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.75), radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.75), radius * 1.1, highlightPaint);
        break;
      case 6:
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.25), radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.25), radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.5), radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.5), radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.75), radius * 1.1, highlightPaint);
        canvas.drawCircle(Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.75), radius * 1.1, highlightPaint);
        break;
    }
  }

  void _drawDotsPattern(Canvas canvas, Rect faceRect, double radius, Paint paint, Offset offset) {
    final center = faceRect.center + offset;
    
    switch (dots) {
      case 1:
        canvas.drawCircle(center, radius, paint);
        break;
      case 2:
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.3) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.7) + offset,
          radius,
          paint,
        );
        break;
      case 3:
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.25) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(center, radius, paint);
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.75) + offset,
          radius,
          paint,
        );
        break;
      case 4:
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.3) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.3) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.7) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.7) + offset,
          radius,
          paint,
        );
        break;
      case 5:
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.25) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.25) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(center, radius, paint);
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.25, faceRect.top + faceRect.height * 0.75) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.75, faceRect.top + faceRect.height * 0.75) + offset,
          radius,
          paint,
        );
        break;
      case 6:
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.25) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.25) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.5) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.5) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.3, faceRect.top + faceRect.height * 0.75) + offset,
          radius,
          paint,
        );
        canvas.drawCircle(
          Offset(faceRect.left + faceRect.width * 0.7, faceRect.top + faceRect.height * 0.75) + offset,
          radius,
          paint,
        );
        break;
    }
  }

  void _drawConfettiRibbons(Canvas canvas, Rect rect, double confettiIntensity, double glowIntensity) {
    // 創建彩色彩帶效果，圍繞骰子飄舞 - 使用更鮮豔的顏色
    final ribbonColors = [
      const Color(0xFFFF0040), // 鮮紅色
      const Color(0xFF0080FF), // 亮藍色
      const Color(0xFF00FF40), // 亮綠色
      const Color(0xFFFFD700), // 金黃色
      const Color(0xFF8000FF), // 紫色
      const Color(0xFFFF8000), // 橙色
      const Color(0xFFFF0080), // 粉紅色
      const Color(0xFF00FFFF), // 青色
    ];

    // 定義彩帶的基本位置和參數
    final centerX = rect.width / 2;
    final centerY = rect.height / 2;
    final radius = rect.width * 0.8; // 彩帶環繞半徑

    for (int i = 0; i < ribbonColors.length; i++) {
      // 每條彩帶有不同的角度和動畫偏移
      final baseAngle = (i * math.pi * 2 / ribbonColors.length);
      final animatedAngle = baseAngle + (confettiIntensity * math.pi * 4); // 旋轉動畫
      
      // 彩帶的波動效果
      final waveOffset = math.sin(confettiIntensity * math.pi * 6 + i) * 8;
      final currentRadius = radius + waveOffset;
      
      // 計算彩帶位置
      final startX = centerX + math.cos(animatedAngle) * currentRadius * 0.6;
      final startY = centerY + math.sin(animatedAngle) * currentRadius * 0.6;
      final endX = centerX + math.cos(animatedAngle) * currentRadius;
      final endY = centerY + math.sin(animatedAngle) * currentRadius;
      
      // 彩帶透明度動畫 - 增加基礎透明度和變化範圍
      final alpha = (0.6 + math.sin(confettiIntensity * math.pi * 3 + i) * 0.3).clamp(0.4, 1.0);
      
      _drawSingleRibbon(canvas, 
        Offset(startX, startY), 
        Offset(endX, endY), 
        ribbonColors[i].withValues(alpha: alpha * (0.9 + glowIntensity * 0.1)),
        confettiIntensity,
        i
      );
    }

    // 添加一些較小的彩帶片段
    _drawSmallConfettiPieces(canvas, rect, confettiIntensity, glowIntensity);
  }

  void _drawSingleRibbon(Canvas canvas, Offset start, Offset end, Color color, double intensity, int index) {
    final ribbonPaint = Paint()
      ..color = color
      ..strokeWidth = 5.0 + (intensity * 3.0)  // 增加基礎粗細
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 創建彎曲的彩帶路徑
    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    // 添加曲線讓彩帶看起來更自然
    final midX = (start.dx + end.dx) / 2;
    final midY = (start.dy + end.dy) / 2;
    final curveOffset = math.sin(intensity * math.pi * 4 + index) * 15;
    
    final controlPoint1 = Offset(
      midX + curveOffset, 
      midY - curveOffset
    );
    final controlPoint2 = Offset(
      midX - curveOffset, 
      midY + curveOffset
    );
    
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      end.dx, end.dy
    );
    
    canvas.drawPath(path, ribbonPaint);

    // 添加彩帶高光效果 - 增強高光
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7 * intensity)
      ..strokeWidth = 2.0 + intensity
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    canvas.drawPath(path, highlightPaint);

    // 添加彩帶陰影效果，增加深度
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3 * intensity)
      ..strokeWidth = ribbonPaint.strokeWidth + 1.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    // 稍微偏移繪製陰影
    final shadowPath = Path();
    shadowPath.moveTo(start.dx + 1, start.dy + 1);
    
    final shadowMidX = (start.dx + end.dx) / 2;
    final shadowMidY = (start.dy + end.dy) / 2;
    final shadowCurveOffset = math.sin(intensity * math.pi * 4 + index) * 15;
    
    final shadowControlPoint1 = Offset(
      shadowMidX + shadowCurveOffset + 1, 
      shadowMidY - shadowCurveOffset + 1
    );
    final shadowControlPoint2 = Offset(
      shadowMidX - shadowCurveOffset + 1, 
      shadowMidY + shadowCurveOffset + 1
    );
    
    shadowPath.cubicTo(
      shadowControlPoint1.dx, shadowControlPoint1.dy,
      shadowControlPoint2.dx, shadowControlPoint2.dy,
      end.dx + 1, end.dy + 1
    );
    
    canvas.drawPath(shadowPath, shadowPaint);
  }

  void _drawSmallConfettiPieces(Canvas canvas, Rect rect, double intensity, double glowIntensity) {
    final confettiColors = [
      const Color(0xFFFF0040), // 鮮紅色
      const Color(0xFF0080FF), // 亮藍色
      const Color(0xFF00FF40), // 亮綠色
      const Color(0xFFFFD700), // 金黃色
      const Color(0xFF8000FF), // 紫色
      const Color(0xFFFF8000), // 橙色
    ];

    final random = math.Random(123); // 固定種子保持一致性
    
    for (int i = 0; i < 12; i++) {
      // 隨機位置，但圍繞骰子中心
      final angle = random.nextDouble() * math.pi * 2;
      final distance = (rect.width * 0.4) + (random.nextDouble() * rect.width * 0.3);
      final animatedDistance = distance + (math.sin(intensity * math.pi * 3 + i) * 10);
      
      final x = rect.width / 2 + math.cos(angle + intensity * math.pi * 2) * animatedDistance;
      final y = rect.height / 2 + math.sin(angle + intensity * math.pi * 2) * animatedDistance;
      
      // 彩色碎片的透明度動畫 - 增加透明度
      final alpha = (math.sin(intensity * math.pi * 5 + i) * 0.4 + 0.6).clamp(0.3, 1.0);
      
      final confettiPaint = Paint()
        ..color = confettiColors[i % confettiColors.length].withValues(alpha: alpha * (0.8 + glowIntensity * 0.2))
        ..style = PaintingStyle.fill;
      
      // 繪製小矩形彩紙片 - 增加大小
      final size = 3.0 + (intensity * 4.0);
      final confettiRect = Rect.fromCenter(
        center: Offset(x, y),
        width: size,
        height: size * 1.5,
      );
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(intensity * math.pi * 4 + i);
      canvas.translate(-x, -y);
      
      // 繪製彩紙片
      canvas.drawRect(confettiRect, confettiPaint);
      
      // 添加彩紙片邊框讓它更明顯
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      
      canvas.drawRect(confettiRect, borderPaint);
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is Dice3DPainter && 
           (oldDelegate.dots != dots || 
            oldDelegate.glowIntensity != glowIntensity ||
            oldDelegate.sparkleIntensity != sparkleIntensity ||
            oldDelegate.confettiIntensity != confettiIntensity);
  }
}
