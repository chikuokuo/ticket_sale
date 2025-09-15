# Italy Trip Dice Feature

## 概述

義大利隨機行程骰子是一個互動式 Flutter 元件，提供用戶隨機的義大利旅遊景點建議。這個元件具有精美的動畫效果和用戶友好的介面。

## 功能特色

### 🎲 立體骰子與漂浮動畫
- **立體設計**: 多層漸層背景營造 3D 立體效果
- **動態光暈**: 3 秒循環的金色光暈呼吸效果
- **漂浮動畫**: 2.2 秒循環的上下浮動（6-10px 位移）
- **微旋轉**: 微妙的 ±0.5° 旋轉動畫
- **多層陰影**: 深色主陰影 + 柔和中陰影 + 動態光暈 + 內部高光
- **真實感**: 投影隨動畫縮放，光暈強度動態變化

### 🎯 點擊互動
- 點擊後提供觸覺反饋（Haptic Feedback）
- 禁用重複點擊防止意外操作
- 700-900ms 的搖骰動畫：
  - 快速左右震動（±12px）
  - 360° 旋轉動畫
  - 縮放效果：0.92 → 1.08 → 1.0（彈性回復）
- 骰面點數在動畫期間快速變化 6-8 次

### 🎨 真正的 3D 立體設計
- **三面立體效果**: 正面 + 頂面 + 右側面，完全模擬真實骰子
- **多層漸層**: 每個面都有獨特的光影效果
- **立體點數**: 骰子點數帶有陰影，增加深度感
- **動態光暈**: 金色和橙色雙層光暈呼吸效果
- **防破版設計**: 添加安全邊界，確保動畫不會超出螢幕
- 支援深淺色主題，手機/平板自適應

### 🚀 可拖曳功能
- 用戶可以自由拖曳骰子到任何位置
- 拖曳時暫停漂浮動畫
- 位置會被記住直到下次重啟

## 檔案結構

```
lib/
├── models/
│   └── italy_trip.dart          # 義大利行程資料模型
├── widgets/
│   ├── italy_trip_dice.dart     # 主要骰子元件
│   └── italy_trip_dialog.dart   # 結果彈窗元件
└── screens/
    └── italy_dice_test_screen.dart  # 測試頁面
```

## 使用方法

### 基本用法

```dart
import '../widgets/italy_trip_dice.dart';
import '../models/italy_trip.dart';

// 在 Widget 的 build 方法中
Stack(
  children: [
    // 你的主要內容
    YourMainContent(),
    
    // 添加義大利骰子
    ItalyTripDice(
      alignment: Alignment.bottomLeft,  // 可選：bottomLeft 或 bottomRight
      onPick: (ItalyTrip trip) {
        // 當用戶選中行程時的回調
        print('Selected: ${trip.nameEn}');
      },
    ),
  ],
)
```

### 在主導航中使用

骰子已經整合到 `MainNavigationScreen` 中：
- 只在票券和套票頁面顯示（索引 0 和 1）
- 預設位置：左下角（`Alignment.bottomLeft`）
- 避免與右下角的 Jackpot 浮動按鈕重疊
- 可拖曳到任意位置

### 測試頁面

可以從設定頁面進入測試頁面來體驗完整功能：
1. 進入應用程式
2. 點擊底部導航的「設定」
3. 滾動到「Test Features」區段
4. 點擊「Italy Trip Dice」

## 行程資料

目前包含 10 個精選的義大利熱門景點：

