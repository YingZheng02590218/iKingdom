//
//  DataBaseManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/13.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

class DataBaseManager  {
    
    // データベース
    
    // モデルオブフェクトの追加
    func addJournalEntry(date: String,debit_category: String,debit_amount: Int,credit_category: String,credit_amount: Int,smallWritting: String) {
        // オブジェクトを作成
        let dataBaseJournalEntry = DataBaseJournalEntry() //仕訳
        // 自動採番にした
        //                        journalEntry.number = 2
        dataBaseJournalEntry.date = date                        //日付
        dataBaseJournalEntry.debit_category = debit_category    //借方勘定
        dataBaseJournalEntry.debit_amount = debit_amount        //借方金額 Int型(TextField.text アンラップ)
        dataBaseJournalEntry.credit_category = credit_category  //貸方勘定
        dataBaseJournalEntry.credit_amount = credit_amount      //貸方金額 Int型(TextField.text アンラップ)
        dataBaseJournalEntry.smallWritting = smallWritting      //小書き
        print(dataBaseJournalEntry)
        // データベース　書き込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)書き込みトランザクション内でデータを追加する
        try! realm.write {
            dataBaseJournalEntry.save() //仕分け番号　自動採番
            realm.add(dataBaseJournalEntry)
        }
    }
    // モデルオブフェクトの取得
    func getJournalEntry() -> Results<DataBaseJournalEntry> { //DataBaseJournalEntry {
        // データベース　読み込み
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // (2)データベース内に保存されているDataBaseJournalEntryモデルを全て取得する
        let objects = realm.objects(DataBaseJournalEntry.self) // DataBaseJournalEntryモデル
        print("DataBaseJournalEntryモデル : \(objects.count)")
        print(objects)
        
        // オブジェクトを準備
//        let dataBaseJournalEntry = DataBaseJournalEntry() //仕訳
        // 自動採番にした
        //                        journalEntry.number = 2
//        dataBaseJournalEntry.date = objects[0].date                        //日付
//        dataBaseJournalEntry.debit_category = objects[0].debit_category    //借方勘定
//        dataBaseJournalEntry.debit_amount = objects[0].debit_amount        //借方金額 Int型(TextField.text アンラップ)
//        dataBaseJournalEntry.credit_category = objects[0].credit_category  //貸方勘定
//        dataBaseJournalEntry.credit_amount = objects[0].credit_amount      //貸方金額 Int型(TextField.text アンラップ)
//        dataBaseJournalEntry.smallWritting = objects[0].smallWritting      //小書き
//        print(dataBaseJournalEntry)
        
//        return dataBaseJournalEntry
        return objects
    }
    
}
