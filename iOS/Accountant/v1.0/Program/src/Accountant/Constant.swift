//
//  Constant.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/11/02.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

enum Constant {

    // MARK: - App Store

    // Short Link
    static let APPSTOREAPPPAGESHORT = "https://apple.co/3Xnkc0m"
    // Content Link
    static let APPSTOREAPPPAGE = "https://apps.apple.com/us/app/%E8%A4%87%E5%BC%8F%E7%B0%BF%E8%A8%98%E3%81%AE%E4%BC%9A%E8%A8%88%E5%B8%B3%E7%B0%BF-paciolist-%E3%83%91%E3%83%81%E3%83%A7%E3%83%BC%E3%83%AA%E4%B8%BB%E7%BE%A9/id1535793378?itsct=apps_box_link&itscg=30200"

    // MARK: - マネタイズ対応

#if DEBUG
    // テスト用広告ユニットID
    static let ADMOBID = "ca-app-pub-3940256099942544/2934735716"
    // テスト用広告ユニットID インタースティシャル
    static let ADMOBIDINTERSTITIAL = "ca-app-pub-3940256099942544/4411468910"
    // テスト用広告ユニットID リワード
    static let ADMOB_ID_REWARD = "ca-app-pub-3940256099942544/1712485313"
#else
    // 広告ユニットID
    static let ADMOBID = "ca-app-pub-7616440336243237/8565070944"
    // 広告ユニットID インタースティシャル
    static let ADMOBIDINTERSTITIAL = "ca-app-pub-7616440336243237/4964823000"
    // 広告ユニットID リワード
    static let ADMOB_ID_REWARD = "ca-app-pub-7616440336243237/9207320341"
#endif
    // 広告を表示しない仕訳件数
    static let SHOW_REWARD_AD_COUNT: Int = 50

    // ニューモフィズム
    static let LIGHTSHADOWOPACITY: Float = 0.3
    static let DARKSHADOWOPACITY: Float = 0.5
    static let ELEMENTDEPTH: CGFloat = 5
    static let edged = false

    // MARK: - Firebase Analytics ログイベント

    // MARK: SELECT_CONTENT

    // パラメータ FirebaseAnalytics.Param.CONTENT_TYPE (String)
    static let JOURNALENTRY = "journalentry" // 仕訳画面
    static let JOURNALS = "journals"          // 仕訳帳画面
    static let WORKSHEET = "worksheet"        // 精算表画面

    // パラメータ FirebaseAnalytics.Param.ITEM_ID (String)
    static let ADDCOMPOUNDJOURNALENTRY = "add_compound_journalentry"   // 通常仕訳 複合仕訳
    static let ADDJOURNALENTRY = "add_journalentry"                    // 通常仕訳
    static let ADDADJUSTINGJOURNALENTRY = "add_adjustingjournalentry" // 決算整理仕訳
    static let DELETEJOURNALENTRY = "delete_journalentry"                    // 通常仕訳
    static let DELETEADJUSTINGJOURNALENTRY = "delete_adjustingjournalentry" // 決算整理仕訳

    // MARK: 法人：繰越利益勘定、個人事業主：元入金勘定

    static var capitalAccountName: String {
        // 法人/個人フラグ
        if UserDefaults.standard.bool(forKey: "corporation_switch") {
            return CapitalAccountType.retainedEarnings.rawValue
        } else {
            return CapitalAccountType.capital.rawValue
        }
    }
    
    // 月次推移表を更新する　true: リロードする
    static var needToReload = false
    // 仕訳画面の勘定科目を更新する　true: リロードする
    static var needToReloadCategory = false
    
    // MARK: レビュー促進ダイアログ
    
    static let NEED_SHOW_REVIEW_DIALOG = "NEED_SHOW_REVIEW_DIALOG"
    static let SHOW_REVIEW_DIALOG_DATE = "SHOW_REVIEW_DIALOG_DATE"
    static let PROCESS_COMPLETED_COUNT = "PROCESS_COMPLETED_COUNT"
    static let LAST_VERSION_PROMPETD_FOR_REVIEW = "LAST_VERSION_PROMPETD_FOR_REVIEW"
}
