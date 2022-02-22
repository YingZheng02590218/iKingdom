//
//  AppDelegate.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2019/11/12.
//  Copyright © 2019 Hisashi Ishihara. All rights reserved.
//

//import NeuKit
import RealmSwift
import Firebase // マネタイズ対応
import GoogleMobileAds
import SwiftyStoreKit // アップグレード機能　スタンダードプラン
import StoreKit
import AppTrackingTransparency // IDFA対応
import AdSupport // IDFA対応


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 0) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
                // DataBaseTaxonomyオブジェクトを列挙します
                migration.enumerateObjects(ofType: DataBaseTaxonomy.className()) { oldObject, newObject in
                    // スキーマバージョンが0のときだけ、'numberOfTaxonomy'プロパティを追加します
                    if oldSchemaVersion < 1 {
                        let fiscalYear = oldObject!["fiscalYear"] as! Int
                        newObject!["numberOfTaxonomy"] = 0
                        let accountName = oldObject!["accountName"] as! String
                        let total = oldObject!["total"] as! Int64
                    }
                }
        })

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        print(config) // schemaVersion を確認できる
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        let realm = try! Realm()
        // Override point for customization after application launch.
        
        // // マネタイズ対応　Use Firebase library to configure APIs
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        // チュートリアル対応　初回起動時　4行を追加
        let ud = UserDefaults.standard
        // 仕訳帳
        var firstLunchKey = "firstLunch_Journals"
        var firstLunch = [firstLunchKey: true]
        ud.register(defaults: firstLunch)
        // 動作確認用
//        ud.set(true, forKey: firstLunchKey)
//        print(ud.bool(forKey: firstLunchKey))
        // 仕訳
        firstLunchKey = "firstLunch_JournalEntry"
        firstLunch = [firstLunchKey: true]
        ud.register(defaults: firstLunch)
        // 動作確認用
//        ud.set(true, forKey: firstLunchKey)
//        print(ud.bool(forKey: firstLunchKey))
        // 精算表
        firstLunchKey = "firstLunch_WorkSheet"
        firstLunch = [firstLunchKey: true]
        ud.register(defaults: firstLunch)
        // 動作確認用
//        ud.set(true, forKey: firstLunchKey)
//        print(ud.bool(forKey: firstLunchKey))
        // 試算表
        firstLunchKey = "firstLunch_TrialBalance"
        firstLunch = [firstLunchKey: true]
        ud.register(defaults: firstLunch)
        // 動作確認用
//        ud.set(true, forKey: firstLunchKey)
//        print(ud.bool(forKey: firstLunchKey))
        // 会計期間
        firstLunchKey = "firstLunch_SettingPeriod"
        firstLunch = [firstLunchKey: true]
        ud.register(defaults: firstLunch)
        // 動作確認用
//        ud.set(true, forKey: firstLunchKey)
//        print(ud.bool(forKey: firstLunchKey))
        // 勘定科目
        firstLunchKey = "firstLunch_SettingsCategory"
        firstLunch = [firstLunchKey: true]
        ud.register(defaults: firstLunch)
        // 動作確認用
//        ud.set(true, forKey: firstLunchKey)
//        print(ud.bool(forKey: firstLunchKey))
        // 帳簿情報
        firstLunchKey = "firstLunch_SettingsInformation"
        firstLunch = [firstLunchKey: true]
        ud.register(defaults: firstLunch)
        // 動作確認用
//        ud.set(true, forKey: firstLunchKey)
//        print(ud.bool(forKey: firstLunchKey))
        // 設定　仕訳帳
        firstLunchKey = "firstLunch_SettingsJournals"
        firstLunch = [firstLunchKey: true]
        ud.register(defaults: firstLunch)
        // 動作確認用
//        ud.set(true, forKey: firstLunchKey)
//        print(ud.bool(forKey: firstLunchKey))

        // レビュー催促機能
        let key = "startUpCount"
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: key) + 1, forKey: key)
        UserDefaults.standard.synchronize()
        let count = UserDefaults.standard.integer(forKey: key)
        if count == 15 { // 起動が15回目にレビューを催促する
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
        }
        // アップグレード機能　スタンダードプラン　see notes below for the meaning of Atomic / Non-Atomic
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
                default:
                    break
                }
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
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
        }
        else {// iOS14未満
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            } else {
                print("🥺制限")
            }
        }
    }

    func application(_ app: UIApplication, open inputURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Ensure the URL is a file URL
        guard inputURL.isFileURL else { return false }
                
        // Reveal / import the document at the URL
        guard let documentBrowserViewController = window?.rootViewController as? DocumentBrowserViewController else { return false }

        documentBrowserViewController.revealDocument(at: inputURL, importIfNeeded: true) { (revealedDocumentURL, error) in
            if let error = error {
                // Handle the error appropriately
                print("Failed to reveal the document at URL \(inputURL) with error: '\(error)'")
                return
            }
            
            // Present the Document View Controller for the revealed URL
            documentBrowserViewController.presentDocument(at: revealedDocumentURL!)
        }

        return true
    }

    ///Alert表示
    private func showRequestTrackingAuthorizationAlert() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    print("🎉")
                    //IDFA取得
                    print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied, .restricted, .notDetermined:
                    print("😭")
                @unknown default:
                    fatalError()
                }
            })
        }
    }
}

