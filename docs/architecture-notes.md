# nhviewer-universal 程式架構筆記

這份筆記的目標是幫助「熟悉 Java，但對 Android/Flutter/Dart 幾乎零基礎」的開發者，快速理解這個專案的：

- 進入點
- 執行流程
- 各類別與重要函數功能
- 資料儲存與暫存方式
- 主要演算法與邏輯
- 程式碼結構與分類

---

## 1. 先用 Java 腦袋理解這個專案

如果你熟悉 Java，可以先把 Flutter 專案大致映射成這樣：

| Flutter / Dart 概念 | 可類比的 Java / Android 概念 |
| --- | --- |
| `main()` | Java `public static void main()` / Android App 啟動點 |
| `Widget` | Android View / Fragment / RecyclerView item 的組合概念 |
| `StatefulWidget` | 有內部狀態的 UI 元件，類似 View + controller |
| `StatelessWidget` | 純展示元件，輸入決定輸出 |
| `ChangeNotifier` | 可觀察狀態物件，類似簡化版 ViewModel + observer |
| `Provider` | 依賴注入 + 狀態共享容器 |
| `GoRouter` | 路由器 / 頁面導頁規則 |
| `sqflite` | SQLite 存取層 |
| `MethodChannel` | Flutter 與原生 Android 溝通橋樑 |

這個專案本質上可以理解成：

1. Flutter UI 層
2. Provider 狀態層
3. Store(SQLite) 本地資料層
4. Dio / WebView 遠端 API 與 Cloudflare 處理層
5. 少量 Android 原生橋接層

---

## 2. 專案結構

### 2.1 核心檔案

| 路徑 | 角色 |
| --- | --- |
| `lib/main.dart` | 幾乎所有 UI、路由、SQLite Store、畫面流程都在這裡 |
| `lib/model/state_model.dart` | Provider 狀態模型：全域 UI 狀態、漫畫列表狀態、當前漫畫狀態 |
| `lib/model/data_model.dart` | API JSON 對應資料模型 |
| `lib/theme.dart` | Material 3 主題色與 `ThemeData` 組裝 |
| `android/app/src/main/java/com/ttdyce/concept_nhv/MainActivity.java` | Android 原生入口，負責 WebView cookie 橋接 |
| `android/settings.gradle.kts` | Android plugin 與 Kotlin 版本設定 |
| `android/app/build.gradle.kts` | Android app module 編譯設定 |
| `test/domain_test.dart` | 網域 / 圖片子網域可用性測試 |

### 2.2 結構上的特徵

- 這是一個「單檔主導」的 Flutter 專案：`main.dart` 很大，承擔了畫面、路由、儲存、輔助邏輯。
- 資料模型與狀態模型有拆出去，但 service/repository/controller 尚未再細分。
- 因此閱讀順序建議是：
  1. `lib/main.dart`
  2. `lib/model/state_model.dart`
  3. `lib/model/data_model.dart`
  4. `android/MainActivity.java`
  5. `lib/theme.dart`

---

## 3. 程式進入點與啟動流程

## 3.1 Flutter 進入點：`lib/main.dart`

### `main()`

位置：`lib/main.dart`

功能：

1. `WidgetsFlutterBinding.ensureInitialized()`
   - 初始化 Flutter 執行環境。
2. 若是 Android，呼叫 `FlutterDisplayMode.setHighRefreshRate()`
   - 嘗試啟用高更新率。
3. 呼叫 `Store.init()`
   - 初始化 SQLite 資料庫與表格。
4. `runApp(...)`
   - 建立整個 App。
5. 以 `MultiProvider` 注入三個全域狀態物件：
   - `AppModel`
   - `ComicListModel`
   - `CurrentComicModel`
6. 用 `MaterialApp.router + GoRouter` 建立整個導頁系統。

### 啟動後第一個畫面

App 啟動後先進 `/`，對應 `FirstScreen`。

`FirstScreen` 的職責不是首頁，而是：

- 先檢查舊的 Cloudflare cookie 是否還有效
- 如果有效，直接載入首頁資料並跳到 `/index`
- 如果無效，開 WebView 讓使用者通過 Cloudflare 驗證，再取出 cookie

這是整個專案的第一個「關鍵流程」。

---

## 4. 整體執行流程

## 4.1 啟動流程

