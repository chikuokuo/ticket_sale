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
  late Animation<double> _floatAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<double> _glowAnimation;

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

    // 移除搖擺動畫，改為簡單的數字切換
  }

  void _startFloatingAnimation() {
    _floatController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
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
      animation: _glowController,
      builder: (context, child) {
        return SizedBox(
          width: 84,
          height: 84,
          child: CustomPaint(
            painter: Dice3DPainter(
              dots: _currentDots,
              glowIntensity: _glowAnimation.value,
            ),
            size: const Size(84, 84),
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
      bottom: 100 + _position.dy,
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
          animation: Listenable.merge([_floatController, _glowController]),
          builder: (context, child) {
            final floatOffset = _isDragging ? 0.0 : _floatAnimation.value;
            final rotation = _isDragging ? 0.0 : _rotationAnimation.value;
            final shadowScale = _isDragging ? 1.0 : _shadowAnimation.value;

            // 簡化邊界計算，只考慮漂浮動畫
            final glowRadius = 8.0; // 最大光暈半徑
            final requiredPadding = floatOffset.abs() + glowRadius + 10; // 額外 10px 安全邊界
            final safePadding = math.max(25.0, requiredPadding); // 最少 25 像素邊界
            
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
                          width: 60,
                          height: 8,
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
    super.dispose();
  }
}

class Dice3DPainter extends CustomPainter {
  final int dots;
  final double glowIntensity;

  Dice3DPainter({
    required this.dots,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // 添加剪裁以防止繪製超出邊界
    canvas.clipRect(rect.inflate(2));
    
    // 確保 glowIntensity 在有效範圍內
    final safeGlowIntensity = glowIntensity.clamp(0.0, 1.0);
    
    // 繪製光暈效果（先繪製，避免覆蓋）
    _drawGlow(canvas, rect, safeGlowIntensity);
    
    // 繪製立體骰子的主體
    _drawDiceCube(canvas, rect, safeGlowIntensity);
    
    // 繪製骰子點數
    _drawDots(canvas, rect, safeGlowIntensity);
  }

  void _drawDiceCube(Canvas canvas, Rect rect, double safeGlowIntensity) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF8B4513).withValues(alpha: 0.8);

    // 增強立體效果的參數 - 更大的深度和更好的透視
    final depth = 24.0; // 大幅增加深度
    final perspectiveOffset = 22.0; // 增強透視偏移
    final sideDepth = 28.0; // 側面深度
    final mainFaceInset = 6.0; // 稍微減少內邊距讓側面更突出

    // 先繪製陰影面（背景）
    _drawShadowFaces(canvas, rect, depth, perspectiveOffset);

    // 添加左側面 - 創造更強立體效果
    _drawLeftSideFace(canvas, rect, mainFaceInset, sideDepth, paint, safeGlowIntensity);

    // 主面 (正面) - 更立體，稍微向內縮
    final mainFace = RRect.fromRectAndRadius(
      Rect.fromLTWH(mainFaceInset, mainFaceInset,
                   rect.width - mainFaceInset * 2, rect.height - mainFaceInset * 2),
      const Radius.circular(12),
    );

    // 主面漸層 - 更真實的光影效果，響應動態光源
    paint.shader = LinearGradient(
      begin: const Alignment(-0.3, -0.3), // 光源來自左上
      end: const Alignment(0.7, 0.7),
      colors: [
        Color.lerp(const Color(0xFFFFFFF8), Colors.white, safeGlowIntensity * 0.3) ?? const Color(0xFFFFFFF8), // 動態最亮點
        Color.lerp(const Color(0xFFFFFAF0), const Color(0xFFFFFFF8), safeGlowIntensity * 0.2) ?? const Color(0xFFFFFAF0), // 動態亮部
        Color.lerp(const Color(0xFFF5F5DC), const Color(0xFFFFFAF0), safeGlowIntensity * 0.15) ?? const Color(0xFFF5F5DC), // 動態中間調
        Color.lerp(const Color(0xFFE8E4D0), const Color(0xFFF0F0E8), safeGlowIntensity * 0.1) ?? const Color(0xFFE8E4D0), // 動態暗部
        const Color(0xFFD3CDB0), // 保持最暗部穩定
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    ).createShader(mainFace.outerRect);

    canvas.drawRRect(mainFace, paint);

    // 右側面 (立體效果) - 大幅增強透視和深度
    final rightFacePath = Path()
      ..moveTo(rect.width - mainFaceInset, mainFaceInset) // 主面右上角
      ..lineTo(rect.width - 2, 2) // 右面右上角 (更外側)
      ..lineTo(rect.width - 2, rect.height - sideDepth + 2) // 右面右下角 (使用側面深度)
      ..lineTo(rect.width - mainFaceInset, rect.height - mainFaceInset) // 主面右下角
      ..close();

    // 額外的右側面深度層 - 創造更強立體感
    final rightFaceDeepPath = Path()
      ..moveTo(rect.width - 1, 1) // 最外層右上角
      ..lineTo(rect.width - 1, rect.height - sideDepth + 1) // 最外層右下角
      ..lineTo(rect.width - 2, rect.height - sideDepth + 2) // 連接到內層
      ..lineTo(rect.width - 2, 2) // 連接到內層上方
      ..close();

    // 先繪製最深層的右側面
    paint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFF7A6B4A), // 最深的暗色
        const Color(0xFF6B5C3B), // 更深的陰影
        const Color(0xFF5D4E2D), // 最暗邊緣
      ],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(rect);

    canvas.drawPath(rightFaceDeepPath, paint);

    // 主要右側面漸層 - 增強立體感，響應光源變化
    paint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
         Color.lerp(const Color(0xFFD8CDB0), const Color(0xFFE3D8BD), safeGlowIntensity * 0.25) ?? const Color(0xFFD8CDB0), // 與主面接觸處更亮
         Color.lerp(const Color(0xFFC3B294), const Color(0xFFCEB8A1), safeGlowIntensity * 0.2) ?? const Color(0xFFC3B294), // 動態中等明度
         Color.lerp(const Color(0xFFAB9B78), const Color(0xFFB6A683), safeGlowIntensity * 0.15) ?? const Color(0xFFAB9B78), // 動態中等陰影
         Color.lerp(const Color(0xFF96865F), const Color(0xFFA1916A), safeGlowIntensity * 0.1) ?? const Color(0xFF96865F), // 動態較暗陰影
        const Color(0xFF8B7A5A), // 邊緣保持暗色穩定
      ],
      stops: const [0.0, 0.25, 0.5, 0.8, 1.0],
    ).createShader(rect);

    canvas.drawPath(rightFacePath, paint);

    // 頂面 (立體效果) - 大幅改善透視角度和深度
    final topFacePath = Path()
      ..moveTo(mainFaceInset, mainFaceInset) // 主面左上角
      ..lineTo(2, 2) // 頂面左上角 (更外側)
      ..lineTo(rect.width - 2, 2) // 頂面右上角 (更外側)
      ..lineTo(rect.width - mainFaceInset, mainFaceInset) // 主面右上角
      ..close();

    // 額外的頂面深度層 - 創造更強立體感
    final topFaceDeepPath = Path()
      ..moveTo(1, 1) // 最外層左上角
      ..lineTo(rect.width - 1, 1) // 最外層右上角
      ..lineTo(rect.width - 2, 2) // 連接到內層右側
      ..lineTo(2, 2) // 連接到內層左側
      ..close();

    // 先繪製最深層的頂面
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFE0E0D0), // 最亮的受光面
        const Color(0xFFD8D8C8), // 中等亮度
        const Color(0xFFD0D0C0), // 較暗的邊緣
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(rect);

    canvas.drawPath(topFaceDeepPath, paint);

    // 主要頂面漸層 - 增強受光面效果，響應光源變化
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
         Color.lerp(const Color(0xFFFFFFF8), Colors.white, safeGlowIntensity * 0.3) ?? const Color(0xFFFFFFF8), // 動態最亮受光點
         Color.lerp(const Color(0xFFF8F8F0), const Color(0xFFFFFFF8), safeGlowIntensity * 0.25) ?? const Color(0xFFF8F8F0), // 動態高亮部
         Color.lerp(const Color(0xFFF0F0E8), const Color(0xFFF8F8F0), safeGlowIntensity * 0.2) ?? const Color(0xFFF0F0E8), // 動態中等亮度
         Color.lerp(const Color(0xFFE8E8D8), const Color(0xFFF0F0E8), safeGlowIntensity * 0.15) ?? const Color(0xFFE8E8D8), // 動態接觸處
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ).createShader(rect);

    canvas.drawPath(topFacePath, paint);

    // 先繪製邊框再繪製高光
    canvas.drawPath(rightFacePath, strokePaint);
    canvas.drawPath(topFacePath, strokePaint);
    canvas.drawRRect(mainFace, strokePaint);

    // 多層內部高光效果
    _drawInnerHighlights(canvas, mainFace, safeGlowIntensity);

    // 添加邊緣銳化效果
    _drawEdgeSharpening(canvas, rect, mainFace, rightFacePath, topFacePath, safeGlowIntensity);
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
    // 多層光暈效果，營造強烈的立體感和動態光源
    final glowPaint = Paint()..style = PaintingStyle.fill;

    // 最外層光暈 - 減少範圍防止破版
    glowPaint
      ..color = Color(0xFFFFD700).withValues(alpha: safeGlowIntensity * 0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + (safeGlowIntensity * 4));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(6 + (safeGlowIntensity * 3)),
        const Radius.circular(18),
      ),
      glowPaint,
    );

    // 外層光暈 - 金色，控制範圍
    glowPaint
      ..color = Color(0xFFFFD700).withValues(alpha: safeGlowIntensity * 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + (safeGlowIntensity * 3));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(4 + (safeGlowIntensity * 2)),
        const Radius.circular(16),
      ),
      glowPaint,
    );

    // 中層光暈 - 橙金色，適中範圍
    glowPaint
      ..color = Color(0xFFFF8C00).withValues(alpha: safeGlowIntensity * 0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + (safeGlowIntensity * 2));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(3 + (safeGlowIntensity * 1.5)),
        const Radius.circular(14),
      ),
      glowPaint,
    );

    // 內層光暈 - 明亮白金色，小範圍
    glowPaint
      ..color = Color(0xFFFFFACD).withValues(alpha: safeGlowIntensity * 0.6)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + (safeGlowIntensity * 1.5));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(2 + safeGlowIntensity),
        const Radius.circular(12),
      ),
      glowPaint,
    );

    // 最內層光暈 - 純白高光，最小範圍
    glowPaint
      ..color = Colors.white.withValues(alpha: safeGlowIntensity * 0.3)
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
      ..color = Colors.white.withValues(alpha: safeGlowIntensity * 0.6)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 + (safeGlowIntensity * 0.3));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(0.5 + (safeGlowIntensity * 0.2)),
        const Radius.circular(8),
      ),
      glowPaint,
    );
  }

  void _drawDots(Canvas canvas, Rect rect, double safeGlowIntensity) {
    const dotRadius = 6.5; // 稍微增大點數
    final mainFaceRect = Rect.fromLTWH(16, 16, rect.width - 32, rect.height - 32); // 調整以配合新的內邊距

    // 深層凹陷陰影 - 模擬骰子點數是凹進去的
    final deepShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final mediumShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final lightShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    // 繪製多層陰影以營造深度凹陷感
    _drawDotsPattern(canvas, mainFaceRect, dotRadius + 2.5, deepShadowPaint, const Offset(2.5, 2.5));
    _drawDotsPattern(canvas, mainFaceRect, dotRadius + 1.8, mediumShadowPaint, const Offset(1.8, 1.8));
    _drawDotsPattern(canvas, mainFaceRect, dotRadius + 1.0, lightShadowPaint, const Offset(1.0, 1.0));

    // 繪製主點數（帶凹陷立體效果）
    _drawDotsPatternWithGradient(canvas, mainFaceRect, dotRadius);

    // 添加點數邊緣高光
    _drawDotsHighlight(canvas, mainFaceRect, dotRadius, safeGlowIntensity);
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is Dice3DPainter && 
           (oldDelegate.dots != dots || oldDelegate.glowIntensity != glowIntensity);
  }
}
