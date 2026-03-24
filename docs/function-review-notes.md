# nhviewer-universal 函式整理、命名建議與擴充建議

這份筆記的目的，是把作者目前專案中的函式依檔案逐一整理，說明：

- 這個函式在做什麼
- 現在的名稱是否貼切
- 如果要改名，建議更合適的名字
- 這個函式應該歸在哪一類
- 未來要擴充時，這個函式應該怎麼拆或怎麼改

---

## 1. 先給總結

這個專案目前的函式大致分成 8 類：

1. 啟動 / bootstrap
2. 路由 / 導頁
3. 畫面組裝 / UI build
4. 狀態管理 / 狀態轉換
5. 本地資料存取 / SQLite
6. 遠端 API / Cloudflare cookie 流程
7. 圖片 fallback / 韌性處理
8. 資料模型轉換 / 主題工廠

最值得優先改善的不是單一函式本身，而是：

- `main.dart` 承擔過多責任
- `Store` 類別放在 `main.dart` 中，且混合 DB schema、CRUD、業務語意
- `FirstScreen` 同時負責啟動、驗證、WebView、cookie、首頁初始化
- `App` / `_AppState` 的 `build()` 太大
- 某些名稱過於泛用，例如 `App`、`FirstScreen`、`ThirdScreen`

如果只看「可讀性 / 可擴充性」，這個專案接下來最適合做的是：

1. 把 `main.dart` 拆成 `screens/`, `widgets/`, `services/`, `storage/`
2. 把 `Store` 抽成獨立檔案
3. 把 Cloudflare / cookie 流程抽成 service
4. 把圖片 fallback 邏輯抽成 image resolver / image service

---

## 2. 建議的函式分類方式

### 2.1 啟動與應用骨架

- `main()`
- `App.build()`
- `_AppState.initState()`
- `_AppState.showLoadingIfNeeded()`

### 2.2 畫面流程 / 路由入口

- `FirstScreen.*`
- `IndexScreen.build()`
- `ThirdScreen.build()`
- `SettingsScreen.build()`
- `CollectionScreen.build()`

### 2.3 清單與卡片顯示

- `CollectionSliver.build()`
- `CollectionListScreen.build()`
- `ComicSliverGrid.build()`
- `ComicListItem.build()`
- `CollectionSliverGrid.build()`

### 2.4 狀態管理

- `AppModel`
- `ComicListModel.*`
- `CurrentComicModel.*`

### 2.5 本地資料存取

- `Store.*`

### 2.6 API / Cloudflare / 原生橋接

- `FirstScreen.receiveCFCookies()`
- `FirstScreen.testLastCFCookies()`
- `MainActivity.configureFlutterEngine()`
- `MainActivity.receiveCFCookies()`

### 2.7 圖片韌性處理

- `_SimpleCachedNetworkImageState.*`

### 2.8 資料模型 / 主題工廠

- `NHList.fromJson()/toJson()`
- `NHComic.fromJson()/toJson()`
- `Title.fromJson()/toJson()`
- `NHImages.fromJson()/toJson()`
- `Pages.fromJson()/toJson()`
- `Tags.fromJson()/toJson()`
- `NHVMaterialTheme.*`
- `MaterialSchemeUtils.toColorScheme()`

---

## 3. `lib/main.dart` 函式整理

## 3.1 App 啟動與路由

| 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `main()` | Flutter 啟動入口，初始化 binding、高更新率、SQLite、Provider、Router | 好 | 保持 | 啟動 / bootstrap | 若 bootstrap 流程再變長，建議拆成 `bootstrapApp()` |

### 補充

- `main()` 現在很合理，問題不在名稱，在於它把很多設定直接塞進 `runApp(...)`。
- 若未來路由與依賴更多，建議把 `Provider` 與 `GoRouter` 配置拆到獨立檔案。

---

## 3.2 Collection 相關畫面

