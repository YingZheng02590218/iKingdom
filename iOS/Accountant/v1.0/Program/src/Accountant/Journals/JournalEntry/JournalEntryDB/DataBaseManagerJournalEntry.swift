//
//  DataBaseManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/13.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift // データベースのインポート

// 仕訳クラス
class DataBaseManagerJournalEntry  {
    
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
//        let accountLeft = Account()                             //仕訳
//        accountLeft.accountName = debit_category
//        dataBaseJournalEntry.account.append(accountLeft)
//        let accountRight = Account()                            //仕訳 ※Accountオブジェクトをひとつでプロパティを上書きはできなかった
//        accountRight.accountName = credit_category
//        dataBaseJournalEntry.account.append(accountRight)
        let dataBaseManagerAccount = DataBaseManagerAccount()       //仕訳
        let left_number = dataBaseManagerAccount.getNumberOfAccount(accountName: debit_category) // 丁数
        let right_number = dataBaseManagerAccount.getNumberOfAccount(accountName: credit_category)

        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear = object.dataBaseJournals?.fiscalYear
        
        let realm = try! Realm()
        try! realm.write {
            number = dataBaseJournalEntry.save() //仕訳番号　自動採番

            dataBaseJournalEntry.fiscalYear = fiscalYear!                        //年度
//            realm.add(dataBaseJournalEntry)
            // 仕訳帳に仕訳データを追加
//            let object = realm.object(ofType: DataBaseJournals.self, forPrimaryKey: 1 ) // ToDo
            object.dataBaseJournals?.dataBaseJournalEntries.append(dataBaseJournalEntry)
            // 勘定へ転記
            // 勘定に借方の仕訳データを追加
//            let object_leftAccount = realm.object(ofType: DataBaseAccount.self, forPrimaryKey: left_number ) // ToDo
//            object_leftAccount?.dataBaseJournalEntries.append(dataBaseJournalEntry)
            // 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
            object.dataBaseGeneralLedger?.dataBaseAccounts[left_number-1].dataBaseJournalEntries.append(dataBaseJournalEntry)
            // 勘定に貸方の仕訳データを追加
//            let object_rightAccount = realm.object(ofType: DataBaseAccount.self, forPrimaryKey: right_number ) // 勘定科目のプライマリーキーを指定する
//            object_rightAccount?.dataBaseJournalEntries.append(dataBaseJournalEntry)
            object.dataBaseGeneralLedger?.dataBaseAccounts[right_number-1].dataBaseJournalEntries.append(dataBaseJournalEntry)
        }
        // 仕訳データを追加したら、試算表を再計算するためのフラグをここで立てる 2020/06/1614:47
        //flag_journalEntryAdded = true
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す　2020/06/18 16:29
        let dataBaseManager = DataBaseManagerTB()
        dataBaseManager.setAccountTotal(account_left: debit_category, account_right: credit_category)//, debit_number: (object.dataBaseGeneralLedger?.dataBaseAccounts[left_number-1].number)!, credit_number: (object.dataBaseGeneralLedger?.dataBaseAccounts[right_number-1].number)!)
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
        let dataBaseManagerAccount = DataBaseManagerAccount()       //仕訳
        let left_number = dataBaseManagerAccount.getNumberOfAccount(accountName: debit_category)
        let right_number = dataBaseManagerAccount.getNumberOfAccount(accountName: credit_category)

