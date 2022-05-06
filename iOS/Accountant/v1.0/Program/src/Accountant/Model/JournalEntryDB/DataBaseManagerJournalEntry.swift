//
//  DataBaseManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/13.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 仕訳クラス
class DataBaseManagerJournalEntry {
    
    // 追加　仕訳
    func addJournalEntry(date: String,debit_category: String,debit_amount: Int64,credit_category: String,credit_amount: Int64,smallWritting: String) -> Int {
        // オブジェクトを作成
        let dataBaseJournalEntry = DataBaseJournalEntry()       //仕訳
        var number = 0                                          //仕訳番号 自動採番にした
        dataBaseJournalEntry.date = date                        //日付
        dataBaseJournalEntry.debit_category = debit_category    //借方勘定
        dataBaseJournalEntry.debit_amount = debit_amount        //借方金額 Int型(TextField.text アンラップ)
        dataBaseJournalEntry.credit_category = credit_category  //貸方勘定
        dataBaseJournalEntry.credit_amount = credit_amount      //貸方金額 Int型(TextField.text アンラップ)
        dataBaseJournalEntry.smallWritting = smallWritting      //小書き
        // オブジェクトを作成
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let left_object = dataBaseManagerAccount.getAccountByAccountName(accountName: debit_category)
        let right_object = dataBaseManagerAccount.getAccountByAccountName(accountName: credit_category)

        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let fiscalYear = object.dataBaseJournals?.fiscalYear
        
        let realm = try! Realm()
        try! realm.write {
            number = dataBaseJournalEntry.save() //仕訳番号　自動採番
            dataBaseJournalEntry.fiscalYear = fiscalYear!                        //年度
            // 仕訳帳に仕訳データを追加
            object.dataBaseJournals?.dataBaseJournalEntries.append(dataBaseJournalEntry)
            // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
            // 勘定に借方の仕訳データを追加
            left_object?.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            // 勘定に貸方の仕訳データを追加
            right_object?.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
        }
        // 仕訳データを追加したら、試算表を再計算する
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す　2020/06/18 16:29
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotal(account_left: debit_category, account_right: credit_category)
        return number
    }
    // 追加　決算整理仕訳
    func addAdjustingJournalEntry(date: String,debit_category: String,debit_amount: Int64,credit_category: String,credit_amount: Int64,smallWritting: String) -> Int {
        // オブジェクトを作成
        let dataBaseJournalEntry = DataBaseAdjustingEntry()
        var number = 0                                          //仕訳番号 自動採番にした
        dataBaseJournalEntry.date = date                        //日付
        dataBaseJournalEntry.debit_category = debit_category    //借方勘定
        dataBaseJournalEntry.debit_amount = debit_amount        //借方金額 Int型(TextField.text アンラップ)
        dataBaseJournalEntry.credit_category = credit_category  //貸方勘定
        dataBaseJournalEntry.credit_amount = credit_amount      //貸方金額 Int型(TextField.text アンラップ)
        dataBaseJournalEntry.smallWritting = smallWritting      //小書き
        // オブジェクトを作成
        let dataBaseManagerAccount = DataBaseManagerAccount()
        let left_object = dataBaseManagerAccount.getAccountByAccountName(accountName: debit_category)
        let right_object = dataBaseManagerAccount.getAccountByAccountName(accountName: credit_category)

        let realm = try! Realm()
        try! realm.write {
            number = dataBaseJournalEntry.save() //仕訳番号　自動採番
            // 開いている会計帳簿の年度を取得
            let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
            let fiscalYear = object.dataBaseJournals?.fiscalYear
            dataBaseJournalEntry.fiscalYear = fiscalYear!                        //年度
            // 仕訳帳に仕訳データを追加
            object.dataBaseJournals?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
            //勘定へ転記
            // 勘定に借方の仕訳データを追加
            left_object?.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.決算整理仕訳リスト
            // 勘定に貸方の仕訳データを追加
            right_object?.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.決算整理仕訳リスト
        }
        // 仕訳データを追加したら、試算表を再計算する
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す　2020/06/18 16:29
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotalAdjusting(account_left: debit_category, account_right: credit_category)
        return number
    }
    
