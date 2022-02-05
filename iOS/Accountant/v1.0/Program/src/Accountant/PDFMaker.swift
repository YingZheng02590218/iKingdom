//
//  PDFMaker.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/06/05.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import Foundation
import QuickLook

//struct Item {
//    var name: String
//    var price: Int
//}

class PDFMaker: UIViewController {
    
    static var items = [Item]()
    
    var PDFpath: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /*
     レシートに項目を追加するアクション
     */
//    @IBAction func actionAddItem(){
//        //名前と価格を尋ねる
//        let alert = UIAlertController(title: "項目を追加", message: nil, preferredStyle: .alert)
//        //項目の名前を入力するテキストフィールド
//        alert.addTextField { (nameTextField) in
//            nameTextField.placeholder = "名前"
//        }
//        //項目の価格を入力するテキストフィールド
//        alert.addTextField { (priceTextField) in
//            priceTextField.placeholder = "価格"
//        }
//        //UIAlertAction
//        let actionAdd = UIAlertAction(title: "追加", style: .default) { (action) in
//            guard let name = alert.textFields?.first?.text else { return }
//            //価格の文字列を価格の桁数に変換する
//            guard let priceStr = alert.textFields?[1].text else { return }
//            let price = Int(priceStr) ?? 0
//            //項目を追加する
//            let item = Item(name: name, price: price)
//            self.items.append(item)
//            //テーブルビューを再読み込みする
//            self.tableView.reloadData()
//        }
//        alert.addAction(actionAdd)
//        let actionDismiss = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(actionDismiss)
//        present(alert, animated: true, completion: nil)
//    }
//
    
    static func readDB() {
        let dataBaseManager = DataBaseManagerJournalEntry()
        let objects = dataBaseManager.getJournalEntry(section: 0)
        
        var htmlString = ""
        // HTMLのヘッダーを取得する
//        let htmlHeader = headerHTMLstring()
//        htmlString.append(htmlHeader)
        // 行を取得する
        var totalPrice = 0
        for item in objects {
//            // 仕訳クラス
//            class DataBaseJournalEntry: RObject {
//                // モデル定義
//            //    @objc dynamic var number: Int = 0                 //仕訳番号
//                @objc dynamic var fiscalYear: Int = 0               //年度
//                @objc dynamic var date: String = ""                 //日付
//                @objc dynamic var debit_category: String = ""       //借方勘定
//                @objc dynamic var debit_amount: Int64 = 0           //借方金額
//                @objc dynamic var credit_category: String = ""      //貸方勘定
//                @objc dynamic var credit_amount: Int64 = 0          //貸方金額
//                @objc dynamic var smallWritting: String = ""        //小書き
//                @objc dynamic var balance_left: Int64 = 0           //差引残高
//                @objc dynamic var balance_right: Int64 = 0          //差引残高
            let fiscalYear = item.fiscalYear
            let date = item.date
            let debit_category = item.debit_category
            let debit_amount = item.debit_amount
            let credit_category = item.credit_category
            let credit_amount = item.credit_amount
            let smallWritting = item.smallWritting
            let balance_left = item.balance_left
            let balance_right = item.balance_right
            
//            let rowString = getSingleRow(itemName: date, itemPrice: fiscalYear)
//            htmlString.append(rowString)
//            totalPrice += price
        }
        // 合計金額を追加する
        htmlString.append("\n 合計金額: \(totalPrice) yen \n")
        // フッターを取得する
        let footerString = footerHTMLstring()
        htmlString.append(footerString)
        //HTML -> PDF
        let pdfData = getPDF(fromHTML: htmlString)
        //PDFデータを一時ディレクトリに保存する
        if let savedPath = saveToTempDirectory(data: pdfData) {
//            //PDFファイルを表示する
//            self.PDFpath = savedPath
//            let previewController = QLPreviewController()
//            previewController.dataSource = self
//            present(previewController, animated: true, completion: nil)
        }
        
//        // 通常仕訳
//        //② todo 借方の場合は左寄せ、貸方の場合は右寄せ。小書きは左寄せ。
//
//        let d = "\(objects[indexPath.row].date)" // 日付
//        // 月別のセクションのうち、日付が一番古いものに月欄に月を表示し、それ以降は空白とする。
//        if indexPath.section == 0 {
//            if indexPath.row > 0 { // 二行目以降は月の先頭のみ、月を表示する
//                // 一行上のセルに表示した月とこの行の月を比較する
//                let upperCellMonth = "\(objects[indexPath.row - 1].date)" // 日付
//                let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
//                if dateMonth == "0" { // 日の十の位が0の場合は表示しない
//                    if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
//                        cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
//                    }else{
//                        cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
//                    }
//                }else{
//                    if upperCellMonth[upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 5)..<upperCellMonth.index(upperCellMonth.startIndex, offsetBy: 7)] != "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" {
//                        cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
//                    }else{
//                        cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
//                    }
//                }
//            }else { // 先頭行は月を表示
//                let dateMonth = d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 6)] // 日付の6文字目にある月の十の位を抽出
//                if dateMonth == "0" { // 日の十の位が0の場合は表示しない
//                    cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 6)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
//                }else{
//                    cell.label_list_date_month.text = "\(d[d.index(d.startIndex, offsetBy: 5)..<d.index(d.startIndex, offsetBy: 7)])" // 「月」
//                }
//            }
//        }else{
//            cell.label_list_date_month.text = "" // 注意：空白を代入しないと、変な値が入る。
//        }
//        let date = d[d.index(d.startIndex, offsetBy: 8)..<d.index(d.startIndex, offsetBy: 9)] // 日付の9文字目にある日の十の位を抽出
//        if date == "0" { // 日の十の位が0の場合は表示しない
//            cell.label_list_date.text = "\(objects[indexPath.row].date.suffix(1))" // 末尾1文字の「日」         //日付
//        }else{
//            cell.label_list_date.text = "\(objects[indexPath.row].date.suffix(2))" // 末尾2文字の「日」         //日付
//        }
//        cell.label_list_date.textAlignment = NSTextAlignment.right
//        cell.label_list_summary_debit.text = " (\(objects[indexPath.row].debit_category))"     //借方勘定
//        cell.label_list_summary_debit.textAlignment = NSTextAlignment.left
//        cell.label_list_summary_credit.text = "(\(objects[indexPath.row].credit_category)) "   //貸方勘定
//        cell.label_list_summary_credit.textAlignment = NSTextAlignment.right
//        cell.label_list_summary.text = "\(objects[indexPath.row].smallWritting) "              //小書き
//        cell.label_list_summary.textAlignment = NSTextAlignment.left
//        if objects[indexPath.row].debit_category == "損益勘定" { // 損益勘定の場合
//            cell.label_list_number_left.text = ""
//        }else{
//            print(objects[indexPath.row].debit_category)
//            let numberOfAccount_left = dataBaseManager.getNumberOfAccount(accountName: "\(objects[indexPath.row].debit_category)")  // 丁数を取得
//            cell.label_list_number_left.text = numberOfAccount_left.description                                     // 丁数　借方
//        }
//        if objects[indexPath.row].credit_category == "損益勘定" { // 損益勘定の場合
//            cell.label_list_number_right.text = ""
//        }else{
//            print(objects[indexPath.row].credit_category)
//            let numberOfAccount_right = dataBaseManager.getNumberOfAccount(accountName: "\(objects[indexPath.row].credit_category)")    // 丁数を取得
//            cell.label_list_number_right.text = numberOfAccount_right.description                                   // 丁数　貸方
//        }
//        cell.label_list_debit.text = "\(addComma(string: String(objects[indexPath.row].debit_amount))) "        //借方金額
//        cell.label_list_credit.text = "\(addComma(string: String(objects[indexPath.row].credit_amount))) "      //貸方金額
//        // セルの選択を許可
//        cell.selectionStyle = .default
    }
    /*
     レシートを印刷するアクション
     */
    static func actionPrint( ) { // オーバーライドして使用する
        var htmlString = ""
        // HTMLのヘッダーを取得する
//        let htmlHeader = headerHTMLstring()
//        htmlString.append(htmlHeader)
        // 行を取得する
        var totalPrice = 0
        for item in items {
            let name = item.name
            let price = item.price
//            let rowString = getSingleRow(itemName: name, itemPrice: price)
//            htmlString.append(rowString)
            totalPrice += price
        }
        // 合計金額を追加する
        htmlString.append("\n 合計金額: \(totalPrice) yen \n")
        // フッターを取得する
        let footerString = footerHTMLstring()
        htmlString.append(footerString)
        //HTML -> PDF
        let pdfData = getPDF(fromHTML: htmlString)
        //PDFデータを一時ディレクトリに保存する
        if let savedPath = saveToTempDirectory(data: pdfData) {
//            //PDFファイルを表示する
//            self.PDFpath = savedPath
//            let previewController = QLPreviewController()
//            previewController.dataSource = self
//            present(previewController, animated: true, completion: nil)
        }
    }
    
