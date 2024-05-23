//
//  PDFMakerAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/02/15.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class PDFMakerAccount {
    
    var PDFpath: URL?
    
    let hTMLhelper = HTMLhelperAccount()
    let paperSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72) // 調整した　A4 210×297mm
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
        PDFpath = nil
        
        guard let tempDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return }
        let pDFsDirectory = tempDirectory.appendingPathComponent("PDFs", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: pDFsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("失敗した")
        }
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: pDFsDirectory, includingPropertiesForKeys: nil) // ファイル一覧を取得
            // if you want to filter the directory contents you can do like this:
            let pdfFiles = directoryContents.filter { $0.pathExtension == "pdf" }
            print("pdf urls: ", pdfFiles)
            let pdfFileNames = pdfFiles.map { $0.deletingPathExtension().lastPathComponent }
            print("pdf list: ", pdfFileNames)
            // ファイルのデータを取得
            for fileName in pdfFileNames {
                let content = pDFsDirectory.appendingPathComponent(fileName + ".pdf")
                do {
                    try FileManager.default.removeItem(at: content)
                } catch let error {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
        
        let url = readDB()
        completion(url)
    }
    
    // PDFファイルを生成
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
        
        var htmlString = ""
        
        // ページ数
        var pageNumber = 1
        
        // 行を取得する
        var totalDebitAmount: Int64 = 0
        var totalCreditAmount: Int64 = 0
        var counter = 0
        
        // HTMLのヘッダーを取得する
        let htmlHeader = hTMLhelper.headerHTMLstring()
        htmlString.append(htmlHeader)

        // 開始仕訳
        if let dataBaseTransferEntry = generalLedgerAccountModel.getOpeningJournalEntryInAccount(account: account) {

            let fiscalYear = dataBaseTransferEntry.fiscalYear
            if counter == 0 {
                let tableHeader = hTMLhelper.headerstring(title: account, fiscalYear: fiscalYear, pageNumber: pageNumber)
                htmlString.append(tableHeader)
            }
            // 日付
            guard let date = DateManager.shared.dateFormatter.date(from: dataBaseTransferEntry.date) else {
                return nil
            }

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

            let debitAmount = dataBaseTransferEntry.credit_amount
            let creditAmount = dataBaseTransferEntry.debit_amount
            _ = dataBaseTransferEntry.smallWritting
            var correspondingAccounts: String = "" // 当勘定の相手勘定
            if debitCategory == account {
                correspondingAccounts = creditCategory
            } else if creditCategory == account {
                correspondingAccounts = debitCategory
            }
            let numberOfAccount: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(correspondingAccounts)")
            _ = dataBaseTransferEntry.balance_left
            _ = dataBaseTransferEntry.balance_right

            let balanceAmount = generalLedgerAccountModel.getBalanceAmountOpeningJournalEntry()
            let balanceDebitOrCredit = generalLedgerAccountModel.getBalanceDebitOrCreditOpeningJournalEntry()

            let rowString = hTMLhelper.getSingleRow(
                month: String(date.month),
                day: String(date.day),
                debitCategory: debitCategory,
                debitAmount: debitAmount,
                creditCategory: creditCategory,
                creditAmount: creditAmount,
                correspondingAccounts: correspondingAccounts,
                numberOfAccount: numberOfAccount,
                balanceAmount: balanceAmount,
                balanceDebitOrCredit: balanceDebitOrCredit
            )
            htmlString.append(rowString)

            totalDebitAmount += dataBaseTransferEntry.debit_amount
            totalCreditAmount += dataBaseTransferEntry.credit_amount

            if counter >= 29 {
                let tableFooter = hTMLhelper.footerstring(debitAmount: totalDebitAmount, creditAmount: totalCreditAmount)
                htmlString.append(tableFooter)
            }
            counter += 1
            if counter >= 30 {
                counter = 0
                pageNumber += 1
            }
        }

        // 仕訳
        // 月別の月末日を取得 12ヶ月分
        for month in 0..<lastDays.count {
            // 仕訳の数だけ繰り返す
            for i in 0..<numberOfDatabaseJournalEntries(forSection: month) {
                // 通常仕訳　通常仕訳 勘定別
                if let databaseJournalEntry = databaseJournalEntries(forSection: month, forRow: i) {
                    
                    let fiscalYear = databaseJournalEntry.fiscalYear
                    if counter == 0 {
                        let tableHeader = hTMLhelper.headerstring(title: account, fiscalYear: fiscalYear, pageNumber: pageNumber)
                        htmlString.append(tableHeader)
                    }
                    // 日付
                    guard let date = DateManager.shared.dateFormatter.date(from: databaseJournalEntry.date) else {
                        return nil
                    }
                    
                    let debitCategory = databaseJournalEntry.debit_category
                    let debitAmount = databaseJournalEntry.debit_amount
                    let creditCategory = databaseJournalEntry.credit_category
                    let creditAmount = databaseJournalEntry.credit_amount
                    _ = databaseJournalEntry.smallWritting
                    var correspondingAccounts: String = "" // 当勘定の相手勘定
                    if debitCategory == account {
                        correspondingAccounts = creditCategory
                    } else if creditCategory == account {
                        correspondingAccounts = debitCategory
                    }
                    let numberOfAccount: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(correspondingAccounts)")
                    _ = databaseJournalEntry.balance_left
                    _ = databaseJournalEntry.balance_right
                    
                    let balanceAmount = generalLedgerAccountModel.getBalanceAmount(indexPath: IndexPath(row: i, section: 0))
                    let balanceDebitOrCredit = generalLedgerAccountModel.getBalanceDebitOrCredit(indexPath: IndexPath(row: i, section: 0))
                    
                    let rowString = hTMLhelper.getSingleRow(
                        month: String(date.month),
                        day: String(date.day),
                        debitCategory: debitCategory,
                        debitAmount: debitAmount,
                        creditCategory: creditCategory,
                        creditAmount: creditAmount,
                        correspondingAccounts: correspondingAccounts,
                        numberOfAccount: numberOfAccount,
                        balanceAmount: balanceAmount,
                        balanceDebitOrCredit: balanceDebitOrCredit
                    )
                    htmlString.append(rowString)
                    
                    totalDebitAmount += databaseJournalEntry.debit_amount
                    totalCreditAmount += databaseJournalEntry.credit_amount
                    
                    if counter >= 29 {
                        let tableFooter = hTMLhelper.footerstring(debitAmount: totalDebitAmount, creditAmount: totalCreditAmount)
                        htmlString.append(tableFooter)
                    }
                    counter += 1
                    if counter >= 30 {
                        counter = 0
                        pageNumber += 1
                    }
                }
            }
        }
        
        // 決算整理仕訳
        for i in 0..<dataBaseAdjustingEntries.count {
            
            let fiscalYear = dataBaseAdjustingEntries[i].fiscalYear
            if counter == 0 {
                let tableHeader = hTMLhelper.headerstring(title: account, fiscalYear: fiscalYear, pageNumber: pageNumber)
                htmlString.append(tableHeader)
            }
            // 日付
            guard let date = DateManager.shared.dateFormatter.date(from: dataBaseAdjustingEntries[i].date) else {
                return nil
            }

            let debitCategory = dataBaseAdjustingEntries[i].debit_category
            let debitAmount = dataBaseAdjustingEntries[i].debit_amount
            let creditCategory = dataBaseAdjustingEntries[i].credit_category
            let creditAmount = dataBaseAdjustingEntries[i].credit_amount
            _ = dataBaseAdjustingEntries[i].smallWritting
            var correspondingAccounts: String = "" // 当勘定の相手勘定
            if debitCategory == account {
                correspondingAccounts = creditCategory
            } else if creditCategory == account {
                correspondingAccounts = debitCategory
            }
            let numberOfAccount: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(correspondingAccounts)")
            _ = dataBaseAdjustingEntries[i].balance_left
            _ = dataBaseAdjustingEntries[i].balance_right
            
            let balanceAmount = generalLedgerAccountModel.getBalanceAmountAdjusting(indexPath: IndexPath(row: i, section: 0))
            let balanceDebitOrCredit = generalLedgerAccountModel.getBalanceDebitOrCreditAdjusting(indexPath: IndexPath(row: i, section: 0))
            
            let rowString = hTMLhelper.getSingleRow(
                month: String(date.month),
                day: String(date.day),
                debitCategory: debitCategory,
                debitAmount: debitAmount,
                creditCategory: creditCategory,
                creditAmount: creditAmount,
                correspondingAccounts: correspondingAccounts,
                numberOfAccount: numberOfAccount,
                balanceAmount: balanceAmount,
                balanceDebitOrCredit: balanceDebitOrCredit
            )
            htmlString.append(rowString)
            
            totalDebitAmount += dataBaseAdjustingEntries[i].debit_amount
            totalCreditAmount += dataBaseAdjustingEntries[i].credit_amount
            
            if counter >= 29 {
                let tableFooter = hTMLhelper.footerstring(debitAmount: totalDebitAmount, creditAmount: totalCreditAmount)
                htmlString.append(tableFooter)
            }
            counter += 1
            if counter >= 30 {
                counter = 0
                pageNumber += 1
            }
        }
        
        // 資本振替仕訳
        if let dataBaseCapitalTransferJournalEntry = dataBaseCapitalTransferJournalEntry {
            
            let fiscalYear = dataBaseCapitalTransferJournalEntry.fiscalYear
            if counter == 0 {
                let tableHeader = hTMLhelper.headerstring(title: account, fiscalYear: fiscalYear, pageNumber: pageNumber)
                htmlString.append(tableHeader)
            }
            // 日付
            guard let date = DateManager.shared.dateFormatter.date(from: dataBaseCapitalTransferJournalEntry.date) else {
                return nil
            }

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
            
            let debitAmount = dataBaseCapitalTransferJournalEntry.debit_amount
            let creditAmount = dataBaseCapitalTransferJournalEntry.credit_amount
            _ = dataBaseCapitalTransferJournalEntry.smallWritting
            var correspondingAccounts: String = "" // 当勘定の相手勘定
            if debitCategory == account {
                correspondingAccounts = creditCategory
            } else if creditCategory == account {
                correspondingAccounts = debitCategory
            }
            let numberOfAccount: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(correspondingAccounts)")
            _ = dataBaseCapitalTransferJournalEntry.balance_left
            _ = dataBaseCapitalTransferJournalEntry.balance_right
            
            let balanceAmount = generalLedgerAccountModel.getBalanceAmountCapitalTransferJournalEntry()
            let balanceDebitOrCredit = generalLedgerAccountModel.getBalanceDebitOrCreditCapitalTransferJournalEntry()
            
            let rowString = hTMLhelper.getSingleRow(
                month: String(date.month),
                day: String(date.day),
                debitCategory: debitCategory,
                debitAmount: debitAmount,
                creditCategory: creditCategory,
                creditAmount: creditAmount,
                correspondingAccounts: correspondingAccounts,
                numberOfAccount: numberOfAccount,
                balanceAmount: balanceAmount,
                balanceDebitOrCredit: balanceDebitOrCredit
            )
            htmlString.append(rowString)
            
            totalDebitAmount += dataBaseCapitalTransferJournalEntry.debit_amount
            totalCreditAmount += dataBaseCapitalTransferJournalEntry.credit_amount
            
            if counter >= 29 {
                let tableFooter = hTMLhelper.footerstring(debitAmount: totalDebitAmount, creditAmount: totalCreditAmount)
                htmlString.append(tableFooter)
            }
            counter += 1
            if counter >= 30 {
                counter = 0
                pageNumber += 1
            }
        }
        // 損益振替仕訳
        if let dataBaseTransferEntry = generalLedgerAccountModel.getTransferEntryInAccount(account: account) {
            
            let fiscalYear = dataBaseTransferEntry.fiscalYear
            if counter == 0 {
                let tableHeader = hTMLhelper.headerstring(title: account, fiscalYear: fiscalYear, pageNumber: pageNumber)
                htmlString.append(tableHeader)
            }
            // 日付
            guard let date = DateManager.shared.dateFormatter.date(from: dataBaseTransferEntry.date) else {
                return nil
            }

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
            
            let debitAmount = dataBaseTransferEntry.debit_amount
            let creditAmount = dataBaseTransferEntry.credit_amount
            _ = dataBaseTransferEntry.smallWritting
            var correspondingAccounts: String = "" // 当勘定の相手勘定
            if debitCategory == account {
                correspondingAccounts = creditCategory
            } else if creditCategory == account {
                correspondingAccounts = debitCategory
            }
            let numberOfAccount: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(correspondingAccounts)")
            _ = dataBaseTransferEntry.balance_left
            _ = dataBaseTransferEntry.balance_right
            
            let balanceAmount = Int64(0)
            let balanceDebitOrCredit = "-"
            
            let rowString = hTMLhelper.getSingleRow(
                month: String(date.month),
                day: String(date.day),
                debitCategory: debitCategory,
                debitAmount: debitAmount,
                creditCategory: creditCategory,
                creditAmount: creditAmount,
                correspondingAccounts: correspondingAccounts,
                numberOfAccount: numberOfAccount,
                balanceAmount: balanceAmount,
                balanceDebitOrCredit: balanceDebitOrCredit
            )
            htmlString.append(rowString)
            
            totalDebitAmount += dataBaseTransferEntry.debit_amount
            totalCreditAmount += dataBaseTransferEntry.credit_amount
            
            if counter >= 29 {
                let tableFooter = hTMLhelper.footerstring(debitAmount: totalDebitAmount, creditAmount: totalCreditAmount)
                htmlString.append(tableFooter)
            }
            counter += 1
            if counter >= 30 {
                counter = 0
                pageNumber += 1
            }
        }
        
        if counter > 0 && counter <= 30 {
            for _ in counter ..< 30 {
                let rowString = hTMLhelper.getSingleRowEmpty()
                htmlString.append(rowString)
                
                if counter >= 29 {
                    let tableFooter = hTMLhelper.footerstring(debitAmount: totalDebitAmount, creditAmount: totalCreditAmount)
                    htmlString.append(tableFooter)
                }
                counter += 1
                pageNumber += 1
            }
        }
        // フッターを取得する
        let footerString = hTMLhelper.footerHTMLstring()
        htmlString.append(footerString)
        print(htmlString)
        // HTML -> PDF
        let pdfData = getPDF(fromHTML: htmlString)        
        // PDFデータを一時ディレクトリに保存する
        if let fileName = saveToTempDirectory(data: pdfData) {
            // PDFファイルを表示する
            PDFpath = fileName
            
            return PDFpath
        } else {
            return nil
        }
    }
    
    /*
     この関数はHTML文字列を受け取り、PDFファイルを表す `NSData` オブジェクトを返します。
     */
    func getPDF(fromHTML: String) -> NSData {
        let renderer = UIPrintPageRenderer()
        let paperFrame = CGRect(origin: .zero, size: paperSize)
        
        renderer.setValue(paperFrame, forKey: "paperRect")
        renderer.setValue(paperFrame, forKey: "printableRect")
        
        let formatter = UIMarkupTextPrintFormatter(markupText: fromHTML)
        formatter.perPageContentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, paperFrame, [:])
        for pageI in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            print(UIGraphicsGetPDFContextBounds())
            renderer.drawPage(at: pageI, in: paperFrame)
        }
        UIGraphicsEndPDFContext()
        return pdfData
    }
    
    /*
     この関数は、特定の `data` をアプリの一時ストレージに保存します。さらに、そのファイルが存在する場所のパスを返します。
     */
    func saveToTempDirectory(data: NSData) -> URL? {
        guard let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return nil }
        let pDFsDirectory = documentDirectory.appendingPathComponent("PDFs", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: pDFsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("失敗した")
        }
        
        let filePath = pDFsDirectory.appendingPathComponent("\(fiscalYear)-GeneralLedger-\(account)" + ".pdf")
        do {
            try data.write(to: filePath)
            print(filePath)
            return filePath
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