    /**
    * 会計帳簿.仕訳帳.仕訳[ ] オブジェクトを取得するメソッド
    * 開いている帳簿の仕訳帳から通常仕訳を取得する
    * 日付を降順にソートする
    * @param -
    * @return 仕訳[ ]
    */
    func getJournalEntryAll() -> Results<DataBaseJournalEntry> {
        
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let dataBaseJournalEntries = dataBaseAccountingBooks.dataBaseJournals!.dataBaseJournalEntries
                        .sorted(byKeyPath: "date", ascending: true)
        return dataBaseJournalEntries
    }
    // 取得　仕訳 編集する仕訳をプライマリーキーで取得
    func getJournalEntryWithNumber(number: Int) -> DataBaseJournalEntry? {
        let realm = try! Realm()
        guard let dataBaseJournalEntry = realm.object(ofType: DataBaseJournalEntry.self, forPrimaryKey: number) else { return nil }
    
        return dataBaseJournalEntry
    }
    // 取得　決算整理仕訳 編集する仕訳をプライマリーキーで取得
    func getAdjustingEntryWithNumber(number: Int) -> DataBaseAdjustingEntry? {
        let realm = try! Realm()
        guard let dataBaseJournalEntry = realm.object(ofType: DataBaseAdjustingEntry.self, forPrimaryKey: number) else { return nil }
    
        return dataBaseJournalEntry
    }
    // 仕訳　総数
    func getJournalEntryCount() -> Results<DataBaseJournalEntry> {
        let realm = try! Realm()
        let objects = realm.objects(DataBaseJournalEntry.self)
        return objects
    }
    // 決算整理仕訳　総数
    func getAdjustingEntryCount() -> Results<DataBaseAdjustingEntry> {
        let realm = try! Realm()
        let objects = realm.objects(DataBaseAdjustingEntry.self)
        return objects
    }
    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseSettingsTaxonomyAccount.self)// 2020/11/08
        objects = objects.filter("category LIKE '\(accountName)'")// 2020/11/08
        // 設定勘定科目のプライマリーキーを取得する
        if let numberOfAccount = objects.first {
            return numberOfAccount.number
        }
        else {
            return 0 // クラッシュ対応
        }
    }
    // 勘定のプライマリーキーを取得　※丁数ではない
    func getPrimaryNumberOfAccount(accountName: String) -> Int {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAccount.self)
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
        let number: Int = objects[0].number
        return number
    }
    
    
    /**
    * 会計帳簿.総勘定元帳.勘定 オブジェクトを取得するメソッド
    * 年度を指定して勘定を取得する
    * @param  勘定名
    * @return  勘定
    */
    private func getAccountByAccountNameWithFiscalYear(accountName: String, fiscalYear: Int) -> DataBaseAccount? {
        let realm = try! Realm()
        
        let dataBaseAccountingBooks = realm.objects(DataBaseAccountingBooks.self)
                                        .filter("fiscalYear == \(fiscalYear)")
        guard let dataBaseAccountingBook = dataBaseAccountingBooks.first else { return nil }
        
        let dataBaseAccounts = dataBaseAccountingBook.dataBaseGeneralLedger?.dataBaseAccounts
                                .filter("accountName LIKE '\(accountName)'")
        guard let dataBaseAccount = dataBaseAccounts?.first else { return nil }

        return dataBaseAccount
    }
    
    // 更新 仕訳
    func updateJournalEntry(primaryKey: Int, date: String, debit_category: String, debit_amount: Int64, credit_category: String, credit_amount: Int64, smallWritting: String, completion: (Int) -> Void) {
        let realm = try! Realm()
        // 編集する仕訳
        guard let dataBaseJournalEntry = realm.object(ofType: DataBaseJournalEntry.self, forPrimaryKey: primaryKey) else { return }
        // 再計算用に、勘定をメモしておく
        let account_left = dataBaseJournalEntry.debit_category
        let account_right = dataBaseJournalEntry.credit_category
        // 編集前の仕訳帳と借方勘定と貸方勘定
        guard let oldLeft_object = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        guard let oldRight_object = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        // 編集後の仕訳帳と借方勘定と貸方勘定
        guard let left_object = getAccountByAccountNameWithFiscalYear(accountName: debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        guard let right_object = getAccountByAccountNameWithFiscalYear(accountName: credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        // 編集する仕訳
        try! realm.write {
            let value: [String: Any] = ["number": primaryKey, "date": date, "debit_category":debit_category, "debit_amount":debit_amount, "credit_category":credit_category, "credit_amount":credit_amount, "smallWritting":smallWritting]
            realm.create(DataBaseJournalEntry.self, value: value, update: .modified) // 一部上書き更新
        }
        // 編集前の勘定から借方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldLeft_object.dataBaseJournalEntries.count where oldLeft_object.dataBaseJournalEntries[i].number == primaryKey ||
        oldLeft_object.dataBaseJournalEntries[i].isInvalidated {
            try! realm.write {
                oldLeft_object.dataBaseJournalEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
            continue outerLoop
        }
        break
    }
        // 編集前の勘定から貸方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldRight_object.dataBaseJournalEntries.count where oldRight_object.dataBaseJournalEntries[i].number == primaryKey ||
        oldRight_object.dataBaseJournalEntries[i].isInvalidated {
            try! realm.write {
                oldRight_object.dataBaseJournalEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
            continue outerLoop
        }
        break
    }
        // 編集後の仕訳帳と借方勘定と貸方勘定へ関連を追加する
        try! realm.write {
            // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
            // 勘定に借方の仕訳データを追加
            left_object.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            // 勘定に貸方の仕訳データを追加
            right_object.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
        }
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotal(account_left: account_left  , account_right: account_right  ) //編集前の借方勘定と貸方勘定
        dataBaseManager.setAccountTotal(account_left: debit_category, account_right: credit_category) //編集後の借方勘定と貸方勘定
        
        completion(primaryKey) //　ここでコールバックする（呼び出し元に処理を戻す）
    }
    // 更新 決算整理仕訳
    func updateAdjustingJournalEntry(primaryKey: Int, date: String, debit_category: String, debit_amount: Int64, credit_category: String, credit_amount: Int64, smallWritting: String, completion: (Int) -> Void) {
        let realm = try! Realm()
        // 編集する仕訳
        guard let dataBaseJournalEntry = realm.object(ofType: DataBaseAdjustingEntry.self, forPrimaryKey: primaryKey) else { return }
        // 再計算用に、勘定をメモしておく
        let account_left = dataBaseJournalEntry.debit_category
        let account_right = dataBaseJournalEntry.credit_category
        // 編集前の仕訳帳と借方勘定と貸方勘定
        guard let oldLeft_object = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        guard let oldRight_object = getAccountByAccountNameWithFiscalYear(accountName: dataBaseJournalEntry.credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        // 編集後の仕訳帳と借方勘定と貸方勘定
        guard let left_object = getAccountByAccountNameWithFiscalYear(accountName: debit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        guard let right_object = getAccountByAccountNameWithFiscalYear(accountName: credit_category, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        // 編集する仕訳
        try! realm.write {
            let value: [String: Any] = ["number": primaryKey, "date": date, "debit_category":debit_category, "debit_amount":debit_amount, "credit_category":credit_category, "credit_amount":credit_amount, "smallWritting":smallWritting]
            realm.create(DataBaseAdjustingEntry.self, value: value, update: .modified) // 一部上書き更新
        }
        // 編集前の勘定から借方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldLeft_object.dataBaseAdjustingEntries.count where oldLeft_object.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldLeft_object.dataBaseAdjustingEntries[i].isInvalidated {
            try! realm.write {
                oldLeft_object.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
            continue outerLoop
        }
        break
    }
        // 編集前の勘定から貸方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldRight_object.dataBaseAdjustingEntries.count where oldRight_object.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldRight_object.dataBaseAdjustingEntries[i].isInvalidated {
            try! realm.write {
                oldRight_object.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
            continue outerLoop
        }
        break
    }
        // 編集後の仕訳帳と借方勘定と貸方勘定へ関連を追加する
        try! realm.write {
            // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
            // 勘定に借方の仕訳データを追加
            left_object.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            // 勘定に貸方の仕訳データを追加
            right_object.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
        }
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotalAdjusting(account_left: account_left, account_right: account_right)//編集前の借方勘定と貸方勘定　 // 決算整理仕訳用にしないといけない
        dataBaseManager.setAccountTotalAdjusting(account_left: debit_category, account_right: credit_category)//編集後の借方勘定と貸方勘定　 // 決算整理仕訳用にしないといけない
        
        completion(primaryKey) //　ここでコールバックする（呼び出し元に処理を戻す）
    }
    
    // 削除　仕訳
    func deleteJournalEntry(number: Int) -> Bool {
        let realm = try! Realm()
        let object = realm.object(ofType: DataBaseJournalEntry.self, forPrimaryKey: number)!
        // 再計算用に、勘定をメモしておく
        let account_left = object.debit_category
        let account_right = object.credit_category
        try! realm.write {
            realm.delete(object)
            print("object.isInvalidated: \(object.isInvalidated)")
        }
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotal(account_left: account_left, account_right: account_right)
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
    // 削除　決算整理仕訳
    func deleteAdjustingJournalEntry(number: Int) -> Bool {
        let realm = try! Realm()
        let object = realm.object(ofType: DataBaseAdjustingEntry.self, forPrimaryKey: number)!
        // 再計算用に、勘定をメモしておく
        let account_left = object.debit_category
        let account_right = object.credit_category
        try! realm.write {
            realm.delete(object)
        }
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す
        let dataBaseManager = TBModel()
        dataBaseManager.setAccountTotalAdjusting(account_left: account_left, account_right: account_right) // 決算整理仕訳用にしないといけない
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
}