1. `main()` 啟動 Flutter
2. `Store.init()` 建立 / 開啟 SQLite
3. `FirstScreen.build()` 透過 `FutureBuilder` 等待 `testLastCFCookies()`
4. 若 cookie 有效：
   - 呼叫 `ComicListModel.fetchIndex()`
   - 再跳轉到 `/index`
5. 若 cookie 無效：
   - 開 WebView 載入 `https://nhentai.net`
   - 原生 Android 透過 `MethodChannel` 把 WebView cookie 回傳給 Flutter
   - `Store.setCFCookies()` 存入 SQLite
   - 再次驗證 cookie
   - 成功後跳 `/index`

## 4.2 首頁流程

1. `/index` 進到 `IndexScreen`
2. `IndexScreen` 只回傳 `App`
3. `App` 是主要畫面容器，內含：
   - `SliverAppBar + SearchAnchor`
   - 根據 `AppModel.navigationIndex` 切換頁面內容
4. 預設 index = 0，顯示漫畫列表首頁
5. 漫畫資料由 `ComicListModel.comics` 提供

## 4.3 點進漫畫詳情流程

1. 使用者點 `ComicListItem`
2. 先呼叫 `CurrentComicModel.fetchComic(id)`
3. 再導頁到 `/third?id=xxx`
4. `ThirdScreen` 顯示漫畫每一頁圖片
5. `CurrentComicModel.currentComic` 被設定時，會自動：
   - 把漫畫資料寫入 `Comic` 表
   - 把這本漫畫加入 `History` 集合
6. 閱讀過程中滾動位置會寫進 `Options`
7. 下次再進同一部漫畫時，會讀出 `lastSeenOffset-<id>` 自動捲回

## 4.4 收藏 / 稍後閱讀 / 歷史流程

1. 使用者在列表卡片按下動作按鈕
2. 先 `Store.addComic(...)`
3. 再 `Store.collectComic(collectionName: 'Favorite' or 'Next', ...)`
4. Collection 畫面用 SQL join 從 `Collection + Comic` 讀出資料

---

## 5. 路由與畫面結構

Router 由 `GoRouter` 建立，主要路由如下：

| 路由 | 畫面 | 功能 |
| --- | --- | --- |
| `/` | `FirstScreen` | 啟動檢查 Cloudflare cookie |
| `/index` | `IndexScreen -> App` | 首頁主畫面 |
| `/collection` | `CollectionScreen` | 某個收藏夾的內容 |
| `/third` | `ThirdScreen` | 單一本漫畫閱讀頁 |
| `/settings` | `SettingsScreen` | 設定頁 |

另外有一個 `ShellRoute`：

- 負責共用外框
- 內含 `Scaffold`
- 提供底部 `NavigationBar`
- 提供首頁上的排序 `FloatingActionButton`

---

## 6. 狀態管理

狀態管理在 `lib/model/state_model.dart`。

## 6.1 `AppModel`

職責：全域 UI 狀態

欄位：

- `_navigationIndex`
  - 底部導覽列目前在哪個頁籤
- `searchController`
  - Search bar / suggestion 的控制器
- `_isLoading`
  - 是否正在載入

重要邏輯：

### `navigationIndex` setter

功能：

- 切換頁籤時更新 index
- 若是重複點首頁或從首頁切換，會清空搜尋欄文字
- 呼叫 `notifyListeners()` 讓 UI 重建

### `isLoading` setter

功能：

- 控制頁面是否顯示 loading bar
- 改值後通知 UI 更新

## 6.2 `ComicListModel`

職責：漫畫列表狀態

欄位：

- `_fetchedComics`
  - 已抓到的分頁結果
- `everyCollectionFuture`
  - 收藏頁使用的 Future
- `pageLoaded`
  - 已載入到第幾頁
- `_noMorePage`
  - 是否沒有更多頁
- `_sortByPopularType`
  - 目前排序規則
- `_fetchPage`
  - 保存「下一次抓頁」函數

重要函數：

### `fetchEveryCollectionFuture()`

功能：

- 呼叫 `Store.getEveryCollection()`
- 把結果 Future 存進 `everyCollectionFuture`
- 通知 UI 更新

### `fetchIndex(...)`

功能：

- 首頁載入專用
- 本質上只是包一層 `fetchSearch(q: '')`

### `fetchSearch(...)`

功能：

- 核心 API 請求函數
- 可用於首頁與搜尋
- 可處理：
  - 搜尋關鍵字
  - 分頁
  - 排序
  - cookie fallback
  - 語言 query fallback

