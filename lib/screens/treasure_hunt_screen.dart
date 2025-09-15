import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

class TreasureHuntScreen extends StatefulWidget {
  const TreasureHuntScreen({super.key});

  @override
  State<TreasureHuntScreen> createState() => _TreasureHuntScreenState();
}

class _TreasureHuntScreenState extends State<TreasureHuntScreen>
    with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonScale;
  
  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  void _onTreasurePressed(String treasureId) {
    HapticFeedback.lightImpact();
    // Handle treasure tap
    print('Treasure tapped: $treasureId');
  }

  void _onExplorePressed() {
    _buttonController.forward().then((_) {
      _buttonController.reverse();
    });
    HapticFeedback.mediumImpact();
    // Handle explore button tap
    print('Explore new treasure map');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5A2E17), // 深棕色
              Color(0xFF8B4513), // 橘棕色
            ],
          ),
          // 添加歐洲地圖紋理效果 (使用程序化生成的紋理)
          // 注意：可以替換為實際的地圖圖片資源
        ),
        child: Stack(
          children: [
            // 背景歐洲地圖紋理
            CustomPaint(
              size: Size.infinite,
              painter: BackgroundMapPainter(),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 32 : 20),
                child: Column(
                  children: [
                    // 標題區域
                    _buildHeader(l10n),
                    const SizedBox(height: 24),
                    
                    // 資訊卡片區域
                    _buildInfoCards(l10n),
                    const SizedBox(height: 32),
                    
                    // 地圖區域
                    _buildTreasureMap(),
                    const SizedBox(height: 32),
                    
                    // 底部按鈕
                    _buildExploreButton(l10n),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Column(
      children: [
        // 主標題
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              color: const Color(0xFFFFD700),
              size: isTablet ? 32 : 28,
            ),
            SizedBox(width: isTablet ? 16 : 8),
            Flexible(
              child: Text(
                l10n.europeanTreasureHunt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 28 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                  shadows: const [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: isTablet ? 16 : 8),
            Icon(
              Icons.flash_on,
              color: const Color(0xFFFFD700),
              size: isTablet ? 32 : 28,
            ),
          ],
        ),
        SizedBox(height: isTablet ? 20 : 16),
        
        // 副標題
        Container(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
          child: Text(
            l10n.treasureHuntDescription,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTablet ? 18 : 14,
              color: const Color(0xFFFFE4B5),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final cardHeight = isTablet ? 120.0 : 100.0;
    
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: cardHeight,
            child: _buildInfoCard('2', l10n.digCount),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: cardHeight,
            child: _buildInfoCard('2', l10n.treasuresFound),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: cardHeight,
            child: _buildInfoCard('0', l10n.discovered),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String number, String label) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 20 : 16, 
        horizontal: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 2,
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: isTablet ? 36 : 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 8 : 4),
          Flexible(
            flex: 1,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 11,
                  color: const Color(0xFFFFE4B5),
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreasureMap() {
    final screenWidth = MediaQuery.of(context).size.width;
    final mapHeight = screenWidth > 600 ? 450.0 : 320.0; // 手機上降低高度避免破版
    
    return Container(
      width: double.infinity,
      height: mapHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            // 地圖背景
            Container(
              decoration: BoxDecoration(
                // 使用真實的歐洲古地圖作為背景
                image: DecorationImage(
                  image: AssetImage('assets/images/europeanBackground (1).jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color(0xFF8B4513).withOpacity(0.2), // 添加溫暖的棕色調
                    BlendMode.overlay,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // 在地圖上添加一層漸層來增強可讀性
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF5A2E17).withOpacity(0.1), // 半透明深棕色
                          Colors.transparent,
                          Colors.transparent,
                          Color(0xFF5A2E17).withOpacity(0.1), // 底部稍微加深
                        ],
                        stops: [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // 裝飾元素 - 更多海洋和探險主題
                  Positioned(
                    top: 20,
                    left: 30,
                    child: Icon(
                      Icons.sailing,
                      color: const Color(0xFF8B4513).withOpacity(0.3),
                      size: 24,
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 40,
                    child: Icon(
                      Icons.anchor,
                      color: const Color(0xFF8B4513).withOpacity(0.3),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    top: 60,
                    right: 20,
                    child: Transform.rotate(
                      angle: 0.3,
                      child: Icon(
                        Icons.navigation,
                        color: const Color(0xFF8B4513).withOpacity(0.4),
                        size: 28,
                      ),
                    ),
                  ),
                  // 更多裝飾元素
                  Positioned(
                    top: 40,
                    left: 60,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.directions_boat,
                        color: const Color(0xFF4682B4).withOpacity(0.3),
                        size: 18,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 20,
                    child: Icon(
                      Icons.explore,
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 60,
                    child: Transform.rotate(
                      angle: 0.8,
                      child: Text(
                        '⚓',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF8B4513).withOpacity(0.25),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Text(
                      '🧭',
                      style: TextStyle(
                        fontSize: 20,
                        color: const Color(0xFF8B4513).withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 寶藏標記
            ..._buildTreasureMarkers(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTreasureMarkers() {
    final screenWidth = MediaQuery.of(context).size.width;
    final mapHeight = screenWidth > 600 ? 450.0 : 320.0; // 與地圖高度一致
    final mapWidth = screenWidth - 40; // 減去 padding
    
    // 根據歐洲實際城市位置調整寶藏座標
    final treasures = [
      TreasureData('paris_treasure', '🏆', 0.25, 0.48, 0),        // 巴黎 - 法國
      TreasureData('london_treasure', '👑', 0.15, 0.35, 300),    // 倫敦 - 英國
      TreasureData('rome_treasure', '🏆', 0.40, 0.70, 600),      // 羅馬 - 義大利
      TreasureData('barcelona_treasure', '📜', 0.18, 0.75, 900), // 巴塞隆納 - 西班牙
      TreasureData('amsterdam_treasure', '💰', 0.32, 0.38, 1200), // 阿姆斯特丹 - 荷蘭
      TreasureData('berlin_treasure', '💎', 0.42, 0.42, 1500),   // 柏林 - 德國
      TreasureData('zurich_treasure', '⏳', 0.35, 0.52, 1800),   // 蘇黎世 - 瑞士
      TreasureData('athens_treasure', '🗝️', 0.65, 0.78, 2100),  // 雅典 - 希臘
    ];

    return treasures.map((treasure) {
      return Positioned(
        left: treasure.x * (mapWidth - 60), // 調整根據實際容器寬度，減去寶藏圖標寬度
        top: treasure.y * (mapHeight - 60), // 調整根據實際容器高度，減去寶藏圖標高度
        child: TreasureMarker(
          treasureId: treasure.id,
          icon: treasure.icon,
          delay: treasure.delay,
          onTap: _onTreasurePressed,
        ),
      );
    }).toList();
  }

  Widget _buildExploreButton(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return AnimatedBuilder(
      animation: _buttonScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScale.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF8C00), // 深橘色
                  Color(0xFFFFD700), // 金色
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _onExplorePressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Flexible(
                      child: Text(
                        l10n.exploreNewTreasureMap,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          shadows: const [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    const Icon(
                      Icons.flash_on,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TreasureData {
  final String id;
  final String icon;
  final double x;
  final double y;
  final int delay;

  TreasureData(this.id, this.icon, this.x, this.y, this.delay);
}

class TreasureMarker extends StatefulWidget {
  final String treasureId;
  final String icon;
  final int delay;
  final Function(String) onTap;

  const TreasureMarker({
    super.key,
    required this.treasureId,
    required this.icon,
    required this.delay,
    required this.onTap,
  });

  @override
  State<TreasureMarker> createState() => _TreasureMarkerState();
}

class _TreasureMarkerState extends State<TreasureMarker>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _tapController;
  late Animation<double> _radarScale;
  late Animation<double> _radarOpacity;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    
    // 雷達脈衝動畫
    _radarController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _radarScale = Tween<double>(begin: 0.6, end: 1.8).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeOut),
    );
    
    _radarOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeOut),
    );

    // 點擊動畫
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _tapScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );

    // 延遲啟動雷達動畫
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _radarController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) {
      _tapController.reverse();
    });
    widget.onTap(widget.treasureId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_radarController, _tapController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 雷達脈衝效果
              ...List.generate(3, (index) {
                final delay = index * 0.3;
                return Transform.scale(
                  scale: _radarScale.value - delay,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(
                          (_radarOpacity.value - delay * 0.2).clamp(0.0, 1.0),
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),
              
              // 寶藏圖標
              Transform.scale(
                scale: _tapScale.value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFF8C00),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                      const BoxShadow(
                        color: Colors.black38,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.icon,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class EuropeMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final landPaint = Paint()
      ..color = const Color(0xFFDEB887).withOpacity(0.4) // 更明顯的陸地顏色
      ..style = PaintingStyle.fill;
    
    final coastlinePaint = Paint()
      ..color = const Color(0xFF8B4513).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;


    final width = size.width;
    final height = size.height;
    
    // 繪製更詳細的歐洲地圖
    _drawBritishIsles(canvas, width, height, landPaint, coastlinePaint);
    _drawFrance(canvas, width, height, landPaint, coastlinePaint);
    _drawSpain(canvas, width, height, landPaint, coastlinePaint);
    _drawItaly(canvas, width, height, landPaint, coastlinePaint);
    _drawGermany(canvas, width, height, landPaint, coastlinePaint);
    _drawScandinavia(canvas, width, height, landPaint, coastlinePaint);
    _drawEasternEurope(canvas, width, height, landPaint, coastlinePaint);
    _drawMediterraneanIslands(canvas, width, height, landPaint, coastlinePaint);
    
    // 添加一些裝飾性的海洋路線
    _drawSeaRoutes(canvas, width, height);
  }

  void _drawBritishIsles(Canvas canvas, double width, double height, Paint landPaint, Paint coastlinePaint) {
    final path = Path();
    // 英國主島
    path.moveTo(width * 0.12, height * 0.25);
    path.quadraticBezierTo(width * 0.08, height * 0.28, width * 0.09, height * 0.35);
    path.quadraticBezierTo(width * 0.11, height * 0.42, width * 0.15, height * 0.45);
    path.quadraticBezierTo(width * 0.18, height * 0.48, width * 0.20, height * 0.44);
    path.quadraticBezierTo(width * 0.22, height * 0.35, width * 0.19, height * 0.28);
    path.quadraticBezierTo(width * 0.16, height * 0.22, width * 0.12, height * 0.25);
    path.close();
    
    // 愛爾蘭
    final ireland = Path();
    ireland.addOval(Rect.fromCenter(
      center: Offset(width * 0.06, height * 0.35),
      width: width * 0.04,
      height: height * 0.08,
    ));
    
    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, coastlinePaint);
    canvas.drawPath(ireland, landPaint);
    canvas.drawPath(ireland, coastlinePaint);
  }

  void _drawFrance(Canvas canvas, double width, double height, Paint landPaint, Paint coastlinePaint) {
    final path = Path();
    path.moveTo(width * 0.20, height * 0.42);
    path.quadraticBezierTo(width * 0.18, height * 0.52, width * 0.16, height * 0.62);
    path.quadraticBezierTo(width * 0.20, height * 0.68, width * 0.28, height * 0.70);
    path.quadraticBezierTo(width * 0.32, height * 0.65, width * 0.35, height * 0.58);
    path.quadraticBezierTo(width * 0.38, height * 0.50, width * 0.35, height * 0.45);
    path.quadraticBezierTo(width * 0.28, height * 0.40, width * 0.20, height * 0.42);
    path.close();
    
    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, coastlinePaint);
  }

  void _drawSpain(Canvas canvas, double width, double height, Paint landPaint, Paint coastlinePaint) {
    final path = Path();
    path.moveTo(width * 0.08, height * 0.62);
    path.quadraticBezierTo(width * 0.05, height * 0.70, width * 0.08, height * 0.78);
    path.quadraticBezierTo(width * 0.15, height * 0.82, width * 0.25, height * 0.80);
    path.quadraticBezierTo(width * 0.30, height * 0.75, width * 0.28, height * 0.68);
    path.quadraticBezierTo(width * 0.20, height * 0.62, width * 0.08, height * 0.62);
    path.close();
    
    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, coastlinePaint);
  }

  void _drawItaly(Canvas canvas, double width, double height, Paint landPaint, Paint coastlinePaint) {
    final path = Path();
    // 義大利靴子形狀
    path.moveTo(width * 0.38, height * 0.55);
    path.quadraticBezierTo(width * 0.35, height * 0.65, width * 0.37, height * 0.75);
    path.quadraticBezierTo(width * 0.39, height * 0.82, width * 0.42, height * 0.85);
    path.quadraticBezierTo(width * 0.45, height * 0.82, width * 0.44, height * 0.75);
    path.quadraticBezierTo(width * 0.42, height * 0.65, width * 0.40, height * 0.58);
    path.quadraticBezierTo(width * 0.39, height * 0.55, width * 0.38, height * 0.55);
    path.close();
    
    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, coastlinePaint);
  }

  void _drawGermany(Canvas canvas, double width, double height, Paint landPaint, Paint coastlinePaint) {
    final path = Path();
    path.moveTo(width * 0.32, height * 0.35);
    path.quadraticBezierTo(width * 0.28, height * 0.40, width * 0.30, height * 0.50);
    path.quadraticBezierTo(width * 0.35, height * 0.52, width * 0.42, height * 0.50);
    path.quadraticBezierTo(width * 0.48, height * 0.45, width * 0.50, height * 0.38);
    path.quadraticBezierTo(width * 0.45, height * 0.32, width * 0.38, height * 0.30);
    path.quadraticBezierTo(width * 0.35, height * 0.32, width * 0.32, height * 0.35);
    path.close();
    
    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, coastlinePaint);
  }

  void _drawScandinavia(Canvas canvas, double width, double height, Paint landPaint, Paint coastlinePaint) {
    final path = Path();
    // 斯堪的納維亞半島
    path.moveTo(width * 0.40, height * 0.08);
    path.quadraticBezierTo(width * 0.35, height * 0.15, width * 0.38, height * 0.25);
    path.quadraticBezierTo(width * 0.42, height * 0.30, width * 0.48, height * 0.28);
    path.quadraticBezierTo(width * 0.55, height * 0.25, width * 0.58, height * 0.18);
    path.quadraticBezierTo(width * 0.60, height * 0.10, width * 0.55, height * 0.05);
    path.quadraticBezierTo(width * 0.48, height * 0.03, width * 0.40, height * 0.08);
    path.close();
    
    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, coastlinePaint);
  }

  void _drawEasternEurope(Canvas canvas, double width, double height, Paint landPaint, Paint coastlinePaint) {
    final path = Path();
    path.moveTo(width * 0.52, height * 0.30);
    path.quadraticBezierTo(width * 0.48, height * 0.40, width * 0.50, height * 0.55);
    path.quadraticBezierTo(width * 0.55, height * 0.65, width * 0.65, height * 0.68);
    path.quadraticBezierTo(width * 0.75, height * 0.65, width * 0.80, height * 0.55);
    path.quadraticBezierTo(width * 0.78, height * 0.40, width * 0.75, height * 0.32);
    path.quadraticBezierTo(width * 0.65, height * 0.28, width * 0.52, height * 0.30);
    path.close();
    
    canvas.drawPath(path, landPaint);
    canvas.drawPath(path, coastlinePaint);
  }

  void _drawMediterraneanIslands(Canvas canvas, double width, double height, Paint landPaint, Paint coastlinePaint) {
    // 西西里島
    final sicily = Path();
    sicily.addOval(Rect.fromCenter(
      center: Offset(width * 0.42, height * 0.88),
      width: width * 0.03,
      height: height * 0.02,
    ));
    
    // 撒丁島
    final sardinia = Path();
    sardinia.addOval(Rect.fromCenter(
      center: Offset(width * 0.32, height * 0.80),
      width: width * 0.02,
      height: height * 0.04,
    ));
    
    canvas.drawPath(sicily, landPaint);
    canvas.drawPath(sicily, coastlinePaint);
    canvas.drawPath(sardinia, landPaint);
    canvas.drawPath(sardinia, coastlinePaint);
  }

  void _drawSeaRoutes(Canvas canvas, double width, double height) {
    final routePaint = Paint()
      ..color = const Color(0xFF4682B4).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    
    // 繪製幾條虛線海洋航線
    final path1 = Path();
    path1.moveTo(width * 0.15, height * 0.50);
    path1.quadraticBezierTo(width * 0.25, height * 0.45, width * 0.35, height * 0.48);
    
    final path2 = Path();
    path2.moveTo(width * 0.20, height * 0.75);
    path2.quadraticBezierTo(width * 0.30, height * 0.78, width * 0.40, height * 0.82);
    
    canvas.drawPath(path1, routePaint);
    canvas.drawPath(path2, routePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BackgroundMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // 創建背景地圖紋理
    final backgroundPaint = Paint()
      ..color = const Color(0xFF8B4513).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    
    final linePaint = Paint()
      ..color = const Color(0xFFDEB887).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 繪製大陸輪廓作為背景
    final continentPath = Path();
    
    // 簡化的歐洲大陸輪廓
    continentPath.moveTo(width * 0.05, height * 0.3);
    continentPath.quadraticBezierTo(width * 0.1, height * 0.2, width * 0.2, height * 0.25);
    continentPath.quadraticBezierTo(width * 0.4, height * 0.15, width * 0.7, height * 0.2);
    continentPath.quadraticBezierTo(width * 0.9, height * 0.3, width * 0.95, height * 0.5);
    continentPath.quadraticBezierTo(width * 0.9, height * 0.7, width * 0.7, height * 0.8);
    continentPath.quadraticBezierTo(width * 0.4, height * 0.9, width * 0.2, height * 0.85);
    continentPath.quadraticBezierTo(width * 0.1, height * 0.7, width * 0.05, height * 0.5);
    continentPath.quadraticBezierTo(width * 0.03, height * 0.4, width * 0.05, height * 0.3);
    continentPath.close();
    
    canvas.drawPath(continentPath, backgroundPaint);
    
    // 添加一些裝飾性的經緯線
    for (int i = 1; i < 4; i++) {
      // 緯線
      final latPath = Path();
      latPath.moveTo(0, height * (0.2 + i * 0.2));
      latPath.quadraticBezierTo(
        width * 0.5, height * (0.15 + i * 0.2), 
        width, height * (0.2 + i * 0.2)
      );
      canvas.drawPath(latPath, linePaint);
      
      // 經線
      final lonPath = Path();
      lonPath.moveTo(width * (0.2 + i * 0.2), 0);
      lonPath.quadraticBezierTo(
        width * (0.25 + i * 0.2), height * 0.5,
        width * (0.2 + i * 0.2), height
      );
      canvas.drawPath(lonPath, linePaint);
    }
    
    // 添加一些裝飾性的島嶼點
    final islandPaint = Paint()
      ..color = const Color(0xFFDEB887).withOpacity(0.1)
      ..style = PaintingStyle.fill;
      
    // 小島嶼
    canvas.drawCircle(Offset(width * 0.15, height * 0.4), 3, islandPaint);
    canvas.drawCircle(Offset(width * 0.75, height * 0.6), 2, islandPaint);
    canvas.drawCircle(Offset(width * 0.6, height * 0.8), 2.5, islandPaint);
    canvas.drawCircle(Offset(width * 0.3, height * 0.9), 2, islandPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RadarPing extends StatefulWidget {
  final Widget child;
  final int delay;

  const RadarPing({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  State<RadarPing> createState() => _RadarPingState();
}

class _RadarPingState extends State<RadarPing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _scale = Tween<double>(begin: 0.6, end: 1.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _opacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(_opacity.value),
                    width: 2,
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}
