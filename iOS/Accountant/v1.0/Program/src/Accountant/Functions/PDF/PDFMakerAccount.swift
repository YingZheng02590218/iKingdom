//
//  PDFMakerAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/02/15.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit


class PDFMakerAccount {
    
    
    var PDFpath: [URL]?

    let hTMLhelper = HTMLhelperAccount()
    let paperSize = CGSize(width: 170 / 25.4 * 72, height: 257 / 25.4 * 72) // 調整した　A4 210×297mm
    // 勘定名
    var account: String = ""
    var fiscalYear = 0

    func initialize(account: String) {
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        fiscalYear = dataBaseAccountingBooks.fiscalYear
        // 初期化
        self.account = account
        PDFpath = []
        
        guard let tempDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else { return }
        let pDFsDirectory = tempDirectory.appendingPathComponent("PDFs", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: pDFsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            print("失敗した")
        }
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: pDFsDirectory, includingPropertiesForKeys: nil) // ファイル一覧を取得
            // if you want to filter the directory contents you can do like this:
            let pdfFiles = directoryContents.filter{ $0.pathExtension == "pdf" }
            print("pdf urls:",pdfFiles)
            let pdfFileNames = pdfFiles.map{ $0.deletingPathExtension().lastPathComponent }
            print("pdf list:", pdfFileNames)
            // ファイルのデータを取得
            for fileName in pdfFileNames {
                let content = pDFsDirectory.appendingPathComponent(fileName + ".pdf")
                do {
                    try FileManager.default.removeItem(at: content)
                }
                catch let error {
                    print(error)
                }
            }
        }
        catch {
            print(error)
        }
        
        readDB()
    }
    
    func readDB() {
        // 勘定のデータを取得する
        let genearlLedgerAccountModel = GenearlLedgerAccountModel()
        // 通常仕訳　勘定別
        let dataBaseJournalEntries = genearlLedgerAccountModel.getJournalEntryInAccount(account: account)
        // 決算整理仕訳　勘定別　損益勘定を含む　繰越利益を含む
        let dataBaseAdjustingEntries = genearlLedgerAccountModel.getAdjustingJournalEntryInAccount(account: account)
        genearlLedgerAccountModel.initialize(account: account, databaseJournalEntries: dataBaseJournalEntries, dataBaseAdjustingEntries: dataBaseAdjustingEntries)
        
        var htmlString = ""
        
        // ページ数
        var pageNumber = 1

        // 行を取得する
        var totalDebit_amount:Int64 = 0
        var totalCredit_amount:Int64 = 0
        var counter = 0

        // HTMLのヘッダーを取得する
        let htmlHeader = hTMLhelper.headerHTMLstring()
        htmlString.append(htmlHeader)
        // 行数分繰り返す 仕訳
        for i in 0..<dataBaseJournalEntries.count {

            let fiscalYear = dataBaseJournalEntries[i].fiscalYear
            if counter == 0 {
                let tableHeader = hTMLhelper.headerstring(title: account, fiscalYear: fiscalYear, pageNumber: pageNumber)
                htmlString.append(tableHeader)
            }
            // データ
            let month = dataBaseJournalEntries[i].date[dataBaseJournalEntries[i].date.index(dataBaseJournalEntries[i].date.startIndex, offsetBy: 5)..<dataBaseJournalEntries[i].date.index(dataBaseJournalEntries[i].date.startIndex, offsetBy: 7)]
            let date = dataBaseJournalEntries[i].date[dataBaseJournalEntries[i].date.index(dataBaseJournalEntries[i].date.startIndex, offsetBy: 8)..<dataBaseJournalEntries[i].date.index(dataBaseJournalEntries[i].date.startIndex, offsetBy: 10)]
            let debit_category = dataBaseJournalEntries[i].debit_category
            let debit_amount = dataBaseJournalEntries[i].debit_amount
            let credit_category = dataBaseJournalEntries[i].credit_category
            let credit_amount = dataBaseJournalEntries[i].credit_amount
            let smallWritting = dataBaseJournalEntries[i].smallWritting
            var correspondingAccounts: String = "" // 当勘定の相手勘定
            if debit_category == account {
                correspondingAccounts = credit_category
            }
            else if credit_category == account {
                correspondingAccounts = debit_category
            }
            let numberOfAccount: Int = genearlLedgerAccountModel.getNumberOfAccount(accountName: "\(correspondingAccounts)")
            let balance_left = dataBaseJournalEntries[i].balance_left
            let balance_right = dataBaseJournalEntries[i].balance_right

            let balanceAmount = genearlLedgerAccountModel.getBalanceAmount(indexPath: IndexPath(row: i, section: 0))
            let balanceDebitOrCredit = genearlLedgerAccountModel.getBalanceDebitOrCredit(indexPath: IndexPath(row: i, section: 0))

            let rowString = hTMLhelper.getSingleRow(month: String(month), day: String(date), debit_category: debit_category, debit_amount: debit_amount, credit_category: credit_category, credit_amount: credit_amount, correspondingAccounts: correspondingAccounts, numberOfAccount: numberOfAccount, balanceAmount: balanceAmount, balanceDebitOrCredit: balanceDebitOrCredit)
            htmlString.append(rowString)
            
            totalDebit_amount += dataBaseJournalEntries[i].debit_amount
            totalCredit_amount += dataBaseJournalEntries[i].credit_amount
            
            if counter >= 29 {
                let tableFooter = hTMLhelper.footerstring(debit_amount: totalDebit_amount, credit_amount: totalCredit_amount)
                htmlString.append(tableFooter)
            }
            counter += 1
            if counter >= 30 {
                counter = 0
                pageNumber += 1
            }
        }
        // 行数分繰り返す 決算整理仕訳
        for i in 0..<dataBaseAdjustingEntries.count {

            let fiscalYear = dataBaseAdjustingEntries[i].fiscalYear
            if counter == 0 {
                let tableHeader = hTMLhelper.headerstring(title: account, fiscalYear: fiscalYear, pageNumber: pageNumber)
                htmlString.append(tableHeader)
            }
            // データ
            let month = dataBaseAdjustingEntries[i].date[dataBaseAdjustingEntries[i].date.index(dataBaseAdjustingEntries[i].date.startIndex, offsetBy: 5)..<dataBaseAdjustingEntries[i].date.index(dataBaseAdjustingEntries[i].date.startIndex, offsetBy: 7)]
            let date = dataBaseAdjustingEntries[i].date[dataBaseAdjustingEntries[i].date.index(dataBaseAdjustingEntries[i].date.startIndex, offsetBy: 8)..<dataBaseAdjustingEntries[i].date.index(dataBaseAdjustingEntries[i].date.startIndex, offsetBy: 10)]
            let debit_category = dataBaseAdjustingEntries[i].debit_category
            let debit_amount = dataBaseAdjustingEntries[i].debit_amount
            let credit_category = dataBaseAdjustingEntries[i].credit_category
            let credit_amount = dataBaseAdjustingEntries[i].credit_amount
            let smallWritting = dataBaseAdjustingEntries[i].smallWritting
            var correspondingAccounts: String = "" // 当勘定の相手勘定
            if debit_category == account {
                correspondingAccounts = credit_category
            }
            else if credit_category == account {
                correspondingAccounts = debit_category
            }
            let numberOfAccount: Int = genearlLedgerAccountModel.getNumberOfAccount(accountName: "\(correspondingAccounts)")
            let balance_left = dataBaseAdjustingEntries[i].balance_left
            let balance_right = dataBaseAdjustingEntries[i].balance_right

            let balanceAmount = genearlLedgerAccountModel.getBalanceAmountAdjusting(indexPath: IndexPath(row: i, section: 0))
            let balanceDebitOrCredit = genearlLedgerAccountModel.getBalanceDebitOrCreditAdjusting(indexPath: IndexPath(row: i, section: 0))

            let rowString = hTMLhelper.getSingleRow(month: String(month), day: String(date), debit_category: debit_category, debit_amount: debit_amount, credit_category: credit_category, credit_amount: credit_amount, correspondingAccounts: correspondingAccounts, numberOfAccount: numberOfAccount, balanceAmount: balanceAmount, balanceDebitOrCredit: balanceDebitOrCredit)
            htmlString.append(rowString)
            
            totalDebit_amount += dataBaseAdjustingEntries[i].debit_amount
            totalCredit_amount += dataBaseAdjustingEntries[i].credit_amount
            
            if counter >= 29 {
                let tableFooter = hTMLhelper.footerstring(debit_amount: totalDebit_amount, credit_amount: totalCredit_amount)
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
                    let tableFooter = hTMLhelper.footerstring(debit_amount: totalDebit_amount, credit_amount: totalCredit_amount)
                    htmlString.append(tableFooter)
                }
                counter += 1
                pageNumber += 1
            }
        }
        // フッターを取得する
        let footerString = hTMLhelper.footerHTMLstring()
        htmlString.append(footerString)
        //HTML -> PDF
        let pdfData = getPDF(fromHTML: htmlString)

        print(htmlString)
        //PDFデータを一時ディレクトリに保存する
        if let fileName = saveToTempDirectory(data: pdfData) {
            //PDFファイルを表示する
            self.PDFpath?.append(fileName)
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
            renderer.drawPage(at: pageI, in:paperFrame)
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
        }
        catch {
            print("失敗した")
        }
        
        // "receipt-" + UUID().uuidString
       // "\(fiscalYear)-Account-\(account)"

        let filePath = pDFsDirectory.appendingPathComponent("\(fiscalYear)-GenearlLedger-\(account)" + ".pdf")
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