邏輯：

1. 若 `clearComic = true`，清空 `_fetchedComics`
2. 根據 `NHLanguage.current` 組出語言 query
3. 組出 `https://nhentai.net/api/galleries/search?...`
4. 優先嘗試「不帶 cookie」請求
5. 失敗時，從 `Store.getCFCookies()` 取出 `userAgent + token`
6. 帶 header 再試一次
7. 若再失敗，使用 `NHLanguage.alternatives` 做 retry
8. 成功後把新頁資料 append 到 `_fetchedComics`
9. 更新 `_noMorePage`、`pageLoaded`
10. 重新設定 `_fetchPage`

### `fetchPage({int? page})`

功能：

- 呼叫前一次記下來的 `_fetchPage`
- 用於 infinite scroll 觸發抓下一頁

### `comicsLoaded`

功能：

- 計算總共已載入多少筆漫畫

### `comics`

功能：

- 把 `_fetchedComics` 多個分頁 flatten 成一個列表

## 6.3 `CurrentComicModel`

職責：單本漫畫閱讀狀態

欄位：

- `scrollController`
  - 閱讀頁滾動控制器
- `_currentComic`
  - 當前漫畫內容
- `headers`
  - 圖片請求可能需要的 HTTP headers

重要函數：

### `currentComic` setter

功能：

- 設定當前漫畫
- 如果不是 null，就自動把這本漫畫寫進本地資料庫
- 同時加入 `History`

這代表：

- 「打開漫畫」本身就會觸發歷史紀錄

### `fetchComic(String id)`

功能：

- 請求單本漫畫 API：`/api/gallery/<id>`
- 先不帶 headers 試
- 失敗時讀取 Cloudflare cookie 再帶 headers 試
- 成功後寫入 `currentComic`

### `clearComic()`

功能：

- 清空目前漫畫

---

## 7. 資料模型

資料模型在 `lib/model/data_model.dart`。

這個檔案幾乎全部是 JSON <-> Dart object 的轉換。

主要類別：

| 類別 | 功能 |
| --- | --- |
| `NHList` | API 列表回傳，包含 `result / num_pages / per_page` |
| `NHComic` | 單本漫畫資料 |
| `Title` | 英文 / 日文 / pretty title |
| `NHImages` | 圖片資訊，包含 pages / cover / thumbnail |
| `Pages` | 單張圖片資料，含格式代碼 `t`、寬高 |
| `Tags` | 標籤資料 |

每個 class 幾乎都有：

- `fromJson(Map<String, dynamic>)`
- `toJson()`

這些函數的職責都很單純：

- `fromJson`：把 API 回傳轉成 Dart 物件
- `toJson`：把物件再轉回 Map，方便存 DB 或 debug

---

## 8. 資料儲存與暫存方式

## 8.1 記憶體暫存

### UI / 狀態暫存

透過 Provider 中的 `ChangeNotifier` 保存：

- `AppModel`
- `ComicListModel`
- `CurrentComicModel`

這是執行中記憶體層的狀態，不是永久儲存。

### 圖片快取

`cached_network_image` 會自動做圖片快取。

這代表圖片除了網路重新抓，也有套件自己的 cache 機制。

## 8.2 永久儲存：SQLite

SQLite 由 `Store` 這個類別集中管理。

### `Store.init()`

功能：

- 決定 DB 路徑
- 建立 / 開啟 `database.db`
- 建表
- 做 schema upgrade

### 建立的資料表

#### `Options`

用途：

- 存 key-value 型設定

目前實際用途：

- `userAgent`
- `token`
- `lastSeenOffset-<comicId>`

#### `Comic`

用途：

- 存漫畫基本資料

欄位：

- `id`
- `mid`
- `title`
- `images`
- `pages`

#### `Collection`

用途：

- 存收藏夾關係

欄位：

- `name`
- `comicid`
- `dateCreated`

可以存：

- `Favorite`
- `Next`
- `History`

#### `SearchHistory`

用途：

- 存搜尋歷史

欄位：

- `id`
- `query`
- `created_at`

## 8.3 `Store` 重要函數

### Cookie / options 類

- `setCFCookies(userAgent, token)`
- `getCFCookies()`
- `deleteCFCookies()`
- `setOption(name, value)`
- `getOption(name)`

### 漫畫 / 收藏類

