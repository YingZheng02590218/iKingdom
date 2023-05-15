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
    
    func inputButtonTapped(journalEntryType: JournalEntryType)
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
    func buttonTappedForJournalEntriesPackageFixing()
    // 入力チェック　バリデーション
    func textInputCheck() -> Bool
    // 決算整理仕訳　の処理
    func buttonTappedForAdjustingAndClosingEntries()
    // 仕訳編集　の処理
    func buttonTappedForJournalEntriesFixing()
    // 仕訳　の処理
    func buttonTappedForJournalEntries()
    // タブバーの仕訳タブからの遷移の場合
    func buttonTappedForJournalEntriesOnTabBar()
    // ダイアログ　オフライン
    func showDialogForOfline()
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
    
    func inputButtonTapped(journalEntryType: JournalEntryType) {
        if journalEntryType == .JournalEntriesPackageFixing { // 仕訳一括編集
            // バリデーションチェック
            if self.view.textInputCheckForJournalEntriesPackageFixing() {
                
                view.buttonTappedForJournalEntriesPackageFixing()
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
                        
                        self.view.buttonTappedForAdjustingAndClosingEntries()
                    } else if journalEntryType == .JournalEntriesFixing { // 仕訳編集
                        
                        self.view.buttonTappedForJournalEntriesFixing()
                    } else if journalEntryType == .JournalEntries { // 仕訳
                        
                        self.view.buttonTappedForJournalEntries()
                    } else if journalEntryType == .JournalEntry { // タブバーの仕訳タブからの遷移の場合
                        
                        self.view.buttonTappedForJournalEntriesOnTabBar()
                    }
                } else {
                    // ダイアログ　オフライン
                    view.showDialogForOfline()
                }
            }
        }
    }
}
