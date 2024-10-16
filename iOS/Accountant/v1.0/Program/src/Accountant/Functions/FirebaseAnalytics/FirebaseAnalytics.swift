//
//  FirebaseAnalytics.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/02/02.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import FirebaseAnalytics // イベントログ対応

enum FirebaseAnalytics {

    static func logEvent(event: AnalyticsEvents, parameters: [String: NSObject]?) {
        // イベントログ
        Analytics.logEvent(
            event.description,
            parameters: parameters
        )
    }
}

enum AnalyticsEvents: CustomStringConvertible {
    // iCloudバックアップ
    case iCloudBackup
    // ローカル通知
    case localNotificationEvereyDay

    var description: String {
        switch self {
        case .iCloudBackup:
            return "icloud_backup"
        case .localNotificationEvereyDay:
            return "local_notification_everey_day"
        }
    }
}

enum AnalyticsEventParameters: CustomStringConvertible {
    // 処理種類
    case kind

    var description: String {
        switch self {
        case .kind:
            return "kind"
        }
    }
}

enum Parameter: CustomStringConvertible {
    // バックアップ
    case backup
    // リストア
    case restore
    // 削除
    case delete

    var description: String {
        switch self {
        case .backup:
            return "backup"
        case .restore:
            return "restore"
        case .delete:
            return "delete"
        }
    }
}
