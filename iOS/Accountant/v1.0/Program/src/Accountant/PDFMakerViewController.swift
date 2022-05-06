//
//  PDFMakerViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/06/05.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import Foundation
import QuickLook
import UIKit
import PDFKit


class PDFMakerViewController: UIViewController, QLPreviewControllerDataSource, UIPrintInteractionControllerDelegate {
        
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var pdfView: PDFView!
    
    var PDFpath: [URL]?
    let hTMLhelper = HTMLhelper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
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
//                if self.PDFpath?.count ?? 0 == 0 {
//                    //PDFファイルを表示する
//                    self.PDFpath?.append(content)
//                }
//                else {
                    do {
                        try FileManager.default.removeItem(at: content)
                    }
                    catch let error {
                        print(error)
                    }
//                }
            }
        }
        catch {
            print(error)
        }

        
        readDB()

    }
    
    @IBAction func tap(_ sender: Any) {
        
        readDB()

        
        if let PDFpath = self.PDFpath?[0] {
            let document = PDFDocument(url: PDFpath)
            pdfView.document = document
            pdfView.backgroundColor = .lightGray
            // PDFの拡大率を調整する
            pdfView.autoScales = true
            // 表示モード
            pdfView.displayMode = .singlePageContinuous
        }
    }
    
    @IBAction func tappedPreview(_ sender: Any) {
        
        if let PDFpath = self.PDFpath?[0] {
            let document = PDFDocument(url: PDFpath)
            pdfView.document = document
            pdfView.backgroundColor = .lightGray
            // PDFの拡大率を調整する
            pdfView.autoScales = true
            // 表示モード
            pdfView.displayMode = .singlePageContinuous
        }
    }
    
    @IBAction func tappedQLPreview(_ sender: Any) {
//        let previewController = QLPreviewController()
//        previewController.dataSource = self
//        present(previewController, animated: true, completion: nil)
    }
    
    func readDB() {
        let dataBaseManager = DataBaseManagerJournalEntry()
        let objects = dataBaseManager.getJournalEntryAll()
        
        var htmlString = ""
        // 行を取得する
         var totalDebit_amount:Int64 = 0
        var totalCredit_amount:Int64 = 0
        var counter = 0
        // HTMLのヘッダーを取得する
         let htmlHeader = hTMLhelper.headerHTMLstring()
        htmlString.append(htmlHeader)
        for item in objects {
            
            let fiscalYear = item.fiscalYear
            if counter == 0 {
                let tableHeader = hTMLhelper.headerstring(title:"仕訳帳", fiscalYear: fiscalYear, pageNumber: 9)
                htmlString.append(tableHeader)
            }
            // 仕訳クラス                // モデル定義
            ////    @objc dynamic var number: Int = 0                 //仕訳番号
            //    @objc dynamic var fiscalYear: Int = 0               //年度
            //    @objc dynamic var date: String = ""                 //日付
            //    @objc dynamic var debit_category: String = ""       //借方勘定
            //    @objc dynamic var debit_amount: Int64 = 0           //借方金額
            //    @objc dynamic var credit_category: String = ""      //貸方勘定
            //    @objc dynamic var credit_amount: Int64 = 0          //貸方金額
            //    @objc dynamic var smallWritting: String = ""        //小書き
            //    @objc dynamic var balance_left: Int64 = 0           //差引残高
            //    @objc dynamic var balance_right: Int64 = 0          //差引残高
            let month = item.date[item.date.index(item.date.startIndex, offsetBy: 5)..<item.date.index(item.date.startIndex, offsetBy: 7)]
            let date = item.date[item.date.index(item.date.startIndex, offsetBy: 9)..<item.date.index(item.date.startIndex, offsetBy: 10)]
            let debit_category = item.debit_category
            let debit_amount = item.debit_amount
            let credit_category = item.credit_category
            let credit_amount = item.credit_amount
            let smallWritting = item.smallWritting
            let balance_left = item.balance_left
            let balance_right = item.balance_right
            
            let rowString = hTMLhelper.getSingleRow(month: String(month), day: String(date), debit_category: debit_category, debit_amount: debit_amount, credit_category: credit_category, credit_amount: credit_amount, smallWritting: smallWritting)
            htmlString.append(rowString)
            
            totalDebit_amount += item.debit_amount
            totalCredit_amount += item.credit_amount

            if counter >= 9 {
                let tableFooter = hTMLhelper.footerstring(debit_amount: totalDebit_amount, credit_amount: totalCredit_amount)
                htmlString.append(tableFooter)
            }
            counter += 1
            if counter >= 10 {
                counter = 0
            }
        }
         if counter > 0 && counter <= 10 {
             for _ in counter ..< 10 {
                 let rowString = hTMLhelper.getSingleRowEmpty()
                 htmlString.append(rowString)
                 
                 if counter >= 9 {
                     let tableFooter = hTMLhelper.footerstring(debit_amount: totalDebit_amount, credit_amount: totalCredit_amount)
                     htmlString.append(tableFooter)
                 }
                 counter += 1
             }
         }
        // フッターを取得する
         let footerString = hTMLhelper.footerHTMLstring()
        htmlString.append(footerString)
        //HTML -> PDF
        let pdfData = getPDF(fromHTML: htmlString)
        //PDFデータを一時ディレクトリに保存する
        if let fileName = saveToTempDirectory(data: pdfData) {
            //PDFファイルを表示する
            self.PDFpath?.append(fileName)
        }
        
        // textViewにHTMLを表示させる
//        textView.attributedText = NSAttributedString.parseHTML2Text(sourceText:htmlString)
//        pdfView.isHidden = true
    }

