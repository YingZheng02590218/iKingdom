//
//  JournalEntryPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/05/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

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
    func inputButtonTapped(journalEntryType: JournalEntryType)
    // OKボタン
    func okButtonTappedDialogForFinal(journalEntryData: JournalEntryData)
    // OKボタン ダイアログ　オフライン
    func okButtonTappedDialogForOfline()
    // 広告を閉じた
    func adDidDismissFullScreenContent()
}

protocol JournalEntryPresenterOutput: AnyObject {
    
    func setupUI()
    
    func updateUI()
    // チュートリアル対応 ウォークスルー型
    func showWalkThrough()
    // ニューモフィズム　ボタンとビューのデザインを指定する
    func createEMTNeumorphicView()
    // チュートリアル対応 コーチマーク型　コーチマークを開始
    func presentAnnotation()
    // 入力チェック　バリデーション 仕訳一括編集
    func textInputCheckForJournalEntriesPackageFixing() -> Bool
    // 仕訳一括編集　の処理
    func buttonTappedForJournalEntriesPackageFixing() -> JournalEntryData
    // 入力チェック　バリデーション
    func textInputCheck() -> Bool
    // 決算整理仕訳　の処理
    func buttonTappedForAdjustingAndClosingEntries() -> JournalEntryData?
    // 仕訳編集　の処理
    func buttonTappedForJournalEntriesFixing() -> (JournalEntryData?, Int, Int)
    // 仕訳　の処理
    func buttonTappedForJournalEntries() -> JournalEntryData?
    // タブバーの仕訳タブからの遷移の場合
    func buttonTappedForJournalEntriesOnTabBar() -> JournalEntryData?
    // ダイアログ　オフライン
    func showDialogForOfline()
    // ダイアログ　なにも入力されていない
    func showDialogForEmpty()
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
    // 入力ボタン
    func inputButtonTapped(journalEntryType: JournalEntryType) {
        if journalEntryType == .JournalEntriesPackageFixing { // 仕訳一括編集
            // バリデーションチェック
            if self.view.textInputCheckForJournalEntriesPackageFixing() {
                // 入力値を取得する
                let journalEntryData = view.buttonTappedForJournalEntriesPackageFixing()
                if journalEntryData.checkPropertyIsNil() {
                    // ダイアログ　なにも入力されていない
                    view.showDialogForEmpty()
                } else {
                    // ダイアログ　ほんとうに変更しますか？
                    view.showDialogForFinal(journalEntryData: journalEntryData)
                }

            }
        } else { // 一括編集以外
            
            // バリデーションチェック
            if self.view.textInputCheck() {
                
                // オフラインの場合広告が表示できないので、ネットワーク接続を確認する
                if Network.shared.isOnline() ||
                    // アップグレード機能　スタンダードプラン サブスクリプション購読済み
                    UpgradeManager.shared.inAppPurchaseFlag {
                    // ネットワークあり
                    // 仕訳タイプ判定　仕訳、決算整理仕訳、編集、一括編集
                    if journalEntryType == .AdjustingAndClosingEntries { // 決算整理仕訳
                        // 入力値を取得する
                        if let journalEntryData = view.buttonTappedForAdjustingAndClosingEntries() {
                            // 決算整理仕訳
                            model.addAdjustingJournalEntry(journalEntryData: journalEntryData) { number in
                                // 決算整理仕訳後に遷移元画面へ戻る
                                view.goBackToPreviousScreen()
                            }
                        }
                    } else if journalEntryType == .JournalEntriesFixing { // 仕訳編集
                        // 入力値を取得する
                        let result = view.buttonTappedForJournalEntriesFixing()
                        if let journalEntryData = result.0 {
                            if result.1 == 1 { // 決算整理仕訳
                                // 決算整理仕訳 更新
                                model.updateAdjustingJournalEntry(journalEntryData: journalEntryData, primaryKey: result.2) { number in
                                    // 仕訳帳画面へ戻る
                                    view.goBackToJournalsScreen(number: number)
                                }
                            } else { // 仕訳
                                // 仕訳 更新
                                model.updateJournalEntry(journalEntryData: journalEntryData, primaryKey: result.2) { number in
                                    // 仕訳帳画面へ戻る
                                    view.goBackToJournalsScreen(number: number)
                                }
                            }
                        }
                    } else if journalEntryType == .JournalEntries { // 仕訳
                        // 入力値を取得する
                        if let journalEntryData = view.buttonTappedForJournalEntries() {
                            // 仕訳
                            model.addJournalEntry(journalEntryData: journalEntryData) { number in
                                // 仕訳帳画面へ戻る
                                view.goBackToJournalsScreenJournalEntry(number: number)
                            }
                        }
                    } else if journalEntryType == .JournalEntry { // タブバーの仕訳タブからの遷移の場合
                        // 入力値を取得する
                        if let journalEntryData = view.buttonTappedForJournalEntriesOnTabBar() {
                            // 仕訳
                            model.addJournalEntry(journalEntryData: journalEntryData) { number in
                                // ダイアログ 記帳しました
                                view.showDialogForSucceed()
                            }
                        }
                    }
                } else {
                    // ダイアログ　オフライン
                    view.showDialogForOfline()
                }
            }
        }
    }
    // OKボタン　
    func okButtonTappedDialogForFinal(journalEntryData: JournalEntryData) {
        // 画面を閉じる　仕訳帳へ編集した仕訳データを渡す
        view.closeScreen(journalEntryData: journalEntryData)
    }
    // OKボタン ダイアログ　オフライン
    func okButtonTappedDialogForOfline() {
        // アップグレード画面を表示
        view.showUpgradeScreen()
    }
    // 広告を閉じた
    func adDidDismissFullScreenContent() {
        // アップグレード画面を表示
        view.showUpgradeScreen()
    }
}
