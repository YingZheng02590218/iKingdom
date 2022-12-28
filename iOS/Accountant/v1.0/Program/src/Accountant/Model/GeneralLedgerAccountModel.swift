//
//  GeneralLedgerAccountModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/27.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol GenearlLedgerAccountModelInput {
    func initialize(account: String, databaseJournalEntries: Results<DataBaseJournalEntry>, dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>)
    func getBalanceAmount(indexPath: IndexPath) -> Int64
    func getBalanceAmountAdjusting(indexPath: IndexPath) -> Int64
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) -> String
    func getNumberOfAccount(accountName: String) -> Int

    func getAllAdjustingEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry>
    func getJournalEntryInAccount(account: String) -> Results<DataBaseJournalEntry>
    func getAdjustingJournalEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry>
    func getAllAdjustingEntryInPLAccountWithRetainedEarningsCarriedForward(account: String) -> Results<DataBaseAdjustingEntry>
}
// 勘定クラス
class GeneralLedgerAccountModel: GenearlLedgerAccountModelInput {

    let dataBaseManagerGeneralLedgerAccountBalance = DataBaseManagerGeneralLedgerAccountBalance()

    // 差引残高　計算
    func initialize(account: String, databaseJournalEntries: Results<DataBaseJournalEntry>, dataBaseAdjustingEntries: Results<DataBaseAdjustingEntry>) {
        
        dataBaseManagerGeneralLedgerAccountBalance.calculateBalance(account: account, databaseJournalEntries: databaseJournalEntries, dataBaseAdjustingEntries: dataBaseAdjustingEntries) // 毎回、計算は行わない
    }
    // 取得　差引残高額　仕訳
    func getBalanceAmount(indexPath: IndexPath) -> Int64 {
        
        dataBaseManagerGeneralLedgerAccountBalance.getBalanceAmount(indexPath: indexPath)
    }
    // 取得　差引残高額　 決算整理仕訳　損益勘定以外
    func getBalanceAmountAdjusting(indexPath: IndexPath) -> Int64 {
        
        dataBaseManagerGeneralLedgerAccountBalance.getBalanceAmountAdjusting(indexPath: indexPath)
    }
    // 借又貸を取得
    func getBalanceDebitOrCredit(indexPath: IndexPath) -> String {
        
        dataBaseManagerGeneralLedgerAccountBalance.getBalanceDebitOrCredit(indexPath: indexPath)
    }
    // 借又貸を取得 決算整理仕訳
    func getBalanceDebitOrCreditAdjusting(indexPath: IndexPath) -> String {
        
        dataBaseManagerGeneralLedgerAccountBalance.getBalanceDebitOrCreditAdjusting(indexPath: indexPath)
    }
    
