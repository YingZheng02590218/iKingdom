//
//  PDFMakerBS.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/11/02.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit


class PDFMakerBS {
    
    
    var PDFpath: [URL]?
    
    let hTMLhelper = HTMLhelperBS()
    let paperSize = CGSize(width: 170 / 25.4 * 72, height: 257 / 25.4 * 72) // 調整した　A4 210×297mm
    var fiscalYear = 0
    
    func initialize(bSData: BSData, completion: ([URL]?) -> Void) {
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        fiscalYear = dataBaseAccountingBooks.fiscalYear
        // 初期化
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
        
        let url = createHTML(bSData: bSData)
        completion(url)
    }
    
    func createHTML(bSData: BSData) -> [URL]? {
        // HTML
        var htmlString = ""
        
        // PDFごとに1回コール
        let headerHTMLstring = hTMLhelper.headerHTMLstring()
        htmlString.append(headerHTMLstring)
        // ページごとに1回コール
        let headerstring = hTMLhelper.headerstring(company: bSData.company, fiscalYear: bSData.fiscalYear, theDayOfReckoning: bSData.theDayOfReckoning)
        htmlString.append(headerstring)
        
        // テーブル　トップ 資産の部
        var tableTopString = hTMLhelper.tableTopString()
        htmlString.append(tableTopString)
        // 流動資産
        tableTopString = hTMLhelper.middleRowTop(title: BalanceSheet.Assets.currentAssets.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in bSData.objects0100 {
            let rowString = hTMLhelper.getSingleRow(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        // 流動資産
        var middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Assets.currentAssets.getTotalAmount(), amount: bSData.CurrentAssets_total)
        htmlString.append(middleRowEnd)
        // 固定資産
        tableTopString = hTMLhelper.middleRowTop(title: BalanceSheet.Assets.nonCurrentAssets.rawValue)
        htmlString.append(tableTopString)
        tableTopString = hTMLhelper.smallRowTop(title: BalanceSheet.NonCurrentAssets.tangibleFixedAssets.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in bSData.objects010142 {
            let rowString = hTMLhelper.getSingleRowIndent2space(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        tableTopString = hTMLhelper.smallRowTop(title: BalanceSheet.NonCurrentAssets.intangibleAssets.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in bSData.objects010143 {
            let rowString = hTMLhelper.getSingleRowIndent2space(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        tableTopString = hTMLhelper.smallRowTop(title: BalanceSheet.NonCurrentAssets.investments.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in bSData.objects010144 {
            let rowString = hTMLhelper.getSingleRowIndent2space(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        // 固定資産
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Assets.nonCurrentAssets.getTotalAmount(), amount: bSData.FixedAssets_total)
        htmlString.append(middleRowEnd)
        // 繰延資産
        tableTopString = hTMLhelper.middleRowTop(title: BalanceSheet.Assets.deferredAssets.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in bSData.objects0102 {
            let rowString = hTMLhelper.getSingleRow(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        // 繰延資産
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Assets.deferredAssets.getTotalAmount(), amount: bSData.DeferredAssets_total)
        htmlString.append(middleRowEnd)
        
        // テーブル　エンド 資産の部 合計
        var tableEndString = hTMLhelper.tableEndString(title: BalanceSheet.Block.assets.getTotalAmount(), amount: bSData.Asset_total)
        htmlString.append(tableEndString)
        
        
        // テーブル　トップ 負債の部
        tableTopString = hTMLhelper.tableTopString(block: BalanceSheet.Block.liabilities.rawValue)
        htmlString.append(tableTopString)
        
        tableTopString = hTMLhelper.middleRowTop(title: BalanceSheet.Liabilities.currentLiabilities.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in bSData.objects0114 {
            let rowString = hTMLhelper.getSingleRow(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Liabilities.currentLiabilities.getTotalAmount(), amount: bSData.CurrentLiabilities_total)
        htmlString.append(middleRowEnd)
        
        tableTopString = hTMLhelper.middleRowTop(title: BalanceSheet.Liabilities.fixedLiabilities.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in bSData.objects0115 {
            let rowString = hTMLhelper.getSingleRow(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Liabilities.fixedLiabilities.getTotalAmount(), amount: bSData.FixedLiabilities_total)
        htmlString.append(middleRowEnd)
        // テーブル　エンド 負債の部 合計
        tableEndString = hTMLhelper.tableEndString(amount: bSData.Liability_total)
        htmlString.append(tableEndString)
        
        
        // テーブル　トップ 資本の部
        tableTopString = hTMLhelper.tableTopString(block: BalanceSheet.Block.netAssets.rawValue)
        htmlString.append(tableTopString)
        tableTopString = hTMLhelper.middleRowTop(title: BalanceSheet.NetAssets.cashAndCashEquivalents.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in bSData.objects0129 {
            let rowString = hTMLhelper.getSingleRow(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.NetAssets.cashAndCashEquivalents.getTotalAmount(), amount: bSData.CapitalStock_total)
        htmlString.append(middleRowEnd)
        
        tableTopString = hTMLhelper.middleRowTop(title: BalanceSheet.NetAssets.accumulatedOtherComprehensiveIncome.rawValue)
        htmlString.append(tableTopString)
        // tableMiddle 行数分繰り返す
        for item in bSData.objects01210 {
            let rowString = hTMLhelper.getSingleRow(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
            htmlString.append(rowString)
        }
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.NetAssets.accumulatedOtherComprehensiveIncome.getTotalAmount(), amount: bSData.OtherCapitalSurpluses_total)
        htmlString.append(middleRowEnd)
        
        if 0 < bSData.objects01211.count { //新株予約権16 が0件の場合
            // tableMiddle 行数分繰り返す
            for item in bSData.objects01211 {
                let rowString = hTMLhelper.middleRowEndIndent0space(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
                htmlString.append(rowString)
            }
        }
        
        if 0 < bSData.objects01213.count { //非支配株主持分22 が0件の場合
            // tableMiddle 行数分繰り返す
            for item in bSData.objects01213 {
                let rowString = hTMLhelper.middleRowEndIndent0space(title: item.category, amount: DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: item.number, lastYear: false)) // TODO: 金額　取得先
                htmlString.append(rowString)
            }
        }
        
        // テーブル　エンド 負債・純資産の部 合計
        tableEndString = hTMLhelper.tableEndString(capitalAmount: bSData.Equity_total, amount: bSData.Liability_and_Equity_total)
        htmlString.append(tableEndString)
        
        
        // ページごとに1回コール
        let footerstring = hTMLhelper.footerstring()
        htmlString.append(footerstring)
        // PDFごとに1回コール
        let footerHTMLstring = hTMLhelper.footerHTMLstring()
        htmlString.append(footerHTMLstring)
        
        print(htmlString)
        //HTML -> PDF
        let pdfData = getPDF(fromHTML: htmlString)
        //PDFデータを一時ディレクトリに保存する
        if let fileName = saveToTempDirectory(data: pdfData) {
            //PDFファイルを表示する
            self.PDFpath?.append(fileName)
            
            return self.PDFpath
        }
        else {
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
        }
        catch {
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
