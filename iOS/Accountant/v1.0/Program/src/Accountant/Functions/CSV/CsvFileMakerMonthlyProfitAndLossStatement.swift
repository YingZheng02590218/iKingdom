//
//  CsvFileMakerMonthlyProfitAndLossStatement.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/10/10.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

// 月次推移表　損益計算書
class CsvFileMakerMonthlyProfitAndLossStatement {
    
    var csvPath: URL?
    var fiscalYear = 0
    // 月別の月末日を取得 12ヶ月分
    let dates = DateManager.shared.getTheDayOfEndingOfMonth()
    // 大区分ごとに設定勘定科目を取得する
    // 取得 大区分、中区分、小区分 スイッチONの勘定科目 個人事業主　（仕訳、総勘定元帳、貸借対照表、損益計算書、精算表、試算表 で使用している）
    var objects0 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 6, rank1: nil)
    
    var objects1 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 7, rank1: 13)
    var objects2 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 7, rank1: 14)
    
    var objects3 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 8, rank1: nil)
    
    var objects4 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 9, rank1: 15)
    var objects5 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 9, rank1: 16)
    
    var objects6 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 10, rank1: 17)
    var objects7 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 10, rank1: 18)
    
    var objects8 = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: 11, rank1: nil)

    
    func initialize(completion: (URL?) -> Void) {
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        self.fiscalYear = dataBaseAccountingBooks.fiscalYear
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
        var csv = ""
        
        // 勘定科目　列
        for i in 0..<objects0.count {
            var line = ""
            line += objects0[i].category + ","
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
                        rank0: 6,
                        rank1: nil,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                // 行の最後
                if d != dates.endIndex - 1 {
                    if !text.isEmpty {
                        line += text + ","
                    } else {
                        line += "" + ","
                    }
                } else {
                    if !text.isEmpty {
                        line += text + "\r\n"
                    } else {
                        line += "" + "\r\n"
                    }
                }
            }
            csv += line // csv = CSVとして出力する内容全体
        }
        
        // 勘定科目　列
        var line = ""
        line += ProfitAndLossStatement.Block.sales.getTotalAmount() + "," // 売上高
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.NetSales)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        // 勘定科目　列
        for i in 0..<objects1.count {
            var line = ""
            line += objects1[i].category + ","
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
                        rank0: 7,
                        rank1: 13,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                // 行の最後
                if d != dates.endIndex - 1 {
                    if !text.isEmpty {
                        line += text + ","
                    } else {
                        line += "" + ","
                    }
                } else {
                    if !text.isEmpty {
                        line += text + "\r\n"
                    } else {
                        line += "" + "\r\n"
                    }
                }
            }
            csv += line // csv = CSVとして出力する内容全体
        }
        
        // 勘定科目　列
        for i in 0..<objects2.count {
            var line = ""
            line += objects2[i].category + ","
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
                        rank0: 7,
                        rank1: 14,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                // 行の最後
                if d != dates.endIndex - 1 {
                    if !text.isEmpty {
                        line += text + ","
                    } else {
                        line += "" + ","
                    }
                } else {
                    if !text.isEmpty {
                        line += text + "\r\n"
                    } else {
                        line += "" + "\r\n"
                    }
                }
            }
            csv += line // csv = CSVとして出力する内容全体
        }
        
        // 勘定科目　列
        line = ""
        line += ProfitAndLossStatement.Block.costOfGoodsSold.getTotalAmount() + "," // 売上原価
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.CostOfGoodsSold)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        // 勘定科目　列
        line = ""
        line += ProfitAndLossStatement.Benefits.grossProfitOrLoss.rawValue + "," // 売上総利益
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.GrossProfitOrLoss)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        // 勘定科目　列
        for i in 0..<objects3.count {
            var line = ""
            line += objects3[i].category + ","
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
                        rank0: 8,
                        rank1: nil,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                // 行の最後
                if d != dates.endIndex - 1 {
                    if !text.isEmpty {
                        line += text + ","
                    } else {
                        line += "" + ","
                    }
                } else {
                    if !text.isEmpty {
                        line += text + "\r\n"
                    } else {
                        line += "" + "\r\n"
                    }
                }
            }
            csv += line // csv = CSVとして出力する内容全体
        }
        
        // 勘定科目　列
        line = ""
        line += ProfitAndLossStatement.Block.sellingGeneralAndAdministrativeExpenses.getTotalAmount() + "," // 販売費及び一般管理費
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.SellingGeneralAndAdministrativeExpenses)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        // 勘定科目　列
        line = ""
        line += ProfitAndLossStatement.Benefits.otherCapitalSurplusesTotal.rawValue + "," // 営業利益
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.OtherCapitalSurpluses_total)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        // 勘定科目　列
        for i in 0..<objects4.count {
            var line = ""
            line += objects4[i].category + ","
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
                        rank0: 9,
                        rank1: 15,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                // 行の最後
                if d != dates.endIndex - 1 {
                    if !text.isEmpty {
                        line += text + ","
                    } else {
                        line += "" + ","
                    }
                } else {
                    if !text.isEmpty {
                        line += text + "\r\n"
                    } else {
                        line += "" + "\r\n"
                    }
                }
            }
            csv += line // csv = CSVとして出力する内容全体
        }
        
        // 勘定科目　列
        line = ""
        line += ProfitAndLossStatement.Block.nonOperatingIncome.getTotalAmount() + "," // 営業外収益
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.NonOperatingIncome)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        // 勘定科目　列
        for i in 0..<objects5.count {
            var line = ""
            line += objects5[i].category + ","
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
                        rank0: 9,
                        rank1: 16,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                // 行の最後
                if d != dates.endIndex - 1 {
                    if !text.isEmpty {
                        line += text + ","
                    } else {
                        line += "" + ","
                    }
                } else {
                    if !text.isEmpty {
                        line += text + "\r\n"
                    } else {
                        line += "" + "\r\n"
                    }
                }
            }
            csv += line // csv = CSVとして出力する内容全体
        }
        
        // 勘定科目　列
        line = ""
        line += ProfitAndLossStatement.Block.nonOperatingExpenses.getTotalAmount() + "," // 営業外費用
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.NonOperatingExpenses)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        // 勘定科目　列
        line = ""
        line += ProfitAndLossStatement.Benefits.ordinaryIncomeOrLoss.rawValue + "," // 経常利益
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.OrdinaryIncomeOrLoss)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        // 勘定科目　列
        for i in 0..<objects6.count {
            var line = ""
            line += objects6[i].category + ","
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
                        rank0: 10,
                        rank1: 17,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                // 行の最後
                if d != dates.endIndex - 1 {
                    if !text.isEmpty {
                        line += text + ","
                    } else {
                        line += "" + ","
                    }
                } else {
                    if !text.isEmpty {
                        line += text + "\r\n"
                    } else {
                        line += "" + "\r\n"
                    }
                }
            }
            csv += line // csv = CSVとして出力する内容全体
        }
        
        // 勘定科目　列
        line = ""
        line += ProfitAndLossStatement.Block.extraordinaryProfits.getTotalAmount() + "," // 特別利益
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.ExtraordinaryIncome)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        // 勘定科目　列
        for i in 0..<objects7.count {
            var line = ""
            line += objects7[i].category + ","
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
                        rank0: 10,
                        rank1: 18,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                // 行の最後
                if d != dates.endIndex - 1 {
                    if !text.isEmpty {
                        line += text + ","
                    } else {
                        line += "" + ","
                    }
                } else {
                    if !text.isEmpty {
                        line += text + "\r\n"
                    } else {
                        line += "" + "\r\n"
                    }
                }
            }
            csv += line // csv = CSVとして出力する内容全体
        }
        
        // 勘定科目　列
        line = ""
        line += ProfitAndLossStatement.Block.extraordinaryLoss.getTotalAmount() + "," // 特別損失
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.ExtraordinaryLosses)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        // 勘定科目　列
        line = ""
        line += ProfitAndLossStatement.Benefits.incomeOrLossBeforeIncomeTaxes.rawValue + "," // 税引前当期純利益
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.IncomeOrLossBeforeIncomeTaxes)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        // 勘定科目　列
        for i in 0..<objects8.count {
            var line = ""
            line += objects8[i].category + ","
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
                        rank0: 11,
                        rank1: nil,
                        left: dataBaseMonthlyTransferEntry.balance_left,
                        right: dataBaseMonthlyTransferEntry.balance_right
                    )
                }
                // 行の最後
                if d != dates.endIndex - 1 {
                    if !text.isEmpty {
                        line += text + ","
                    } else {
                        line += "" + ","
                    }
                } else {
                    if !text.isEmpty {
                        line += text + "\r\n"
                    } else {
                        line += "" + "\r\n"
                    }
                }
            }
            csv += line // csv = CSVとして出力する内容全体
        }
        
        // 勘定科目　列
        line = ""
        line += ProfitAndLossStatement.Block.incomeTaxes.getTotalAmount() + "," // 法人税、住民税及び事業税
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.IncomeTaxes)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        // 勘定科目　列
        line = ""
        line += ProfitAndLossStatement.Benefits.netIncomeOrLoss.rawValue + "," // 当期純利益
        // 月別　列
        for d in 0..<dates.count {
            // 残高金額
            var text = ""
            // 取得 月次損益計算書　今年度で日付の前方一致
            if let dataBaseMonthlyProfitAndLossStatement = DataBaseManagerMonthlyBSnPL.shared.getMonthlyProfitAndLossStatement(
                yearMonth: "\(dates[d].year)" + "/" + "\(String(format: "%02d", dates[d].month))" // BEGINSWITH 前方一致
            ) {
                // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
                text = StringUtility.shared.setMinusMark(amount: dataBaseMonthlyProfitAndLossStatement.NetIncomeOrLoss)
            }
            // 行の最後
            if d != dates.endIndex - 1 {
                if !text.isEmpty {
                    line += text + ","
                } else {
                    line += "" + ","
                }
            } else {
                if !text.isEmpty {
                    line += text + "\r\n"
                } else {
                    line += "" + "\r\n"
                }
            }
        }
        csv += line // csv = CSVとして出力する内容全体
        
        var headLine = ""
        for i in 0..<dates.count {
            headLine.append(",\(dates[i].year)" + "-" + "\(String(format: "%02d", dates[i].month))")
        }
        csv = "勘定科目\(headLine)\r\n" + csv // 見出し行を先頭行に追加
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
    
    // 残高の金額を表示用に整形する　残高がマイナスの場合、三角のマークをつける
    private func getBalanceAmount(rank0: Int, rank1: Int?, left: Int64, right: Int64) -> String {
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
        return StringUtility.shared.setMinusMark(amount: result)
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
        
        let filePath = csvsDirectory.appendingPathComponent("\(fiscalYear)-MonthlyProfitAndLossStatement" + ".csv")
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
