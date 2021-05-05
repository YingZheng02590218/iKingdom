//
//  DataBaseManagerSettingsOperatingJournalEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/05.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 仕訳テンプレートクラス
class DataBaseManagerSettingsOperatingJournalEntry {
    
    // 追加　仕訳テンプレート
    func addJournalEntry(nickname: String,debit_category: String,debit_amount: Int64,credit_category: String,credit_amount: Int64,smallWritting: String) -> Int {
        // オブジェクトを作成
        let dataBaseJournalEntry = DataBaseSettingsOperatingJournalEntry()       //仕訳テンプレート
        dataBaseJournalEntry.nickname = nickname                        //ニックネーム
        var number = 0                                          //仕訳番号 自動採番にした
        dataBaseJournalEntry.debit_category = debit_category    //借方勘定
        dataBaseJournalEntry.debit_amount = debit_amount        //借方金額 Int型(TextField.text アンラップ)
        dataBaseJournalEntry.credit_category = credit_category  //貸方勘定
        dataBaseJournalEntry.credit_amount = credit_amount      //貸方金額 Int型(TextField.text アンラップ)
        dataBaseJournalEntry.smallWritting = smallWritting      //小書き
        
        let realm = try! Realm()
        try! realm.write {
            number = dataBaseJournalEntry.save() //仕訳番号　自動採番
            // 仕訳テンプレートを追加
            realm.add(dataBaseJournalEntry)
        }
        return number
    }
    // 取得　仕訳テンプレート
    func getJournalEntry() -> Results<DataBaseSettingsOperatingJournalEntry> {
        let realm = try! Realm()
        let objects = realm.objects(DataBaseSettingsOperatingJournalEntry.self)
        return objects
    }

}
