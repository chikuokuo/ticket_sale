# Flutter 票務販售 App

一款功能完善的 Flutter 應用程式，用於瀏覽和購買多種服務的票券，包含博物館門票和火車旅程。此 App 整合了 G2Rail 等第三方服務以獲取即時火車數據，並使用 Stripe 進行安全的線上支付。

## 核心功能

- **多服務票務系統**: 支援訂購不同類別的票券。
  - **博物館門票**: 重構後的模組，用於購買新天鵝堡門票。
  - **火車票**: 查詢火車路線並預訂車票。
- **即時數據**: 整合 **G2Rail API** 以擷取最新的火車時刻表與票務狀況。
- **安全支付**: 利用 **Stripe** 安全地處理線上支付流程。
- **狀態管理**: 使用 **Riverpod** 在整個應用程式中進行穩健且可擴展的狀態管理。
- **主題化**: 擁有一個集中化的主題系統，以確保 App 整體外觀與風格的一致性。
- **基於環境的配置**: 透過 `.env` 檔案來管理 API 金鑰和敏感資訊。

## 使用流程

### 購買博物館門票
1.  從主畫面導航至博物館區塊。
2.  使用者可以看到成人和孩童的票價。
3.  選擇參訪日期 (必須是至少兩天後) 和一個入場時段 (AM/PM)。
4.  填寫聯絡電子郵件和支付資訊。
5.  新增出席者，並指定他們的姓名和類型 (成人/孩童)。
6.  在管理出席者時，總金額會自動重新計算。
7.  前往摘要畫面以檢視訂單。
8.  使用 Stripe 支付網關完成購買。

### 購買火車票
1.  從主畫面導航至火車票區塊。
2.  在期望的站點之間搜尋火車路線。
3.  App 會從 G2Rail API 擷取並顯示可用的班次。
4.  選擇一個期望的班次以查看詳細資訊。
5.  為預訂輸入乘客資訊。
6.  在摘要畫面上檢視旅程細節和總金額。
7.  使用 Stripe 支付網關完成購買。

## 專案架構

此專案採用功能驅動的結構進行組織，以分離關注點並提升可擴展性。

```
sale_ticket_app/
└── lib/
    ├── main.dart             # 應用程式的主要進入點。
    ├── models/               # 資料模型 (如 Attendee, TrainTrip 等)。
    ├── providers/            # 用於狀態管理的 Riverpod providers。
    ├── screens/              # 各功能的 UI 畫面。
    ├── services/             # 外部服務的客戶端 (G2Rail, Stripe)。
    ├── theme/                # 應用程式的全域配色與主題。
    └── widgets/              # 可重複使用的 UI 元件。
```

-   `main.dart`: 初始化 App，設定 providers 並定義路由。
-   `models/`: 包含所有博物館和火車票務的資料結構。
-   `providers/`: 包含由 Riverpod 管理的業務邏輯和狀態。
-   `screens/`: 包含各個獨立的畫面，按功能組織 (例如 `museum_ticket_screen.dart`, `train_ticket_screen.dart`)。
-   `services/`: 處理與 G2Rail、Stripe 等外部 API 的通訊。
-   `theme/`: 定義應用程式的視覺風格。
-   `widgets/`: 包含在多個畫面中使用的小型、可重複使用的 widget。

## 如何開始

若要在本機執行此專案，請遵循以下步驟：

### 1. 先決條件
- 確保已安裝 [Flutter SDK](https://flutter.dev/docs/get-started/install)。
- 您將需要 G2Rail 和 Stripe 的 API 金鑰。

### 2. 安裝
1.  複製此儲存庫。
2.  導航至專案目錄：`cd sale_ticket_app`
3.  安裝專案依賴：
    ```sh
    flutter pub get
    ```

### 3. 環境配置
1.  在專案的根目錄下，建立一個名為 `.env` 的檔案。
2.  將您的 API 金鑰和其他環境特定變數加入此檔案。它應該看起來像這樣：
    ```
    # G2Rail API 憑證
    G2RAIL_API_KEY=your_g2rail_api_key_here

    # Stripe API 憑證
    STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here
    STRIPE_SECRET_KEY=your_stripe_secret_key_here
    ```

### 4. 執行應用程式
```sh
flutter run
```