    // 追加　勘定
    func addGeneralLedgerAccount(number: Int) {
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 設定画面の勘定科目一覧にある勘定を取得する
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        let objectt = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccount(number: number)
        // オブジェクトを作成 勘定
        let dataBaseAccount = DataBaseAccount(
            fiscalYear: object.fiscalYear,
            accountName: objectt!.category,
            debit_total: 0,
            credit_total: 0,
            debit_balance: 0,
            credit_balance: 0,
            debit_total_Adjusting: 0,
            credit_total_Adjusting: 0,
            debit_balance_Adjusting: 0,
            credit_balance_Adjusting: 0,
            debit_total_AfterAdjusting: 0,
            credit_total_AfterAdjusting: 0,
            debit_balance_AfterAdjusting: 0,
            credit_balance_AfterAdjusting: 0
        )
        do {
            try DataBaseManager.realm.write {
                let num = dataBaseAccount.save() // dataBaseAccount.number = number
                //　自動採番ではなく、設定勘定科目のプライマリーキーを使用する　2020/11/08 年度を追加すると勘定クラスの連番が既に使用されている
                print("dataBaseAccount", number)
                print("dataBaseAccount", num)
                object.dataBaseGeneralLedger!.dataBaseAccounts.append(dataBaseAccount)   // 勘定を作成して総勘定元帳に追加する
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    // 追加　勘定　不足している勘定を追加する
    func addGeneralLedgerAccountLack() {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        // 総勘定元帳　取得
        let dataBaseManagerGeneralLedger = DataBaseManagerGeneralLedger()
        // 設定画面の勘定科目一覧にある勘定を取得する
        let objects = dataBaseManagerGeneralLedger.getObjects()
        // 設定勘定科目と総勘定元帳ないの勘定を比較
        for i in 0..<objects.count {
            let dataBaseAccount = getAccountByAccountName(accountName: objects[i].category)
            print("addGeneralLedgerAccountLack", objects[i].category)
            if dataBaseAccount != nil {
                // print("勘定は存在する")
            } else {
                // print("勘定が存在しない")
                // オブジェクトを作成 勘定
                let dataBaseAccount = DataBaseAccount(
                    fiscalYear: object.fiscalYear,
                    accountName: objects[i].category,
                    debit_total: 0,
                    credit_total: 0,
                    debit_balance: 0,
                    credit_balance: 0,
                    debit_total_Adjusting: 0,
                    credit_total_Adjusting: 0,
                    debit_balance_Adjusting: 0,
                    credit_balance_Adjusting: 0,
                    debit_total_AfterAdjusting: 0,
                    credit_total_AfterAdjusting: 0,
                    debit_balance_AfterAdjusting: 0,
                    credit_balance_AfterAdjusting: 0
                )
                do {
                    try DataBaseManager.realm.write {
                        let number = dataBaseAccount.save() //　自動採番
                        print("dataBaseAccount", number)
                        object.dataBaseGeneralLedger!.dataBaseAccounts.append(dataBaseAccount)   // 勘定を作成して総勘定元帳に追加する
                    }
                } catch {
                    print("エラーが発生しました")
                }
            }
        }
    }

    // 取得　通常仕訳 勘定別に取得
    func getJournalEntryInAccount(account: String) -> Results<DataBaseJournalEntry> {
        let dataBaseAccountingBook = DataBaseManager.realm.objects(DataBaseAccountingBooks.self).filter("openOrClose == \(true)").first
        if account == "損益勘定" {
            // 損益勘定の場合
            let dataBasePLAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBasePLAccount
            let dataBaseJournalEntries = (dataBasePLAccount?.dataBaseJournalEntries.sorted(byKeyPath: "date", ascending: true))!
            return dataBaseJournalEntries
        } else {
            // 損益勘定以外の勘定の場合
            let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
                .filter("accountName LIKE '\(account)'").first
            let dataBaseJournalEntries = (dataBaseAccount?.dataBaseJournalEntries.sorted(byKeyPath: "date", ascending: true))!
            return dataBaseJournalEntries
        }
    }
    // 取得 決算整理仕訳 勘定別に取得
    func getAdjustingJournalEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry> {
        let dataBaseAccountingBook = DataBaseManager.realm.objects(DataBaseAccountingBooks.self).filter("openOrClose == \(true)").first
        if account == "損益勘定" {
            // 損益勘定の場合
            let dataBasePLAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBasePLAccount
            let dataBaseJournalEntries = (dataBasePLAccount?.dataBaseAdjustingEntries.sorted(byKeyPath: "date", ascending: true))!
            return dataBaseJournalEntries
        } else {
            // 損益勘定以外の勘定の場合
            let dataBaseAccount = dataBaseAccountingBook?.dataBaseGeneralLedger?.dataBaseAccounts
                .filter("accountName LIKE '\(account)'").first
            let dataBaseJournalEntries = (dataBaseAccount?.dataBaseAdjustingEntries.sorted(byKeyPath: "date", ascending: true))!
            return dataBaseJournalEntries
        }
    }

    // 取得 仕訳　勘定別 全年度
    func getAllJournalEntryInAccountAll(account: String) -> Results<DataBaseJournalEntry> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseJournalEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)), // 条件を間違えないように注意する
            NSPredicate(format: "!(debit_category LIKE %@) AND !(credit_category LIKE %@)", NSString(string: "損益勘定"), NSString(string: "損益勘定"))
        ])
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　勘定別　損益勘定以外 全年度
    func getAllAdjustingEntryInAccountAll(account: String) -> Results<DataBaseAdjustingEntry> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseAdjustingEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)), // 条件を間違えないように注意する
            NSPredicate(format: "!(debit_category LIKE %@) AND !(credit_category LIKE %@)", NSString(string: "損益勘定"), NSString(string: "損益勘定"))
        ])
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　勘定別 損益勘定のみ　繰越利益は除外 全年度
    func getAllAdjustingEntryInPLAccountAll(account: String) -> Results<DataBaseAdjustingEntry> {
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseAdjustingEntry.self, predicates: [
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)), // 条件を間違えないように注意する
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "損益勘定"), NSString(string: "損益勘定")),
            NSPredicate(format: "!(debit_category LIKE %@) AND !(credit_category LIKE %@)", NSString(string: "繰越利益"), NSString(string: "繰越利益")) // 消すと、損益勘定の差引残高の計算が狂う　2020/10/11
        ])
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　勘定別　損益勘定以外
    func getAllAdjustingEntryInAccount(account: String) -> Results<DataBaseAdjustingEntry> {
        // 開いている会計帳簿の年度を取得
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let dataBaseAccount = dataBaseAccountingBooks.dataBaseGeneralLedger!.dataBaseAccounts
            .filter("accountName LIKE '\(account)'")
        var objects = dataBaseAccount[0].dataBaseAdjustingEntries
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
            .filter("!(debit_category LIKE '\("損益勘定")') && !(credit_category LIKE '\("損益勘定")')")
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　勘定別 損益勘定のみ　繰越利益は除外
    func getAllAdjustingEntryInPLAccount(account: String) -> Results<DataBaseAdjustingEntry> {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseAdjustingEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "損益勘定"), NSString(string: "損益勘定")),
            NSPredicate(format: "!(debit_category LIKE %@) AND !(credit_category LIKE %@)", NSString(string: "繰越利益"), NSString(string: "繰越利益")) // 消すと、損益勘定の差引残高の計算が狂う　2020/10/11
        ])
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　勘定別 損益勘定のみ　繰越利益を含む
    func getAllAdjustingEntryInPLAccountWithRetainedEarningsCarriedForward(account: String) -> Results<DataBaseAdjustingEntry> {
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let dataBaseAccount = dataBaseAccountingBooks.dataBaseGeneralLedger!.dataBaseAccounts
            .filter("accountName LIKE '\(account)'")
        var objects = dataBaseAccount[0].dataBaseAdjustingEntries
            .filter("debit_category LIKE '\(account)' || credit_category LIKE '\(account)'")
            .filter("debit_category LIKE '\("損益勘定")' || credit_category LIKE '\("損益勘定")'")
        // .filter("!(debit_category LIKE '\("繰越利益")') && !(credit_category LIKE '\("繰越利益")')") // 消すと、損益勘定の差引残高の計算が狂う　2020/10/11
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }
    // 取得 決算整理仕訳　勘定別 損益勘定のみ　繰越利益のみ
    func getAllAdjustingEntryWithRetainedEarningsCarriedForward(account: String) -> Results<DataBaseAdjustingEntry> {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let fiscalYear: Int = object.dataBaseJournals!.fiscalYear
        var objects = RealmManager.shared.readWithPredicate(type: DataBaseAdjustingEntry.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: fiscalYear)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: account), NSString(string: account)),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "損益勘定"), NSString(string: "損益勘定")),
            NSPredicate(format: "debit_category LIKE %@ OR credit_category LIKE %@", NSString(string: "繰越利益"), NSString(string: "繰越利益"))
        ])
        objects = objects.sorted(byKeyPath: "date", ascending: true)
        return objects
    }

    // 丁数を取得
    func getNumberOfAccount(accountName: String) -> Int {
        if accountName == "損益勘定" {
            return 0
        } else {
            let objects = RealmManager.shared.readWithPredicate(type: DataBaseSettingsTaxonomyAccount.self, predicates: [ // DataBaseAccount.self) 2020/11/08
                NSPredicate(format: "category LIKE %@", NSString(string: accountName)) // "accountName LIKE '\(accountName)'")// 2020/11/08
            ])
            print(objects)
            // 勘定のプライマリーキーを取得する
            let numberOfAccount = objects[0].number
            return numberOfAccount
        }
    }

    // 取得　勘定名から勘定を取得
    func getAccountByAccountName(accountName: String) -> DataBaseAccount? {
        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let dataBaseAccount = RealmManager.shared.read(type: DataBaseAccount.self, predicates: [
            NSPredicate(format: "fiscalYear == %@", NSNumber(value: object.dataBaseJournals!.fiscalYear)),
            NSPredicate(format: "accountName LIKE %@", NSString(string: accountName))
        ])
        return dataBaseAccount
    }
    // 削除　勘定　設定勘定科目を削除するときに呼ばれる
    func deleteAccount(number: Int) -> Bool {
        // (2)データベース内に保存されているモデルを取得する　プライマリーキーを指定してオブジェクトを取得
        guard let object = RealmManager.shared.findFirst(type: DataBaseSettingsTaxonomyAccount.self, key: number) else { return false }
        // 勘定　全年度　取得
        let objectsssss = RealmManager.shared.readWithPredicate(type: DataBaseAccount.self, predicates: [
            NSPredicate(format: "accountName LIKE %@", NSString(string: object.category))
        ])
        // 勘定クラス　勘定ないの仕訳を取得
        let dataBaseManagerAccount = GeneralLedgerAccountModel()
        let objectss = dataBaseManagerAccount.getAllJournalEntryInAccountAll(account: object.category) // 全年度の仕訳データを確認する
        let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccountAll(account: object.category) // 全年度の仕訳データを確認する
        let objectssss = dataBaseManagerAccount.getAllAdjustingEntryInPLAccountAll(account: object.category) // 全年度の仕訳データを確認する
        // 仕訳クラス　仕訳を削除
        let dataBaseManagerJournalEntry = DataBaseManagerJournalEntry()
        var isInvalidated = true // 初期値は真とする。仕訳データが0件の場合の対策
        var isInvalidatedd = true
        var isInvalidateddd = true
        for _ in 0..<objectss.count {
            isInvalidated = dataBaseManagerJournalEntry.deleteJournalEntry(number: objectss[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // 仕訳クラス　決算整理仕訳仕訳を削除
        for _ in 0..<objectsss.count {
            isInvalidatedd = dataBaseManagerJournalEntry.deleteAdjustingJournalEntry(number: objectsss[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        // 損益振替仕訳を削除
        for _ in 0..<objectssss.count {
            isInvalidateddd = dataBaseManagerJournalEntry.deleteAdjustingJournalEntry(number: objectssss[0].number) // 削除するたびにobjectss.countが減っていくので、iを利用せずに常に要素0を消す
        }
        if isInvalidateddd {
            if isInvalidatedd {
                if isInvalidated {
                    do {
                        try DataBaseManager.realm.write {
                            for _ in 0..<objectsssss.count {
                                // 仕訳が残ってないか
                                DataBaseManager.realm.delete(objectsssss[0])
                            }
                        }
                    } catch {
                        print("エラーが発生しました")
                    }
                    return true // objectsssss.isInvalidated // 成功したら true まだ失敗時の動きは確認していない
                }
            }
        }
        return false
    }
}
