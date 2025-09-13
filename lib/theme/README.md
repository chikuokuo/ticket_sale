# 色彩系統指南 (Color System Guide)

這個資料夾包含了新天鵝堡售票平台的完整色彩系統和主題配置。

## 檔案結構

### `colors.dart` - 色彩系統
包含完整的 Material Design 3 色彩系統，以城堡藍為主題色彩：

- **主要色彩** (Primary): 城堡藍系列 (#1A4B84)
- **次要色彩** (Secondary): UNESCO 金色系列 (#F2C94C)
- **第三色彩** (Tertiary): 淺城堡藍系列 (#2E5B95)
- **功能色彩**: 錯誤(紅色)、成功(綠色)、警告(橘色)、資訊(藍色)
- **中性色彩**: 完整的灰階色彩系列

### `app_theme.dart` - 主題系統
包含完整的應用程式主題配置：

- 字體樣式系統
- 間距和圓角系統
- 陰影樣式
- 元件主題配置 (按鈕、卡片、輸入框等)
- 亮色和深色主題

## 如何使用

### 使用預定義色彩

```dart
// 匯入色彩系統
import 'package:your_app/theme/colors.dart';

// 使用主要色彩
Container(
  color: AppColorScheme.primary,  // 主要城堡藍
  child: Text(
    'Hello Castle',
    style: TextStyle(color: AppColorScheme.secondary), // 金色文字
  ),
)

// 使用功能色彩
Container(
  color: AppColorScheme.success,  // 成功綠色
  // 或
  color: AppColorScheme.error,    // 錯誤紅色
  color: AppColorScheme.warning,  // 警告橘色
)

// 使用不同深淺度
Container(color: AppColorScheme.getPrimaryShade(100))  // 淺藍色
Container(color: AppColorScheme.getPrimaryShade(900))  // 深藍色
```

### 使用主題樣式

```dart
// 匯入主題系統
import 'package:your_app/theme/app_theme.dart';

// 使用預定義文字樣式
Text(
  'Castle Ticket',
  style: AppTheme.displayLarge,  // 大標題
)

Text(
  'Description',
  style: AppTheme.bodyMedium,    // 內文
)

// 使用間距系統
Padding(
  padding: EdgeInsets.all(AppTheme.spacingM),  // 16px 間距
)

// 使用圓角系統
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppTheme.radiusL), // 12px 圓角
    boxShadow: AppTheme.shadowMedium,  // 中等陰影
  ),
)
```

### 使用漸變色

```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.castleGradient,  // 城堡漸變色
    // 或
    gradient: AppTheme.sunsetGradient,  // 日落漸變色
    gradient: AppTheme.forestGradient,  // 森林漸變色
  ),
)
```

## 色彩主題特點

- **符合 Material Design 3 標準**
- **支援亮色和深色模式**
- **城堡主題設計**: 以新天鵝堡的藍色調為靈感
- **完整的可訪問性支援**: 符合 WCAG 對比度要求
- **豐富的色彩變化**: 每個色彩都有 50-900 的深淺變化

## 自動主題切換

應用程式現在支援自動根據系統設定切換亮色/深色模式：

```dart
MaterialApp(
  theme: AppTheme.lightTheme,      // 亮色主題
  darkTheme: AppTheme.darkTheme,   // 深色主題  
  themeMode: ThemeMode.system,     // 自動切換
)
```

## 擴展色彩系統

如果需要添加新的色彩，請在 `colors.dart` 中添加：

```dart
static const Color customColor = Color(0xFF123456);
static const List<Color> customGradient = [customColor, primary];
```

然後在 `app_theme.dart` 中創建對應的主題配置。
