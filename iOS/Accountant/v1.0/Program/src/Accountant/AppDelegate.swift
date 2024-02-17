//
//  AppDelegate.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2019/11/12.
//  Copyright © 2019 Hisashi Ishihara. All rights reserved.
//

// import NeuKit
import AdSupport // IDFA対応
import AppTrackingTransparency // IDFA対応
import Firebase // マネタイズ対応
import FirebaseMessaging // Push通知
import GoogleMobileAds
import RealmSwift
import SwiftyStoreKit // アップグレード機能　スタンダードプラン

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    public var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 4,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 0 {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
                // スキーマバージョン
                if oldSchemaVersion < 1 {
                    // DataBaseTaxonomyオブジェクトを列挙します
                    migration.enumerateObjects(ofType: DataBaseTaxonomy.className()) { oldObject, newObject in
                        _ = oldObject?["fiscalYear"] as? Int
                        // プロパティを追加します
                        newObject?["numberOfTaxonomy"] = 0
                        _ = oldObject?["accountName"] as? String
                        _ = oldObject?["total"] as? Int64
                    }
                }
                // スキーマバージョン
                if oldSchemaVersion < 2 {
                    // DataBaseAccountingBooksShelfオブジェクトを列挙します
                    migration.enumerateObjects(ofType: DataBaseAccountingBooksShelf.className()) { oldObject, newObject in
                        // 開始残高
                        newObject?["dataBaseOpeningBalanceAccount"] = nil
                    }
                    // DataBaseAccountオブジェクトを列挙します
                    migration.enumerateObjects(ofType: DataBaseAccount.className()) { oldObject, newObject in
                        // 損益振替仕訳
                        newObject?["dataBaseTransferEntry"] = nil
                    }
                    // DataBasePLAccountオブジェクトを列挙します
                    migration.enumerateObjects(ofType: DataBasePLAccount.className()) { oldObject, newObject in
                        // 開始仕訳（前年度の残高振替仕訳の逆仕訳）
                        newObject?["dataBaseOpeningJournalEntry"] = nil
                        // 勘定名
                        newObject?["accountName"] = "損益"
                        // 損益振替仕訳
                        newObject?["dataBaseTransferEntries"] = List<DataBaseTransferEntry>()
                        // 資本振替仕訳
                        newObject?["dataBaseCapitalTransferJournalEntry"] = nil
                    }
                    // DataBaseGeneralLedgerオブジェクトを列挙します
                    migration.enumerateObjects(ofType: DataBaseGeneralLedger.className()) { oldObject, newObject in
                        // 資本金勘定
                        newObject?["dataBaseCapitalAccount"] = nil
                    }
                    // DataBaseJournalsオブジェクトを列挙します
                    migration.enumerateObjects(ofType: DataBaseJournals.className()) { oldObject, newObject in
                        // 資本振替仕訳
                        newObject?["dataBaseCapitalTransferJournalEntry"] = nil
                    }
                    // DataBaseFinancialStatementsオブジェクトを列挙します
                    migration.enumerateObjects(ofType: DataBaseFinancialStatements.className()) { oldObject, newObject in
                        // 繰越試算表
                        newObject?["afterClosingTrialBalance"] = nil
                    }
                    // DataBaseSettingsOperatingオブジェクトを列挙します
                    migration.enumerateObjects(ofType: DataBaseSettingsOperating.className()) { oldObject, newObject in
                        // 損益振替仕訳 初期値はON
                        newObject?["EnglishFromOfClosingTheLedger0"] = true
                        // 資本振替仕訳 初期値はON
                        newObject?["EnglishFromOfClosingTheLedger1"] = true
                        // 残高振替仕訳 初期値はON
                        newObject?["EnglishFromOfClosingTheLedger2"] = true
                    }
                }
                // スキーマバージョン
                if oldSchemaVersion < 3 {
                    // DataBaseSettingsOperatingオブジェクトを列挙します
                    migration.enumerateObjects(ofType: DataBaseSettingsOperatingJournalEntry.className()) { oldObject, newObject in
                        // 設定仕訳画面 よく使う仕訳
                        // グループID 初期値は 0
                        newObject?["group"] = 0
                    }
                }
                // スキーマバージョン
                if oldSchemaVersion < 4 {
                    // DataBaseAccountオブジェクトを列挙します
                    migration.enumerateObjects(ofType: DataBaseAccount.className()) { oldObject, newObject in
                        // 月次残高振替仕訳
                        newObject?["dataBaseMonthlyTransferEntries"] = List<DataBaseMonthlyTransferEntry>()
                    }
                }
            }
        )
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        print(config) // schemaVersion を確認できる
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()
        // Override point for customization after application launch.
        
        // // マネタイズ対応　Use Firebase library to configure APIs
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        // プッシュ通知のパーミッションを初めて取得した直後のapplication(_:didRegisterForRemoteNotificationsWithDeviceToken:)では、FCMトークンがまだ生成されておらず、FIRInstanceID.instanceID().token()の値がnilになることがある
        // なので、オブザーバを利用して確実に取得するのがオススメらしい (addRefreshFcmTokenNotificationObserver())
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.fcmTokenRefreshNotification(_:)),
            name: .MessagingRegistrationTokenRefreshed,
            object: nil
        )
        // Push通知　バッジ
        application.applicationIconBadgeNumber = 0
        // イベントログ
        // Analytics.setUserID("123456")
        // UserDefaultsをセットアップ
        setupUserDefaults()
        
        // アップグレード機能
        // アプリ起動時にトランザクションの監視を開始します
        initSwiftyStorekit()
        // アプリ起動時にネットに繋いでAppStoreで購入済みか確認する（1件のみ有料アイテムを登録）
        UpgradeManager.shared.isPurchasedWhenAppStart()
        Network.shared.setUp() // 初期化対応
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        // 生体認証パスコードロック 認証を要求する
        // applicationWillResignActive: フォアグラウンドからバックグラウンドへ移行しようとした時
        UserDefaults.standard.set(true, forKey: "biometrics")
        UserDefaults.standard.synchronize()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        
        // 生体認証パスコードロック
        // アプリをバックグラウンドに持っていった状態から再度フォアグラウンドへアプリを復帰させる場合
        showPassCodeLock()
        // ローカル通知
        if UserDefaults.standard.bool(forKey: "local_notification_switch") {
            if let time = UserDefaults.standard.string(forKey: "localNotificationEvereyDay") {
                // 文字列を分割する
                let array = time.components(separatedBy: ":")
                print("hour", array[0])
                print("minute", array[1])
                if let hour = Int(array[0]),
                   let minute = Int(array[1]) {
                    // 通知を登録
                    UserNotificationUtility.shared.evereyDayTimerRequest(hour: hour, minute: minute)
                    // 重複した通知を削除
                    UserNotificationUtility.shared.deleteDuplicatedEvereyDayTimerRequest()
                }
            }
        } else {
            // 全ての未配信の通知を削除する
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // IDFA対応
        if #available(iOS 14, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized:
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            case .denied:
                print("😭拒否")
            case .restricted:
                print("🥺制限")
            case .notDetermined:
                showRequestTrackingAuthorizationAlert()
            @unknown default:
                fatalError()
            }
        } else {// iOS14未満
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            } else {
                print("🥺制限")
            }
        }
    }
    
    // MARK: - APNs 登録
    
    // APNs 登録成功時に呼ばれる
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenStr: String = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        print("APNsトークン: \(deviceTokenStr)")
        
        // APNsトークンを、FCM登録トークンにマッピング
        Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
        // Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("FCMトークン: \(token)")
            }
        }
    }
    // APNs 登録失敗時に呼ばれる
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs 登録に失敗しました : \(error.localizedDescription)")
    }
    
    // MARK: - Push通知を受信した時
    
    // Push通知を受信した時（サイレントプッシュ）
    // payload に "Content-available"=1 が設定されている、かつ
    // BackgroundModes の RemoteNotification の設定も必要
    // 実機で、Firebaseからプッシュ通知を送信しても、デバッグできない
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if #available(iOS 10.0, *) {
            print("iOS 10.0 未満")
        } else {
            Messaging.messaging().appDidReceiveMessage(userInfo)
        }
        
        completionHandler(.newData)
    }
    
    @objc
    func fcmTokenRefreshNotification(_ notification: Notification) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("FCMトークン: \(token)")
            }
        }
    }
    // UserDefaultsをセットアップ
    func setupUserDefaults() {
        // チュートリアル対応 コーチマーク型　初回起動時　4行を追加
        let userDefaults = UserDefaults.standard
        // 仕訳帳
        var firstLunchKey = "firstLunch_Journals"
        var firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        // userDefaults.set(true, forKey: firstLunchKey)
        // 仕訳
        firstLunchKey = "firstLunch_JournalEntry"
        firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        // userDefaults.set(true, forKey: firstLunchKey)
        // サンプル仕訳データ
        firstLunchKey = "sample_JournalEntry"
        firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        // userDefaults.set(true, forKey: firstLunchKey)
        // 精算表
        firstLunchKey = "firstLunch_WorkSheet"
        firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        // userDefaults.set(true, forKey: firstLunchKey)
        // 試算表
        firstLunchKey = "firstLunch_TrialBalance"
        firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        // userDefaults.set(true, forKey: firstLunchKey)
        // 会計期間
        firstLunchKey = "firstLunch_SettingPeriod"
        firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        // userDefaults.set(true, forKey: firstLunchKey)
        // 勘定科目
        firstLunchKey = "firstLunch_SettingsCategory"
        firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        // userDefaults.set(true, forKey: firstLunchKey)
        // 帳簿情報
        firstLunchKey = "firstLunch_SettingsInformation"
        firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        // userDefaults.set(true, forKey: firstLunchKey)
        // 設定　仕訳帳
        firstLunchKey = "firstLunch_SettingsJournals"
        firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        // userDefaults.set(true, forKey: firstLunchKey)
        // チュートリアル対応 ウォークスルー型
        firstLunchKey = "firstLunch_WalkThrough"
        firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        // userDefaults.set(true, forKey: firstLunchKey)
        // 法人/個人フラグ　法人:true, 個人:false
        firstLunchKey = "corporation_switch"
        firstLunch = [firstLunchKey: false] // 初期値は個人とする
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        //　userDefaults.set(true, forKey: firstLunchKey)
        // ローカル通知
        firstLunchKey = "local_notification_switch"
        firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        // userDefaults.set(true, forKey: firstLunchKey)
        // ローカル通知 毎日
        firstLunchKey = "localNotificationEvereyDay"
        let localNotificationTime = [firstLunchKey: "19:00"]
        userDefaults.register(defaults: localNotificationTime)
        // 動作確認用
        // userDefaults.set("21:00", forKey: firstLunchKey)
        // 生体認証パスコードロック設定スイッチ
        firstLunchKey = "biometrics_switch"
        firstLunch = [firstLunchKey: false] // 初期値はOFFとする
        userDefaults.register(defaults: firstLunch)
        // 動作確認用
        // userDefaults.set(true, forKey: firstLunchKey)
        // 生体認証パスコードロック
        firstLunchKey = "biometrics"
        firstLunch = [firstLunchKey: true]
        userDefaults.register(defaults: firstLunch)
        // ロック中
        userDefaults.set(true, forKey: firstLunchKey)
    }
    
    // MARK: - アップグレード機能
    
    // アップグレード機能　アプリ起動時にトランザクションの監視を開始します
    func initSwiftyStorekit() {
        // see notes below for the meaning of Atomic / Non-Atomic
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: - IDFA対応
    
    /// Alert表示
    private func showRequestTrackingAuthorizationAlert() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    print("🎉")
                    // IDFA取得
                    print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied, .restricted, .notDetermined:
                    print("😭")
                @unknown default:
                    fatalError()
                }
            })
        }
    }
    
    // MARK: - 生体認証パスコードロック
    
    // 生体認証パスコードロック画面へ遷移させる
    func showPassCodeLock() {
        // パスコードロックを設定していない場合は何もしない
        if !UserDefaults.standard.bool(forKey: "biometrics_switch") {
            return
        }
        // 生体認証パスコードロック　フォアグラウンドへ戻ったとき
        let ud = UserDefaults.standard
        let firstLunchKey = "biometrics"
        if ud.bool(forKey: firstLunchKey) {
            DispatchQueue.global(qos: .default).async {
                DispatchQueue.main.async {
                    // 生体認証パスコードロック
                    if let viewController = UIStoryboard(name: "PassCodeLockViewController", bundle: nil)
                        .instantiateViewController(withIdentifier: "PassCodeLockViewController") as? PassCodeLockViewController {
                        
                        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                            
                            // 現在のrootViewControllerにおいて一番上に表示されているViewControllerを取得する
                            var topViewController: UIViewController = rootViewController
                            while let presentedViewController = topViewController.presentedViewController {
                                topViewController = presentedViewController
                            }
                            
                            // すでにパスコードロック画面がかぶせてあるかを確認する
                            let isDisplayedPasscodeLock: Bool = topViewController.children.map {
                                $0 is PassCodeLockViewController
                            }
                                .contains(true)
                            
                            // パスコードロック画面がかぶせてなければかぶせる
                            if !isDisplayedPasscodeLock {
                                let nav = UINavigationController(rootViewController: viewController)
                                nav.modalPresentationStyle = .overFullScreen
                                nav.modalTransitionStyle   = .crossDissolve
                                topViewController.present(nav, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
}
