//
//  UserData.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/06/12.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import Foundation

class UserData {
    
    // MARK: - Keys
    
    enum UserDefaultsKeys: String {
        // 仕訳帳
        case firstLunchJournals = "firstLunch_Journals"
        // 仕訳
        case firstLunchJournalEntry = "firstLunch_JournalEntry"
        // 設定勘定科目　初期化
        case settingsTaxonomyAccount = "settings_taxonomy_account"
        // サンプル仕訳データ
        case sampleJournalEntry = "sample_JournalEntry"
        // 精算表
        case firstLunchWorkSheet = "firstLunch_WorkSheet"
        // 試算表
        case firstLunchTrialBalance = "firstLunch_TrialBalance"
        // 会計期間
        case firstLunchSettingPeriod = "firstLunch_SettingPeriod"
        // 勘定科目
        case firstLunchSettingsCategory = "firstLunch_SettingsCategory"
        // 帳簿情報
        case firstLunchSettingsInformation = "firstLunch_SettingsInformation"
        // 設定　仕訳帳
        case firstLunchSettingsJournals = "firstLunch_SettingsJournals"
        // チュートリアル対応 ウォークスルー型
        case firstLunchWalkThrough = "firstLunch_WalkThrough"
        // 法人/個人フラグ　法人:true, 個人:false
        case corporationSwitch = "corporation_switch"
        // ローカル通知
        case localNotificationSwitch = "local_notification_switch"
        // ローカル通知 毎日
        case localNotificationEvereyDay = "localNotificationEvereyDay"
        // 生体認証パスコードロック設定スイッチ
        case biometricsSwitch = "biometrics_switch"
        // 生体認証パスコードロック
        case biometrics = "biometrics"
        // リワード広告　報酬
        case rewardAdCoinCount = "reward_ad_coin＿count"
        
        // アプリ起動回数をインクリメントする
        case startUpCount = "startUpCount"
        // 設定表示科目　初期化
        case settingsTaxonomy = "settings_taxonomy"
    }
    
    // MARK: - Data
    
    // MARK: リワード広告　報酬
    static var rewardAdCoinCount: Int {
        get {
            UserDefaults.standard.integer(forKey: UserDefaultsKeys.rewardAdCoinCount.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.rewardAdCoinCount.rawValue)
        }
    }
    
}