| 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `CollectionScreen.build()` | 讀 query parameter 的 `collectionName`，組出單一收藏夾頁面 | 尚可 | `buildCollectionScreen()` 不必，保留即可 | Screen composition | 若 collection 功能變多，建議抽 `CollectionHeader`, `CollectionComicGrid` |
| `CollectionSliver.build()` | 讀 `everyCollectionFuture`，篩出指定 collection 的漫畫，轉成 `ComicCover` 清單 | 名稱偏泛 | `CollectionComicSliver.build()` | Collection page / data-to-view transform | 建議把 `Map -> ComicCover` 轉換搬到 mapper / factory |
| `CollectionListScreen.build()` | 整理 `History/Next/Favorite` 成 `CollectionCover` 列表 | 尚可 | `CollectionOverviewScreen.build()` | Collection overview | 建議抽成 `buildCollectionCovers()` 輔助函式 |

### 命名觀察

- `CollectionSliver` 與 `CollectionListScreen` 都太依賴「UI 呈現元件」命名，而不是「業務語意」。
- 若未來有更多 collection 畫面，應優先讓名稱帶出用途，例如：
  - `CollectionComicSliver`
  - `CollectionOverviewScreen`

---

## 3.3 Enum 與 query helper

| 成員 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `NHLanguage.queryString` | 把語言 enum 轉成 API query | 可以 | `apiQuery` 或 `primaryQuery` | Query helper | 可把 query 封裝成 value object |
| `NHLanguage.alternatives` | 搜尋失敗時使用的 fallback query 列表 | 一般 | `fallbackQueries` | Query fallback policy | 若未來語系更多，建議改成 `List<String> buildFallbackQueries()` |
| `NHPopularType` 常數 | 排序 query 常數 | 偏舊式 | `PopularSortType` enum | Sort policy | 建議改成 enum，避免 magic string |

### 命名建議

- `NHPopularType` 比較像常數容器，不像型別。
- 若重構，建議：

```dart
enum PopularSortType {
  allTime('popular'),
  day('popular-today'),
  week('popular-week'),
  month('popular-month');
}
```

這樣比 `static const` 更有型別安全。

---

## 3.4 `Store` 類別

這是目前最值得拆分的地方。

### 為什麼

`Store` 同時負責：

- 建 DB schema
- migration
- options CRUD
- cookie CRUD
- comic CRUD
- collection CRUD
- search history CRUD

也就是說它現在同時是：

- database initializer
- local repository
- key-value store
- comic repository
- collection repository
- search history repository

這在小專案很方便，但後續擴充會卡。

### 函式整理

| 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `Store.init()` | 開啟 DB、建表、migration | 普通 | `initializeDatabase()` | Storage bootstrap | 應拆到 `LocalDatabase.initialize()` |
| `setCFCookies()` | 儲存 Cloudflare userAgent 與 token | 尚可 | `saveCloudflareCookies()` | Auth / local persistence | 建議拆成 cookie repository |
| `getCFCookies()` | 讀 Cloudflare userAgent 與 token | 尚可 | `loadCloudflareCookies()` | Auth / local persistence | 可改回傳 dedicated type 而非 tuple |
| `deleteCFCookies()` | 刪除 cookie | 尚可 | `clearCloudflareCookies()` | Auth / local persistence | 可整合到 cookie service |
| `setOption()` | 寫任意 option | 可 | 保持 | Generic key-value storage | 建議包 typed API，例如 `saveLastSeenOffset()` |
| `getOption()` | 讀任意 option | 可 | 保持 | Generic key-value storage | 同上 |
| `addComic()` | 把漫畫資訊寫入 `Comic` 表 | 還行 | `upsertComic()` | Comic repository | 因使用 replace，名字應帶 `upsert` 語意 |
| `collectComic()` | 把漫畫加入某收藏夾 | 還行 | `addComicToCollection()` | Collection repository | 建議用 enum 取代裸字串 `collectionName` |
| `uncollectComic()` | 從收藏夾移除漫畫 | 可以 | `removeComicFromCollection()` | Collection repository | 同上 |
| `getComic()` | 只是 debug dump `Comic` 表 | 名稱不準 | `debugPrintComics()` 或 `dumpComics()` | Debug helper | 不應保留在正式 store API 表面 |
| `getCollection()` | 查單一收藏夾內容 | 可以 | `loadCollectionComics()` | Collection query | 回傳型別建議不要是 `Map<String,Object?>` |
| `getEveryCollection()` | 查所有收藏夾 join 資料 | 名稱不準 | `loadAllCollectedComics()` | Collection query | 可拆成 `loadAllCollections()` 與 `loadCollectionSummaries()` |
| `addSearchHistory()` | 寫入搜尋歷史 | 可以 | `saveSearchHistory()` | Search history repository | 可加去重策略 |
| `getSearchHistory()` | 讀搜尋歷史 | 可以 | `loadSearchHistory()` | Search history repository | 可做 limit / paging |
| `deleteSearchHistory()` | 刪除搜尋歷史一筆 | 可以 | `removeSearchHistory()` | Search history repository | 可加 `clearAllSearchHistory()` |

