//
//  NotificationService.swift
//  NotificationService
//
//  Created by Hisashi Ishihara on 2023/02/16.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    // プッシュ通知を受信した時に呼ばれる
    // NotificationServiceSTG か NotificationService を起動すると、Firebaseからプッシュ通知を送信して、デバッグできる
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        
        guard let aps = request.content.userInfo["aps"] as? [String: Any],
              let alert = aps["alert"] as? [String: Any],
              let title = alert["title"] as? String,
              let body = alert["body"] as? String else {
            contentHandler(bestAttemptContent)
            return
        }
        print(title, body)
        
        guard let fcmOptions = request.content.userInfo["fcm_options"] as? [String: Any],
              let image = URL(string: fcmOptions["image"] as? String ?? "") else {
            // 画像がない場合
            contentHandler(bestAttemptContent)
            return
        }
        print(title, body, image)

        // タイトルとボディを書き換え
        bestAttemptContent.title = title
        bestAttemptContent.body = body
        
        let downloadTask = URLSession.shared.downloadTask(with: image) { (url, _, _) in
            guard let url = url else {
                contentHandler(bestAttemptContent)
                return
            }
            // tempに保存
            let fileName = image.lastPathComponent
            let path = URL(fileURLWithPath: NSTemporaryDirectory().appending(fileName))
            
            do {
                try FileManager.default.moveItem(at: url, to: path)
                // 保存先のURLをプッシュ通知の表示領域に伝える
                let attachment = try UNNotificationAttachment(identifier: fileName, url: path, options: nil)
                bestAttemptContent.attachments = [attachment]
                contentHandler(bestAttemptContent)
            } catch {
                contentHandler(bestAttemptContent)
            }
        }
        downloadTask.resume()
    }
    
    // タイムアウト時に呼ばれる
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }


}
