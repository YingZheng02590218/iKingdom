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
    
    // MARK: ローカル通知
    
    // 通知を登録
    func evereyDayTimerRequest(hour: Int, minute: Int) {
        // 通知時間を指定する部分
        // 毎朝xx時
        let dateComponents = DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone.current,
            hour: hour,
            minute: minute
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        let content = UNMutableNotificationContent()
        // 通知メッセージを指定
        // 先頭を0埋めする
        content.title = "\(String(format: "%02d", hour)):\(String(format: "%02d", minute)) 帳簿付けの時刻です"
        content.body = "今日の取引を入力しましょう📝"
        // この通知を受け取った直後の、アプリバッジの値を指定
        content.badge = 1
        // 通知音を指定
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "crrect_answer3.mp3"))
        // identifier には、他の通知設定と重複しない値を指定します
        let request = UNNotificationRequest(
            identifier: "localNotificationEvereyDay", // UUID().uuidString, 通知が重複してしまう。
            content: content,
            trigger: trigger
        )
        // ローカル通知をセット
        center.add(request) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        }
    }
    // 重複した通知を削除
    func deleteDuplicatedEvereyDayTimerRequest() {
        // 未配信の通知の一覧を取得する
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            if !requests.isEmpty {
                for request in requests {
                    // ローカル通知のプロパティを取り出す
                    print("ローカル通知 未配信の通知")
                    print("identifier: ", request.identifier)
                    print("title: ", request.content.title)
                    print("body: ", request.content.body)
                    if request.identifier != "localNotificationEvereyDay" {
                        // 特定の未配信の通知を削除する
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
                    }
                }
            }
        }
    }
    // 指定時刻
    var time: Date = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "ja_JP")
        df.timeZone = .current
        df.dateStyle = .none
        df.timeStyle = .short
        // 時刻
        if let time = UserDefaults.standard.string(forKey: "localNotificationEvereyDay") {
            let array = time.components(separatedBy: ":")
            print("hour", array[0])
            print("minute", array[1])
            return df.date(from: "\(array[0]):\(array[1])") ?? Date()
        } else {
            return Date()
        }
    }()
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
            completionHandler()
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
