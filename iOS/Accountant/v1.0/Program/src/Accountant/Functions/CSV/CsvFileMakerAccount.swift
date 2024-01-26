//
//  CsvFileMakerAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/01/25.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

class CsvFileMakerAccount {
    
    var csvPath: URL?
    // 勘定名
    var account: String = ""
    var fiscalYear = 0
    
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
            let balanceAmount = generalLedgerAccountModel.getBalanceAmountOpeningJournalEntry()
            let balanceDebitOrCredit = generalLedgerAccountModel.getBalanceDebitOrCreditOpeningJournalEntry()

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

        // 行数分繰り返す 仕訳
        for i in 0..<dataBaseJournalEntries.count {
            var line = ""
            
            let date = dataBaseJournalEntries[i].date
            let debitCategory = dataBaseJournalEntries[i].debit_category
            let debitAmount = dataBaseJournalEntries[i].debit_amount
            let creditCategory = dataBaseJournalEntries[i].credit_category
            let creditAmount = dataBaseJournalEntries[i].credit_amount
            let smallWritting = dataBaseJournalEntries[i].smallWritting

            var correspondingAccounts: String = "" // 当勘定の相手勘定
            if debitCategory == account {
                correspondingAccounts = creditCategory
            } else if creditCategory == account {
                correspondingAccounts = debitCategory
            }
            let balanceAmount = generalLedgerAccountModel.getBalanceAmount(indexPath: IndexPath(row: i, section: 0))
            let balanceDebitOrCredit = generalLedgerAccountModel.getBalanceDebitOrCredit(indexPath: IndexPath(row: i, section: 0))

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
            let balanceAmount = generalLedgerAccountModel.getBalanceAmountAdjusting(indexPath: IndexPath(row: i, section: 0))
            let balanceDebitOrCredit = generalLedgerAccountModel.getBalanceDebitOrCreditAdjusting(indexPath: IndexPath(row: i, section: 0))

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
            
            let balanceAmount = generalLedgerAccountModel.getBalanceAmountCapitalTransferJournalEntry()
            let balanceDebitOrCredit = generalLedgerAccountModel.getBalanceDebitOrCreditCapitalTransferJournalEntry()

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
