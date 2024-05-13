//
//  CsvFileMaker.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2024/01/22.
//  Copyright © 2024 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

class CsvFileMaker {
    
    var csvPath: URL?
    
    var fiscalYear = 0
    
    func initialize(completion: (URL?) -> Void) {
        let dataBaseAccountingBooks = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        fiscalYear = dataBaseAccountingBooks.fiscalYear
        // 初期化
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
        
        let dataBaseManager = JournalsModel()
        let dataBaseJournalEntries = dataBaseManager.getJournalEntriesInJournals()
        let dataBaseAdjustingEntries = dataBaseManager.getJournalAdjustingEntry()
        
        var csv = ""
        
        // 行数分繰り返す 仕訳
        for item in dataBaseJournalEntries {
            var line = ""
            
            line += "\(item.date)" + ","
            
            let debitCategory = item.debit_category
            line += "\"" + (debitCategory.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // "[名前]", の[名前]に " が含まれていたら、" を "" に置換（今回は必ず含まれないが）
            let debitAmount = item.debit_amount
            line += String(debitAmount) + ","
            let creditCategory = item.credit_category
            line += "\"" + (creditCategory.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            let creditAmount = item.credit_amount
            line += String(creditAmount) + ","
            let smallWritting = item.smallWritting
            line += "\"" + (smallWritting.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\"\r\n"
            
            csv += line // csv = CSVとして出力する内容全体
        }
        
        // 決算整理仕訳
        for item in dataBaseAdjustingEntries {
            var line = ""
            
            line += "\(item.date)" + ","
            
            let debitCategory = item.debit_category
            line += "\"" + (debitCategory.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            // "[名前]", の[名前]に " が含まれていたら、" を "" に置換（今回は必ず含まれないが）
            let debitAmount = item.debit_amount
            line += String(debitAmount) + ","
            let creditCategory = item.credit_category
            line += "\"" + (creditCategory.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\","
            let creditAmount = item.credit_amount
            line += String(creditAmount) + ","
            let smallWritting = item.smallWritting
            line += "\"" + (smallWritting.replacingOccurrences(of: "\"", with: "\"\"") as String) + "\"\r\n"
            
            csv += line // csv = CSVとして出力する内容全体
        }
        
        csv = "日付,借方勘定,借方金額,貸方勘定,貸方金額,摘要\r\n" + csv // 見出し行を先頭行に追加
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
        
        let filePath = csvsDirectory.appendingPathComponent("\(fiscalYear)-Journals" + ".csv")
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