1. 🌋 **龐貝古城** (Pompeii) - 火山灰保存的古羅馬城市
2. 🏛️ **羅馬競技場** (Colosseum) - 古羅馬標誌性競技場
3. 🛶 **威尼斯貢多拉** (Venice Gondola) - 穿梭運河與石橋
4. 🌈 **五鄉地** (Cinque Terre) - 彩色懸崖村莊與海景
5. ⛪ **米蘭主教座堂** (Duomo di Milano) - 哥德式大教堂
6. 🎨 **烏菲茲美術館** (Uffizi Gallery) - 托斯卡納文藝復興傑作
7. 🏖️ **阿瑪菲海岸** (Amalfi Coast) - 壯麗海岸線與日落
8. 🗼 **比薩斜塔** (Leaning Tower) - 最迷人的工程錯誤
9. 🟦 **藍洞** (Blue Grotto) - 卡布里島的電藍海洞
10. ⛰️ **多洛米蒂健行** (Dolomites Hike) - 鋸齒狀山峰與高山草甸

## 結果彈窗

當用戶點擊骰子後，會顯示一個精美的結果彈窗：

### 設計特色
- 深色漸層背景（#1A1A1A → #2D2D2D）
- 金色描邊和光暈效果
- 24px 圓角設計
- 彈性進入動畫
- 類似遊戲風格的豪華外觀

### 內容元素
- 🇮🇹 義大利國旗 + 景點 emoji
- 金色粗體英文名稱
- 📍 義大利紅色中文地點標記
- 半透明白色英文描述
- 🇮🇹 義大利國旗色漸層標籤
- 「Discover Italy」金色漸層按鈕
- 右上角半透明關閉按鈕

## 技術實作

### 動畫控制器
- `_floatController`: 控制漂浮動畫（2.2秒循環）
- `_shakeController`: 控制搖骰動畫（800ms）
- `_glowController`: 控制光暈呼吸動畫（3秒循環）

### 關鍵動畫
- `_floatAnimation`: 上下浮動位移
- `_rotationAnimation`: 微旋轉
- `_shakeXAnimation`: 左右震動
- `_scaleAnimation`: 縮放彈性效果
- `_shadowAnimation`: 投影縮放
- `_glowAnimation`: 動態光暈強度變化

### 3D 自訂繪製
使用全新的 `Dice3DPainter` 繪製立體骰子：
- **三面立體結構**: 使用 Path 和 RRect 繪製正面、頂面、右側面
- **多層光影效果**: 每個面都有獨特的漸層和高光
- **立體點數**: 點數帶有陰影效果，增加真實感
- **動態光暈**: 根據動畫值動態調整光暈強度和大小
- 支援 1-6 點的標準骰子布局

## 擴展性

### 添加新景點
在 `italy_trip.dart` 的 `ItalyTrip.attractions` 列表中添加新項目：

```dart
ItalyTrip(
  id: "unique_id",
  emoji: "🏛️",
  nameEn: "English Name",
  nameZh: "中文名稱",
  cityZh: "城市中文",
  cityEn: "City English",
  tag: "Italian Attractions",
  description: "English description",
),
```

### 自訂動畫參數
可以修改 `italy_trip_dice.dart` 中的動畫參數：
- 漂浮循環時間：`Duration(milliseconds: 2200)`
- 搖骰時間：`Duration(milliseconds: 800)`
- 浮動範圍：`Tween<double>(begin: 0.0, end: 8.0)`
- 旋轉角度：`Tween<double>(begin: -0.5, end: 0.5)`

## 注意事項

1. **性能優化**: 動畫使用 `AnimatedBuilder` 只重建必要的部分
2. **記憶體管理**: 所有 `AnimationController` 都在 `dispose()` 中正確釋放
3. **觸覺反饋**: 使用 `HapticFeedback.mediumImpact()` 提供觸覺回饋
4. **防重複點擊**: 使用 `_isShaking` 狀態防止動畫期間的重複點擊
5. **響應式設計**: 支援不同螢幕尺寸和方向

## 未來改進

- [ ] 添加音效支援
- [ ] 支援更多國家/地區的行程
- [ ] 添加收藏功能
- [ ] 支援自訂骰子外觀
- [ ] 添加統計功能（最常選中的景點等）
- [ ] 支援分享功能
