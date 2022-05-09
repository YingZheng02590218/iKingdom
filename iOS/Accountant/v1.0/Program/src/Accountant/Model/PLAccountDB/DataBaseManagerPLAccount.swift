//
//  DataBaseManagerPLAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/10/05.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 損益勘定クラス
class DataBaseManagerPLAccount: DataBaseManager {
    
    // チェック 決算整理仕訳　存在するかを確認
    func checkAdjustingEntry(account: String) -> Results<DataBaseAdjustingEntry> {
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let realm = try! Realm()
        var objects = realm.objects(DataBaseAdjustingEntry.self)
        objects = objects
            .filter("fiscalYear == \(object.fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
            .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'")
        return objects
    }
    // チェック 決算整理仕訳　損益勘定内の勘定が存在するかを確認
    func checkAdjustingEntryInPLAccount(account: String) -> Results<DataBaseAdjustingEntry> {
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let objects = object.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseAdjustingEntries
            .sorted(byKeyPath: "date", ascending: true)
            .filter("fiscalYear == \(object.fiscalYear)")
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
            .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'")
        return objects!
    }
    // 追加　決算振替仕訳　損益振替仕訳をする
    // 引数：日付、借方勘定、勘定残高額借方、貸方勘定、勘定残高貸方、小書き
    func addTransferEntry(debit_category: String, amount: Int64, credit_category: String) {
        let realm = try! Realm()
        // 損益計算書に関する勘定科目のみに絞る
        var account: String = "" // 損益振替の相手勘定
        if debit_category == "損益勘定" {
            account = credit_category
        }
        else if credit_category == "損益勘定" {
            account = debit_category
        }
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        if databaseManagerSettingsTaxonomyAccount.checkSettingsTaxonomyAccountRank0(account: account) {
            // オブジェクトを作成
            let dataBaseJournalEntry = DataBaseAdjustingEntry()
            var number = 0                                          //仕訳番号 自動採番にした
            // 開いている会計帳簿の年度を取得
            let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
            let fiscalYear = object.dataBaseJournals?.fiscalYear
            dataBaseJournalEntry.fiscalYear = fiscalYear!                        //年度
            // 決算日
            let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
            var fiscalYearFixed = ""
            if theDayOfReckoning == "12/31" {
                fiscalYearFixed = String(fiscalYear!)
            }
            else {
                fiscalYearFixed = String(fiscalYear!+1)
            }

            dataBaseJournalEntry.date = fiscalYearFixed + "/" + theDayOfReckoning
            dataBaseJournalEntry.debit_category = credit_category    //借方勘定　＊引数の貸方勘定を振替える
            dataBaseJournalEntry.debit_amount = amount        //借方金額
            dataBaseJournalEntry.credit_category = debit_category  //貸方勘定　＊引数の借方勘定を振替える
            dataBaseJournalEntry.credit_amount = amount      //貸方金額
            dataBaseJournalEntry.smallWritting = "損益振替仕訳"      //小書き
            
            // 損益振替仕訳　が1件超が存在する場合は　削除
            let objects = checkAdjustingEntry(account: account) // 損益勘定内に勘定が存在するか
        outerLoop: while objects.count > 1 {
            for i in 0..<objects.count {
                let isInvalidated = deleteAdjustingJournalEntry(primaryKey: objects[i].number)
                print("削除", isInvalidated, objects.count)
                continue outerLoop
            }
            break
        }
            let objectss = checkAdjustingEntryInPLAccount(account: account) // 損益勘定内に勘定が存在するか
        outerLoop: while objectss.count > 1 {
            for i in 0..<objectss.count {
                let isInvalidated = removeAdjustingJournalEntry(primaryKey: objectss[i].number)
                print("関連削除", isInvalidated, objectss.count)
                continue outerLoop
            }
            break
        }
            if objects.count >= 1 {
                // 損益振替仕訳　が存在する場合は　更新
                if amount != 0 {
                    number = updateAdjustingJournalEntry(
                        primaryKey: objects[0].number,
                        date: dataBaseJournalEntry.date,
                        debit_category: dataBaseJournalEntry.debit_category,
                        debit_amount: Int64(dataBaseJournalEntry.debit_amount), //カンマを削除してからデータベースに書き込む
                        credit_category: dataBaseJournalEntry.credit_category,
                        credit_amount: Int64(dataBaseJournalEntry.credit_amount),//カンマを削除してからデータベースに書き込む
                        smallWritting: dataBaseJournalEntry.smallWritting
                    )
                }
                else { // 貸借が0の場合　削除する
                    let isInvalidated = deleteAdjustingJournalEntry(primaryKey: objects[0].number)
                    print(isInvalidated)
                }
            }
            else {
                // 損益振替仕訳　が存在しない場合は　作成
                if amount != 0 {
                    number = dataBaseJournalEntry.save() //仕訳番号　自動採番
                    try! realm.write {
                        // 仕訳帳に仕訳データを追加
                        object.dataBaseJournals?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    }
                    //勘定へ転記 // オブジェクトを作成
                    let objectss = object.dataBaseGeneralLedger
                    // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                    for i in 0..<objectss!.dataBaseAccounts.count {
                        print(objectss!.dataBaseAccounts[i].accountName, account)
                        if objectss!.dataBaseAccounts[i].accountName == account {
                            try! realm.write {
                                // 勘定に借方の仕訳データを追加
                                object.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                            }
                            break
                        }
                    }
                    try! realm.write {
                        // 勘定に貸方の仕訳データを追加
                        object.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    }
                }
            }
        }
    }
    // 追加　決算振替仕訳　資本振替
    // 引数：日付、借方勘定、金額、貸方勘定
    func addTransferEntryToNetWorth(debit_category: String,amount: Int64,credit_category: String) {
        let realm = try! Realm()
        // 損益計算書に関する勘定科目のみに絞る
        var account: String = "" // 損益振替の相手勘定
        if debit_category == "損益勘定" {
            account = credit_category
        }
        else if credit_category == "損益勘定" {
            account = debit_category
        }
        if account == "繰越利益" {
            // オブジェクトを作成
            let dataBaseJournalEntry = DataBaseAdjustingEntry()
            var number = 0                                          //仕訳番号 自動採番にした
            // 開いている会計帳簿の年度を取得
            let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
            let fiscalYear = object.dataBaseJournals?.fiscalYear
            dataBaseJournalEntry.fiscalYear = fiscalYear!                        //年度
            // 決算日
            let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
            var fiscalYearFixed = ""
            if theDayOfReckoning == "12/31" {
                fiscalYearFixed = String(fiscalYear!)
            }
            else {
                fiscalYearFixed = String(fiscalYear!+1)
            }
            dataBaseJournalEntry.date = fiscalYearFixed + "/" + theDayOfReckoning
            dataBaseJournalEntry.debit_category = credit_category    //借方勘定　＊引数の貸方勘定を振替える
            dataBaseJournalEntry.debit_amount = amount        //借方金額
            dataBaseJournalEntry.credit_category = debit_category  //貸方勘定　＊引数の借方勘定を振替える
            dataBaseJournalEntry.credit_amount = amount      //貸方金額
            dataBaseJournalEntry.smallWritting = "資本振替仕訳"
            
            // 損益振替仕訳　が1件超が存在する場合は　削除
            let objects = checkAdjustingEntry(account: account) // 損益勘定内に勘定が存在するか
        outerLoop: while objects.count > 1 {
            for i in 0..<objects.count {
                let isInvalidated = deleteAdjustingJournalEntry(primaryKey: objects[i].number)
                print("削除", isInvalidated, objects.count)
                continue outerLoop
            }
            break
        }
            let objectss = checkAdjustingEntryInPLAccount(account: account) // 損益勘定内に勘定が存在するか
        outerLoop: while objectss.count > 1 {
            for i in 0..<objectss.count {
                let isInvalidated = removeAdjustingJournalEntry(primaryKey: objectss[i].number)
                print("関連削除", isInvalidated, objectss.count)
                continue outerLoop
            }
            break
        }
            if objects.count == 1 {
                // 資本振替仕訳　が存在する場合は　更新
                number = updateAdjustingJournalEntry(
                    primaryKey: objects[0].number,
                    date: dataBaseJournalEntry.date,
                    debit_category: dataBaseJournalEntry.debit_category,
                    debit_amount: Int64(dataBaseJournalEntry.debit_amount), //カンマを削除してからデータベースに書き込む
                    credit_category: dataBaseJournalEntry.credit_category,
                    credit_amount: Int64(dataBaseJournalEntry.credit_amount),//カンマを削除してからデータベースに書き込む
                    smallWritting: dataBaseJournalEntry.smallWritting
                )
            }
            else {
                // 資本振替仕訳　が存在しない場合は　作成
                if amount != 0 {
                    number = dataBaseJournalEntry.save() //仕訳番号　自動採番
                    try! realm.write {
                        // 仕訳帳に仕訳データを追加
                        object.dataBaseJournals?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    }
                    //勘定へ転記 // オブジェクトを作成
                    // 勘定に借方の仕訳データを追加
                    let objectss = object.dataBaseGeneralLedger
                    // 総勘定元帳のなかの勘定で、計算したい勘定と同じ場合
                    for i in 0..<objectss!.dataBaseAccounts.count {
                        print(objectss!.dataBaseAccounts[i].accountName, account)
                        if objectss!.dataBaseAccounts[i].accountName == account {
                            try! realm.write {
                                object.dataBaseGeneralLedger?.dataBaseAccounts[i].dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                            }
                            break
                        }
                    }
                    try! realm.write {
                        // 勘定に貸方の仕訳データを追加
                        object.dataBaseGeneralLedger?.dataBasePLAccount?.dataBaseAdjustingEntries.append(dataBaseJournalEntry)
                    }
                }
            }
        }
    }
    // 更新 決算整理仕訳
    func updateAdjustingJournalEntry(primaryKey: Int, date: String,debit_category: String,debit_amount: Int64,credit_category: String,credit_amount: Int64,smallWritting: String) -> Int {
        // (1)Realmのインスタンスを生成する
        let realm = try! Realm()
        // 編集前の借方勘定と貸方勘定をメモする
        // (2)書き込みトランザクション内でデータを更新する
        try! realm.write {
            let value: [String: Any] = ["number": primaryKey, "date": date, "debit_category":debit_category, "debit_amount":debit_amount, "credit_category":credit_category, "credit_amount":credit_amount, "smallWritting":smallWritting]
            realm.create(DataBaseAdjustingEntry.self, value: value, update: .modified) // 一部上書き更新
        }
        return primaryKey
    }
    // 削除　決算整理仕訳 損益振替仕訳
    func deleteAdjustingJournalEntry(primaryKey: Int) -> Bool {
        let realm = try! Realm()
        guard let dataBaseJournalEntry = realm.object(ofType: DataBaseAdjustingEntry.self, forPrimaryKey: primaryKey) else { return false }
        // 削除前の仕訳帳と借方勘定と貸方勘定
        guard let oldJournals = getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else { return false }
        // 損益計算書に関する勘定科目のみに絞る
        var account: String = "" // 損益振替の相手勘定
        if dataBaseJournalEntry.debit_category == "損益勘定" {
            account = dataBaseJournalEntry.credit_category
        }
        else if dataBaseJournalEntry.credit_category == "損益勘定" {
            account = dataBaseJournalEntry.debit_category
        }
        guard let oldLeft_object: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: account, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return false }
        guard let dataBasePLAccount: DataBasePLAccount = getAccountByAccountNameWithFiscalYear(accountName: "損益勘定", fiscalYear: dataBaseJournalEntry.fiscalYear) else { return false }
        // 仕訳帳から削除前仕訳データの関連を削除
    outerLoop: while true {
        for i in 0..<oldJournals.dataBaseAdjustingEntries.count where oldJournals.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldJournals.dataBaseAdjustingEntries[i].isInvalidated {
            try! realm.write {
                oldJournals.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.仕訳帳.仕訳リスト
            }
            continue outerLoop
        }
        break
    }
        // 勘定から削除前仕訳データの関連を削除
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
        // 勘定から削除前仕訳データの関連を削除
    outerLoop: while true {
        for i in 0..<dataBasePLAccount.dataBaseAdjustingEntries.count where dataBasePLAccount.dataBaseAdjustingEntries[i].number == primaryKey ||
        dataBasePLAccount.dataBaseAdjustingEntries[i].isInvalidated {
            try! realm.write {
                dataBasePLAccount.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
            continue outerLoop
        }
        break
    }
        if !dataBaseJournalEntry.isInvalidated {
            try! realm.write {
                // 仕訳データを削除
                realm.delete(dataBaseJournalEntry)
            }
        }
        return dataBaseJournalEntry.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
    // 関連削除　決算整理仕訳 損益振替仕訳
    func removeAdjustingJournalEntry(primaryKey: Int) -> Bool {
        let realm = try! Realm()
        guard let dataBaseJournalEntry = realm.object(ofType: DataBaseAdjustingEntry.self, forPrimaryKey: primaryKey) else { return false }
        // 削除前の仕訳帳と借方勘定と貸方勘定
        guard let oldJournals = getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else { return false }
        // 損益計算書に関する勘定科目のみに絞る
        var account: String = "" // 損益振替の相手勘定
        if dataBaseJournalEntry.debit_category == "損益勘定" {
            account = dataBaseJournalEntry.credit_category
        }
        else if dataBaseJournalEntry.credit_category == "損益勘定" {
            account = dataBaseJournalEntry.debit_category
        }
        guard let oldLeft_object: DataBaseAccount = getAccountByAccountNameWithFiscalYear(accountName: account, fiscalYear: dataBaseJournalEntry.fiscalYear) else { return false }
        guard let dataBasePLAccount: DataBasePLAccount = getAccountByAccountNameWithFiscalYear(accountName: "損益勘定", fiscalYear: dataBaseJournalEntry.fiscalYear) else { return false }
        // 仕訳帳から削除前仕訳データの関連を削除
    outerLoop: while oldJournals.dataBaseAdjustingEntries.sorted(byKeyPath: "date", ascending: true)
                        .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
                        .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'").count > 1 {
        for i in 0..<oldJournals.dataBaseAdjustingEntries.count where oldJournals.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldJournals.dataBaseAdjustingEntries[i].isInvalidated {
            try! realm.write {
                oldJournals.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.仕訳帳.仕訳リスト
                print(oldJournals.dataBaseAdjustingEntries.count)
            }
            continue outerLoop
        }
        break
    }
        // 勘定から削除前仕訳データの関連を削除
    outerLoop: while oldLeft_object.dataBaseAdjustingEntries.sorted(byKeyPath: "date", ascending: true)
                        .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
                        .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'").count > 1 {
        for i in 0..<oldLeft_object.dataBaseAdjustingEntries.count where oldLeft_object.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldLeft_object.dataBaseAdjustingEntries[i].isInvalidated {
            try! realm.write {
                oldLeft_object.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                print(oldLeft_object.dataBaseAdjustingEntries.count)
            }
            continue outerLoop
        }
        break
    }
        // 勘定から削除前仕訳データの関連を削除
    outerLoop: while dataBasePLAccount.dataBaseAdjustingEntries.sorted(byKeyPath: "date", ascending: true)
                        .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
                        .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'").count > 1 {
        for i in 0..<dataBasePLAccount.dataBaseAdjustingEntries.count where dataBasePLAccount.dataBaseAdjustingEntries[i].number == primaryKey ||
        dataBasePLAccount.dataBaseAdjustingEntries[i].isInvalidated {
            try! realm.write {
                dataBasePLAccount.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                print(dataBasePLAccount.dataBaseAdjustingEntries.count)
            }
            continue outerLoop
        }
        break
    }
        if !dataBaseJournalEntry.isInvalidated {

        }
        return dataBaseJournalEntry.isInvalidated // 成功したら true まだ失敗時の動きは確認していない　2020/07/26
    }
}
