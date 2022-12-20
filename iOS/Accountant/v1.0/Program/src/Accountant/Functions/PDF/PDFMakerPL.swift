//
//  PDFMakerPL.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/11/22.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

class PDFMakerPL {


    var PDFpath: [URL]?

    let hTMLhelper = HTMLhelperPL()
    let paperSize = CGSize(width: 170 / 25.4 * 72, height: 257 / 25.4 * 72) // 調整した　A4 210×297mm 595.2755905512, 841.8897637795
    var fiscalYear = 0

    func initialize(pLData: PLData, completion: ([URL]?) -> Void) {

        fiscalYear = pLData.fiscalYear
        // 初期化
        PDFpath = []
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

        let url = createHTML(pLData: pLData)
        completion(url)
    }

    func createHTML(pLData: PLData) -> [URL]? {
        // HTML
        var htmlString = ""

        // PDFごとに1回コール
        let headerHTMLstring = hTMLhelper.headerHTMLstring()
        htmlString.append(headerHTMLstring)
        // ページごとに1回コール
        let headerstring = hTMLhelper.headerstring(company: pLData.company, fiscalYear: pLData.fiscalYear, theDayOfReckoning: pLData.theDayOfReckoning)
        htmlString.append(headerstring)

        // テーブル　トップ
        var tableTopString = hTMLhelper.tableTopString()
        htmlString.append(tableTopString)
        // 売上高
        var rowString = hTMLhelper.middleRowEndIndent0space(title: ProfitAndLossStatement.Block.sales.rawValue, amount: pLData.netSales)
        htmlString.append(rowString)
        // 売上原価
        rowString = hTMLhelper.middleRowEndIndent0space(title: ProfitAndLossStatement.Block.costOfGoodsSold.rawValue, amount: pLData.costOfGoodsSold)
        htmlString.append(rowString)
        // 売上総利益
        var rowStringForBenefits = hTMLhelper.getSingleRowForBenefits(title: ProfitAndLossStatement.Benefits.grossProfitOrLoss.rawValue, amount: pLData.grossProfitOrLoss)
        htmlString.append(rowStringForBenefits)


        // 販売費及び一般管理費
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.sellingGeneralAndAdministrativeExpenses.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in pLData.objects9 {
            let rowString = hTMLhelper.getSingleRow(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        // 販売費及び一般管理費
        var middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.sellingGeneralAndAdministrativeExpenses.getTotalAmount(), amount: pLData.sellingGeneralAndAdministrativeExpenses)
        htmlString.append(middleRowEnd)

        // 営業利益
        rowStringForBenefits = hTMLhelper.getSingleRowForBenefits(title: ProfitAndLossStatement.Benefits.otherCapitalSurplusesTotal.rawValue, amount: pLData.otherCapitalSurplusesTotal)
        htmlString.append(rowStringForBenefits)


        // 営業外収益
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.nonOperatingIncome.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in pLData.midCategory10 {
            let rowString = hTMLhelper.getSingleRow(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        // 営業外収益
        middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.nonOperatingIncome.getTotalAmount(), amount: pLData.nonOperatingIncome)
        htmlString.append(middleRowEnd)

        // 営業外費用
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.nonOperatingExpenses.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in pLData.midCategory6 {
            let rowString = hTMLhelper.getSingleRow(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        // 営業外費用
        middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.nonOperatingExpenses.getTotalAmount(), amount: pLData.nonOperatingExpenses)
        htmlString.append(middleRowEnd)

        // 経常利益
        rowStringForBenefits = hTMLhelper.getSingleRowForBenefits(title: ProfitAndLossStatement.Benefits.ordinaryIncomeOrLoss.rawValue, amount: pLData.ordinaryIncomeOrLoss)
        htmlString.append(rowStringForBenefits)


        // 特別利益
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.extraordinaryProfits.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in pLData.midCategory11 {
            let rowString = hTMLhelper.getSingleRow(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        // 特別利益
        middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.extraordinaryProfits.getTotalAmount(), amount: pLData.extraordinaryIncome)
        htmlString.append(middleRowEnd)

        // 特別損失
        tableTopString = hTMLhelper.middleRowTop(title: ProfitAndLossStatement.Block.extraordinaryLoss.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in pLData.midCategory7 {
            let rowString = hTMLhelper.getSingleRow(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        // 特別損失
        middleRowEnd = hTMLhelper.middleRowEnd(title: ProfitAndLossStatement.Block.extraordinaryLoss.getTotalAmount(), amount: pLData.extraordinaryLosses)
        htmlString.append(middleRowEnd)

        // 税引前当期純利益
        rowStringForBenefits = hTMLhelper.getSingleRowForBenefits(title: ProfitAndLossStatement.Benefits.incomeOrLossBeforeIncomeTaxes.rawValue, amount: pLData.incomeOrLossBeforeIncomeTaxes)
        htmlString.append(rowStringForBenefits)

        // 法人税等
        rowString = hTMLhelper.middleRowEndIndent0space(title: ProfitAndLossStatement.Block.incomeTaxes.rawValue, amount: pLData.incomeTaxes)
        htmlString.append(rowString)

        // 当期純利益
        rowStringForBenefits = hTMLhelper.getSingleRowForBenefits(title: ProfitAndLossStatement.Benefits.netIncomeOrLoss.rawValue, amount: pLData.netIncomeOrLoss)
        htmlString.append(rowStringForBenefits)

        // テーブル　エンド
        let tableEndString = hTMLhelper.tableEndString()
        htmlString.append(tableEndString)


        // ページごとに1回コール
        let footerstring = hTMLhelper.footerstring()
        htmlString.append(footerstring)
        // PDFごとに1回コール
        let footerHTMLstring = hTMLhelper.footerHTMLstring()
        htmlString.append(footerHTMLstring)

        print(htmlString)
        // HTML -> PDF
        let pdfData = getPDF(fromHTML: htmlString)
        // PDFデータを一時ディレクトリに保存する
        if let fileName = saveToTempDirectory(data: pdfData) {
            // PDFファイルを表示する
            self.PDFpath?.append(fileName)

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