- `addComic(...)`
- `collectComic(...)`
- `uncollectComic(...)`
- `getCollection(collectionName)`
- `getEveryCollection()`

### 搜尋歷史類

- `addSearchHistory(q)`
- `getSearchHistory()`
- `deleteSearchHistory(q)`

---

## 9. Cloudflare / Cookie 驗證流程

這是此專案一個非常重要的特殊邏輯。

## 9.1 為什麼需要它

nhentai 有時會擋直接 API 請求，必須先通過 Cloudflare 驗證。

所以 App 不是單純發 API 就好，而是需要：

1. 先試請求
2. 失敗時帶 cookie
3. cookie 沒有就透過 WebView 取得

## 9.2 相關函數

### `FirstScreen.testLastCFCookies()`

功能：

- 先直接測 API 是否可用
- 若不行，再讀本地存的 cookie + user agent 做重試
- 判斷本地 cookie 是否有效

### `FirstScreen.receiveCFCookies(...)`

功能：

- 透過原生 `MethodChannel` 向 Android 端要求取出 WebView cookie
- 存回 SQLite

### Android 端：`MainActivity.configureFlutterEngine()`

功能：

- 建立 `MethodChannel("samples.flutter.dev/cookies")`
- 接收 Flutter 發來的 `receiveCFCookies`
- 回傳 `CookieManager.getInstance().getCookie("https://nhentai.net")`

### Android 端：`receiveCFCookies()`

功能：

- 真的從 WebView cookie store 中取 cookie 字串

---

## 10. UI 結構與各畫面職責

## 10.1 `FirstScreen`

用途：

- App 啟動畫面
- 驗證 Cloudflare cookie
- 必要時顯示 WebView 驗證頁

主要函數：

- `receiveCFCookies(...)`
- `testLastCFCookies()`
- `build(...)`

## 10.2 `IndexScreen`

用途：

- 單純回傳主要頁面 `App`

## 10.3 `App` / `_AppState`

用途：

- App 主畫面容器
- 搜尋列、loading bar、主內容切換都在這裡

主要職責：

- 顯示 `SearchAnchor`
- 根據 `navigationIndex` 切換內容
- 顯示首頁 / Favorite / Collection list
- 顯示 loading 線條

主要函數：

### `initState()`

- 目前只掛 focus listener，偏輔助用途

### `build(...)`

- 這是主頁大總管
- 主要內容：
  - `SliverAppBar`
  - 搜尋
  - 根據 navigation index 切畫面

### `showLoadingIfNeeded(bool isLoading)`

- 決定是否在 AppBar 底下顯示 `LinearProgressIndicator`

## 10.4 `ThirdScreen`

用途：

- 單本漫畫閱讀頁

主要職責：

- 讀取 query parameter `id`
- 監聽 scroll 結束，寫入 lastSeenOffset
- 顯示所有漫畫頁圖片
- 下次再進來時自動捲回上次位置

## 10.5 `SettingsScreen`

用途：

- 設定頁

目前看得到的功能：

- 語言設定
- diagnose 類功能
- 其他設定項目

## 10.6 `CollectionScreen`

用途：

- 顯示某一個指定 collection 的所有漫畫

## 10.7 `CollectionListScreen`

用途：

- 顯示所有 collection 的封面入口
- 目前主要是：
  - `History`
  - `Next`
  - `Favorite`

## 10.8 `ComicSliverGrid`

用途：

- 把漫畫封面清單畫成 grid

重要邏輯：

- 檢查是否捲到最後一個 item
- 若還有更多頁，觸發 `fetchPage(pageLoaded + 1)`

這就是 infinite scroll 的核心。

## 10.9 `ComicListItem`

用途：

- 單一漫畫卡片

主要互動：

- 點擊：進閱讀頁
- 左按鈕：加入 `Next`
- 右按鈕：加入 `Favorite`
- 長按：從某個 collection 中刪除

## 10.10 `CollectionSliverGrid`

用途：

- 顯示收藏夾入口卡片

## 10.11 `SimpleCachedNetworkImage`

用途：

- 圖片載入元件

重要邏輯：

- 使用 `cached_network_image`
- 先用目前 URL 載圖
- 若失敗，會在：
  - 多個子網域
  - 多個副檔名
  之間做 fallback

這是為了應對 nhentai 不同圖片實際存放位置與格式不一致的問題。

主要函數：