### 對 `Store` 的整體建議

如果未來要擴充，建議拆成至少 4 個檔案：

- `storage/local_database.dart`
- `storage/options_store.dart`
- `storage/comic_repository.dart`
- `storage/search_history_repository.dart`

再進一步可以加：

- `storage/collection_repository.dart`
- `storage/cloudflare_cookie_store.dart`

---

## 3.5 `FirstScreen`

這個類別目前不只是「第一個畫面」，它其實是整個啟動驗證流程控制器。

| 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `receiveCFCookies()` | 向原生端要 WebView cookie，解析 token，存 DB，還順手觸發 `fetchIndex()` | 名稱不足以表達副作用 | `captureAndPersistCloudflareCookies()` | Startup auth bootstrap | 最值得拆分，現在責任太多 |
| `testLastCFCookies()` | 驗證目前是否能進 nhentai；先直接試，不行再帶 cookie 試 | 名稱偏測試感 | `canAccessNhentai()` 或 `validateStoredCloudflareCookies()` | Auth connectivity check | 應拆成純驗證 service |
| `build()` | 啟動畫面，決定直接進首頁還是顯示 WebView 驗證 | `build()` 對 widget 合理，但類別名不夠清楚 | 類別應改名 `BootstrapScreen` 或 `CloudflareGateScreen` | Startup screen | 應抽 service，畫面只做展示 |

### 對 `receiveCFCookies()` 的拆分建議

目前這個函式至少做了 4 件事：

1. 呼叫 MethodChannel
2. 解析 cookie 字串
3. 取得 user agent
4. 寫入 Store 並觸發 fetchIndex

更好的拆法：

- `readCookieStringFromPlatform()`
- `extractCloudflareToken(String cookieString)`
- `persistCloudflareCookiePair(String userAgent, String token)`
- `bootstrapIndexAfterVerification()`

---

## 3.6 `IndexScreen`, `ThirdScreen`, `SettingsScreen`

| 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `IndexScreen.build()` | 只是回傳 `App` | 類別名稱 OK，但內容太薄 | 可保留 | Route wrapper | 若只是 wrapper，甚至可直接路由到 `App` |
| `ThirdScreen.build()` | 漫畫閱讀頁，包含 lastSeenOffset 保存與頁面圖片渲染 | `ThirdScreen` 幾乎無語意 | `ComicReaderScreen` 或 `ComicDetailScreen` | Reader screen | 應把 offset 保存與頁面渲染拆成 helper/widget |
| `SettingsScreen.build()` | 畫設定頁，包含語言切換、資料匯入、license | 類別名稱 OK | 保持 | Settings screen | 可把每個 `ListTile` 拆成獨立 action builder |

### `SettingsScreen.build()` 子功能觀察

雖然只有一個 `build()`，但內部其實包含多個不同責任：

- 語言切換 dialog
- Diagnose placeholder
- 遠端 json 匯入
- 授權頁

如果未來功能增加，建議拆出：

- `_buildLanguageTile()`
- `_buildImportTile()`
- `_buildLicenseTile()`

---

## 3.7 `SimpleCachedNetworkImage`

這是目前專案裡最像獨立元件的類別，整體設計是有價值的。

