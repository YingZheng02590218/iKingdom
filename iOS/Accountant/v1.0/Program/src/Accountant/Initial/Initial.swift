//
//  Initial.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation

class Initial {
    
    // 初期化処理
    func initialize(){
        // 設定画面　勘定科目　初期化
        initialiseMasterData()
        // 設定画面　会計帳簿棚　初期化
        initializeAccountingBooksShelf()
        // 表示科目
        initializeTaxonomy()
    }
    // 設定画面　勘定科目　勘定科目一覧を初期化
    func initialiseMasterData(){
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        // データベースに設定画面の勘定科目一覧があるかをチェック
        // マイグレーション　CSVファイルに変更がある場合、一度作成したモデルオブジェクトを削除してから新たに作り直す　考える
        if !databaseManagerSettingsTaxonomyAccount.checkInitialising() { // データベースにモデルオブフェクトが存在しない場合
            let masterData = MasterData()
            // マスターデータを作成する
            masterData.readMasterDataFromCSVOfTaxonomyAccount()   
        }
        let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
        if !dataBaseManagerSettingsTaxonomy.checkInitialising() { // データベースにモデルオブフェクトが存在しない場合
            let masterData = MasterData()
            masterData.readMasterDataFromCSVOfTaxonomy()
        }
        // 設定勘定科目　初期化　勘定科目のスイッチを設定する　表示科目が選択されていなければOFFにする
        databaseManagerSettingsTaxonomyAccount.initializeSettingsTaxonomyAccount()
        // 設定表示科目　初期化　表示科目のスイッチを設定する　勘定科目のスイッチONが、ひとつもなければOFFにする
        dataBaseManagerSettingsTaxonomy.initializeSettingsTaxonomy()
    }
    // 会計帳簿棚
    func initializeAccountingBooksShelf() {
        // オブジェクト作成
        let dataBaseManager = DataBaseManagerAccountingBooksShelf()
        // データベースに会計帳簿があるかをチェック
        if !dataBaseManager.checkInitialising(DataBase: DataBaseAccountingBooksShelf(), fiscalYear: 0) {
            let number = dataBaseManager.addAccountingBooksShelf(company: "事業者名")
        }
        // 会計帳簿
        initializeAccountingBooks()
    }
    // 初期値用の年月を取得
    func getTheTime() -> Int {
        // 現在時刻を取得
        let now :Date = Date() // UTC時間なので　9時間ずれる

        switch Calendar.current.dateComponents([.month], from: now).month! {
        case 4,5,6,7,8,9,10,11,12:
            return Calendar.current.dateComponents([.year], from: now).year!
//        case 1,2,3:
//            return Calendar.current.date(byAdding: .year, value: -1, to: now)!
        default:
            let lastYear = Calendar.current.dateComponents([.year], from: now).year!
            return lastYear-1 // 1月から3月であれば去年の年に補正する
        }
    }
    // 会計帳簿　会計期間画面
    func initializeAccountingBooks() {
        // オブジェクト作成
        let dataBaseManager = DataBaseManagerAccountingBooks()
        var fiscalYear = getTheTime()     // デフォルトで現在の年月から今年度の会計帳簿を作成する
        fiscalYear -= 1                     // デフォルトで現在の年月から前年度の会計帳簿を作成する
        // データベースに会計帳簿があるかをチェック
        if !dataBaseManager.checkInitializing() {           // データベースにモデルオブフェクトが存在しない場合
            let number = dataBaseManager.addAccountingBooks(fiscalYear: fiscalYear)
            // 仕訳帳画面　　初期化
            initialiseJournals(number: number,fiscalYear: fiscalYear)
            // 総勘定元帳画面　初期化
            initialiseAccounts(number: number,fiscalYear: fiscalYear)
            // 決算書画面　初期化
            initializeFinancialStatements(number: number,fiscalYear: fiscalYear)
        }
    }
    // 仕訳帳画面　仕訳帳を初期化
    func initialiseJournals(number: Int,fiscalYear: Int){
         let dataBaseManager = DataBaseManagerJournals()
        // データベースに仕訳帳画面の仕訳帳があるかをチェック
        if !dataBaseManager.checkInitialising(DataBase: DataBaseJournals(), fiscalYear: fiscalYear) {
            dataBaseManager.addJournals(number: number)
        }
    }
    // 総勘定元帳画面　総勘定元帳を初期化
    func initialiseAccounts(number: Int,fiscalYear: Int) {
        let dataBaseManager = DataBaseManagerGeneralLedger()
        // データベースに勘定画面の勘定があるかをチェック
        if !dataBaseManager.checkInitialising(DataBase: DataBaseGeneralLedger(), fiscalYear: fiscalYear) {
            dataBaseManager.addGeneralLedger(number: number)
        }
    }
    // 決算書画面　初期化
    func initializeFinancialStatements(number: Int,fiscalYear: Int) {
        let dataBaseManager = DataBaseManagerFinancialStatements()
        // データベースに財務諸表があるかをチェック
        if !dataBaseManager.checkInitialising(DataBase: DataBaseFinancialStatements(), fiscalYear: fiscalYear) {
            dataBaseManager.addFinancialStatements(number: number)
        }
    }
    // 初期化　表示科目
    func initializeTaxonomy() {
        // 表示科目
        let dataBaseManagerTaxonomy = DataBaseManagerTaxonomy()
        let isInvalidated = dataBaseManagerTaxonomy.deleteTaxonomyAll()
        if isInvalidated {
            dataBaseManagerTaxonomy.addTaxonomyAll()
        }else {
            print("deleteTaxonomyAll 失敗")
        }
    }
}
