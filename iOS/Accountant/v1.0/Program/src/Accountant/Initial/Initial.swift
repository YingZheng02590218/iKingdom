//
//  Initial.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/02.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation

class Initial {
    
    func initialize(){
        // 設定画面　勘定科目　初期化　ToDo
        initialiseMasterData()
        // 主要簿
        initializeMainBooks(fiscalYear: 2030)
    }
    // 設定画面　勘定科目　勘定科目一覧を初期化
    func initialiseMasterData(){
        // データベース
        let databaseManagerSettingsCategory = DatabaseManagerSettingsCategory() //データベースマネジャー
        // データベースに設定画面の勘定科目一覧があるかをチェック
        if !databaseManagerSettingsCategory.checkInitialising() { // データベースにモデルオブフェクトが存在しない場合
            let masterData = MasterData()
            masterData.readMasterDataFromCSV()   // マスターデータを作成する
        }
    }
    // 主要簿　会計期間画面
    func initializeMainBooks(fiscalYear: Int) {
        // オブジェクト作成
        let dataBaseManagerMainBooks = DataBaseManagerMainBooks()
        // データベースに主要簿があるかをチェック
        if !dataBaseManagerMainBooks.checkInitialising(fiscalYear: fiscalYear) { // データベースにモデルオブフェクトが存在しない場合
            let number = dataBaseManagerMainBooks.addMainBooks(fiscalYear: fiscalYear)
            // 仕訳帳画面　　初期化　ToDo
            initialiseJournalEntryBook(number: number)
            // 総勘定元帳画面　勘定画面　勘定　初期化　ToDo
            initialiseAccounts(number: number)
        }
    }
    // 仕訳帳画面　仕訳帳を初期化
    func initialiseJournalEntryBook(number: Int){
        // Test ToDo
         let dataBaseManagerJournalEntryBook = DataBaseManagerJournalEntryBook()
        // データベースに仕訳帳画面の仕訳帳があるかをチェック
        if !dataBaseManagerJournalEntryBook.checkInitialising() { // データベースにモデルオブフェクトが存在しない場合
            dataBaseManagerJournalEntryBook.addJournalEntryBook(number: number)
        }
//        let dataBaseJournalEntryBook = dataBaseManagerJournalEntryBook.getJournalEntryBook()
//        print("仕訳帳：\(dataBaseJournalEntryBook)")
    }
    // 総勘定元帳画面　勘定画面　勘定を初期化
    func initialiseAccounts(number: Int) {
        // データベース
        let dataBaseManagerGeneralLedger = DataBaseManagerGeneralLedger() //データベースマネジャー
        // データベースに勘定画面の勘定があるかをチェック
        if !dataBaseManagerGeneralLedger.checkInitialising() { // データベースにモデルオブフェクトが存在しない場合
            dataBaseManagerGeneralLedger.addGeneralLedger(number: number)

        }
    }
}