| 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `createState()` | 建立 state | 標準 | 保持 | Widget lifecycle | 無 |
| `_currentUrl` getter | 讀目前 fallback 候選 URL | 好 | 保持 | Image fallback state | 無 |
| `initState()` | 初始建立候選 URL | 好 | 保持 | Widget lifecycle | 無 |
| `didUpdateWidget()` | URL 變動時重設候選列表 | 好 | 保持 | Widget lifecycle | 無 |
| `_resetCandidates()` | 重建 fallback 候選與索引 | 好 | 可改 `resetFallbackCandidates()` | Image fallback | 若未來共用邏輯，抽成 service |
| `_buildCandidateUrls()` | 根據 host 與副檔名產生 fallback 圖片 URL 列表 | 很好 | 可改 `buildFallbackImageUrls()` | Image resolver | 這是最值得抽去 `image_resolver.dart` 的函式 |
| `_scheduleRetry()` | 在下一 frame 切到下一個 fallback URL | 尚可 | `scheduleNextFallbackAttempt()` | Retry scheduling | 可與 retry policy 一起抽出去 |
| `build()` | 組裝 `CachedNetworkImage`、placeholder、error fallback UI | 合理 | 保持 | Reusable image widget | 可分 `buildErrorState()` / `buildLoadingState()` |

### 類別命名建議

- `SimpleCachedNetworkImage` 現在其實已經不 simple 了。
- 它做了：
  - cache
  - retry
  - host fallback
  - extension fallback

更準確的命名可以是：

- `ResilientCachedImage`
- `FallbackCachedNetworkImage`
- `NhentaiImageView`

---

## 3.8 `App` / `_AppState`

這是目前最大的畫面控制器。

| 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `App.extMap` | 圖片副檔名代碼對照 | 名稱太短 | `imageTypeCodeToExtension` | Shared constants | 應抽到 `image_format.dart` |
| `_AppState.initState()` | 掛 focus listener | 可以 | 保持 | Widget lifecycle | 若 focus 邏輯擴大，抽 controller |
| `_AppState.build()` | 組整個首頁：SearchBar、頁面切換、列表顯示 | 類別與函式都太大 | 類別可改 `HomeScreen` / `HomeShell` | Home composition | 最優先拆分之一 |
| `showLoadingIfNeeded()` | 需要時回傳 loading bar | 尚可 | `buildLoadingIndicatorBar()` | UI helper | 可以抽成 widget |

### `App` 命名問題

`App` 在 Flutter 很常用，但這裡它不是整個應用入口，而是首頁主畫面容器。

更貼切的名字：

- `HomeScreen`
- `HomeShell`
- `MainTabScreen`

### `_AppState.build()` 的拆分建議

應拆成：

- `_buildSearchBar(AppModel appModel)`
- `_buildBodyByNavigationIndex(AppModel appModel)`
- `_buildSearchSuggestionTile(...)`
- `_handleSearchSubmit(...)`

這樣未來加功能會好維護很多。

---

## 3.9 `ComicSliverGrid`, `ComicListItem`, `CollectionSliverGrid`

| 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `ComicSliverGrid.build()` | 畫漫畫 grid，並在最後一個 item 觸發 infinite scroll | 好 | 保持 | Grid renderer + paging trigger | 可把 paging trigger 移到 controller |
| `ComicListItem.build()` | 畫單一漫畫卡片，處理點擊、長按、收藏、稍後閱讀 | 可以 | 可改 `ComicCard` 類別 | Card widget | 應把 onTap / onLongPress handler 抽函式 |
| `CollectionSliverGrid.build()` | 畫收藏夾入口 grid | 普通 | `CollectionGrid.build()` | Grid renderer | 應支援動態 childCount，不要寫死 3 |
| `CollectionCover.thumbnailLink` | 根據 `mid` 與副檔名算出收藏封面 URL | 好 | 保持 | Derived view data | 若 placeholder 規則更複雜，可抽 service |
| `CollectionCover.emptyCollection()` | 建立空收藏夾 placeholder 資料 | 好 | 保持 | Factory helper | 可改 named constructor `CollectionCover.empty(...)` |

### `CollectionSliverGrid.build()` 的隱患

目前：

- `childCount: 3`

這代表收藏夾入口數量被硬寫死。

