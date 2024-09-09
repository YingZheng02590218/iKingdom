//
//  JournalEntryPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/05/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Firebase // イベントログ対応
import Foundation
/// GUIアーキテクチャ　MVP
protocol JournalEntryPresenterInput {
    
    func viewDidLoad()
    
    func viewWillAppear()
    
    func viewDidAppear()
    
    func viewDidLayoutSubviews()
    // チュートリアル対応 コーチマーク型
    func showAnnotation()
    // 入力ボタン
    func inputButtonTapped(isForced: Bool, journalEntryType: JournalEntryType, journalEntryData: JournalEntryData?, journalEntryDatas: [JournalEntryData]?, primaryKey: Int?)
    // OKボタン ダイアログ　オフライン
    func okButtonTappedDialogForOfline()
    // アップグレード画面を表示
    func showUpgradeScreen()
}

protocol JournalEntryPresenterOutput: AnyObject {
    
    func setupUI()
    
    func updateUI()
    // 生体認証パスコードロック画面へ遷移させる
    func showPassCodeLock()
    // チュートリアル対応 ウォークスルー型
    func showWalkThrough()
    // ニューモフィズム　ボタンとビューのデザインを指定する
    func createEMTNeumorphicView()
    // チュートリアル対応 コーチマーク型　コーチマークを開始
    func presentAnnotation()
    // 仕訳一括編集　の処理
    func buttonTappedForJournalEntriesPackageFixing() -> JournalEntryData
    // ダイアログ　オフライン
    func showDialogForOfline()
    // ダイアログ　日付と借方勘定科目、貸方勘定科目、金額が同一
    func showDialogForSameJournalEntry(journalEntryType: JournalEntryType, journalEntryData: JournalEntryData)
    // ダイアログ　ほんとうに変更しますか？
    func showDialogForFinal(journalEntryData: JournalEntryData)
    // 画面を閉じる　仕訳帳へ編集した仕訳データを渡す
    func closeScreen(journalEntryData: JournalEntryData)
    // アップグレード画面を表示
    func showUpgradeScreen()
    // ダイアログ 記帳しました
    func showDialogForSucceed()
    // 決算整理仕訳後に遷移元画面へ戻る
    func goBackToPreviousScreen()
    // 仕訳帳画面へ戻る
    func goBackToJournalsScreen(number: Int)
    // 仕訳帳画面へ戻る
    func goBackToJournalsScreenJournalEntry(number: Int)
    // ダイアログ　リワード広告　仕訳を入力する（広告動画を見る）/　広告を非表示（アップグレード）
    func showDialogForRewardAd()
}

final class JournalEntryPresenter: JournalEntryPresenterInput {
    
    // MARK: - var let
    
    private weak var view: JournalEntryPresenterOutput!
    private var model: JournalEntryModelInput
    
