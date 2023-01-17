//
//  PDFMakerViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/06/05.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import Foundation
import PDFKit
import QuickLook
import UIKit

class PDFMakerViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    @IBOutlet var pdfView: PDFView!
    
    // 印刷機能
    let pDFMaker = PDFMaker() // 仕訳帳
    let paperSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72) // A4 210×297mm
//    let paperSize = CGSize(width: 192 / 25.4 * 72, height: 262 / 25.4 * 72) // B5 192×262mm
//    let paperSize = CGSize(width: 187 / 25.4 * 72, height: 257 / 25.4 * 72) // B5 187×257mm コクヨ仕訳帳　実寸
//    let paperSize = CGSize(width: 176 / 25.4 * 72, height: 250 / 25.4 * 72) // B5 176mm x 250mm　標準の ISO の寸法
//    let paperSize = CGSize(width: 128 / 25.4 * 72, height: 182 / 25.4 * 72) // B6 128x182

    override func viewDidLoad() {
        super.viewDidLoad()
        // 初期化
//        pDFMaker.initialize()
    }

    @IBAction func tap(_ sender: Any) {
        
    }
    
    @IBAction func tappedPreview(_ sender: Any) {
        
        if let PDFpath = pDFMaker.PDFpath?[0] {
            let document = PDFDocument(url: PDFpath)
            pdfView.usePageViewController(true)
            
            pdfView.document = document
            pdfView.backgroundColor = .lightGray
            // PDFの拡大率を調整する
            pdfView.autoScales = true
            // 表示モード
            pdfView.displayMode = .singlePageContinuous
            pdfView.displaysPageBreaks = true
        }
    }
    
    /**
     * 印刷ボタン押下時メソッド
     * 仕訳帳画面　Extend Edges: Under Top Bar, Under Bottom Bar のチェックを外すと,仕訳データの行が崩れてしまう。
     */
    @IBAction func button_print(_ sender: UIButton) {
//        // 初期化
//        pDFMaker.initialize()
        // TODO: 動作確認用
        let fiscalYear = "2022"
//        if let fiscalYear = presenter.fiscalYear {
            let printController = UIPrintInteractionController.shared
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .general
            printInfo.jobName = "\(fiscalYear)-Journals"
            printInfo.duplex = .none
            printInfo.orientation = .portrait
            printController.printInfo = printInfo
            printController.printingItem = self.resizePrintingPaper()
            printController.present(animated: true, completionHandler: nil)
//        }
    }

    private func resizePrintingPaper() -> NSData? {
        // CGPDFDocumentを取得
        if let PDFpath = pDFMaker.PDFpath?[0] {
            let document = PDFDocument(url: PDFpath)
            guard let documentRef = document?.documentRef else { return nil }
            
            var pageImages: [UIImage] = []
            
            // 表示しているPDFPageをUIImageに変換
            for pageCount in 0 ..< documentRef.numberOfPages {
                // CGPDFDocument -> CGPDFPage -> UIImage
                if let page = documentRef.page(at: pageCount) { // 毎回空白ページが生成されていた原因。なぜか+1をしていた
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
            
            var mediaBox: CGRect = CGRect(origin: .zero, size: pDFMaker.paperSize) // ここに印刷したいサイズを入れる
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
    
    @IBAction func tappedQLPreview(_ sender: Any) {
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        present(previewController, animated: true, completion: nil)
    }
    
}

/*
 `QLPreviewController` にPDFデータを提供する
 */

extension PDFMakerViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        
        if let PDFpath = pDFMaker.PDFpath {
            return PDFpath.count
        } else {
            return 0
        }
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        guard let pdfFilePath = pDFMaker.PDFpath?[index] else {
            return "" as! QLPreviewItem
        }
        return pdfFilePath as QLPreviewItem
    }
}