- `initState()`
- `didUpdateWidget(...)`
- `_resetCandidates()`
- `_buildCandidateUrls(...)`
- `_scheduleRetry()`
- `build(...)`

---

## 11. 演算法與邏輯重點

## 11.1 搜尋重試演算法

在 `ComicListModel.fetchSearch(...)`：

1. 先用主語言 query 試
2. 失敗時改用 `NHLanguage.alternatives`
3. 一路遞迴 retry
4. 超過 alternatives 長度後放棄

這是一個簡單的 retry + fallback 策略。

## 11.2 Infinite scroll

在 `ComicSliverGrid.build(...)`：

1. 每次畫 item 時檢查是否到最後一筆
2. 若還有下一頁且沒在 loading
3. 呼叫 `fetchPage(pageLoaded + 1)`

## 11.3 歷史紀錄自動寫入

在 `CurrentComicModel.currentComic` setter：

1. 只要單本漫畫載入成功
2. 就自動：
   - 寫入 `Comic`
   - 寫入 `History`

所以「打開漫畫」本身就是 history 寫入點。

## 11.4 圖片 fallback 演算法

在 `SimpleCachedNetworkImage._buildCandidateUrls(...)`：

1. 先看目前 host 是 `t*` 還是 `i*`
2. 生成多組 host 候選
3. 再對同一個檔名生成副檔名候選：
   - `jpg`
   - `webp`
   - `png`
   - `gif`
4. 失敗就逐一重試

## 11.5 最後閱讀位置保存

在 `ThirdScreen`：

1. scroll 結束時把 offset 寫到 `Options`
2. key 格式是 `lastSeenOffset-<comicId>`
3. 下次進同一部漫畫再讀出並捲回

---

## 12. Android 原生層

Android 原生層很薄，主要不是業務邏輯，而是輔助 Flutter 取 cookie。

## 12.1 `MainActivity.java`

主要函數：

### `configureFlutterEngine(...)`

- 建立 Flutter 與 Android 的溝通橋

### `receiveCFCookies()`

- 讀 `CookieManager`
- 回傳 nhentai cookie

這可以理解成：

- Flutter 層無法直接方便拿到 WebView cookie
- 所以請 Android 原生層幫忙

## 12.2 Android build 設定

### `android/settings.gradle.kts`

- 定義 Android plugin 與 Kotlin plugin 版本

### `android/app/build.gradle.kts`

- 定義：
  - namespace
  - compileSdk
  - minSdk / targetSdk
  - Java 版本
  - Kotlin JVM target

---

## 13. 主題系統

在 `lib/theme.dart`。

主要概念：

- `NHVMaterialTheme`
  - 提供 light / dark / contrast 多組 Material 3 色票
- `MaterialScheme`
  - 純資料結構，描述一整組顏色
- `MaterialSchemeUtils.toColorScheme()`
  - 把自定義 scheme 轉成 Flutter `ColorScheme`

目前 App 在 `main()` 中實際使用的是：

- `const NHVMaterialTheme(TextTheme()).dark()`

也就是一開始直接套 dark theme。

---

## 14. 函數功能總表

這裡用「重要性優先」整理。

### `lib/main.dart`

| 函數 / 方法 | 功能 |
| --- | --- |
| `main()` | App 進入點，初始化 Flutter、DB、Provider、Router |
| `FirstScreen.receiveCFCookies()` | 從 Android 端取出 WebView cookie |
| `FirstScreen.testLastCFCookies()` | 驗證現有 cookie 是否可用 |
| `FirstScreen.build()` | 啟動畫面與 Cloudflare 驗證流程 |
| `CollectionScreen.build()` | 畫單一 collection 頁 |
| `CollectionSliver.build()` | 從 Future 取該 collection 的漫畫並轉成 grid data |
| `CollectionListScreen.build()` | 把 `History/Next/Favorite` 聚合成 collection 卡片 |
| `NHLanguage.queryString` | 語言列舉轉 API query 字串 |
| `NHLanguage.alternatives` | 語言 fallback query 列表 |
| `Store.init()` | 建立 / 開啟 SQLite |
| `Store.setCFCookies/getCFCookies/deleteCFCookies()` | Cloudflare cookie 存取 |
| `Store.setOption/getOption()` | 一般 key-value 設定存取 |
| `Store.addComic()` | 寫入漫畫資料 |
| `Store.collectComic()/uncollectComic()` | 收藏夾加入 / 移除 |
| `Store.getCollection()` | 讀單一收藏夾 |
| `Store.getEveryCollection()` | 讀全部收藏夾 |
| `Store.addSearchHistory/getSearchHistory/deleteSearchHistory()` | 搜尋紀錄存取 |
| `IndexScreen.build()` | 進入主畫面 |
| `ThirdScreen.build()` | 顯示漫畫閱讀頁、保存閱讀位置 |
| `SettingsScreen.build()` | 設定頁 UI 與操作 |
| `SimpleCachedNetworkImage.*` | 圖片載入與 fallback |
| `_AppState.build()` | 主畫面總組裝 |
| `_AppState.showLoadingIfNeeded()` | 決定是否顯示 loading bar |
| `ComicSliverGrid.build()` | 漫畫列表 grid + infinite scroll |
| `ComicListItem.build()` | 單本漫畫卡片 UI 與互動 |
| `CollectionSliverGrid.build()` | 收藏夾 grid UI |

