//
//  JournalsModel.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/01.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol JournalsModelInput {
    func initializeJournals(completion: (Bool) -> Void)
    
    func getJournalEntriesInJournals() -> Results<DataBaseJournalEntry>
    func getJournalAdjustingEntry() -> Results<DataBaseAdjustingEntry>
    func getTransferEntryInAccount() -> Results<DataBaseTransferEntry>
    func getCapitalTransferJournalEntryInAccount() -> DataBaseCapitalTransferJournalEntry?

    func updateJournalEntry(primaryKey: Int, fiscalYear: Int)
    func updateAdjustingJournalEntry(primaryKey: Int, fiscalYear: Int)
    func updateJournalEntry(
        primaryKey: Int,
        date: String?,
        debitCategory: String?,
        debitAmount: Int64?,
        creditCategory: String?,
        creditAmount: Int64?,
        smallWritting: String?,
        completion: (Int) -> Void
    )
    func updateAdjustingJournalEntry(
        primaryKey: Int,
        date: String?,
        debitCategory: String?,
        debitAmount: Int64?,
        creditCategory: String?,
        creditAmount: Int64?,
        smallWritting: String?,
        completion: (Int) -> Void
    )
    
    func initializePDFMaker(completion: ([URL]?) -> Void)
}

// 仕訳帳クラス
class JournalsModel: JournalsModelInput {
    
    // 印刷機能
    let pDFMaker = PDFMaker()
    // 初期化 PDFメーカー
    func initializePDFMaker(completion: ([URL]?) -> Void) {
        
        pDFMaker.initialize(completion: { PDFpath in
            completion(PDFpath)
        })
    }
    
    // MARK: - CRUD
    
    // MARK: Create
    
    // MARK: Read
    
    /**
     * 会計帳簿.仕訳帳.仕訳[ ] オブジェクトを取得するメソッド
     * 開いている帳簿の仕訳帳から通常仕訳を取得する
     * 日付を降順にソートする
     * @param -
     * @return 仕訳[ ]
     */
    func getJournalEntriesInJournals() -> Results<DataBaseJournalEntry> {
        
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let dataBaseJournalEntries = dataBaseAccountingBooks.dataBaseJournals!.dataBaseJournalEntries.sorted(byKeyPath: "date", ascending: true)
        return dataBaseJournalEntries
    }
    
    /**
     * 会計帳簿.仕訳帳.決算整理仕訳[ ] オブジェクトを取得するメソッド\
     * 決算整理仕訳
     * 日付を降順にソートする
     * @return 決算整理仕訳[ ]
     */
    func getJournalAdjustingEntry() -> Results<DataBaseAdjustingEntry> {
        let dataBaseAccountingBook = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let dataBaseAdjustingEntries = dataBaseAccountingBook.dataBaseJournals!.dataBaseAdjustingEntries.sorted(byKeyPath: "date", ascending: true)
        return dataBaseAdjustingEntries
    }
    // 取得　損益振替仕訳　※仕訳帳にプロパティを用意せずに、損益勘定のプロパティを参照する。
    func getTransferEntryInAccount() -> Results<DataBaseTransferEntry> {
        DataBaseManagerPLAccount.shared.getTransferEntryInAccount()
    }
    // 取得 資本振替仕訳
    func getCapitalTransferJournalEntryInAccount() -> DataBaseCapitalTransferJournalEntry? {
        let dataBaseAccountingBook = RealmManager.shared.read(type: DataBaseAccountingBooks.self, predicates: [
            NSPredicate(format: "openOrClose == %@", NSNumber(value: true))
        ])
        let dataBaseCapitalTransferJournalEntry = dataBaseAccountingBook?.dataBaseJournals!.dataBaseCapitalTransferJournalEntry
        return dataBaseCapitalTransferJournalEntry
    }
    
    // MARK: Update
    
