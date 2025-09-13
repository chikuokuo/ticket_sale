# 🏰 新天鵝堡背景圖片設置指南

## 📸 添加背景圖片

要使用您的 **`Bg-NeuschwansteinCastle.jpg`** 圖片，請按照以下步驟：

### 第一步：放置圖片
```bash
# 將您的圖片複製到 assets 目錄
cp /path/to/your/Bg-NeuschwansteinCastle.jpg assets/images/
```

### 第二步：刷新應用
```bash
flutter clean
flutter pub get
flutter run
```

## 🎨 新版面設計

### 1. 背景圖片區域
- **全屏城堡背景圖片**：使用您的 `Bg-NeuschwansteinCastle.jpg`
- **標題覆蓋層**：
  - 主標題："Neuschwanstein Castle" 
  - 副標題："Hohenschwangau, Bavaria"
- **漸層遮罩**：確保文字在圖片上清晰可讀

### 2. 票券選擇卡片
包含以下功能區塊：
- **Select Visit Date**：日期選擇器
- **Select Time Slot**：上午/下午時段選擇
- **Tickets**：成人/兒童票券計數器
- **Find Available Times** 按鈕
- 特色標示：即時確認、手機票券、24小時取消

### 3. 重要資訊卡片
完整的重要資訊說明，包含：
- 票券退換政策
- 參觀者資訊和無障礙設施說明
- 兒童票券要求
- 證件驗證說明
- 語音導覽設備限制
- 城堡參觀容量限制
- 雙城堡參觀建議
- 巴伐利亞國王博物館資訊

## 🔄 自動備援機制

如果找不到本地圖片，應用程式會自動使用高品質的新天鵝堡網路圖片作為備援。

## 📋 圖片要求

- **檔案名稱**：必須是 `Bg-NeuschwansteinCastle.jpg`
- **格式**：JPG 或 PNG
- **建議尺寸**：1080×1920 像素（直向）或更高
- **檔案大小**：小於 3MB 以獲得最佳性能

## ✅ 完成設置

現在您的新天鵝堡售票應用程式擁有：
- 美麗的城堡背景圖片
- 清晰的兩區塊布局
- 完整的票券選擇功能
- 詳細的重要資訊說明

只需放置您的圖片檔案，即可享受完美的視覺體驗！🎉
