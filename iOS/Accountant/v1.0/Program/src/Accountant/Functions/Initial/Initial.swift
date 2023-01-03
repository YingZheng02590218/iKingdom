//
//  Initial.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation

// 初期化クラス
class Initial {
    
    /**
    * 初期化　初期化メソッド
    * 設定勘定科目、会計帳簿棚、表示科目を初期化する。
    */
    func initialize() {
        // 設定画面　設定勘定科目　初期化
        initialiseMasterData()
        // 設定画面　会計帳簿棚　初期化
        initializeAccountingBooksShelf()
        // 表示科目　初期化
        initializeTaxonomy()
        // 設定操作　初期化
        initializeSettingsOperating()
        // 設定会計期間　決算日　初期化
        initializePeriod()
        // チュートリアル対応 コーチマーク型　初回起動時
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunch_JournalEntry"
        if userDefaults.bool(forKey: firstLunchKey) {
            // 仕訳のサンプルデータを作成する
            _ = DataBaseManagerJournalEntry.shared.addJournalEntry(
                date: "\(getTheTime())/04/01",
                debitCategory: "現金",
                debitAmount: 1_000_000, // カンマを削除してからデータベースに書き込む
                creditCategory: "売上高",
                creditAmount: 1_000_000,// カンマを削除してからデータベースに書き込む
                smallWritting: "ゾウ商店"
            )
            // よく使う仕訳のサンプルデータを作成する
            _ = DataBaseManagerSettingsOperatingJournalEntry.shared.addJournalEntry(
                nickname: "よく使う仕訳1",
                debitCategory: "現金",
                debitAmount: 1_000_000, // カンマを削除してからデータベースに書き込む
                creditCategory: "売上高",
                creditAmount: 1_000_000,// カンマを削除してからデータベースに書き込む
                smallWritting: "ゾウ商店"
            )
        }
    }
    /**
    * 初期化　初期化メソッド
    * 設定勘定科目を初期化する。
    */
    func initialiseMasterData() {
        // 個人事業主対応　存在確認　引数と同じ勘定科目名が存在するかどうかを確認する
        if !DatabaseManagerSettingsTaxonomyAccount.shared.isExistSettingsTaxonomyAccount(category: "元入金") {
            let number = DatabaseManagerSettingsTaxonomyAccount.shared.addSettingsTaxonomyAccount(
                rank0: "5",
                rank1: "10",
                rank2: "",
                numberOfTaxonomy: "",
                category: "元入金",
                switching: true
            )
            print(number)
        }
        if !DatabaseManagerSettingsTaxonomyAccount.shared.isExistSettingsTaxonomyAccount(category: "事業主貸") {
            let number = DatabaseManagerSettingsTaxonomyAccount.shared.addSettingsTaxonomyAccount(
                rank0: "5",
                rank1: "10",
                rank2: "",
                numberOfTaxonomy: "",
                category: "事業主貸",
                switching: true
            )
            print(number)
        }
        if !DatabaseManagerSettingsTaxonomyAccount.shared.isExistSettingsTaxonomyAccount(category: "事業主借") {
            let number = DatabaseManagerSettingsTaxonomyAccount.shared.addSettingsTaxonomyAccount(
                rank0: "5",
                rank1: "10",
                rank2: "",
                numberOfTaxonomy: "",
                category: "事業主借",
                switching: true
            )
            print(number)
        }
        if !DatabaseManagerSettingsTaxonomyAccount.shared.checkInitialising() {
            // すでに存在するオブジェクトを全て削除する v2.0.2で初期化処理が失敗している場合に対処する処理
            DatabaseManagerSettingsTaxonomyAccount.shared.deleteAllOfSettingsTaxonomyAccount()
            let masterData = MasterData()
            // マスターデータを作成する
            masterData.readMasterDataFromCSVOfTaxonomyAccount()
        }
        if !DataBaseManagerSettingsTaxonomy.shared.checkInitialising() {
            // すでに存在するオブジェクトを全て削除する v2.0.2で初期化処理が失敗している場合に対処する処理
            DataBaseManagerSettingsTaxonomy.shared.deleteAllOfSettingsTaxonomy()
            let masterData = MasterData()
            masterData.readMasterDataFromCSVOfTaxonomy()
        }
        // 法人/個人フラグ
        if UserDefaults.standard.bool(forKey: "corporation_switch") {
            // 設定勘定科目　初期化　勘定科目のスイッチを設定する　表示科目が選択されていなければOFFにする
            DatabaseManagerSettingsTaxonomyAccount.shared.initializeSettingsTaxonomyAccount()
            // 設定表示科目　初期化　表示科目のスイッチを設定する　勘定科目のスイッチONが、ひとつもなければOFFにする
            DataBaseManagerSettingsTaxonomy.shared.initializeSettingsTaxonomy()
        }
    }
    /**
    * 初期化　初期化メソッド
    * 会計帳簿棚を初期化する。
    */
    func initializeAccountingBooksShelf() {
        if !DataBaseManagerAccountingBooksShelf.shared.checkInitialising(dataBase: DataBaseAccountingBooksShelf(), fiscalYear: 0) {
            let number = DataBaseManagerAccountingBooksShelf.shared.addAccountingBooksShelf(company: "事業者名")
            print(number)
        }
        // 会計帳簿
        initializeAccountingBooks()
    }
    /**
    * 初期化　年度メソッド
    * 初期値用の年月を取得する。
    */
    func getTheTime() -> Int {
        // 現在時刻を取得
        let now = Date() // UTC時間なので　9時間ずれる

        switch Calendar.current.dateComponents([.month], from: now).month! {
        case 4, 5, 6, 7, 8, 9, 10, 11, 12:
            return Calendar.current.dateComponents([.year], from: now).year!
//        case 1,2,3:
//            return Calendar.current.date(byAdding: .year, value: -1, to: now)!
        default:
            let lastYear = Calendar.current.dateComponents([.year], from: now).year!
            return lastYear - 1 // 1月から3月であれば去年の年に補正する
        }
    }
    /**
    * 初期化　初期化メソッド
    * 会計帳簿を初期化する。
    */
    func initializeAccountingBooks() {
        let fiscalYear = getTheTime()     // デフォルトで現在の年月から今年度の会計帳簿を作成する
        if !DataBaseManagerAccountingBooks.shared.checkInitializing() {
            let number = DataBaseManagerAccountingBooks.shared.addAccountingBooks(fiscalYear: fiscalYear)
            // 仕訳帳画面　　初期化
            initialiseJournals(number: number, fiscalYear: fiscalYear)
            // 総勘定元帳画面　初期化
            initialiseAccounts(number: number, fiscalYear: fiscalYear)
            // 決算書画面　初期化
            initializeFinancialStatements(number: number, fiscalYear: fiscalYear)
        }
    }
    /**
    * 初期化　初期化メソッド
    * 仕訳帳を初期化する。
    */
    func initialiseJournals(number: Int, fiscalYear: Int) {
        if !DataBaseManagerJournals.shared.checkInitialising(dataBase: DataBaseJournals(), fiscalYear: fiscalYear) {
            DataBaseManagerJournals.shared.addJournals(number: number)
        }
    }
    /**
    * 初期化　初期化メソッド
    * 総勘定元帳を初期化する。
    */
    func initialiseAccounts(number: Int, fiscalYear: Int) {
        // データベースに勘定画面の勘定があるかをチェック
        if !DataBaseManagerGeneralLedger.shared.checkInitialising(dataBase: DataBaseGeneralLedger(), fiscalYear: fiscalYear) {
            DataBaseManagerGeneralLedger.shared.addGeneralLedger(number: number)
        }
    }
    /**
    * 初期化　初期化メソッド
    * 財務諸表を初期化する。
    */
    func initializeFinancialStatements(number: Int, fiscalYear: Int) {
        // データベースに財務諸表があるかをチェック
        if !DataBaseManagerFinancialStatements.shared.checkInitialising(dataBase: DataBaseFinancialStatements(), fiscalYear: fiscalYear) {
            DataBaseManagerFinancialStatements.shared.addFinancialStatements(number: number)
        }
    }
    /**
    * 初期化　初期化メソッド
    * 表示科目を初期化する。
    */
    func initializeTaxonomy() {
        // 表示科目
        let isInvalidated = DataBaseManagerTaxonomy.shared.deleteTaxonomyAll()
        if isInvalidated {
            DataBaseManagerTaxonomy.shared.addTaxonomyAll()
        } else {
            print("deleteTaxonomyAll 失敗")
        }
    }
    /**
    * 初期化　初期化メソッド
    * 設定操作を初期化する。
    */
    func initializeSettingsOperating() {
        if !DataBaseManagerSettingsOperating.shared.checkInitialising() {
            DataBaseManagerSettingsOperating.shared.addSettingsOperating()
        }
    }
    /**
    * 初期化　初期化メソッド
    * 設定会計期間を初期化する。
    */
    func initializePeriod() {
        if !DataBaseManagerSettingsPeriod.shared.checkInitialising() {
            DataBaseManagerSettingsPeriod.shared.addSettingsPeriod()
        }
    }
}