若未來要新增使用者自定義收藏夾，這裡一定要改成：

- `childCount: collections.length`

這是典型的擴充性瓶頸。

---

## 4. `lib/model/state_model.dart` 函式整理

## 4.1 `AppModel`

| 成員 / 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `navigationIndex` setter | 切換 tab 並在特定條件清空搜尋字串 | 可以 | 保持 | Global UI state transition | 若規則更複雜，抽 `handleNavigationChange()` |
| `isLoading` setter | 更新 loading 並通知 UI | 好 | 保持 | Global UI state | 可改細分 `isInitialLoading` / `isPaging` |

### 命名建議

- `AppModel` 太廣，但在小專案可接受。
- 若未來拆層，較好的名字是：
  - `HomeUiState`
  - `NavigationModel`

---

## 4.2 `ComicListModel`

| 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `fetchEveryCollectionFuture()` | 更新收藏資料 Future | 名稱怪 | `refreshCollections()` 或 `loadCollections()` | Collection state refresh | 不應把 `Future` 暴露在名稱裡 |
| `fetchIndex()` | 抓首頁資料，本質上是空 query 搜尋 | 可以 | `fetchHomeFeed()` | Feed loading | 可與 `fetchSearch` 分離成更清楚的 API |
| `fetchSearch()` | 搜尋、重試、排序、cookie fallback 的核心函式 | 好但過重 | `fetchComicList()` 或 `searchComics()` | Core use case | 建議拆成 API client + retry policy + state reducer |
| `fetchPage()` | 抓下一頁或重抓第一頁 | 普通 | `fetchNextPage()` | Paging | 應把 `page == null` 的特殊語意拆乾淨 |

### 特別評論：`fetchSearch()`

這是目前整個專案的核心 use case，但責任非常多：

- 決定 query
- 決定語言 fallback
- 組 URL
- 做 HTTP request
- 做 cookie fallback
- 做 retry
- 更新 state
- 記錄 `_fetchPage`

它是功能正確的，但長期來看非常值得拆。

建議未來拆成：

- `NhentaiApiClient.searchComics(...)`
- `CloudflareAwareHttpClient`
- `SearchRetryPolicy`
- `ComicListStateReducer`

---

## 4.3 `CurrentComicModel`

| 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `currentComic` setter | 設定漫畫並自動寫入歷史紀錄 | 名稱普通，但 setter 有隱性副作用 | 保持，但需註解 | Domain state transition + history side effect | 應把副作用抽成 `onComicOpened()` |
| `fetchComic()` | 抓單本漫畫 API，支援 cookie fallback | 合理 | `loadComicDetail()` | Detail loading | 可抽到 `ComicDetailService` |
| `clearComic()` | 清空當前漫畫 | 好 | 保持 | State reset | 無 |

### 特別評論：`currentComic` setter

這是一個「表面像欄位，實際像 command」的 setter，因為它會：

- 寫 DB
- 寫 History

這不是壞事，但需要在文件或命名上讓人知道。

如果要更清楚，可改成：

- `openComic(NHComic comic)`

因為它更符合語意。

---

## 5. `lib/model/data_model.dart` 函式整理

這個檔案的函式幾乎都是「資料轉換」，命名本身大致合理。

## 5.1 `NHList`

| 函式 | 功能 | 命名建議 | 分類建議 | 未來建議 |
| --- | --- | --- | --- | --- |
| `NHList.fromJson()` | 把列表 API 結果轉成 `NHList` | 保持 | DTO mapper | 可改 codegen |
| `toJson()` | 把 `NHList` 轉回 Map | 保持 | DTO serializer | 同上 |

## 5.2 `NHComic`

| 函式 | 功能 | 命名建議 | 分類建議 | 未來建議 |
| --- | --- | --- | --- | --- |
| `NHComic.fromJson()` | 把單本漫畫資料轉成 `NHComic` | 保持 | DTO mapper | 可改 `json_serializable` |
| `toJson()` | 轉回 Map | 保持 | DTO serializer | 同上 |

## 5.3 `Title`, `NHImages`, `Pages`, `Tags`

