//
//  PDFMakerProfitAndLossStatement.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/11.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

class PDFMakerProfitAndLossStatement {
    
    var PDFpath: URL?
    
    let hTMLhelper = HTMLhelperPL()
    let paperSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72) // 調整した　A4 210×297mm 595.2755905512, 841.8897637795
    let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
    
    func initialize(profitAndLossStatementData: ProfitAndLossStatementData, completion: (URL?) -> Void) {
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
        
        let url = createHTML(profitAndLossStatementData: profitAndLossStatementData)
        completion(url)
    }
    
    func createHTML(profitAndLossStatementData: ProfitAndLossStatementData) -> URL? {
        // HTML
        var htmlString = ""
        // ページ数
        var pageNumber = 1
        // 行数　1ページあたり
        var counter = 0
        
        // PDFごとに1回コール
        let headerHTMLstring = hTMLhelper.headerHTMLstring()
        htmlString.append(headerHTMLstring)
        // PDFページ　トップ
        incrementPage()
        // PDFページ　トップ
        func incrementPage() {
            // ページごとに1回コール
            let headerstring = hTMLhelper.headerstring(
                company: profitAndLossStatementData.company,
                fiscalYear: profitAndLossStatementData.fiscalYear,
                theDayOfReckoning: profitAndLossStatementData.theDayOfReckoning,
                pageNumber: pageNumber
            )
            htmlString.append(headerstring)
            
            // テーブル　トップ
            var tableTopString = hTMLhelper.tableTopString()
            htmlString.append(tableTopString)
        }
        
        var tableTopString = ""
        
        // 売上高
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.sales.rawValue)
        htmlString.append(tableTopString)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        // tableMiddle 行数分繰り返す
        for item in profitAndLossStatementData.objects0 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 6,
                    rank1: 0, // 「-」の代用
                    accountNameOfSettingsTaxonomyAccount: item.category, // 勘定科目名
                    lastYear: false
                )
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= 50 {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        // 売上高 合計
        var middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.sales.getTotalAmount(), amount: profitAndLossStatementData.netSales)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 売上原価
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.costOfGoodsSold.rawValue)
        htmlString.append(tableTopString)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        // tableMiddle 行数分繰り返す
        for item in profitAndLossStatementData.objects1 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 7,
                    rank1: 13,
                    accountNameOfSettingsTaxonomyAccount: item.category, // 勘定科目名
                    lastYear: false
                )
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= 50 {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        // tableMiddle 行数分繰り返す
        for item in profitAndLossStatementData.objects2 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 7,
                    rank1: 14,
                    accountNameOfSettingsTaxonomyAccount: item.category, // 勘定科目名
                    lastYear: false
                )
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= 50 {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        // 売上原価 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.costOfGoodsSold.getTotalAmount(), amount: profitAndLossStatementData.costOfGoodsSold)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 売上総利益
        var rowStringForBenefits = hTMLhelper.getSingleRowForBenefits(title: ProfitAndLossStatement.Benefits.grossProfitOrLoss.rawValue, amount: profitAndLossStatementData.grossProfitOrLoss)
        htmlString.append(rowStringForBenefits)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 販売費及び一般管理費
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.sellingGeneralAndAdministrativeExpenses.rawValue)
        htmlString.append(tableTopString)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        // tableMiddle 行数分繰り返す
        for item in profitAndLossStatementData.objects3 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 8,
                    rank1: 0, // 「-」の代用
                    accountNameOfSettingsTaxonomyAccount: item.category, // 勘定科目名
                    lastYear: false
                )
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= 50 {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        // 販売費及び一般管理費 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.sellingGeneralAndAdministrativeExpenses.getTotalAmount(), amount: profitAndLossStatementData.sellingGeneralAndAdministrativeExpenses)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 営業利益
        rowStringForBenefits = hTMLhelper.getSingleRowForBenefits(
            title: ProfitAndLossStatement.Benefits.otherCapitalSurplusesTotal.rawValue,
            amount: profitAndLossStatementData.otherCapitalSurplusesTotal
        )
        htmlString.append(rowStringForBenefits)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 営業外収益
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.nonOperatingIncome.rawValue)
        htmlString.append(tableTopString)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        // tableMiddle 行数分繰り返す
        for item in profitAndLossStatementData.objects4 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 9,
                    rank1: 15,
                    accountNameOfSettingsTaxonomyAccount: item.category, // 勘定科目名
                    lastYear: false
                )
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= 50 {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        // 営業外収益 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.nonOperatingIncome.getTotalAmount(), amount: profitAndLossStatementData.nonOperatingIncome)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 営業外費用
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.nonOperatingExpenses.rawValue)
        htmlString.append(tableTopString)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        // tableMiddle 行数分繰り返す
        for item in profitAndLossStatementData.objects5 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 9,
                    rank1: 16,
                    accountNameOfSettingsTaxonomyAccount: item.category, // 勘定科目名
                    lastYear: false
                )
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= 50 {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        // 営業外費用 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.nonOperatingExpenses.getTotalAmount(), amount: profitAndLossStatementData.nonOperatingExpenses)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 経常利益
        rowStringForBenefits = hTMLhelper.getSingleRowForBenefits(title: ProfitAndLossStatement.Benefits.ordinaryIncomeOrLoss.rawValue, amount: profitAndLossStatementData.ordinaryIncomeOrLoss)
        htmlString.append(rowStringForBenefits)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 特別利益
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.extraordinaryProfits.rawValue)
        htmlString.append(tableTopString)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        // tableMiddle 行数分繰り返す
        for item in profitAndLossStatementData.objects6 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 10,
                    rank1: 17,
                    accountNameOfSettingsTaxonomyAccount: item.category, // 勘定科目名
                    lastYear: false
                )
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= 50 {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        // 特別利益 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.extraordinaryProfits.getTotalAmount(), amount: profitAndLossStatementData.extraordinaryIncome)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 特別損失
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.extraordinaryLoss.rawValue)
        htmlString.append(tableTopString)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        // tableMiddle 行数分繰り返す
        for item in profitAndLossStatementData.objects7 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 10,
                    rank1: 18,
                    accountNameOfSettingsTaxonomyAccount: item.category, // 勘定科目名
                    lastYear: false
                )
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= 50 {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        // 特別損失 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.extraordinaryLoss.getTotalAmount(), amount: profitAndLossStatementData.extraordinaryLosses)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 税引前当期純利益
        rowStringForBenefits = hTMLhelper.getSingleRowForBenefits(title: ProfitAndLossStatement.Benefits.incomeOrLossBeforeIncomeTaxes.rawValue, amount: profitAndLossStatementData.incomeOrLossBeforeIncomeTaxes)
        htmlString.append(rowStringForBenefits)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 法人税等
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.incomeTaxes.rawValue)
        htmlString.append(tableTopString)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        // tableMiddle 行数分繰り返す
        for item in profitAndLossStatementData.objects8 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 11,
                    rank1: 0, // 「-」の代用
                    accountNameOfSettingsTaxonomyAccount: item.category, // 勘定科目名
                    lastYear: false
                )
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= 50 {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        // 法人税等 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.incomeTaxes.getTotalAmount(), amount: profitAndLossStatementData.incomeTaxes)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 当期純利益
        rowStringForBenefits = hTMLhelper.getSingleRowForBenefits(title: ProfitAndLossStatement.Benefits.netIncomeOrLoss.rawValue, amount: profitAndLossStatementData.netIncomeOrLoss)
        htmlString.append(rowStringForBenefits)
        // PDFページ　追加
        counter += 1
        if counter >= 50 {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // PDFページ　ボトム
        func incrementPageBottom() {
            // テーブル　エンド
            let tableEndString = hTMLhelper.tableEndString()
            htmlString.append(tableEndString)
            
            // ページごとに1回コール
            let footerstring = hTMLhelper.footerstring()
            htmlString.append(footerstring)
        }
        // PDFページ　ボトム
        incrementPageBottom()
        // PDFごとに1回コール
        let footerHTMLstring = hTMLhelper.footerHTMLstring()
        htmlString.append(footerHTMLstring)
        
        print(htmlString)
        // HTML -> PDF
        let pdfData = getPDF(fromHTML: htmlString)
        // PDFデータを一時ディレクトリに保存する
        if let fileName = saveToTempDirectory(data: pdfData) {
            // PDFファイルを表示する
            PDFpath = fileName
            
            return self.PDFpath
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
        
        // "receipt-" + UUID().uuidString
        let filePath = pDFsDirectory.appendingPathComponent("\(fiscalYear)-ProfitAndLossStatement" + ".pdf")
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