    init(view: JournalEntryPresenterOutput, model: JournalEntryModelInput) {
        self.view = view
        self.model = model
    }
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        view.setupUI()
        // 生体認証パスコードロック
        // アプリを未起動状態から再度アプリを起動させる場合
        view.showPassCodeLock()
    }
    
    func viewWillAppear() {
        view.updateUI()
    }
    
    func viewDidAppear() {
        // チュートリアル対応 ウォークスルー型
        view.showWalkThrough()
    }
    
    func viewDidLayoutSubviews() {
        // ニューモフィズム　ボタンとビューのデザインを指定する
        view.createEMTNeumorphicView()
    }
    // チュートリアル対応 コーチマーク型
    // ウォークスルーが終了後に、呼び出される
    func showAnnotation() {
        // チュートリアル対応 コーチマーク型　初回起動時　7行を追加
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunch_JournalEntry"
        if userDefaults.bool(forKey: firstLunchKey) {
            DispatchQueue.main.async {
                // コーチマークを開始
                self.view.presentAnnotation()
            }
        }
    }
    
    /// 入力ボタン
    /// ロジック
    /// 条件
        /// サブスクリプション　(購入済み / 未購入)
        /// データベース　仕訳入力件数　(50件超 / 50件以下)
        /// ネットワーク接続　(オンライン / オフライン)
    /// ダイアログ
        /// ① ダイアログ　リワード広告　(広告動画を見る / 広告を非表示)
        /// ② ダイアログ　日付と借方勘定科目、貸方勘定科目、金額が同一
        /// ③ ダイアログ　ほんとうに変更しますか？
    /// 遷移元画面
        /// 仕訳一括編集 　　仕訳帳画面からの遷移の場合
        /// 仕訳 　　　　　　仕訳帳画面からの遷移の場合
        /// 決算整理仕訳 　　精算表画面からの遷移の場合
        /// 仕訳 　　　　　　タブバーの仕訳タブからの遷移の場合
        /// 決算整理仕訳 　　タブバーの仕訳タブからの遷移の場合
        /// 仕訳編集 　　　　勘定画面・仕訳帳画面からの遷移の場合
        /// 決算整理仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
    func inputButtonTapped(
        isForced: Bool = false,
        journalEntryType: JournalEntryType,
        journalEntryData: JournalEntryData? = nil,
        journalEntryDatas: [JournalEntryData]? = nil,
        primaryKey: Int? = nil
    ) {
        if isForced {
            // ダイアログでOKを押した
        } else {
            // アップグレード機能　スタンダードプラン 未購入
            if !UpgradeManager.shared.inAppPurchaseFlag {
                // オフラインの場合広告が表示できないので、ネットワーク接続を確認する
                guard Network.shared.isOnline() else { // ネットワークあり
                    // ダイアログ　オフライン
                    view.showDialogForOfline()
                    return
                }
                // 仕訳が50件以上入力済みの場合は毎回広告を表示する　マネタイズ対応
                let results = DataBaseManagerJournalEntry.shared.getJournalEntryCount()
                if results.count > Constant.SHOW_REWARD_AD_COUNT {
                    
                    let count = journalEntryType == .CompoundJournalEntry ? journalEntryDatas?.count ?? 0 : 1
                    // リワード　報酬を消費
                    guard spendCoin(count: count) else {
                        // ダイアログ　リワード広告　仕訳を入力する（広告動画を見る）/　広告を非表示（アップグレード）
                        view.showDialogForRewardAd()
                        return
                    }
                    // 仕訳 50件以下　広告を表示しない
                }
            }
        }
        
        switch journalEntryType {
            
        case .JournalEntry:
            // 仕訳 タブバーの仕訳タブからの遷移の場合
            // 仕訳
            if let journalEntryData = journalEntryData {
                model.addJournalEntry(isForced: isForced, journalEntryData: journalEntryData) { _ in
                    // ダイアログ 記帳しました
                    view.showDialogForSucceed()
                    // イベントログ
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterContentType: Constant.JOURNALENTRY,
                        AnalyticsParameterItemID: Constant.ADDJOURNALENTRY
                    ])
                } errorHandler: { numbers in
                    print("仕訳　日付と借方勘定科目、貸方勘定科目、金額が同一の仕訳", numbers)
                    // ダイアログ　日付と借方勘定科目、貸方勘定科目、金額が同一
                    view.showDialogForSameJournalEntry(journalEntryType: journalEntryType, journalEntryData: journalEntryData)
                }
            }
        case .AdjustingAndClosingEntry:
            // 決算整理仕訳 タブバーの仕訳タブからの遷移の場合
            // 決算整理仕訳
            if let journalEntryData = journalEntryData {
                model.addAdjustingJournalEntry(journalEntryData: journalEntryData) { _ in
                    // 決算整理仕訳後に遷移元画面へ戻る
                    view.goBackToPreviousScreen()
                    // イベントログ
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterContentType: Constant.JOURNALENTRY,
                        AnalyticsParameterItemID: Constant.ADDADJUSTINGJOURNALENTRY
                    ])
                }
            }
        case .JournalEntries:
            // 仕訳 仕訳帳画面からの遷移の場合
            // 仕訳
            if let journalEntryData = journalEntryData {
                model.addJournalEntry(isForced: isForced, journalEntryData: journalEntryData) { number in
                    // 仕訳帳画面へ戻る
                    view.goBackToJournalsScreenJournalEntry(number: number)
                    // イベントログ
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterContentType: Constant.JOURNALS,
                        AnalyticsParameterItemID: Constant.ADDJOURNALENTRY
                    ])
                } errorHandler: { numbers in
                    print("仕訳　日付と借方勘定科目、貸方勘定科目、金額が同一の仕訳", numbers)
                    // ダイアログ　日付と借方勘定科目、貸方勘定科目、金額が同一
                    view.showDialogForSameJournalEntry(journalEntryType: journalEntryType, journalEntryData: journalEntryData)
                }
            }
        case .AdjustingAndClosingEntries:
            // 決算整理仕訳 精算表画面からの遷移の場合
            // 決算整理仕訳
            if let journalEntryData = journalEntryData {
                model.addAdjustingJournalEntry(journalEntryData: journalEntryData) { _ in
                    // 決算整理仕訳後に遷移元画面へ戻る
                    view.goBackToPreviousScreen()
                    // イベントログ
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterContentType: Constant.WORKSHEET,
                        AnalyticsParameterItemID: Constant.ADDADJUSTINGJOURNALENTRY
                    ])
                }
            }
        case .JournalEntriesFixing:
            // 仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
            if let primaryKey = primaryKey {
                // 仕訳 更新
                if let journalEntryData = journalEntryData {
                    model.updateJournalEntry(journalEntryData: journalEntryData, primaryKey: primaryKey) { number in
                        // 勘定画面・仕訳帳画面へ戻る
                        view.goBackToJournalsScreen(number: number)
                    }
                }
            }
        case .AdjustingEntriesFixing:
            // 決算整理仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
            if let primaryKey = primaryKey {
                // 決算整理仕訳 更新
                if let journalEntryData = journalEntryData {
                    model.updateAdjustingJournalEntry(journalEntryData: journalEntryData, primaryKey: primaryKey) { number in
                        // 勘定画面・仕訳帳画面へ戻る
                        view.goBackToJournalsScreen(number: number)
                    }
                }
            }
        case .JournalEntriesPackageFixing:
            // 仕訳一括編集 仕訳帳画面からの遷移の場合
            if let journalEntryData = journalEntryData {
                if isForced {
                    // 画面を閉じる　仕訳帳へ編集した仕訳データを渡す
                    view.closeScreen(journalEntryData: journalEntryData)
                } else {
                    // ダイアログ　ほんとうに変更しますか？
                    view.showDialogForFinal(journalEntryData: journalEntryData)
                }
            }
        case .SettingsJournalEntries, .SettingsJournalEntriesFixing:
            break
        case .CompoundJournalEntry:
            // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
            // 仕訳
            if let journalEntryDatas = journalEntryDatas {
                model.addJournalEntry(journalEntryDatas: journalEntryDatas) {
                    // ダイアログ 記帳しました
                    view.showDialogForSucceed()
                    // イベントログ
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterContentType: Constant.JOURNALENTRY,
                        AnalyticsParameterItemID: Constant.ADDCOMPOUNDJOURNALENTRY
                    ])
                }
            }
        case .Undecided:
            break
        }
        // 月次推移表を更新する　true: リロードする
        Constant.needToReload = true
    }
    // OKボタン ダイアログ　オフライン
    func okButtonTappedDialogForOfline() {
        // アップグレード画面を表示
        view.showUpgradeScreen()
    }
    // アップグレード画面を表示
    func showUpgradeScreen() {
        // アップグレード画面を表示
        view.showUpgradeScreen()
    }
    
    // リワード　報酬を消費
    func spendCoin(count: Int) -> Bool {
        if UserData.rewardAdCoinCount >= count {
            UserData.rewardAdCoinCount -= count
            return true
        }
        return false
    }
}
