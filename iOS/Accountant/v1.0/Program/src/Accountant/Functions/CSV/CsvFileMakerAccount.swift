//
//  CsvFileMakerAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/01/25.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class CsvFileMakerAccount {
    
    var csvPath: URL?
    // 勘定名
    var account: String = ""
    var fiscalYear = 0
    // 通常仕訳 勘定別に月別に取得
    private var databaseJournalEntriesSection0: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection1: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection2: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection3: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection4: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection5: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection6: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection7: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection8: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection9: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection10: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection11: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection12: Results<DataBaseJournalEntry>?

    func initialize(account: String, completion: (URL?) -> Void) {
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        fiscalYear = dataBaseAccountingBooks.fiscalYear
        // 初期化
        self.account = account
        csvPath = nil
        guard let tempDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return }
        let csvsDirectory = tempDirectory.appendingPathComponent("CSVs", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: csvsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("失敗した")
        }
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: csvsDirectory, includingPropertiesForKeys: nil) // ファイル一覧を取得
            // if you want to filter the directory contents you can do like this:
            let csvFiles = directoryContents.filter { $0.pathExtension == "csv" }
            print("csv urls: ", csvFiles)
            let csvFileNames = csvFiles.map { $0.deletingPathExtension().lastPathComponent }
            print("csv list: ", csvFileNames)
            // ファイルのデータを取得
            for fileName in csvFileNames {
                let content = csvsDirectory.appendingPathComponent(fileName + ".csv")
                do {
                    try FileManager.default.removeItem(at: content)
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
        
        let url = readDB()
        completion(url)
    }
    
    // csvファイルを生成
    func readDB() -> URL? {
        // 勘定のデータを取得する
        let generalLedgerAccountModel = GeneralLedgerAccountModel()
        // 開始仕訳
        let dataBaseOpeningJournalEntry = generalLedgerAccountModel.getOpeningJournalEntryInAccount(account: account)
        // 通常仕訳　勘定別
        let dataBaseJournalEntries = generalLedgerAccountModel.getJournalEntryInAccount(account: account)
        // 決算整理仕訳　勘定別
        let dataBaseAdjustingEntries = generalLedgerAccountModel.getAdjustingJournalEntryInAccount(account: account)
        // 資本振替仕訳
        let dataBaseCapitalTransferJournalEntry = generalLedgerAccountModel.getCapitalTransferJournalEntryInAccount(account: account)
        generalLedgerAccountModel.initialize(
            account: account,
            dataBaseOpeningJournalEntry: dataBaseOpeningJournalEntry,
            databaseJournalEntries: dataBaseJournalEntries,
            dataBaseAdjustingEntries: dataBaseAdjustingEntries,
            dataBaseCapitalTransferJournalEntry: dataBaseCapitalTransferJournalEntry
        )
        
        // 月別の月末日を取得 12ヶ月分
        let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
        for i in 0..<lastDays.count {
            // 通常仕訳 勘定別に月別に取得
            let dataBaseJournalEntries = generalLedgerAccountModel.getJournalEntryInAccountInMonth(
                account: account,
                yearMonth: "\(lastDays[i].year)" + "/" + "\(String(format: "%02d", lastDays[i].month))"
            )
            switch i {
            case 0:
                databaseJournalEntriesSection0 = dataBaseJournalEntries
            case 1:
                databaseJournalEntriesSection1 = dataBaseJournalEntries
            case 2:
                databaseJournalEntriesSection2 = dataBaseJournalEntries
            case 3:
                databaseJournalEntriesSection3 = dataBaseJournalEntries
            case 4:
                databaseJournalEntriesSection4 = dataBaseJournalEntries
            case 5:
                databaseJournalEntriesSection5 = dataBaseJournalEntries
            case 6:
                databaseJournalEntriesSection6 = dataBaseJournalEntries
            case 7:
                databaseJournalEntriesSection7 = dataBaseJournalEntries
            case 8:
                databaseJournalEntriesSection8 = dataBaseJournalEntries
            case 9:
                databaseJournalEntriesSection9 = dataBaseJournalEntries
            case 10:
                databaseJournalEntriesSection10 = dataBaseJournalEntries
            case 11:
                databaseJournalEntriesSection11 = dataBaseJournalEntries
            case 12:
                databaseJournalEntriesSection12 = dataBaseJournalEntries
            default:
                break
            }
        }
        // 通常仕訳　月次残高
        func numberOfDatabaseJournalEntries(forSection: Int) -> Int {
            switch forSection {
            case 0:
                return databaseJournalEntriesSection0?.count ?? 0
            case 1:
                return databaseJournalEntriesSection1?.count ?? 0
            case 2:
                return databaseJournalEntriesSection2?.count ?? 0
            case 3:
                return databaseJournalEntriesSection3?.count ?? 0
            case 4:
                return databaseJournalEntriesSection4?.count ?? 0
            case 5:
                return databaseJournalEntriesSection5?.count ?? 0
            case 6:
                return databaseJournalEntriesSection6?.count ?? 0
            case 7:
                return databaseJournalEntriesSection7?.count ?? 0
            case 8:
                return databaseJournalEntriesSection8?.count ?? 0
            case 9:
                return databaseJournalEntriesSection9?.count ?? 0
            case 10:
                return databaseJournalEntriesSection10?.count ?? 0
            case 11:
                return databaseJournalEntriesSection11?.count ?? 0
            case 12:
                return databaseJournalEntriesSection12?.count ?? 0
            default:
                return 0
            }
        }
        // 通常仕訳　月次残高
        func databaseJournalEntries(forSection: Int, forRow row: Int) -> DataBaseJournalEntry? {
            switch forSection {
            case 0:
                return databaseJournalEntriesSection0?[row]
            case 1:
                return databaseJournalEntriesSection1?[row]
            case 2:
                return databaseJournalEntriesSection2?[row]
            case 3:
                return databaseJournalEntriesSection3?[row]
            case 4:
                return databaseJournalEntriesSection4?[row]
            case 5:
                return databaseJournalEntriesSection5?[row]
            case 6:
                return databaseJournalEntriesSection6?[row]
            case 7:
                return databaseJournalEntriesSection7?[row]
            case 8:
                return databaseJournalEntriesSection8?[row]
            case 9:
                return databaseJournalEntriesSection9?[row]
            case 10:
                return databaseJournalEntriesSection10?[row]
            case 11:
                return databaseJournalEntriesSection11?[row]
            case 12:
                return databaseJournalEntriesSection12?[row]
            default:
                return nil
            }
        }
        

        var csv = ""
        
        // 開始仕訳
        if let dataBaseTransferEntry = generalLedgerAccountModel.getOpeningJournalEntryInAccount(account: account) {
            var line = ""

            var debitCategory = ""
            if dataBaseTransferEntry.debit_category == "資本金勘定" {
                debitCategory = Constant.capitalAccountName
            } else {
                debitCategory = dataBaseTransferEntry.debit_category == "残高" ? "前期繰越" : dataBaseTransferEntry.debit_category
            }
            var creditCategory = ""
            if dataBaseTransferEntry.credit_category == "資本金勘定" {
                creditCategory = Constant.capitalAccountName
            } else {
                creditCategory = dataBaseTransferEntry.credit_category == "残高" ? "前期繰越" : dataBaseTransferEntry.credit_category
            }
            var correspondingAccounts: String = "" // 当勘定の相手勘定
            if debitCategory == account {
                correspondingAccounts = creditCategory
            } else if creditCategory == account {
                correspondingAccounts = debitCategory
            }
            // 借又貸
            var balanceDebitOrCredit: String = ""
            if dataBaseTransferEntry.balance_left > dataBaseTransferEntry.balance_right {
                balanceDebitOrCredit = "借"
            } else if dataBaseTransferEntry.balance_left < dataBaseTransferEntry.balance_right {
                balanceDebitOrCredit = "貸"
            } else {
                balanceDebitOrCredit = "-"
            }
            // 差引残高額
            var balanceAmount: Int64 = 0
            if dataBaseTransferEntry.balance_left > dataBaseTransferEntry.balance_right { // 借方と貸方を比較
                balanceAmount = dataBaseTransferEntry.balance_left
            } else if dataBaseTransferEntry.balance_right > dataBaseTransferEntry.balance_left {
                balanceAmount = dataBaseTransferEntry.balance_right
            } else {
                balanceAmount = 0
            }
            // 日付
            line += "\(dataBaseTransferEntry.date)" + ","
            // 相手勘定
            line += "\"" + (correspondingAccounts.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // 摘要
            let smallWritting = dataBaseTransferEntry.smallWritting
            line += "\"" + (smallWritting.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // 借方
            let debitAmount = dataBaseTransferEntry.debit_amount
            line += debitCategory == account ? String(debitAmount) + "," : ","
            // 貸方
            let creditAmount = dataBaseTransferEntry.credit_amount
            line += creditCategory == account ? String(creditAmount) + "," : ","
            // 借又貸
            line += "\"" + (balanceDebitOrCredit.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // 差引残高
            line += String(balanceAmount) + "\r\n"
            
            csv += line // csv = CSVとして出力する内容全体
        }

        // 仕訳
        // 月別の月末日を取得 12ヶ月分
        for x in 0..<lastDays.count {
            // 配列のインデックス　月別の月末日を取得 12ヶ月分
            var index: Int?
            
            // MARK: 前月繰越
            // 貸借科目　のみに絞る
            if !DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
                // 月別の翌月の初日を取得 12ヶ月分
                let nextFirstDays = DateManager.shared.getTheDayOfEndingOfMonth(isLastDay: false)
                
                switch x {
                    // case 0: // 初月は前期繰越があるため、不要
                    // 通常仕訳 期首
                case 1:
                    index = 0
                case 2:
                    index = 1
                case 3:
                    index = 2
                case 4:
                    index = 3
                case 5:
                    index = 4
                case 6:
                    index = 5
                case 7:
                    index = 6
                case 8:
                    index = 7
                case 9:
                    index = 8
                case 10:
                    index = 9
                case 11:
                    index = 10 // 決算月　決算日が月末の場合
                case 12:
                    index = 11 // 決算月　決算日が月末ではない場合
                    // 決算月は次期繰越があるため、不要
                    // 通常仕訳 期末
                default:
                    index = nil
                }

                if let index = index,
                   // 月別の翌月の初日を取得 12ヶ月分　に存在するか
                   nextFirstDays.count > index,
                   // 取得 月次残高振替仕訳　今年度の勘定別で日付の先方一致
                   let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: account,
                    yearMonth: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" // BEGINSWITH 前方一致
                   ) {
                    var line = ""

                    // 先頭行
                    let fiscalYear = dataBaseMonthlyTransferEntry.fiscalYear
                    
                    let debitCategory = dataBaseMonthlyTransferEntry.debit_category
                    let debitAmount = dataBaseMonthlyTransferEntry.balance_left // 貸方勘定　＊引数の借方勘定を振替える
                    let creditCategory = dataBaseMonthlyTransferEntry.credit_category
                    let creditAmount = dataBaseMonthlyTransferEntry.balance_right // 借方勘定　＊引数の貸方勘定を振替える
                    let smallWritting = dataBaseMonthlyTransferEntry.smallWritting
                    var correspondingAccounts: String = "" // 当勘定の相手勘定
                    if debitCategory == account {
                        correspondingAccounts = creditCategory
                    } else if creditCategory == account {
                        correspondingAccounts = debitCategory
                    }
                    // 借又貸
                    var balanceDebitOrCredit: String = ""
                    if dataBaseMonthlyTransferEntry.balance_left > dataBaseMonthlyTransferEntry.balance_right {
                        balanceDebitOrCredit = "借"
                    } else if dataBaseMonthlyTransferEntry.balance_left < dataBaseMonthlyTransferEntry.balance_right {
                        balanceDebitOrCredit = "貸"
                    } else {
                        balanceDebitOrCredit = "-"
                    }
                    // 差引残高額
                    var balanceAmount: Int64 = 0
                    if dataBaseMonthlyTransferEntry.balance_left > dataBaseMonthlyTransferEntry.balance_right { // 借方と貸方を比較
                        balanceAmount = dataBaseMonthlyTransferEntry.balance_left
                    } else if dataBaseMonthlyTransferEntry.balance_right > dataBaseMonthlyTransferEntry.balance_left {
                        balanceAmount = dataBaseMonthlyTransferEntry.balance_right
                    } else {
                        balanceAmount = 0
                    }
                    // 日付
                    line += "\(String(format: "%02d", nextFirstDays[index].year))" + "/" + "\(String(format: "%02d", nextFirstDays[index].month))" + "/" + "\(String(format: "%02d", nextFirstDays[index].day))" + ","
                    // 相手勘定
                    line += "\"" + "前月繰越" + "\","
                    // 摘要
                    line += "\"" + (smallWritting.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
                    // 借方 相手勘定の残高勘定
                    line += debitCategory == correspondingAccounts ? String(debitAmount) + "," : ","
                    // 貸方 相手勘定の残高勘定
                    line += creditCategory == correspondingAccounts ? String(creditAmount) + "," : ","
                    // 借又貸
                    line += "\"" + (balanceDebitOrCredit.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
                    // 差引残高
                    line += String(balanceAmount) + "\r\n"
                    
                    csv += line // csv = CSVとして出力する内容全体
                }
            }
            
            // MARK: 仕訳
            // 仕訳の数だけ繰り返す
            for i in 0..<numberOfDatabaseJournalEntries(forSection: x) {
                // 通常仕訳　通常仕訳 勘定別
                if let databaseJournalEntry = databaseJournalEntries(forSection: x, forRow: i) {
                    var line = ""

                    let fiscalYear = databaseJournalEntry.fiscalYear
                    let date = databaseJournalEntry.date
                    
                    let debitCategory = databaseJournalEntry.debit_category
                    let debitAmount = databaseJournalEntry.debit_amount
                    let creditCategory = databaseJournalEntry.credit_category
                    let creditAmount = databaseJournalEntry.credit_amount
                    let smallWritting = databaseJournalEntry.smallWritting
                    var correspondingAccounts: String = "" // 当勘定の相手勘定
                    if debitCategory == account {
                        correspondingAccounts = creditCategory
                    } else if creditCategory == account {
                        correspondingAccounts = debitCategory
                    }
                    let numberOfAccount: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(correspondingAccounts)")
                    _ = databaseJournalEntry.balance_left
                    _ = databaseJournalEntry.balance_right
                    // 借又貸
                    var balanceDebitOrCredit: String = ""
                    if databaseJournalEntry.balance_left > databaseJournalEntry.balance_right {
                        balanceDebitOrCredit = "借"
                    } else if databaseJournalEntry.balance_left < databaseJournalEntry.balance_right {
                        balanceDebitOrCredit = "貸"
                    } else {
                        balanceDebitOrCredit = "-"
                    }
                    // 差引残高額
                    var balanceAmount: Int64 = 0
                    if databaseJournalEntry.balance_left > databaseJournalEntry.balance_right { // 借方と貸方を比較
                        balanceAmount = databaseJournalEntry.balance_left
                    } else if databaseJournalEntry.balance_right > databaseJournalEntry.balance_left {
                        balanceAmount = databaseJournalEntry.balance_right
                    } else {
                        balanceAmount = 0
                    }
                    // 日付
                    line += "\(date)" + ","
                    // 相手勘定
                    line += "\"" + (correspondingAccounts.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
                    // 摘要
                    line += "\"" + (smallWritting.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
                    // 借方
                    line += debitCategory == account ? String(debitAmount) + "," : ","
                    // 貸方
                    line += creditCategory == account ? String(creditAmount) + "," : ","
                    // 借又貸
                    line += "\"" + (balanceDebitOrCredit.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
                    // 差引残高
                    line += String(balanceAmount) + "\r\n"
                    
                    csv += line // csv = CSVとして出力する内容全体
                }
            }
            
            // MARK: 次月繰越
            // 貸借科目　のみに絞る
            if !DatabaseManagerSettingsTaxonomyAccount.shared.checkSettingsTaxonomyAccountRank0(account: account) {
                // 月別の翌月の初日を取得 12ヶ月分
                let nextFirstDays = DateManager.shared.getTheDayOfEndingOfMonth(isLastDay: false)
                
                switch x {
                case 0:
                    // 通常仕訳 期首
                    index = 0
                case 1:
                    index = 1
                case 2:
                    index = 2
                case 3:
                    index = 3
                case 4:
                    index = 4
                case 5:
                    index = 5
                case 6:
                    index = 6
                case 7:
                    index = 7
                case 8:
                    index = 8
                case 9:
                    index = 9
                case 10:
                    index = 10 // 決算月　決算日が月末の場合
                case 11:
                    index = 11 // 決算月　決算日が月末ではない場合
                    // 決算整理仕訳の下に次月繰越を表示させる。月次残高振替仕訳には決算整理仕訳も含まれるため。
                    // 通常仕訳 期末
                default:
                    index = nil
                }
                
                if let index = index,
                   // 月別の月末を取得 12ヶ月分　に存在するか
                   lastDays.count > index,
                   // 取得 月次残高振替仕訳　今年度の勘定別で日付の先方一致
                   let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: account,
                    yearMonth: "\(lastDays[index].year)" + "/" + "\(String(format: "%02d", lastDays[index].month))" // BEGINSWITH 前方一致
                   ) {
                    var line = ""
                    
                    // 先頭行
                    let fiscalYear = dataBaseMonthlyTransferEntry.fiscalYear
                    
                    let debitCategory = dataBaseMonthlyTransferEntry.credit_category // 借方勘定　＊引数の貸方勘定を振替える
                    let debitAmount = dataBaseMonthlyTransferEntry.balance_right // 借方勘定　＊引数の貸方勘定を振替える

                    let creditCategory = dataBaseMonthlyTransferEntry.debit_category // 貸方勘定　＊引数の借方勘定を振替える
                    let creditAmount = dataBaseMonthlyTransferEntry.balance_left // 貸方勘定　＊引数の借方勘定を振替える
                    let smallWritting = dataBaseMonthlyTransferEntry.smallWritting
                    var correspondingAccounts: String = "" // 当勘定の相手勘定
                    if debitCategory == account {
                        correspondingAccounts = creditCategory
                    } else if creditCategory == account {
                        correspondingAccounts = debitCategory
                    }
                    // 借又貸
                    var balanceDebitOrCredit: String = ""
                    if dataBaseMonthlyTransferEntry.balance_left > dataBaseMonthlyTransferEntry.balance_right {
                        balanceDebitOrCredit = "借"
                    } else if dataBaseMonthlyTransferEntry.balance_left < dataBaseMonthlyTransferEntry.balance_right {
                        balanceDebitOrCredit = "貸"
                    } else {
                        balanceDebitOrCredit = "-"
                    }
                    // 差引残高額
                    var balanceAmount: Int64 = 0
                    if dataBaseMonthlyTransferEntry.balance_left > dataBaseMonthlyTransferEntry.balance_right { // 借方と貸方を比較
                        balanceAmount = dataBaseMonthlyTransferEntry.balance_left
                    } else if dataBaseMonthlyTransferEntry.balance_right > dataBaseMonthlyTransferEntry.balance_left {
                        balanceAmount = dataBaseMonthlyTransferEntry.balance_right
                    } else {
                        balanceAmount = 0
                    }

                    // 次月繰越 次月繰越
                    // 日付
                    line += "\(dataBaseMonthlyTransferEntry.date)" + ","
                    // 相手勘定
                    line += "\"" + "次月繰越" + "\","
                    // 摘要
                    line += "\"" + (smallWritting.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
                    // 借方 相手勘定の残高勘定
                    line += debitCategory == correspondingAccounts ? String(debitAmount) + "," : ","
                    // 貸方 相手勘定の残高勘定
                    line += creditCategory == correspondingAccounts ? String(creditAmount) + "," : ","
                    // 借又貸
                    line += "\"" + "-" + "\","
                    // 差引残高
                    line += "0" + "\r\n"
                    
                    csv += line // csv = CSVとして出力する内容全体
                }
            }
        }
        
        // 決算整理仕訳
        for i in 0..<dataBaseAdjustingEntries.count {
            var line = ""
            
            let date = dataBaseAdjustingEntries[i].date
            let debitCategory = dataBaseAdjustingEntries[i].debit_category
            let debitAmount = dataBaseAdjustingEntries[i].debit_amount
            let creditCategory = dataBaseAdjustingEntries[i].credit_category
            let creditAmount = dataBaseAdjustingEntries[i].credit_amount
            let smallWritting = dataBaseAdjustingEntries[i].smallWritting

            var correspondingAccounts: String = "" // 当勘定の相手勘定
            if debitCategory == account {
                correspondingAccounts = creditCategory
            } else if creditCategory == account {
                correspondingAccounts = debitCategory
            }
            // 借又貸
            var balanceDebitOrCredit: String = ""
            if dataBaseAdjustingEntries[i].balance_left > dataBaseAdjustingEntries[i].balance_right {
                balanceDebitOrCredit = "借"
            } else if dataBaseAdjustingEntries[i].balance_left < dataBaseAdjustingEntries[i].balance_right {
                balanceDebitOrCredit = "貸"
            } else {
                balanceDebitOrCredit = "-"
            }
            // 差引残高額
            var balanceAmount: Int64 = 0
            if dataBaseAdjustingEntries[i].balance_left > dataBaseAdjustingEntries[i].balance_right { // 借方と貸方を比較
                balanceAmount = dataBaseAdjustingEntries[i].balance_left
            } else if dataBaseAdjustingEntries[i].balance_right > dataBaseAdjustingEntries[i].balance_left {
                balanceAmount = dataBaseAdjustingEntries[i].balance_right
            } else {
                balanceAmount = 0
            }
            // 日付
            line += "\(date)" + ","
            // 相手勘定
            line += "\"" + (correspondingAccounts.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // 摘要
            line += "\"" + (smallWritting.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // 借方
            line += debitCategory == account ? String(debitAmount) + "," : ","
            // 貸方
            line += creditCategory == account ? String(creditAmount) + "," : ","
            // 借又貸
            line += "\"" + (balanceDebitOrCredit.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // 差引残高
            line += String(balanceAmount) + "\r\n"
            
            csv += line // csv = CSVとして出力する内容全体
        }
        
        // 資本振替仕訳
        if let dataBaseCapitalTransferJournalEntry = dataBaseCapitalTransferJournalEntry {
            var line = ""
            
            var debitCategory = ""
            if dataBaseCapitalTransferJournalEntry.debit_category == "損益" { // 損益勘定の場合
                debitCategory = dataBaseCapitalTransferJournalEntry.debit_category
            } else {
                debitCategory = Constant.capitalAccountName
            }
            var creditCategory = ""
            if dataBaseCapitalTransferJournalEntry.credit_category == "損益" { // 損益勘定の場合
                creditCategory = dataBaseCapitalTransferJournalEntry.credit_category
            } else {
                creditCategory = Constant.capitalAccountName
            }
            
            let date = dataBaseCapitalTransferJournalEntry.date
            let debitAmount = dataBaseCapitalTransferJournalEntry.debit_amount
            let creditAmount = dataBaseCapitalTransferJournalEntry.credit_amount
            let smallWritting = dataBaseCapitalTransferJournalEntry.smallWritting
            var correspondingAccounts: String = "" // 当勘定の相手勘定
            if debitCategory == account {
                correspondingAccounts = creditCategory
            } else if creditCategory == account {
                correspondingAccounts = debitCategory
            }
            // 借又貸
            var balanceDebitOrCredit: String = ""
            if dataBaseCapitalTransferJournalEntry.balance_left > dataBaseCapitalTransferJournalEntry.balance_right {
                balanceDebitOrCredit = "借"
            } else if dataBaseCapitalTransferJournalEntry.balance_left < dataBaseCapitalTransferJournalEntry.balance_right {
                balanceDebitOrCredit = "貸"
            } else {
                balanceDebitOrCredit = "-"
            }
            // 差引残高額
            var balanceAmount: Int64 = 0
            if dataBaseCapitalTransferJournalEntry.balance_left > dataBaseCapitalTransferJournalEntry.balance_right { // 借方と貸方を比較
                balanceAmount = dataBaseCapitalTransferJournalEntry.balance_left
            } else if dataBaseCapitalTransferJournalEntry.balance_right > dataBaseCapitalTransferJournalEntry.balance_left {
                balanceAmount = dataBaseCapitalTransferJournalEntry.balance_right
            } else {
                balanceAmount = 0
            }
            // 日付
            line += "\(date)" + ","
            // 相手勘定
            line += "\"" + (correspondingAccounts.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // 摘要
            line += "\"" + (smallWritting.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // 借方
            line += debitCategory == account ? String(debitAmount) + "," : ","
            // 貸方
            line += creditCategory == account ? String(creditAmount) + "," : ","
            // 借又貸
            line += "\"" + (balanceDebitOrCredit.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // 差引残高
            line += String(balanceAmount) + "\r\n"
            
            csv += line // csv = CSVとして出力する内容全体
        }

        // 損益振替仕訳
        if let dataBaseTransferEntry = generalLedgerAccountModel.getTransferEntryInAccount(account: account) {
            var line = ""
            
            var debitCategory = ""
            if dataBaseTransferEntry.debit_category == "資本金勘定" {
                debitCategory = Constant.capitalAccountName
            } else {
                debitCategory = dataBaseTransferEntry.debit_category == "残高" ? "次期繰越" : dataBaseTransferEntry.debit_category
            }
            var creditCategory = ""
            if dataBaseTransferEntry.credit_category == "資本金勘定" {
                creditCategory = Constant.capitalAccountName
            } else {
                creditCategory = dataBaseTransferEntry.credit_category == "残高" ? "次期繰越" : dataBaseTransferEntry.credit_category
            }
            
            let date = dataBaseTransferEntry.date
            let debitAmount = dataBaseTransferEntry.debit_amount
            let creditAmount = dataBaseTransferEntry.credit_amount
            let smallWritting = dataBaseTransferEntry.smallWritting
            var correspondingAccounts: String = "" // 当勘定の相手勘定
            if debitCategory == account {
                correspondingAccounts = creditCategory
            } else if creditCategory == account {
                correspondingAccounts = debitCategory
            }
            let balanceAmount = Int64(0)
            let balanceDebitOrCredit = "-"

            // 日付
            line += "\(date)" + ","
            // 相手勘定
            line += "\"" + (correspondingAccounts.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // 摘要
            line += "\"" + (smallWritting.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // 借方
            line += debitCategory == account ? String(debitAmount) + "," : ","
            // 貸方
            line += creditCategory == account ? String(creditAmount) + "," : ","
            // 借又貸
            line += "\"" + (balanceDebitOrCredit.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // 差引残高
            line += String(balanceAmount) + "\r\n"
            
            csv += line // csv = CSVとして出力する内容全体
        }
        
        csv = "日付,相手勘定,摘要,借方,貸方,借又貸,差引残高\r\n" + csv // 見出し行を先頭行に追加
        print(csv)
        // csvデータを一時ディレクトリに保存する
        if let fileUrl = saveToTempDirectory(csv: csv) {
            // csvファイルを表示する
            csvPath = fileUrl
            
            return csvPath
        } else {
            return nil
        }
    }
    
    /*
     この関数は、特定の `data` をアプリの一時ストレージに保存します。さらに、そのファイルが存在する場所のパスを返します。
     */
    func saveToTempDirectory(csv: String) -> URL? {
        guard let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return nil }
        let csvsDirectory = documentDirectory.appendingPathComponent("CSVs", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: csvsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("失敗した")
        }
        
        let filePath = csvsDirectory.appendingPathComponent("\(fiscalYear)-GeneralLedger-\(account)" + ".csv")
        // テンポラリディレクトリ/data.csv の URL （ファイルパス）取得
        if let strm = OutputStream(url: filePath, append: false) { // 新規書き込みでストリーム作成
            strm.open() // ストリームオープン（fopenみたいな）
            let BOM = "\u{feff}"
            // U+FEFF：バイトオーダーマーク（Byte Order Mark, BOM）
            // Unicode の U+FEFFは、表示がない文字。「ZERO WIDTH NO-BREAK SPACE」（幅の無い改行しない空白）
            strm.write(BOM, maxLength: 3) // UTF-8 の BOM 3バイト 0xEF 0xBB 0xBF 書き込み
            let data = csv.data(using: .utf8)
            // string.data(using: .utf8)メソッドで文字コード UTF-8 の
            // Data 構造体を得る
            _ = data?.withUnsafeBytes { // dataのバッファに直接アクセス
                if let baseAddress = $0.baseAddress {
                    strm.write(baseAddress, maxLength: Int(data?.count ?? 0))
                    // 【$0】
                    // 連続したメモリ領域を指す UnsafeRawBufferPointer パラメーター
                    // 【$0.baseAddress】
                    // バッファへの最初のバイトへのポインタ
                    // 【maxLength:】
                    // 書き込むバイトdataバッファのバイト数（全長）
                    // 【data?.count ?? 0】
                    // ?? は、Nil結合演算子（Nil-Coalescing Operator）。
                    // data?.count が nil の場合、0。
                    // 【_ = data】
                    // 戻り値を利用しないため、_で受け取る。
                }
            }
            strm.close() // ストリームクローズ
        }
        print(filePath)
        return filePath
    }
}