//    let paperSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72) // A4, 72 dpi
    let paperSize = CGSize(width: 192 / 25.4 * 72, height: 262 / 25.4 * 72) // B5 192×262mm
//    let paperSize = CGSize(width: 187 / 25.4 * 72, height: 257 / 25.4 * 72) // B5 187×257mm コクヨ仕訳帳　実寸
//    let paperSize = CGSize(width: 176 / 25.4 * 72, height: 250 / 25.4 * 72) // B5 176mm x 250mm　標準の ISO の寸法
//    let paperSize = CGSize(width: 128 / 25.4 * 72, height: 182 / 25.4 * 72) / B6 128x182

    /*
     この関数はHTML文字列を受け取り、PDFファイルを表す `NSData` オブジェクトを返します。
     */
     func getPDF(fromHTML: String) -> NSData {
        let renderer = UIPrintPageRenderer()
        let paperFrame = CGRect(origin: .zero, size: paperSize)
         
        renderer.setValue(paperFrame, forKey: "paperRect")
        renderer.setValue(paperFrame, forKey: "printableRect")
         
        let formatter = UIMarkupTextPrintFormatter(markupText: fromHTML)
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
         
        let pdfData = NSMutableData()
         
         UIGraphicsBeginPDFContextToData(pdfData, paperFrame, nil)
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
         let filePath = pDFsDirectory.appendingPathComponent("receipt-" + UUID().uuidString + ".pdf")
         do {
             try data.write(to: filePath)
             print(filePath)
             return filePath
         } catch {
             print(error.localizedDescription)
             return nil
         }
    }
    
    /**
     * 印刷ボタン押下時メソッド
     * 仕訳帳画面　Extend Edges: Under Top Bar, Under Bottom Bar のチェックを外すと,仕訳データの行が崩れてしまう。
     */
    @IBAction func button_print(_ sender: UIButton) {
        let printController = UIPrintInteractionController.shared

        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = .general
        printInfo.orientation = .landscape

        printController.printInfo = printInfo
        printController.printingItem = self.resizePrintingPaper()

        printController.present(animated: true, completionHandler: nil)
    }

    private func resizePrintingPaper() -> NSData? {
        // CGPDFDocumentを取得
        if let PDFpath = self.PDFpath?[0] {
            let document = PDFDocument(url: PDFpath)
            guard let documentRef = document?.documentRef else { return nil }
            
            var pageImages: [UIImage] = []
            
            // 表示しているPDFPageをUIImageに変換
            for pageCount in 0 ..< documentRef.numberOfPages {
                // CGPDFDocument -> CGPDFPage -> UIImage
                if let page = documentRef.page(at: pageCount + 1) {
                    let pageRect = page.getBoxRect(.mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                    let pageImage = renderer.image { context in
                        UIColor.white.set()
                        context.fill(pageRect)
                        
                        context.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                        context.cgContext.scaleBy(x: 1.0, y: -1.0)
                        
                        context.cgContext.drawPDFPage(page)
                    }
                    // Image配列に格納
                    pageImages.append(pageImage)
                }
            }
            // UIImageにしたPDFPageをNSDataに変換
            let pdfData: NSMutableData = NSMutableData()
            let pdfConsumer: CGDataConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
            
            var mediaBox: CGRect = CGRect(origin: .zero, size: paperSize) // ここに印刷したいサイズを入れる
            let pdfContext: CGContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil)!
            
            pageImages.forEach { image in
                pdfContext.beginPage(mediaBox: &mediaBox)
                pdfContext.draw(image.cgImage!, in: mediaBox)
                pdfContext.endPage()
            }
            
            return pdfData
        }
        return nil
    }

    // MARK: - UIImageWriteToSavedPhotosAlbum
    
    @objc func didFinishWriteImage(_ image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer) {
        if let error = error {
        print("Image write error: \(error)")
        }
    }

    func printInteractionController ( _ printInteractionController: UIPrintInteractionController, choosePaper paperList: [UIPrintPaper]) -> UIPrintPaper {
        print("printInteractionController")
        for i in 0..<paperList.count {
            let paper: UIPrintPaper = paperList[i]
        print(" paperListのビクセル is \(paper.paperSize.width) \(paper.paperSize.height)")
        }
        //ピクセル
        print(" pageSizeピクセル    -> \(paperSize)")
        let bestPaper = UIPrintPaper.bestPaper(forPageSize: paperSize, withPapersFrom: paperList)
        //mmで用紙サイズと印刷可能範囲を表示
        print(" paperSizeミリ      -> \(bestPaper.paperSize.width / 72.0 * 25.4), \(bestPaper.paperSize.height / 72.0 * 25.4)")
        print(" bestPaper         -> \(bestPaper.printableRect.origin.x / 72.0 * 25.4), \(bestPaper.printableRect.origin.y / 72.0 * 25.4), \(bestPaper.printableRect.size.width / 72.0 * 25.4), \(bestPaper.printableRect.size.height / 72.0 * 25.4)\n")
        return bestPaper
    }
}

/*
 `QLPreviewController` にPDFデータを提供する
 */

extension PDFMakerViewController {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        if self.PDFpath != nil {
            return self.PDFpath?.count ?? 0
        } else {
            return 0
        }
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let pdfFilePath = self.PDFpath?[index] else {
            return "" as! QLPreviewItem
        }
        return pdfFilePath as QLPreviewItem
    }
}