### `lib/model/state_model.dart`

| 函數 / 方法 | 功能 |
| --- | --- |
| `AppModel.navigationIndex` setter | 切頁與清搜尋欄 |
| `AppModel.isLoading` setter | 控制全域 loading 狀態 |
| `ComicListModel.fetchEveryCollectionFuture()` | 更新收藏 Future |
| `ComicListModel.fetchIndex()` | 抓首頁漫畫 |
| `ComicListModel.fetchSearch()` | 抓搜尋 / 首頁 / 排序資料 |
| `ComicListModel.fetchPage()` | 抓下一頁 |
| `CurrentComicModel.currentComic` setter | 設定漫畫並寫 History |
| `CurrentComicModel.fetchComic()` | 抓單本漫畫 |
| `CurrentComicModel.clearComic()` | 清除當前漫畫 |

### `lib/model/data_model.dart`

每個 `fromJson()` 與 `toJson()` 都是資料轉換用途。

---

## 15. 資料流總結

這個專案最常見的資料流是：

### 首頁載入

`FirstScreen`  
-> `ComicListModel.fetchIndex()`  
-> `Dio GET /api/galleries/search`  
-> `NHList.fromJson()`  
-> 存進 `ComicListModel._fetchedComics`  
-> `Provider` 通知 UI  
-> `ComicSliverGrid` 顯示

### 點開漫畫

`ComicListItem.onTap()`  
-> `CurrentComicModel.fetchComic(id)`  
-> `Dio GET /api/gallery/<id>`  
-> `NHComic.fromJson()`  
-> 設定 `currentComic`  
-> 自動寫入 `Comic` + `History`  
-> `ThirdScreen` 顯示所有頁面

### 收藏

`ComicListItem` 按鈕  
-> `Store.addComic()`  
-> `Store.collectComic()`  
-> `Collection` 與 `Comic` 建立關聯  
-> 收藏頁 SQL join 讀回

---

## 16. 現階段程式碼風格觀察

這個專案目前偏向：

- 小型專案
- 實用導向
- 邏輯集中
- 快速開發

優點：

- 所有關鍵流程都很直接
- 一個檔案就能追完整體流程
- 對單人維護其實不難

缺點：

- `main.dart` 太大
- `Store`、UI、路由耦合較高
- 若未來功能增長，維護成本會上升

如果未來想往更乾淨架構走，最值得先拆的是：

1. `Store` 搬到 `repository / local_data_source`
2. `FirstScreen` 的 Cloudflare 邏輯搬到 `service`
3. `main.dart` 拆成：
   - `screens/`
   - `widgets/`
   - `services/`
   - `repositories/`

---

## 17. 建議的閱讀順序

如果你之後要自己改功能，建議用這個順序看：

1. `lib/main.dart` 的 `main()`
2. `FirstScreen`
3. `App` / `_AppState`
4. `ComicSliverGrid` / `ComicListItem`
5. `ThirdScreen`
6. `Store`
7. `lib/model/state_model.dart`
8. `lib/model/data_model.dart`
9. `android/MainActivity.java`

---

## 18. 一句話總結

這是一個用 Flutter 寫的 nhentai 閱讀器，核心流程是：

- 先處理 Cloudflare cookie
- 用 Provider 管理列表與當前漫畫狀態
- 用 SQLite 保存收藏、歷史、搜尋紀錄與一些 option
- 用 GoRouter 導頁
- 用單一大型 `main.dart` 組起整個 UI 與大部分業務邏輯

