import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

class TreasureFoundDialog extends StatefulWidget {
  final String emoji;
  final String title;
  final String category;
  final String location;
  final String userEmail;

  const TreasureFoundDialog({
    super.key,
    required this.emoji,
    required this.title,
    required this.category,
    required this.location,
    required this.userEmail,
  });

  @override
  State<TreasureFoundDialog> createState() => _TreasureFoundDialogState();
}

class _TreasureFoundDialogState extends State<TreasureFoundDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeDialog() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final dialogWidth = isTablet ? 400.0 : screenSize.width * 0.9;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // 半透明背景遮罩
            Opacity(
              opacity: _fadeAnimation.value * 0.6,
              child: Container(
                color: Colors.black,
              ),
            ),
            
            // 對話框
            Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: dialogWidth,
                    margin: EdgeInsets.symmetric(horizontal: isTablet ? 0 : 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF8B4513), // 棕色
                          Color(0xFFCD853F), // 沙棕色
                          Color(0xFFDEB887), // 淺棕色
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 3,
                          offset: const Offset(0, 8),
                        ),
                        const BoxShadow(
                          color: Colors.black38,
                          blurRadius: 15,
                          spreadRadius: 1,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 32 : 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 頂部區域：寶藏圖示和關閉按鈕
                          Row(
                            children: [
                              // 寶藏小圖示
                              Container(
                                width: isTablet ? 52 : 44,
                                height: isTablet ? 52 : 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.emoji,
                                    style: TextStyle(
                                      fontSize: isTablet ? 28 : 24,
                                      decoration: TextDecoration.none,
                                      fontFamily: null, // 使用系統默認字體以支援 emoji
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              
                              const Spacer(),
                              
                              // 關閉按鈕
                              GestureDetector(
                                onTap: _closeDialog,
                                child: Container(
                                  width: isTablet ? 40 : 36,
                                  height: isTablet ? 40 : 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white.withOpacity(0.8),
                                    size: isTablet ? 20 : 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: isTablet ? 24 : 20),
                          
                          // 標題
                          Text(
                            l10n.treasureFoundAt(widget.title),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTablet ? 24 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                              shadows: const [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: isTablet ? 12 : 8),
                          
                          // 副標題
                          Text(
                            '${widget.category} • ${widget.location}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: Colors.white.withOpacity(0.7),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          
                          SizedBox(height: isTablet ? 32 : 24),
                          
                          // 寶藏 Emoji 大圖示
                          Container(
                            width: isTablet ? 160 : 120,
                            height: isTablet ? 160 : 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFFD700),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.emoji,
                                style: TextStyle(
                                  fontSize: isTablet ? 80 : 60,
                                  decoration: TextDecoration.none,
                                  fontFamily: null, // 使用系統默認字體以支援 emoji
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isTablet ? 32 : 24),
                          
                          // 重點文字區塊
                          Container(
                            padding: EdgeInsets.all(isTablet ? 20 : 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              l10n.treasureEmailSent(widget.title, widget.userEmail),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                                height: 1.4,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isTablet ? 32 : 24),
                          
                          // 完成按鈕
                          SizedBox(
                            width: double.infinity,
                            height: isTablet ? 56 : 48,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF8C00), // 深橘色
                                    Color(0xFFFFD700), // 金色
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: _closeDialog,
                                  child: Center(
                                    child: Text(
                                      l10n.gotIt,
                                      style: TextStyle(
                                        fontSize: isTablet ? 18 : 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        decoration: TextDecoration.none,
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
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// 顯示寶藏發現對話框的輔助函數
Future<void> showTreasureFoundDialog(
  BuildContext context, {
  required String emoji,
  required String title,
  required String category,
  required String location,
  required String userEmail,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent, // 我們自己處理背景
    builder: (BuildContext context) {
      return TreasureFoundDialog(
        emoji: emoji,
        title: title,
        category: category,
        location: location,
        userEmail: userEmail,
      );
    },
  );
}