| 函式 | 功能 | 命名建議 | 分類建議 | 未來建議 |
| --- | --- | --- | --- | --- |
| `fromJson()` | 把 API 片段轉成對應資料類型 | 保持 | DTO mapper | 可用 code generation |
| `toJson()` | 轉回 Map | 保持 | DTO serializer | 同上 |

### 命名評論

- `Title` 可能有點太泛，若未來專案變大可改成 `ComicTitle`
- `Pages` 單數/複數略不直觀，可考慮：
  - `ComicPageImage`
  - `ImageSpec`
- `Tags` 若改單數類別名 `Tag` 會更自然

### 未來擴充建議

這一層最適合的改進不是改名，而是改生成方式：

- `json_serializable`
- `freezed`

好處：

- 少手寫
- 更不容易漏欄位
- 不用手動維護 `fromJson/toJson`

---

## 6. `lib/theme.dart` 函式整理

這個檔案本質上是主題工廠，不是業務邏輯。

| 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `lightScheme()` | 回傳淺色配色資料 | 好 | 保持 | Theme factory | 無 |
| `light()` | 回傳淺色 `ThemeData` | 好 | 保持 | Theme factory | 無 |
| `lightMediumContrastScheme()` | 回傳淺色中對比配色 | 好 | 保持 | Theme factory | 無 |
| `lightMediumContrast()` | 回傳淺色中對比 `ThemeData` | 好 | 保持 | Theme factory | 無 |
| `lightHighContrastScheme()` | 回傳淺色高對比配色 | 好 | 保持 | Theme factory | 無 |
| `lightHighContrast()` | 回傳淺色高對比 `ThemeData` | 好 | 保持 | Theme factory | 無 |
| `darkScheme()` | 回傳深色配色資料 | 好 | 保持 | Theme factory | 無 |
| `dark()` | 回傳深色 `ThemeData` | 好 | 保持 | Theme factory | 無 |
| `darkMediumContrastScheme()` | 回傳深色中對比配色 | 好 | 保持 | Theme factory | 無 |
| `darkMediumContrast()` | 回傳深色中對比 `ThemeData` | 好 | 保持 | Theme factory | 無 |
| `darkHighContrastScheme()` | 回傳深色高對比配色 | 好 | 保持 | Theme factory | 無 |
| `darkHighContrast()` | 回傳深色高對比 `ThemeData` | 好 | 保持 | Theme factory | 無 |
| `theme(ColorScheme colorScheme)` | 根據 color scheme 組出 `ThemeData` | 可 | `buildThemeData()` | Theme assembly | 無 |
| `toColorScheme()` | 把 `MaterialScheme` 轉成 Flutter `ColorScheme` | 很好 | 保持 | Theme mapper | 無 |

### 命名觀察

- 這個檔案命名整體是好的。
- 若要更一致，`theme()` 可以改叫 `buildThemeData()`，語意會比單字 `theme` 更完整。

---

## 7. Android 原生層 `MainActivity.java`

| 函式 | 目前功能 | 命名評價 | 建議命名 | 分類建議 | 未來擴充建議 |
| --- | --- | --- | --- | --- | --- |
| `configureFlutterEngine()` | 註冊 MethodChannel，讓 Flutter 可呼叫原生取 cookie | 標準 override | 保持 | Native bridge setup | 無 |
| `receiveCFCookies()` | 從 `CookieManager` 讀 `https://nhentai.net` 的 cookie | 名稱可以，但偏舊式縮寫 | `readCloudflareCookies()` | Native bridge helper | 可回傳結構化資料而非裸字串 |

### 命名評論

- `receiveCFCookies()` 在 Flutter 與 Java 兩邊都出現了。
- 但兩邊的語意不完全一樣：
  - Java 端：真的去讀 cookie
  - Flutter 端：讀 cookie + 解析 + 存 DB + 觸發 fetchIndex

這容易造成混淆。

建議：

- Android 端：`readCloudflareCookies()`
- Flutter 端：`captureAndPersistCloudflareCookies()`

---

## 8. 哪些名字最值得優先改

如果你想做低風險、但顯著提升可讀性的命名調整，我會先改這幾個：

