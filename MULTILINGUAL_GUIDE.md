# Multilingual Support Guide / 多語系支援指南

## Overview / 概述

This Flutter app now supports 6 languages:
這個 Flutter 應用程式現在支援 6 種語言：

1. **English** 🇺🇸 (Default/預設)
2. **Korean** 🇰🇷 (한국어)
3. **French** 🇫🇷 (Français)
4. **German** 🇩🇪 (Deutsch)
5. **Japanese** 🇯🇵 (日本語)
6. **Vietnamese** 🇻🇳 (Tiếng Việt)

## Features / 功能

### Language Switching / 語言切換
- Tap the language icon (🌐) in the top-right corner of the main screen
- 點擊主畫面右上角的語言圖示 (🌐)
- Select your preferred language from the list
- 從清單中選擇您偏好的語言

### Dynamic UI Updates / 動態介面更新
- All text elements update immediately when language is changed
- 語言更改時，所有文字元素會立即更新
- Navigation tabs, buttons, and labels are all localized
- 導航標籤、按鈕和標籤都已本地化

## Implementation Details / 實作細節

### Files Structure / 檔案結構
```
lib/
├── l10n/                           # Localization files / 本地化檔案
│   ├── app_en.arb                 # English strings / 英文字串
│   ├── app_ko.arb                 # Korean strings / 韓文字串
│   ├── app_fr.arb                 # French strings / 法文字串
│   ├── app_de.arb                 # German strings / 德文字串
│   ├── app_ja.arb                 # Japanese strings / 日文字串
│   ├── app_vi.arb                 # Vietnamese strings / 越南文字串
│   └── app_localizations*.dart    # Generated files / 生成的檔案
├── providers/
│   └── language_provider.dart     # Language state management / 語言狀態管理
└── screens/
    └── language_selection_screen.dart # Language picker UI / 語言選擇介面
```

### Configuration Files / 配置檔案
- `l10n.yaml` - Localization configuration / 本地化配置
- `pubspec.yaml` - Dependencies and Flutter settings / 依賴項和 Flutter 設定

## How to Use in Code / 如何在程式碼中使用

### Basic Usage / 基本使用
```dart
import '../l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Text(l10n.welcome); // Shows "Welcome", "환영합니다", etc.
  }
}
```

### With Riverpod Provider / 使用 Riverpod Provider
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/language_provider.dart';

class MyConsumerWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Text(l10n.currentLanguage),
        Text('Current: ${currentLocale.languageCode}'),
      ],
    );
  }
}
```

### Change Language Programmatically / 程式化更改語言
```dart
// Change to Korean / 更改為韓文
ref.read(languageProvider.notifier).changeToKorean();

// Change to any language / 更改為任何語言
ref.read(languageProvider.notifier).changeLanguage('fr');
```

## Available Strings / 可用字串

The following strings are available in all languages:
以下字串在所有語言中都可用：

### Navigation / 導航
- `appTitle` - App title / 應用程式標題
- `tickets` - Tickets tab / 票券標籤
- `trains` - Trains tab / 火車標籤
- `bundles` - Bundles tab / 套餐標籤
- `treasureHunt` - Treasure Hunt tab / 尋寶標籤

### Common Actions / 常用動作
- `search` - Search button / 搜尋按鈕
- `bookNow` - Book now button / 立即預訂按鈕
- `confirm` - Confirm button / 確認按鈕
- `cancel` - Cancel button / 取消按鈕
- `back` - Back button / 返回按鈕
- `next` - Next button / 下一步按鈕
- `done` - Done button / 完成按鈕

### Forms / 表單
- `firstName` - First name field / 名字欄位
- `lastName` - Last name field / 姓氏欄位
- `email` - Email field / 電子郵件欄位
- `phoneNumber` - Phone number field / 電話號碼欄位
- `address` - Address field / 地址欄位

### Status Messages / 狀態訊息
- `loading` - Loading message / 載入訊息
- `error` - Error message / 錯誤訊息
- `noDataAvailable` - No data message / 無資料訊息

### Language Selection / 語言選擇
- `selectLanguage` - Language selection title / 語言選擇標題
- `language` - Language label / 語言標籤
- `changed` - Changed status / 更改狀態

## Adding New Strings / 新增字串

1. Add the new string to `lib/l10n/app_en.arb` (English template):
   在 `lib/l10n/app_en.arb` (英文範本) 中新增字串：

```json
{
  "newString": "New String",
  "@newString": {
    "description": "Description of the new string"
  }
}
```

2. Add translations to all other ARB files:
   在所有其他 ARB 檔案中新增翻譯：

```json
// app_ko.arb
"newString": "새로운 문자열"

// app_fr.arb  
"newString": "Nouvelle Chaîne"

// app_de.arb
"newString": "Neue Zeichenkette"

// app_ja.arb
"newString": "新しい文字列"

// app_vi.arb
"newString": "Chuỗi Mới"
```

3. Regenerate localization files:
   重新生成本地化檔案：

```bash
flutter gen-l10n
```

4. Use in code:
   在程式碼中使用：

```dart
Text(l10n.newString)
```

## Testing / 測試

### Manual Testing / 手動測試
1. Run the app: `flutter run`
   執行應用程式：`flutter run`
2. Tap the language icon in the top-right corner
   點擊右上角的語言圖示
3. Select different languages and verify UI updates
   選擇不同語言並驗證介面更新
4. Navigate through different screens to test all translations
   瀏覽不同畫面以測試所有翻譯

### Build Testing / 建置測試
```bash
# Test web build / 測試 web 建置
flutter build web

# Test Android build / 測試 Android 建置
flutter build apk

# Test iOS build / 測試 iOS 建置
flutter build ios
```

## Troubleshooting / 疑難排解

### Common Issues / 常見問題

1. **Localization files not generated / 本地化檔案未生成**
   ```bash
   flutter clean
   flutter pub get
   flutter gen-l10n
   ```

2. **Missing translations / 缺少翻譯**
   - Check all ARB files have the same keys
   - 檢查所有 ARB 檔案是否有相同的鍵值
   - Run `flutter gen-l10n` after adding new strings
   - 新增字串後執行 `flutter gen-l10n`

3. **Language not switching / 語言未切換**
   - Verify the language provider is properly imported
   - 驗證語言提供者是否正確匯入
   - Check if the locale is supported in `main.dart`
   - 檢查 `main.dart` 中是否支援該語言環境

## Future Enhancements / 未來增強

- Add more languages / 新增更多語言
- Implement persistent language selection / 實作持久化語言選擇
- Add right-to-left (RTL) language support / 新增從右到左 (RTL) 語言支援
- Implement automatic language detection based on device settings / 實作基於設備設定的自動語言檢測

## Support / 支援

For questions or issues related to multilingual support, please check:
有關多語言支援的問題或疑問，請檢查：

- Flutter internationalization documentation
- ARB file format specification  
- This implementation in the codebase