        let realm = try! Realm()
        try! realm.write {
            number = dataBaseJournalEntry.save() //仕訳番号　自動採番
            // 開いている会計帳簿の年度を取得
            let dataBaseManagerPeriod = DataBaseManagerPeriod()
            let object = dataBaseManagerPeriod.getSettingsPeriod()
            let fiscalYear = object.dataBaseJournals?.fiscalYear
            dataBaseJournalEntry.fiscalYear = fiscalYear!                        //年度
            // 仕訳帳に仕訳データを追加
            object.dataBaseJournals?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
            //勘定へ転記
            // 勘定に借方の仕訳データを追加
            object.dataBaseGeneralLedger?.dataBaseAccounts[left_number-1].dataBaseAdjustingEntries.append(dataBaseJournalEntry)
            // 勘定に貸方の仕訳データを追加
            object.dataBaseGeneralLedger?.dataBaseAccounts[right_number-1].dataBaseAdjustingEntries.append(dataBaseJournalEntry)
        }
        // 仕訳データを追加したら、試算表を再計算するためのフラグをここで立てる 2020/06/1614:47
        //flag_journalEntryAdded = true
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す　2020/06/18 16:29
        let dataBaseManager = DataBaseManagerTB()
        dataBaseManager.setAccountTotalAdjusting(account_left: debit_category, account_right: credit_category)
        return number
    }
    // 取得　仕訳
    func getJournalEntry(section: Int) -> Results<DataBaseJournalEntry> {
        let realm = try! Realm()
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        var objects = realm.objects(DataBaseJournalEntry.self)
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        switch section {
        case 0: // April
            objects = objects.filter("date LIKE '*/04/*'")
            break
        case 1: // May
            objects = objects.filter("date LIKE '*/05/*'")
            break
        case 2: // June
            objects = objects.filter("date LIKE '*/06/*'")
            break
        case 3: // July
            objects = objects.filter("date LIKE '*/07/*'")
            break
        case 4: // Ogust
            objects = objects.filter("date LIKE '*/08/*'")
            break
        case 5: // September
            objects = objects.filter("date LIKE '*/09/*'")
            break
        case 6: // October
            objects = objects.filter("date LIKE '*/10/*'")
            break
        case 7: // Nobember
            objects = objects.filter("date LIKE '*/11/*'")
            break
        case 8: // December
            objects = objects.filter("date LIKE '*/12/*'")
            break
        case 9: // January
            objects = objects.filter("date LIKE '*/01/*'")
            break
        case 10: // Feburary
            objects = objects.filter("date LIKE '*/02/*'")
            break
        case 11: // March
            objects = objects.filter("date LIKE '*/03/*'")
            break
        default:
            // ありえない
            break
        }
        return objects
    }
    // 取得　決算整理仕訳
    func getJournalAdjustingEntry(section: Int) -> Results<DataBaseAdjustingEntry> {
        let realm = try! Realm()
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        objects = objects.filter("fiscalYear == \(fiscalYear)")
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        switch section {
        case 0: // April
            objects = objects.filter("date LIKE '*/04/*'")
            break
        case 1: // May
            objects = objects.filter("date LIKE '*/05/*'")
            break
        case 2: // June
            objects = objects.filter("date LIKE '*/06/*'")
            break
        case 3: // July
            objects = objects.filter("date LIKE '*/07/*'")
            break
        case 4: // Ogust
            objects = objects.filter("date LIKE '*/08/*'")
            break
        case 5: // September
            objects = objects.filter("date LIKE '*/09/*'")
            break
        case 6: // October
            objects = objects.filter("date LIKE '*/10/*'")
            break
        case 7: // Nobember
            objects = objects.filter("date LIKE '*/11/*'")
            break
        case 8: // December
            objects = objects.filter("date LIKE '*/12/*'")
            break
        case 9: // January
            objects = objects.filter("date LIKE '*/01/*'")
            break
        case 10: // Feburary
            objects = objects.filter("date LIKE '*/02/*'")
            break
        case 11: // March
            objects = objects.filter("date LIKE '*/03/*'")
            break
        default:
            // ありえない
            break
        }
        return objects
    }
    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        let realm = try! Realm()
        if accountName == "損益勘定" {
            var objects = realm.objects(DataBasePLAccount.self)
            objects = objects.filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
            // 勘定のプライマリーキーを取得する
            let numberOfAccount = objects[0].number
            return numberOfAccount
        }else {
            var objects = realm.objects(DataBaseAccount.self)
            objects = objects.filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
            // 勘定のプライマリーキーを取得する
            let numberOfAccount = objects[0].number
            return numberOfAccount
        }
    }
    // 丁数を取得　損益勘定
