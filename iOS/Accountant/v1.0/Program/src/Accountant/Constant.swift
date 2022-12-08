//
//  Constant.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/11/02.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

struct Constant {
    
    // MARK: - マネタイズ対応
    
#if DEBUG
    // テスト用広告ユニットID
    static let ADMOB_ID = "ca-app-pub-3940256099942544/2934735716"
    // テスト用広告ユニットID インタースティシャル
    static let ADMOB_ID_INTERSTITIAL = "ca-app-pub-3940256099942544/4411468910"
#else
    // 広告ユニットID
    static let ADMOB_ID = "ca-app-pub-7616440336243237/8565070944"
    // 広告ユニットID インタースティシャル
    static let ADMOB_ID_INTERSTITIAL = "ca-app-pub-7616440336243237/4964823000"
#endif
    
    // ニューモフィズム
    static let LIGHTSHADOWOPACITY: Float = 0.3
    static let DARKSHADOWOPACITY: Float = 0.5
    static let ELEMENTDEPTH: CGFloat = 5
    static let edged = false

    // MARK: - Firebase Analytics ログイベント

    // MARK: SELECT_CONTENT

    // パラメータ FirebaseAnalytics.Param.CONTENT_TYPE (String)
    static let JOURNAL_ENTRY = "journalentry" // 仕訳画面
    static let JOURNALS = "journals"          // 仕訳帳画面
    static let WORKSHEET = "worksheet"        // 精算表画面

    // パラメータ FirebaseAnalytics.Param.ITEM_ID (String)
    static let ADD_JOURNAL_ENTRY = "add_journalentry"                    // 通常仕訳
    static let ADD_ADJUSTING_JOURNAL_ENTRY = "add_adjustingjournalentry" // 決算整理仕訳
    static let DELETE_JOURNAL_ENTRY = "delete_journalentry"                    // 通常仕訳
    static let DELETE_ADJUSTING_JOURNAL_ENTRY = "delete_adjustingjournalentry" // 決算整理仕訳
}