| 現名 | 建議名 | 原因 |
| --- | --- | --- |
| `FirstScreen` | `BootstrapScreen` / `CloudflareGateScreen` | 目前名稱毫無語意 |
| `ThirdScreen` | `ComicReaderScreen` | 現在完全不知道是漫畫閱讀頁 |
| `App` | `HomeScreen` / `HomeShell` | 不是整個 app，而是主畫面容器 |
| `Store` | `LocalStore` / `AppDatabaseStore` | 過於寬泛 |
| `fetchEveryCollectionFuture()` | `refreshCollections()` | 名稱不應暴露 Future 細節 |
| `testLastCFCookies()` | `validateStoredCloudflareCookies()` | 更精確 |
| `receiveCFCookies()` | `captureAndPersistCloudflareCookies()` | 更符合實際副作用 |
| `getComic()` | `debugPrintComics()` | 目前只是 debug，不是 query API |
| `NHPopularType` | `PopularSortType` | 應該是一個型別而不是常數袋 |
| `SimpleCachedNetworkImage` | `FallbackCachedNetworkImage` | 實際功能已不 simple |

---

## 9. 未來擴充性的修改建議

## 9.1 第一階段：低風險重構

這一階段幾乎不改行為，只改善結構。

### 建議項目

1. 把 `Store` 移到 `lib/storage/store.dart`
2. 把 `FirstScreen` 與 `ThirdScreen` 改名
3. 把 `App` 改名成 `HomeShell`
4. 把 `fetchEveryCollectionFuture()` 改名
5. 把圖片副檔名 / host fallback 常數移到獨立檔案

## 9.2 第二階段：責任分離

### 建議拆分

- `services/cloudflare_service.dart`
  - 管 `receiveCFCookies`
  - 管 `testLastCFCookies`

- `services/nhentai_api_client.dart`
  - 管 `fetchSearch`
  - 管 `fetchComic`

- `storage/collection_repository.dart`
  - 管 collection CRUD

- `storage/search_history_repository.dart`
  - 管 search history CRUD

- `widgets/comic_card.dart`
  - 對應 `ComicListItem`

- `widgets/fallback_cached_network_image.dart`
  - 對應 `SimpleCachedNetworkImage`

## 9.3 第三階段：更好的型別與 domain model

### 建議項目

1. `NHPopularType` 改 enum
2. 收藏夾名稱改 enum，例如：
   - `favorite`
   - `next`
   - `history`
3. `Store.getCollection()` / `getEveryCollection()` 不再回傳 `List<Map<String,Object?>>`
4. 建立專門的 DB row model 或 mapper

## 9.4 第四階段：可測試性改善

### 目前難測的點

- `fetchSearch()` 責任過多
- `Store` 與 DB 綁太死
- `FirstScreen` 同時處理 UI + side effects

### 建議做法

1. 把 HTTP client 注入，而不是在函式內直接 `Dio()`
2. 把 `Store` 介面化
3. 把 query fallback policy 抽出來
4. 為 `SimpleCachedNetworkImage` 的 URL fallback 產生器補單元測試

---

## 10. 最後的整理建議

如果你現在要開始做大一點的維護，我的建議順序是：

1. 改名：
   - `FirstScreen`
   - `ThirdScreen`
   - `App`
   - `fetchEveryCollectionFuture()`
2. 把 `Store` 抽檔
3. 把 `SimpleCachedNetworkImage` 抽檔
4. 把 `fetchSearch()` 拆成 service + state update
5. 把 `CollectionSliverGrid.childCount = 3` 改掉，避免未來收藏夾擴充卡住

---

## 11. 一句話總結

這個專案的函式目前大多「功能上可用、命名大致能看懂」，但最大的問題不是單點命名，而是：

- 太多責任集中在 `main.dart`
- 有些名稱只反映「畫面順序」，沒有反映「業務語意」
- 幾個核心函式同時做太多事

如果以未來可擴充性來看，最需要優先改善的是：

- 啟動畫面 / cookie 驗證流程
- Store 分層
- 首頁主畫面拆分
- API / retry / image fallback 的責任抽離