    /*
     この関数はHTML文字列を受け取り、PDFファイルを表す `NSData` オブジェクトを返します。
     */
    static func getPDF(fromHTML: String) -> NSData {
        let renderer = UIPrintPageRenderer()
        let paperSize = CGSize(width: 595.2, height: 841.8) //B6
        let paperFrame = CGRect(origin: .zero, size: paperSize)
        renderer.setValue(paperFrame, forKey: "paperRect")
        renderer.setValue(paperFrame, forKey: "printableRect")
        let formatter = UIMarkupTextPrintFormatter(markupText: fromHTML)
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, [:])
        for pageI in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: pageI, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        return pdfData
    }
    
    /*
     この関数は、特定の `data` をアプリの一時ストレージに保存します。さらに、そのファイルが存在する場所のパスを返します。
     */
    static func saveToTempDirectory(data: NSData) -> URL? {
        let tempDirectory = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let filePath = tempDirectory.appendingPathComponent("receipt-" + UUID().uuidString + ".pdf")
        do {
            try data.write(to: filePath)
            return filePath
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }


}

///*
// テーブルビューにデータを提供する
// */
//extension ViewController {
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return items.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let item = items[indexPath.row]
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
//        cell.textLabel?.text = item.name
//        cell.detailTextLabel?.text = String(item.price)
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        let rowI = indexPath.row
//        items.remove(at: rowI)
//        tableView.reloadData()
//    }
//
//}

/*
 `QLPreviewController` にPDFデータを提供する
 */

extension PDFMaker: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        if self.PDFpath != nil {
            return 1
        } else {
            return 0
        }
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let pdfFilePath = self.PDFpath else {
            return "" as! QLPreviewItem
        }
        return pdfFilePath as QLPreviewItem
    }
    
}


