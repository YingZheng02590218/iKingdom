//
//  PDFMakerBalanceSheet.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/02.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

class PDFMakerBalanceSheet {

    var PDFpath: URL?

    let hTMLhelper = HTMLhelperBS()
    let paperSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72) // 調整した　A4 210×297mm
    let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()

    func initialize(balanceSheetData: BalanceSheetData, completion: (URL?) -> Void) {
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

        let url = createHTML(balanceSheetData: balanceSheetData)
        completion(url)
    }

    func createHTML(balanceSheetData: BalanceSheetData) -> URL? {
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
                company: balanceSheetData.company,
                fiscalYear: balanceSheetData.fiscalYear,
                theDayOfReckoning: balanceSheetData.theDayOfReckoning,
                pageNumber: pageNumber
            )
            htmlString.append(headerstring)
            
            // テーブル　トップ
            var tableTopString = hTMLhelper.tableTopString()
            htmlString.append(tableTopString)
        }
        
        // テーブル　トップ 資産の部
        var tableTopString = hTMLhelper.tableTopTitleString()
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
        // 流動資産
        tableTopString = hTMLhelper.middleRowTop(title: BalanceSheet.Assets.currentAssets.rawValue)
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
        for item in balanceSheetData.objects0 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 0,
                    rank1: 0,
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
        for item in balanceSheetData.objects1 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 0,
                    rank1: 1,
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
        for item in balanceSheetData.objects2 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 0,
                    rank1: 2,
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
        // 流動資産 合計
        var middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Assets.currentAssets.getTotalAmount(), amount: balanceSheetData.currentAssetsTotal)
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
        // 固定資産
        tableTopString = hTMLhelper.middleRowTop(title: BalanceSheet.Assets.nonCurrentAssets.rawValue)
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
        // 有形固定資産
        tableTopString = hTMLhelper.smallRowTop(title: BalanceSheet.NonCurrentAssets.tangibleFixedAssets.rawValue)
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
        for item in balanceSheetData.objects3 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 1,
                    rank1: 3,
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
        // 無形固定資産
        tableTopString = hTMLhelper.smallRowTop(title: BalanceSheet.NonCurrentAssets.intangibleAssets.rawValue)
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
        for item in balanceSheetData.objects4 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 1,
                    rank1: 4,
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
        // 投資その他の資産
        tableTopString = hTMLhelper.smallRowTop(title: BalanceSheet.NonCurrentAssets.investments.rawValue)
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
        for item in balanceSheetData.objects5 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 1,
                    rank1: 5,
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
        // 固定資産 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Assets.nonCurrentAssets.getTotalAmount(), amount: balanceSheetData.fixedAssetsTotal)
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

        // 繰延資産
        tableTopString = hTMLhelper.middleRowTop(title: BalanceSheet.Assets.deferredAssets.rawValue)
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
        for item in balanceSheetData.objects6 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 2,
                    rank1: 6,
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
        // 繰延資産 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Assets.deferredAssets.getTotalAmount(), amount: balanceSheetData.deferredAssetsTotal)
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

        // テーブル　エンド 資産の部 合計
        var tableEndString = hTMLhelper.tableEndTitleString(title: BalanceSheet.Block.assets.getTotalAmount(), amount: balanceSheetData.assetTotal)
        htmlString.append(tableEndString)
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


        // テーブル　トップ 負債の部
        tableTopString = hTMLhelper.tableTopTitleString(block: BalanceSheet.Block.liabilities.rawValue)
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

        // 流動負債
        tableTopString = hTMLhelper.middleRowTop(title: BalanceSheet.Liabilities.currentLiabilities.rawValue)
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
        for item in balanceSheetData.objects7 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 3,
                    rank1: 7,
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
        for item in balanceSheetData.objects8 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 3,
                    rank1: 8,
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
        // 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Liabilities.currentLiabilities.getTotalAmount(), amount: balanceSheetData.currentLiabilitiesTotal)
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

        // 固定負債
        tableTopString = hTMLhelper.middleRowTop(title: BalanceSheet.Liabilities.fixedLiabilities.rawValue)
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
        for item in balanceSheetData.objects9 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 4,
                    rank1: 9,
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
        // 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Liabilities.fixedLiabilities.getTotalAmount(), amount: balanceSheetData.fixedLiabilitiesTotal)
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
        // テーブル　エンド 負債の部 合計
        tableEndString = hTMLhelper.tableEndTitleString(amount: balanceSheetData.liabilityTotal)
        htmlString.append(tableEndString)
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


        // テーブル　トップ 資本の部
        tableTopString = hTMLhelper.tableTopTitleString(block: BalanceSheet.Block.netAssets.rawValue)
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
        for item in balanceSheetData.objects10 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 5,
                    rank1: 10,
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
        for item in balanceSheetData.objects11 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 5,
                    rank1: 11,
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
        for item in balanceSheetData.objects12 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 5,
                    rank1: 12,
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
        for item in balanceSheetData.objects13 {
            let rowString = hTMLhelper.getSingleRow(
                title: item.category,
                amount: DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: 5,
                    rank1: 19,
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
        // テーブル　エンド 負債・資本の部 合計
        tableEndString = hTMLhelper.tableEndTitleString(capitalAmount: balanceSheetData.equityTotal, amount: balanceSheetData.liabilityAndEquityTotal)
        htmlString.append(tableEndString)
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
        let filePath = pDFsDirectory.appendingPathComponent("\(fiscalYear)-BalanceSheet" + ".pdf")
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
