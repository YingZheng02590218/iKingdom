//
//  PDFMakerPLAccount.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/06.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

class PDFMakerPLAccount {

    var PDFpath: URL?

    let hTMLhelper = HTMLhelperAccount() // 共通で使用する
    let paperSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72) // 調整した　A4 210×297mm
    // 勘定名
    var account: String = "損益"
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
        // 勘定のデータを取得する
        let generalLedgerAccountModel = GeneralLedgerPLAccountModel()
        // 損益振替仕訳
        let dataBaseTransferEntries = generalLedgerAccountModel.getTransferEntryInAccount()
        // 資本振替仕訳
        let dataBaseCapitalTransferJournalEntry = generalLedgerAccountModel.getCapitalTransferJournalEntryInAccount()
        generalLedgerAccountModel.initialize(
            dataBaseTransferEntries: dataBaseTransferEntries,
            dataBaseCapitalTransferJournalEntry: dataBaseCapitalTransferJournalEntry
        )

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
        
        // 損益振替仕訳
        for i in 0..<dataBaseTransferEntries.count {

            let fiscalYear = dataBaseTransferEntries[i].fiscalYear
            if counter == 0 {
                let tableHeader = hTMLhelper.headerstring(title: account, fiscalYear: fiscalYear, pageNumber: pageNumber)
                htmlString.append(tableHeader)
            }
            // データ
            let month = dataBaseTransferEntries[i].date[
                dataBaseTransferEntries[i].date.index(
                    dataBaseTransferEntries[i].date.startIndex,
                    offsetBy: 5
                )..<dataBaseTransferEntries[i].date.index(
                    dataBaseTransferEntries[i].date.startIndex,
                    offsetBy: 7
                )
            ]
            let date = dataBaseTransferEntries[i].date[
                dataBaseTransferEntries[i].date.index(
                    dataBaseTransferEntries[i].date.startIndex,
                    offsetBy: 8
                )..<dataBaseTransferEntries[i].date.index(
                    dataBaseTransferEntries[i].date.startIndex,
                    offsetBy: 10
                )
            ]
            let debitCategory = dataBaseTransferEntries[i].debit_category
            let debitAmount = dataBaseTransferEntries[i].debit_amount
            let creditCategory = dataBaseTransferEntries[i].credit_category
            let creditAmount = dataBaseTransferEntries[i].credit_amount
            _ = dataBaseTransferEntries[i].smallWritting
            var correspondingAccounts: String = "" // 当勘定の相手勘定
            if debitCategory == account {
                correspondingAccounts = creditCategory
            } else if creditCategory == account {
                correspondingAccounts = debitCategory
            }
            let numberOfAccount: Int = generalLedgerAccountModel.getNumberOfAccount(accountName: "\(correspondingAccounts)")
            _ = dataBaseTransferEntries[i].balance_left
            _ = dataBaseTransferEntries[i].balance_right

            let balanceAmount = generalLedgerAccountModel.getBalanceAmount(indexPath: IndexPath(row: i, section: 0))
            let balanceDebitOrCredit = generalLedgerAccountModel.getBalanceDebitOrCredit(indexPath: IndexPath(row: i, section: 0))

            let rowString = hTMLhelper.getSingleRow(
                month: String(month),
                day: String(date),
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

            totalDebitAmount += dataBaseTransferEntries[i].debit_amount
            totalCreditAmount += dataBaseTransferEntries[i].credit_amount

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
            // データ
            let month = dataBaseCapitalTransferJournalEntry.date[
                dataBaseCapitalTransferJournalEntry.date.index(
                    dataBaseCapitalTransferJournalEntry.date.startIndex,
                    offsetBy: 5
                )..<dataBaseCapitalTransferJournalEntry.date.index(
                    dataBaseCapitalTransferJournalEntry.date.startIndex,
                    offsetBy: 7
                )
            ]
            let date = dataBaseCapitalTransferJournalEntry.date[
                dataBaseCapitalTransferJournalEntry.date.index(
                    dataBaseCapitalTransferJournalEntry.date.startIndex,
                    offsetBy: 8
                )..<dataBaseCapitalTransferJournalEntry.date.index(
                    dataBaseCapitalTransferJournalEntry.date.startIndex,
                    offsetBy: 10
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
                month: String(month),
                day: String(date),
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
