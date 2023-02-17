//
//  UserNotificationUtility.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/02/17.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import FirebaseMessaging // Push通知
import UserNotifications // Push通知

final class UserNotificationUtility: NSObject {
    
    static var shared = UserNotificationUtility()
    private var center = UNUserNotificationCenter.current()
    
    func initialize() {
        center.delegate = UserNotificationUtility.shared
    }
    // Push通知 Firebase
    func showPushPermit(completion: @escaping (Result<Bool, Error>) -> Void) {
        // プッシュ通知の許可を要求
        center.requestAuthorization(options: [.alert, .badge, .sound]) { isGranted, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                print("プッシュ通知許可要求エラー : \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            print("プッシュ通知が \(isGranted ? "許可" : "拒否") されました。")
            completion(.success(isGranted))
        }
    }
}

extension UserNotificationUtility: UNUserNotificationCenterDelegate {
        
    // フォアグラウンドで通知を受信した時
    // UNUserNotificationCenter.current().delegate = self も必須
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo as NSDictionary
        print("userNotificationCenter willPresent : userInfo=\(userInfo)")
        
        // push通知設定したい場合
        // badgeは設定しないほうが良いかも
        if #available(iOS 14.0, *) {
            // banner: 端末上部にバナー表示
            // list: 通知センターに表示
            // sound: 通知音
            // badge: バッジ
            completionHandler([.list, .banner, .badge, .sound]) // alertはdeprecated
        } else {
            // Fallback on earlier versions
            completionHandler([.alert, .badge, .sound])
        }
        
        // 通知を押したので通知フラグのアイコンを消す
        // 上部でbadgeを設定した場合、消せる
        // UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // MARK: - Push通知がタップされた時
    
    // Push通知がタップされた時
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 通知の情報を取得
        let notification = response.notification
        // リモート通知かローカル通知かを判別
        if notification.request.trigger is UNPushNotificationTrigger {
            print("didReceive Push Notification")
        } else {
            print("didReceive Local Notification")
        }
        // 通知の ID を取得
        print("notification.request.identifier: \(notification.request.identifier)")
        // 通知を押したので通知フラグのアイコンを消す
        UIApplication.shared.applicationIconBadgeNumber = 0
        // push通知に付随しているデータを取得
        let userInfo = response.notification.request.content.userInfo as NSDictionary
        print("userNotificationCenter didReceive : userInfo=\(userInfo)")
        // アクションによって処理を分岐する
        guard let action = userInfo["action"] as? String else {
            completionHandler()
            return
        }
        print(action)
        // アップデートのお知らせ
        if action == PushNotificationAction.appStore.description {
            // 外部でブラウザを開く
            let url = URL(string: Constant.APPSTOREAPPPAGE)
            if let url = url {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
        // ホワイトリスト 【whitelist】 WL
        // 対象を選別して受け入れたり拒絶したりする仕組みの一つで、受け入れる対象を列挙した目録（リスト）を作り、そこに載っていないものは拒絶する方式。また、そのような目録のこと。
        // IT分野では、通信やアクセスを許可する対象やアドレスなどのリストを作成し、それ以外は拒否・禁止する方式を「ホワイトリスト方式」という。許可したい対象が特定可能で、拒否したい対象より少数の場合に適している。
        
        completionHandler()
    }
}
// Push通知をタップされた時のアクション
enum PushNotificationAction: CustomStringConvertible {
    // カスタムデータ
    // キー: action
    
    // 値:
    // AppStore アプリページ
    case appStore

    var description: String {
        switch self {
        case .appStore:
            return "appStore"
        }
    }
}