    // 会計処理　転記、合計残高試算表(残高、合計(決算整理前、決算整理仕訳、決算整理後))、表示科目
    func initializeJournals(completion: (Bool) -> Void) {
        // 転記　仕訳から勘定への関連を付け直す
        DataBaseManagerJournals.shared.reconnectJournalEntryToAccounts()
        // 全勘定の合計と残高を計算する　注意：決算日設定機能で決算日を変更後に損益勘定と繰越利益の日付を更新するために必要な処理である
        let databaseManager = TBModel()
        databaseManager.setAllAccountTotal()            // 集計　合計残高試算表(残高、合計(決算整理前、決算整理仕訳、決算整理後))
        databaseManager.calculateAmountOfAllAccount()   // 合計額を計算
        // ウィジェット　貸借対照表と損益計算書の、五大区分の合計額と当期純利益の額を再計算する
        DataBaseManagerBalanceSheetProfitAndLossStatement.shared.setupAmountForBsAndPL()

        completion(true)
    }
    
    // 更新　仕訳　年度
    func updateJournalEntry(primaryKey: Int, fiscalYear: Int) {
        // 編集する仕訳
        guard let dataBaseJournalEntry = RealmManager.shared.readWithPrimaryKey(type: DataBaseJournalEntry.self, key: primaryKey) else { return }
        // 編集前の仕訳帳と借方勘定と貸方勘定
        guard let oldJournals = DataBaseManagerJournals.shared.getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        guard let oldLeftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.debit_category,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else { return }
        guard let oldRightObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.credit_category,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else { return }
        // 編集後の仕訳帳と借方勘定と貸方勘定
        guard let journals = DataBaseManagerJournals.shared.getJournalsWithFiscalYear(fiscalYear: fiscalYear) else { return }
        guard let leftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.debit_category,
            fiscalYear: fiscalYear
        ) else { return }
        guard let rightObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.credit_category,
            fiscalYear: fiscalYear
        ) else { return }
        // 編集する仕訳
        do {
            try DataBaseManager.realm.write {
                let value: [String: Any] = [
                    "number": primaryKey,
                    "fiscalYear": fiscalYear
                ]
                DataBaseManager.realm.create(DataBaseJournalEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        // 編集前の仕訳帳から仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldJournals.dataBaseJournalEntries.count where oldJournals.dataBaseJournalEntries[i].number == primaryKey ||
        oldJournals.dataBaseJournalEntries[i].isInvalidated {
            // TODO: removeしきれてない
            do {
                try DataBaseManager.realm.write {
                    oldJournals.dataBaseJournalEntries.remove(at: i) // 会計帳簿.仕訳帳.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        // 編集前の勘定から借方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldLeftObject.dataBaseJournalEntries.count where oldLeftObject.dataBaseJournalEntries[i].number == primaryKey ||
        oldLeftObject.dataBaseJournalEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldLeftObject.dataBaseJournalEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        // 編集前の勘定から貸方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldRightObject.dataBaseJournalEntries.count where oldRightObject.dataBaseJournalEntries[i].number == primaryKey ||
        oldRightObject.dataBaseJournalEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldRightObject.dataBaseJournalEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        // 編集後の仕訳帳と借方勘定と貸方勘定へ関連を追加する
        do {
            try DataBaseManager.realm.write {
                journals.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.仕訳帳.仕訳リスト
                // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
                // 勘定に借方の仕訳データを追加
                leftObject.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                // 勘定に貸方の仕訳データを追加
                rightObject.dataBaseJournalEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
        } catch {
            print("エラーが発生しました")
        }
        
    }
    // 更新　決算整理仕訳　年度 損益振替仕訳、資本振替仕訳以外の決算整理仕訳
    func updateAdjustingJournalEntry(primaryKey: Int, fiscalYear: Int) {
        // 編集する仕訳
        guard let dataBaseJournalEntry = RealmManager.shared.readWithPrimaryKey(type: DataBaseAdjustingEntry.self, key: primaryKey) else { return }
        // 編集前の仕訳帳と借方勘定と貸方勘定
        guard let oldJournals = DataBaseManagerJournals.shared.getJournalsWithFiscalYear(fiscalYear: dataBaseJournalEntry.fiscalYear) else { return }
        guard let oldLeftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.debit_category,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else { return }
        guard let oldRightObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.credit_category,
            fiscalYear: dataBaseJournalEntry.fiscalYear
        ) else { return }
        // 編集後の仕訳帳と借方勘定と貸方勘定
        guard let journals = DataBaseManagerJournals.shared.getJournalsWithFiscalYear(fiscalYear: fiscalYear) else { return }
        guard let leftObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.debit_category,
            fiscalYear: fiscalYear
        ) else { return }
        guard let rightObject: DataBaseAccount = DataBaseManagerAccount.shared.getAccountByAccountNameWithFiscalYear(
            accountName: dataBaseJournalEntry.credit_category,
            fiscalYear: fiscalYear
        ) else { return }
        // 編集する仕訳
        do {
            try DataBaseManager.realm.write {
                let value: [String: Any] = [
                    "number": primaryKey,
                    "fiscalYear": fiscalYear
                ]
                DataBaseManager.realm.create(DataBaseAdjustingEntry.self, value: value, update: .modified) // 一部上書き更新
            }
        } catch {
            print("エラーが発生しました")
        }
        // 編集前の仕訳帳から仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldJournals.dataBaseAdjustingEntries.count where oldJournals.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldJournals.dataBaseAdjustingEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldJournals.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.仕訳帳.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        // 編集前の勘定から借方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldLeftObject.dataBaseAdjustingEntries.count where oldLeftObject.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldLeftObject.dataBaseAdjustingEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldLeftObject.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        // 編集前の勘定から貸方の仕訳データを削除
    outerLoop: while true {
        for i in 0..<oldRightObject.dataBaseAdjustingEntries.count where oldRightObject.dataBaseAdjustingEntries[i].number == primaryKey ||
        oldRightObject.dataBaseAdjustingEntries[i].isInvalidated {
            do {
                try DataBaseManager.realm.write {
                    oldRightObject.dataBaseAdjustingEntries.remove(at: i) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                }
            } catch {
                print("エラーが発生しました")
            }
            continue outerLoop
        }
        break
    }
        // 編集後の仕訳帳と借方勘定と貸方勘定へ関連を追加する
        do {
            try DataBaseManager.realm.write {
                journals.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.仕訳帳.仕訳リスト
                // 勘定へ転記 開いている会計帳簿の総勘定元帳の勘定に仕訳データを追加したい
                // 勘定に借方の仕訳データを追加
                leftObject.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
                // 勘定に貸方の仕訳データを追加
                rightObject.dataBaseAdjustingEntries.append(dataBaseJournalEntry) // 会計帳簿.総勘定元帳.勘定.仕訳リスト
            }
        } catch {
            print("エラーが発生しました")
        }
    }
    // 更新 仕訳　日付、借方勘定、借方金額、貸方勘定、貸方金額、小書き
    func updateJournalEntry(
        primaryKey: Int,
        date: String?,
        debitCategory: String?,
        debitAmount: Int64?,
        creditCategory: String?,
        creditAmount: Int64?,
        smallWritting: String?,
        completion: (Int) -> Void
    ) {
        DataBaseManagerJournalEntry.shared.updateJournalEntry(
            primaryKey: primaryKey,
            date: date,
            debitCategory: debitCategory,
            debitAmount: debitAmount,
            creditCategory: creditCategory,
            creditAmount: creditAmount,
            smallWritting: smallWritting,
            completion: { primaryKey in
                print("Result is \(primaryKey)")
                completion(primaryKey)
            }
        )
    }
    // 更新 決算整理仕訳　日付、借方勘定、借方金額、貸方勘定、貸方金額、小書き
    func updateAdjustingJournalEntry(
        primaryKey: Int,
        date: String?,
        debitCategory: String?,
        debitAmount: Int64?,
        creditCategory: String?,
        creditAmount: Int64?,
        smallWritting: String?,
        completion: (Int) -> Void
    ) {
        DataBaseManagerAdjustingEntry.shared.updateAdjustingJournalEntry(
            primaryKey: primaryKey,
            date: date,
            debitCategory: debitCategory,
            debitAmount: debitAmount,
            creditCategory: creditCategory,
            creditAmount: creditAmount,
            smallWritting: smallWritting,
            completion: { primaryKey in
                print("Result is \(primaryKey)")
                completion(primaryKey)
            }
        )
    }
    
    // MARK: Delete

}
