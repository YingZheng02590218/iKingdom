//
//  PDFMakerMonthlyTrendsBalanceSheet.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/10/14.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

// 月次推移表　貸借対照表
class PDFMakerMonthlyTrendsBalanceSheet {
    
    var PDFpath: URL?
    
    let hTMLhelper = HTMLhelperMonthlyBS()
    let paperSize = CGSize(width: 297 / 25.4 * 72, height: 210 / 25.4 * 72) // 調整した　A4 297×210mm 595.2755905512, 841.8897637795 横向き
    
    let company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
    let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
    let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
    
    // 月別の月末日を取得 12ヶ月分
    let dates = DateManager.shared.getTheDayOfEndingOfMonth()
    // 大区分ごとに設定勘定科目を取得する
    // 取得 大区分、中区分、小区分 スイッチONの勘定科目 個人事業主　（仕訳、総勘定元帳、貸借対照表、損益計算書、精算表、試算表 で使用している）
    var objects0 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 0, rank1: 0)
    var objects1 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 0, rank1: 1)
    var objects2 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 0, rank1: 2)
    
    var objects3 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 1, rank1: 3)
    var objects4 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 1, rank1: 4)
    var objects5 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 1, rank1: 5)
    
    var objects6 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 2, rank1: 6)
    
    var objects7 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 3, rank1: 7)
    var objects8 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 3, rank1: 8)
    
    var objects9 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 4, rank1: 9)
    
    var objects10 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 10) // 株主資本
    var objects11 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 11) // 評価・換算差額等
    var objects12 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 12) // 新株予約権
    var objects13 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 5, rank1: 19) // 非支配株主持分
    
    let rowCountLimit = 30
    
    func initialize(completion: (URL?) -> Void) {
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
        
        let url = createHTML()
        completion(url)
    }
    
    func createHTML() -> URL? {
        // HTML
        var htmlString = ""
        // 月別の列　13ヶ月分
        var monthes: [String: String] = [:]
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
                company: company,
                fiscalYear: fiscalYear,
                theDayOfReckoning: theDayOfReckoning,
                pageNumber: pageNumber
            )
            htmlString.append(headerstring)
            
            for d in 0..<dates.count {
                monthes.updateValue("\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))", forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
            }
            // テーブル　トップ
            var tableTopString = hTMLhelper.tableTopString(monthes: monthes)
            htmlString.append(tableTopString)
        }
        
        // 勘定科目　列
        for i in 0..<objects0.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects0[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 0,
                        rank1: 0,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                    print(String(describing: monthes["\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))"]))
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects0[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        
        // 勘定科目　列
        for i in 0..<objects1.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects1[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 0,
                        rank1: 1,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects1[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        
        // 勘定科目　列
        for i in 0..<objects2.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects2[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 0,
                        rank1: 2,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects2[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        
        // 月別の列　13ヶ月分
        monthes = [:]
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次貸借対照表　今年度で日付の前方一致
            if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.CurrentAssets_total)
                monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
            }
        }
        // 流動資産 合計
        var middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Assets.currentAssets.getTotalAmount(), monthes: monthes)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= rowCountLimit {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        // 勘定科目　列
        for i in 0..<objects3.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects3[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 1,
                        rank1: 3,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects3[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        // 勘定科目　列
        for i in 0..<objects4.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects4[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 1,
                        rank1: 4,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects4[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        // 勘定科目　列
        for i in 0..<objects5.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects5[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 1,
                        rank1: 5,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects5[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        
        // 月別の列　13ヶ月分
        monthes = [:]
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次貸借対照表　今年度で日付の前方一致
            if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.FixedAssets_total)
                monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
            }
        }
        // 固定資産 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Assets.nonCurrentAssets.getTotalAmount(), monthes: monthes)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= rowCountLimit {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 勘定科目　列
        for i in 0..<objects6.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects6[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 2,
                        rank1: 6,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects6[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        
        // 月別の列　13ヶ月分
        monthes = [:]
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次貸借対照表　今年度で日付の前方一致
            if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.DeferredAssets_total)
                monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
            }
        }
        // 繰延資産 合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Assets.deferredAssets.getTotalAmount(), monthes: monthes)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= rowCountLimit {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // MARK: 資産　合計
        // 月別の列　13ヶ月分
        monthes = [:]
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次貸借対照表　今年度で日付の前方一致
            if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.Asset_total)
                monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
            }
        }
        // テーブル　エンド 資産の部 合計
        var tableEndString = hTMLhelper.getSingleRowForBenefits(title: BalanceSheet.Block.assets.getTotalAmount(), monthes: monthes)
        htmlString.append(tableEndString)
        // PDFページ　追加
        counter += 1
        if counter >= rowCountLimit {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 月別の列　13ヶ月分
        monthes = [:]
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次貸借対照表　今年度で日付の前方一致
            if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.Asset_total)
                monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
            }
        }
        // 勘定科目　列
        for i in 0..<objects7.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects7[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 3,
                        rank1: 7,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects7[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        // 勘定科目　列
        for i in 0..<objects8.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects8[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 3,
                        rank1: 8,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects8[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        
        // 月別の列　13ヶ月分
        monthes = [:]
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次貸借対照表　今年度で日付の前方一致
            if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.CurrentLiabilities_total)
                monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
            }
        }
        // 流動負債　合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Liabilities.currentLiabilities.getTotalAmount(), monthes: monthes)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= rowCountLimit {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 勘定科目　列
        for i in 0..<objects9.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects9[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 4,
                        rank1: 9,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects9[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        
        // 月別の列　13ヶ月分
        monthes = [:]
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次貸借対照表　今年度で日付の前方一致
            if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.FixedLiabilities_total)
                monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
            }
        }
        // 固定負債　合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: BalanceSheet.Liabilities.fixedLiabilities.getTotalAmount(), monthes: monthes)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= rowCountLimit {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // MARK: 負債　合計
        // 月別の列　13ヶ月分
        monthes = [:]
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次貸借対照表　今年度で日付の前方一致
            if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.Liability_total)
                monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
            }
        }
        // テーブル　エンド 負債の部 合計
        tableEndString = hTMLhelper.getSingleRowForBenefits(title: BalanceSheet.Block.liabilities.getTotalAmount(), monthes: monthes)
        htmlString.append(tableEndString)
        // PDFページ　追加
        counter += 1
        if counter >= rowCountLimit {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // 勘定科目　列
        for i in 0..<objects10.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects10[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 5,
                        rank1: 10,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects10[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        
        // 勘定科目　列
        for i in 0..<objects11.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects11[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 5,
                        rank1: 11,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects11[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        
        // 勘定科目　列
        for i in 0..<objects12.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects12[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 5,
                        rank1: 12,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects12[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        
        // 勘定科目　列
        for i in 0..<objects13.count {
            // 月別の列　13ヶ月分
            var monthes: [String: String] = [:]
            // 月別　列
            for d in 0..<dates.count {
                // 残高金額
                var text = ""
                // 取得 月次損益振替仕訳、月次残高振替仕訳　今年度の勘定別で日付の先方一致
                if let dataBaseMonthlyTransferEntry = DataBaseManagerMonthlyTransferEntry.shared.getMonthlyTransferEntryInAccountBeginsWith(
                    account: objects13[i].category,
                    yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
                ) {
                    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                    text = getBalanceAmount(
                        rank0: 5,
                        rank1: 19,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                    monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
                }
            }
            let rowString = hTMLhelper.getSingleRow(
                title: objects13[i].category,
                monthes: monthes
            ) // TODO: 金額　取得先
            htmlString.append(rowString)
            // PDFページ　追加
            counter += 1
            if counter >= rowCountLimit {
                counter = 0
                pageNumber += 1
                // PDFページ　ボトム
                incrementPageBottom()
                // PDFページ　トップ
                incrementPage()
            }
        }
        
        // 月別の列　13ヶ月分
        monthes = [:]
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次貸借対照表　今年度で日付の前方一致
            if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.Capital_total)
                monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
            }
        }
        // 資本　合計
        middleRowEnd = hTMLhelper.middleRowEnd(title: "資本　合計", monthes: monthes)
        htmlString.append(middleRowEnd)
        // PDFページ　追加
        counter += 1
        if counter >= rowCountLimit {
            counter = 0
            pageNumber += 1
            // PDFページ　ボトム
            incrementPageBottom()
            // PDFページ　トップ
            incrementPage()
        }
        
        // MARK: 純資産 合計
        // 月別の列　13ヶ月分
        monthes = [:]
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次貸借対照表　今年度で日付の前方一致
            if let dataBaseMonthlyBalanceSheet = DataBaseManagerMonthlyBSnPL.shared.getMonthlyBalanceSheet(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setComma(amount: dataBaseMonthlyBalanceSheet.Equity_total)
                monthes.updateValue(text, forKey: "\(dates[d].year)" + "-" + "\(String(format: "%02d", dates[d].month))")
            }
        }
        // テーブル　エンド 純資産 合計
        tableEndString = hTMLhelper.getSingleRowForBenefits(title: BalanceSheet.Block.netAssets.getTotalAmount(), monthes: monthes)
        htmlString.append(tableEndString)
        // PDFページ　追加
        counter += 1
        if counter >= rowCountLimit {
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
    
    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
    private func getBalanceAmount(rank0: Int, rank1: Int, left: Int64, right: Int64) -> String {
        var result: Int64 = 0
        var debitOrCredit: String = "" // 借又貸
        var positiveOrNegative: String = "" // 借又貸
        
        // 借方と貸方で金額が大きい方はどちらか
        if left > right {
            result = left
            debitOrCredit = "借"
        } else if left < right {
            result = right
            debitOrCredit = "貸"
        } else {
            debitOrCredit = "-"
        }
        
        switch rank0 {
        case 0, 1, 2, 7, 8, 11: // 流動資産 固定資産 繰延資産,売上原価 販売費及び一般管理費 税金
            switch debitOrCredit {
            case "貸":
                positiveOrNegative = "-"
            default:
                positiveOrNegative = ""
            }
        case 9, 10: // 営業外損益 特別損益
            if rank1 == 15 || rank1 == 17 { // 営業外損益
                switch debitOrCredit {
                case "借":
                    positiveOrNegative = "-"
                default:
                    positiveOrNegative = ""
                }
            } else if rank1 == 16 || rank1 == 18 { // 特別損益
                switch debitOrCredit {
                case "貸":
                    positiveOrNegative = "-"
                default:
                    positiveOrNegative = ""
                }
            }
        default: // 3,4,5,6（流動負債 固定負債 資本）, 売上
            switch debitOrCredit {
            case "借":
                positiveOrNegative = "-"
            default:
                positiveOrNegative = ""
            }
        }
        
        if positiveOrNegative == "-" {
            // 残高がマイナスの場合、三角のマークをつける
            result = (result * -1)
        }
        // 三角形を追加
        return StringUtility.shared.setComma(amount: result)
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
        let filePath = pDFsDirectory.appendingPathComponent("\(fiscalYear)-MonthlyTrendsBalanceSheet" + ".pdf")
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