//    func getNumberOfPLAccount(accountName: String) -> Int {
//        let realm = try! Realm()
//        var objects = realm.objects(DataBasePLAccount.self)
//        objects = objects.filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
//        // 勘定のプライマリーキーを取得する
//        let numberOfAccount = objects[0].number
//        return numberOfAccount
//    }
    // 勘定のプライマリーキーを取得　※丁数ではない
    func getPrimaryNumberOfAccount(accountName: String) -> Int {
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAccount.self)
        // 開いている会計帳簿の年度を取得
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        let object = dataBaseManagerPeriod.getSettingsPeriod()
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        objects = objects
            .filter("fiscalYear == \(fiscalYear)")
            .filter("accountName LIKE '\(accountName)'")// 条件を間違えないように注意する
        let number: Int = objects[0].number
        return number
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
        let dataBaseManager = DataBaseManagerTB()
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
        let dataBaseManager = DataBaseManagerTB()
        dataBaseManager.setAccountTotalAdjusting(account_left: account_left, account_right: account_right) // 決算整理仕訳用にしないといけない
        return object.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
    // 更新 仕訳
    func updateJournalEntry(primaryKey: Int, date: String,debit_category: String,debit_amount: Int64,credit_category: String,credit_amount: Int64,smallWritting: String) -> Int {
        let realm = try! Realm()
        // 編集前の借方勘定と貸方勘定をメモする
        // プライマリーキーを指定してオブジェクトを取得
        let object = realm.object(ofType: DataBaseJournalEntry.self, forPrimaryKey: primaryKey)!
        // 再計算用に、勘定をメモしておく
        let account_left = object.debit_category
        let account_right = object.credit_category
        try! realm.write {
            let value: [String: Any] = ["number": primaryKey, "date": date, "debit_category":debit_category, "debit_amount":debit_amount, "credit_category":credit_category, "credit_amount":credit_amount, "smallWritting":smallWritting]
            realm.create(DataBaseJournalEntry.self, value: value, update: .modified) // 一部上書き更新
        }
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す
        let dataBaseManager = DataBaseManagerTB()
        dataBaseManager.setAccountTotal(account_left: account_left  , account_right: account_right  ) //編集前の借方勘定と貸方勘定
        dataBaseManager.setAccountTotal(account_left: debit_category, account_right: credit_category) //編集後の借方勘定と貸方勘定
        return primaryKey
    }
    // 更新 決算整理仕訳
    func updateAdjustingJournalEntry(primaryKey: Int, date: String,debit_category: String,debit_amount: Int64,credit_category: String,credit_amount: Int64,smallWritting: String) -> Int {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 編集前の借方勘定と貸方勘定をメモする
        // プライマリーキーを指定してオブジェクトを取得
        let object = realm.object(ofType: DataBaseAdjustingEntry.self, forPrimaryKey: primaryKey)!
        // 再計算用に、勘定をメモしておく
        let account_left = object.debit_category
        let account_right = object.credit_category
        // (2)書き込みトランザクション内でデータを更新する
        try! realm.write {
            let value: [String: Any] = ["number": primaryKey, "date": date, "debit_category":debit_category, "debit_amount":debit_amount, "credit_category":credit_category, "credit_amount":credit_amount, "smallWritting":smallWritting]
            realm.create(DataBaseAdjustingEntry.self, value: value, update: .modified) // 一部上書き更新
        }
        // 仕訳データを追加後に、勘定ごとに保持している合計と残高を再計算する処理をここで呼び出す
        let dataBaseManager = DataBaseManagerTB()
        dataBaseManager.setAccountTotalAdjusting(account_left: account_left, account_right: account_right)//編集前の借方勘定と貸方勘定　 // 決算整理仕訳用にしないといけない
        dataBaseManager.setAccountTotalAdjusting(account_left: debit_category, account_right: credit_category)//編集後の借方勘定と貸方勘定　 // 決算整理仕訳用にしないといけない
        return primaryKey
    }
}
