//
//  PDFMaker.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/06/05.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

class PDFMaker {

    var PDFpath: URL?
    
    let hTMLhelper = HTMLhelper()
    let paperSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72) // 調整した　A4 210×297mm
    var fiscalYear = 0

    func initialize(completion: (URL?) -> Void) {
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        fiscalYear = dataBaseAccountingBooks.fiscalYear
        // 初期化
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
        
        let dataBaseManager = JournalsModel()
        let dataBaseJournalEntries = dataBaseManager.getJournalEntriesInJournals()
        let dataBaseAdjustingEntries = dataBaseManager.getJournalAdjustingEntry()
        // 損益振替仕訳
        let dataBaseTransferEntries = dataBaseManager.getTransferEntryInAccount()

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
        // 行数分繰り返す 仕訳
        for item in dataBaseJournalEntries {
            
            let fiscalYear = item.fiscalYear
            if counter == 0 {
                let tableHeader = hTMLhelper.headerstring(title: "仕訳帳", fiscalYear: fiscalYear, pageNumber: pageNumber)
                htmlString.append(tableHeader)
            }
            // 仕訳クラス                // モデル定義
            ////    @objc dynamic var number: Int = 0                 //仕訳番号
            //    @objc dynamic var fiscalYear: Int = 0               //年度
            //    @objc dynamic var date: String = ""                 //日付
            //    @objc dynamic var debit_category: String = ""       //借方勘定
            //    @objc dynamic var debit_amount: Int64 = 0           //借方金額
            //    @objc dynamic var credit_category: String = ""      //貸方勘定
            //    @objc dynamic var credit_amount: Int64 = 0          //貸方金額
            //    @objc dynamic var smallWritting: String = ""        //小書き
            //    @objc dynamic var balance_left: Int64 = 0           //差引残高
            //    @objc dynamic var balance_right: Int64 = 0          //差引残高
            let month = item.date[item.date.index(item.date.startIndex, offsetBy: 5)..<item.date.index(item.date.startIndex, offsetBy: 7)]
            let date = item.date[item.date.index(item.date.startIndex, offsetBy: 8)..<item.date.index(item.date.startIndex, offsetBy: 10)]
            let debitCategory = item.debit_category
            let debitAmount = item.debit_amount
            let creditCategory = item.credit_category
            let creditAmount = item.credit_amount
            let smallWritting = item.smallWritting
            _ = item.balance_left
            _ = item.balance_right
            let generalLedgerAccountModel = GeneralLedgerAccountModel()
            let numberOfAccountCredit: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(creditCategory)") // 損益勘定の場合はエラーになる
            let numberOfAccountDebit: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(debitCategory)") // 損益勘定の場合はエラーになる

            let rowString = hTMLhelper.getSingleRow(
                month: String(month),
                day: String(date),
                debitCategory: debitCategory,
                debitAmount: debitAmount,
                creditCategory: creditCategory,
                creditAmount: creditAmount,
                smallWritting: smallWritting,
                numberOfAccountCredit: numberOfAccountCredit,
                numberOfAccountDebit: numberOfAccountDebit
            )
            htmlString.append(rowString)
            
            totalDebitAmount += item.debit_amount
            totalCreditAmount += item.credit_amount
            
            if counter >= 9 {
                let tableFooter = hTMLhelper.footerstring(debitAmount: totalDebitAmount, creditAmount: totalCreditAmount)
                htmlString.append(tableFooter)
            }
            counter += 1
            if counter >= 10 {
                counter = 0
                pageNumber += 1
            }
        }
        // 行数分繰り返す 決算整理仕訳
        for item in dataBaseAdjustingEntries {
            
            let fiscalYear = item.fiscalYear
            if counter == 0 {
                let tableHeader = hTMLhelper.headerstring(title: "仕訳帳", fiscalYear: fiscalYear, pageNumber: pageNumber)
                htmlString.append(tableHeader)
            }
            let month = item.date[item.date.index(item.date.startIndex, offsetBy: 5)..<item.date.index(item.date.startIndex, offsetBy: 7)]
            let date = item.date[item.date.index(item.date.startIndex, offsetBy: 8)..<item.date.index(item.date.startIndex, offsetBy: 10)]
            let debitCategory = item.debit_category
            let debitAmount = item.debit_amount
            let creditCategory = item.credit_category
            let creditAmount = item.credit_amount
            let smallWritting = item.smallWritting
            _ = item.balance_left
            _ = item.balance_right
            let generalLedgerAccountModel = GeneralLedgerAccountModel()
            let numberOfAccountCredit: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(creditCategory)")// 損益勘定の場合はエラーになる
            let numberOfAccountDebit: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(debitCategory)")// 損益勘定の場合はエラーになる
            
            let rowString = hTMLhelper.getSingleRow(
                month: String(month),
                day: String(date),
                debitCategory: debitCategory,
                debitAmount: debitAmount,
                creditCategory: creditCategory,
                creditAmount: creditAmount,
                smallWritting: smallWritting,
                numberOfAccountCredit: numberOfAccountCredit,
                numberOfAccountDebit: numberOfAccountDebit
            )
            htmlString.append(rowString)
            
            totalDebitAmount += item.debit_amount
            totalCreditAmount += item.credit_amount
            
            if counter >= 9 {
                let tableFooter = hTMLhelper.footerstring(debitAmount: totalDebitAmount, creditAmount: totalCreditAmount)
                htmlString.append(tableFooter)
            }
            counter += 1
            if counter >= 10 {
                counter = 0
                pageNumber += 1
            }
        }
        // 損益振替仕訳
        for item in dataBaseTransferEntries {

            let fiscalYear = item.fiscalYear
            if counter == 0 {
                let tableHeader = hTMLhelper.headerstring(title: "仕訳帳", fiscalYear: fiscalYear, pageNumber: pageNumber)
                htmlString.append(tableHeader)
            }
            let month = item.date[item.date.index(item.date.startIndex, offsetBy: 5)..<item.date.index(item.date.startIndex, offsetBy: 7)]
            let date = item.date[item.date.index(item.date.startIndex, offsetBy: 8)..<item.date.index(item.date.startIndex, offsetBy: 10)]
            let debitCategory = item.debit_category
            let debitAmount = item.debit_amount
            let creditCategory = item.credit_category
            let creditAmount = item.credit_amount
            let smallWritting = item.smallWritting
            _ = item.balance_left
            _ = item.balance_right
            let generalLedgerAccountModel = GeneralLedgerAccountModel()
            let numberOfAccountCredit: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(creditCategory)")// 損益勘定の場合はエラーになる
            let numberOfAccountDebit: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(debitCategory)")// 損益勘定の場合はエラーになる

            let rowString = hTMLhelper.getSingleRow(
                month: String(month),
                day: String(date),
                debitCategory: debitCategory,
                debitAmount: debitAmount,
                creditCategory: creditCategory,
                creditAmount: creditAmount,
                smallWritting: smallWritting,
                numberOfAccountCredit: numberOfAccountCredit,
                numberOfAccountDebit: numberOfAccountDebit
            )
            htmlString.append(rowString)

            totalDebitAmount += item.debit_amount
            totalCreditAmount += item.credit_amount

            if counter >= 9 {
                let tableFooter = hTMLhelper.footerstring(debitAmount: totalDebitAmount, creditAmount: totalCreditAmount)
                htmlString.append(tableFooter)
            }
            counter += 1
            if counter >= 10 {
                counter = 0
                pageNumber += 1
            }
        }
        // 資本振替仕訳
        if let dataBaseCapitalTransferJournalEntry = dataBaseManager.getCapitalTransferJournalEntryInAccount() {
            let fiscalYear = dataBaseCapitalTransferJournalEntry.fiscalYear
            if counter == 0 {
                let tableHeader = hTMLhelper.headerstring(title: "仕訳帳", fiscalYear: fiscalYear, pageNumber: pageNumber)
                htmlString.append(tableHeader)
            }
            let month = dataBaseCapitalTransferJournalEntry.date[
                dataBaseCapitalTransferJournalEntry.date.index(
                    dataBaseCapitalTransferJournalEntry.date.startIndex, offsetBy: 5
                )..<dataBaseCapitalTransferJournalEntry.date.index(
                    dataBaseCapitalTransferJournalEntry.date.startIndex, offsetBy: 7
                )
            ]
            let date = dataBaseCapitalTransferJournalEntry.date[
                dataBaseCapitalTransferJournalEntry.date.index(
                    dataBaseCapitalTransferJournalEntry.date.startIndex, offsetBy: 8
                )..<dataBaseCapitalTransferJournalEntry.date.index(
                    dataBaseCapitalTransferJournalEntry.date.startIndex, offsetBy: 10
                )
            ]
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
            let smallWritting = dataBaseCapitalTransferJournalEntry.smallWritting
            _ = dataBaseCapitalTransferJournalEntry.balance_left
            _ = dataBaseCapitalTransferJournalEntry.balance_right
            let generalLedgerAccountModel = GeneralLedgerAccountModel()
            let numberOfAccountCredit: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(creditCategory)")
            let numberOfAccountDebit: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(debitCategory)")

            let rowString = hTMLhelper.getSingleRow(
                month: String(month),
                day: String(date),
                debitCategory: debitCategory,
                debitAmount: debitAmount,
                creditCategory: creditCategory,
                creditAmount: creditAmount,
                smallWritting: smallWritting,
                numberOfAccountCredit: numberOfAccountCredit,
                numberOfAccountDebit: numberOfAccountDebit
            )
            htmlString.append(rowString)

            totalDebitAmount += dataBaseCapitalTransferJournalEntry.debit_amount
            totalCreditAmount += dataBaseCapitalTransferJournalEntry.credit_amount

            if counter >= 9 {
                let tableFooter = hTMLhelper.footerstring(debitAmount: totalDebitAmount, creditAmount: totalCreditAmount)
                htmlString.append(tableFooter)
            }
            counter += 1
            if counter >= 10 {
                counter = 0
                pageNumber += 1
            }
        }
        if counter > 0 && counter <= 10 {
            for _ in counter ..< 10 {
                let rowString = hTMLhelper.getSingleRowEmpty()
                htmlString.append(rowString)
                
                if counter >= 9 {
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
        
        let filePath = pDFsDirectory.appendingPathComponent("\(fiscalYear)-Journals" + ".pdf")
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
