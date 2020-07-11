//
//  ViewControllerWS.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 精算表クラス
class ViewControllerWS: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPrintInteractionControllerDelegate {

    @IBOutlet weak var view_top: UIView!
    @IBOutlet weak var TableView_WS: UITableView!
    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TableView_WS.delegate = self
        TableView_WS.dataSource = self
        
        let databaseManager = DataBaseManagerTB() //データベースマネジャー
        databaseManager.culculatAmountOfAllAccount()
        // 月末、年度末などの決算日をラベルに表示する
        let dataBaseManagerAccountingBooksShelf = DataBaseManagerAccountingBooksShelf() //データベースマネジャー
        let company = dataBaseManagerAccountingBooksShelf.getCompany()
        label_company_name.text = company // 社名
//        label_closingDate.text = "令和xx年3月31日"
        let dataBaseManagerPeriod = DataBaseManagerPeriod() //データベースマネジャー
        let fiscalYear = dataBaseManagerPeriod.getSettingsPeriodYear()
        // ToDo どこで設定した年度のデータを参照するか考える
        label_closingDate.text = fiscalYear.description + "年3月31日" // 決算日を表示する
        label_title.text = "精算表"
    }
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = databaseManagerSettings.getAllSettingsCategory()
        return objects.count + 1 //合計額の行の分
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        let objects = databaseManagerSettings.getAllSettingsCategory()
        let databaseManager = DataBaseManagerTB() //データベースマネジャー

        if indexPath.row < objects.count {
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as! TableViewCellWS
            // 勘定科目をセルに表示する
            //        cell.textLabel?.text = "\(objects[indexPath.row].category as String)"
            cell.label_account.text = "\(objects[indexPath.row].category as String)"
            cell.label_account.textAlignment = NSTextAlignment.center
//            switch segmentedControl_switch.selectedSegmentIndex {
//            case 0: // 合計　借方
//                cell.label_debit.text = databaseManager.setComma(amount: databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 0))
//                    // 合計　貸方
//                cell.label_credit.text = databaseManager.setComma(amount:databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 1))
//                break
//            case 1: // 残高　借方
//                cell.label_debit.text = databaseManager.setComma(amount:databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 2))
//                    // 残高　貸方
//                cell.label_credit.text = databaseManager.setComma(amount:databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 3))
//                break
//            default:
//                print("cell_WS")
//            }
            return cell
        }else {
            let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
            let object = dataBaseManagerFinancialStatements.getFinancialStatements()
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as! TableViewCellWS
////            let r = 0
////            switch r {
//            switch segmentedControl_switch.selectedSegmentIndex {
//            case 0: // 合計　借方
//                cell.label_debit.text = databaseManager.setComma(amount: object.compoundTrialBalance!.debit_total_total)
//                    // 合計　貸方
//                cell.label_credit.text = databaseManager.setComma(amount: object.compoundTrialBalance!.credit_total_total)
//                break
//            case 1: // 残高　借方
//                cell.label_debit.text = databaseManager.setComma(amount:object.compoundTrialBalance!.debit_balance_total)
//                    // 残高　貸方
//                cell.label_credit.text = databaseManager.setComma(amount:object.compoundTrialBalance!.credit_balance_total)
//                break
//            default:
//                print("cell_last_TB")
//            }
            return cell
        }
    }
    var printing: Bool = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
    // disable sticky section header
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if printing {
            print("navigationController!.navigationBar.bounds.height : \(self.navigationController!.navigationBar.bounds.height)")
            print("scrollView.contentOffset.y   : \(scrollView.contentOffset.y)")
            print("scrollView.contentInset      : \(scrollView.contentInset)")
            print("view_top.bounds.height       : \(view_top.bounds.height)")
            print("TableView_TB.bounds.height   : \(TableView_WS.bounds.height)")
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // ここがポイント。画面表示用にインセットを設定した、ステータスバーとナビゲーションバーの高さの分をリセットするために0を設定する。
            // スクロールのオフセットがヘッダー部分のビューとステータスバーの高さ以上　かつ　0以上
            if scrollView.contentOffset.y >= view_top.bounds.height+UIApplication.shared.statusBarFrame.height && scrollView.contentOffset.y >= 0 {
                scrollView.contentInset = UIEdgeInsets(top: -(view_top.bounds.height+UIApplication.shared.statusBarFrame.height+TableView_WS.sectionHeaderHeight), left: 0, bottom: 0, right: 0)
            }
        }else{
            // インセットを設定する　ステータスバーとナビゲーションバーより下からテーブルビューを配置するため
//            scrollView.contentInset = UIEdgeInsets(top: +self.navigationController!.navigationBar.bounds.height+UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
//            if scrollView.contentOffset.y <= view_top.bounds.height && scrollView.contentOffset.y >= 0 { // スクロールがview高さ以上かつ0以上
//                scrollView.contentInset = UIEdgeInsets(top: scrollView.contentOffset.y * -1, left: 0, bottom: 0, right: 0)
//            }else if scrollView.contentOffset.y >= 0 { // viewの重複を防ぐ scrollView.contentOffset.y >= view_top.bounds.height &&
////                scrollView.contentInset = UIEdgeInsets(top: (view_top.bounds.height) * -1, left: 0, bottom: 0, right: 0)//[TableView] Warning once only: UITableView was told to layout its visible cells and other contents without being in the view hierarchy
////                scrollView.contentInset = UIEdgeInsets(top: scrollView.contentOffset.y * -1, left: 0, bottom: 0, right: 0)//注意：view_top.bounds.heightを指定するとテーブルの最下行が表示されなくなる
//                scrollView.contentInset = UIEdgeInsets(top: (scrollView.contentOffset.y-self.navigationController!.navigationBar.bounds.height) * -1, left: 0, bottom: 0, right: 0)
////                        let edgeInsets = UIEdgeInsets(top: self.navigationController!.navigationBar.bounds.height, left: 0, bottom: 0, right: 0)
////                        TableView_TB.contentInset = edgeInsets
////                        TableView_TB.scrollIndicatorInsets = edgeInsets
//            }else if scrollView.contentOffset.y >= 0{//view_top.bounds.height {
//    //            scrollView.contentInset = UIEdgeInsets(top: (tableView.sectionHeaderHeight+scrollView.contentOffset.y) * -1, left: 0, bottom: 0, right: 0)
//                scrollView.contentInset = UIEdgeInsets(top: scrollView.contentOffset.y * -1, left: 0, bottom: 0, right: 0)
//            }
//            print("navigationController!.navigationBar.bounds.height : \(self.navigationController!.navigationBar.bounds.height)")
//            print("scrollView.contentOffset.y   :: \(scrollView.contentOffset.y)")
//            print("scrollView.contentInset      :: \(scrollView.contentInset)")
//            print("view_top.bounds.height       :: \(view_top.bounds.height)")
//            print("TableView_TB.bounds.height   :: \(TableView_WS.bounds.height)")
//        }else{
//            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        }
    }
    var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    @IBOutlet var button_print: UIButton!
    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func button_print(_ sender: UIButton) {
        printing = true
        let indexPath = TableView_WS.indexPathsForVisibleRows // テーブル上で見えているセルを取得する
        print("TableView_TB.indexPathsForVisibleRows: \(indexPath)")
//        self.TableView_TB.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.bottom, animated: false)
        self.TableView_WS.scrollToRow(at: IndexPath(row: indexPath!.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)// 一度最下行までレイアウトを描画させる
        self.TableView_WS.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする

        // 第三の方法
        //余計なUIをキャプチャしないように隠す
        TableView_WS.showsVerticalScrollIndicator = false
//            pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
//        pageSize = CGSize(width: TableView_TB.contentSize.width / 25.4 * 72, height: TableView_TB.contentSize.height / 25.4 * 72)
        pageSize = CGSize(width: TableView_WS.contentSize.width, height: TableView_WS.contentSize.height)
        print("TableView_TB.contentSize:\(TableView_WS.contentSize)")
        //viewと同じサイズのコンテキスト（オフスクリーンバッファ）を作成
//        var rect = self.view.bounds
        //p-41 「ビットマップグラフィックスコンテキストを使って新しい画像を生成」
        //1. UIGraphicsBeginImageContextWithOptions関数でビットマップコンテキストを生成し、グラフィックススタックにプッシュします。
        UIGraphicsBeginImageContextWithOptions(pageSize, true, 0.0)
            //2. UIKitまたはCore Graphicsのルーチンを使って、新たに生成したグラフィックスコンテキストに画像を描画します。
//        imageRect.draw(in: CGRect(origin: .zero, size: pageSize))
            //3. UIGraphicsGetImageFromCurrentImageContext関数を呼び出すと、描画した画像に基づく UIImageオブジェクトが生成され、返されます。必要ならば、さらに描画した上で再びこのメソッ ドを呼び出し、別の画像を生成することも可能です。
        //p-43 リスト 3-1 縮小画像をビットマップコンテキストに描画し、その結果の画像を取得する
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let newImage = self.TableView_WS.captureImagee()
//        let indexPath = TableView_TB.indexPathsForVisibleRows // テーブル上で見えているセルを取得する
//        print("TableView_TB.indexPathsForVisibleRows: \(indexPath)")
//        self.TableView_TB.scrollToRow(at: IndexPath(row: indexPath!.count-1, section: 0), at: UITableView.ScrollPosition.top, animated: false)
//        let newImage = self.TableView_TB.getContentImage(captureSize: pageSize)
        //4. UIGraphicsEndImageContextを呼び出してグラフィックススタックからコンテキストをポップします。
        UIGraphicsEndImageContext()
        printing = false
        self.TableView_WS.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)// 元の位置に戻す //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
        /*
        ビットマップグラフィックスコンテキストでの描画全体にCore Graphicsを使用する場合は、
         CGBitmapContextCreate関数を使用して、コンテキストを作成し、
         それに画像コンテンツを描画します。
         描画が完了したら、CGBitmapContextCreateImage関数を使用し、そのビットマップコンテキストからCGImageRefを作成します。
         Core Graphicsの画像を直接描画したり、この画像を使用して UIImageオブジェクトを初期化することができます。
         完了したら、グラフィックスコンテキストに対 してCGContextRelease関数を呼び出します。
        */
        let myImageView = UIImageView(image: newImage)
        myImageView.layer.position = CGPoint(x: self.view.frame.midY, y: self.view.frame.midY)
        
//PDF
        //p-49 リスト 4-2 ページ単位のコンテンツの描画
            let framePath = NSMutableData()
        //p-45 「PDFコンテキストの作成と設定」
            // PDFグラフィックスコンテキストは、UIGraphicsBeginPDFContextToData関数、
            //  または UIGraphicsBeginPDFContextToFile関数のいずれかを使用して作成します。
            //  UIGraphicsBeginPDFContextToData関数の場合、
            //  保存先はこの関数に渡される NSMutableDataオブジェクトです。
            UIGraphicsBeginPDFContextToData(framePath, myImageView.bounds, nil)
        print(" myImageView.bounds : \(myImageView.bounds)")
        //p-46 「UIGraphicsBeginPDFPage関数は、デフォルトのサイズを使用してページを作成します。」
            UIGraphicsBeginPDFPage()
         /* PDFページの描画
           UIGraphicsBeginPDFPageは、デフォルトのサイズを使用して新しいページを作成します。一方、
           UIGraphicsBeginPDFPageWithInfo関数を利用す ると、ページサイズや、PDFページのその他の属性をカスタマイズできます。
        */
        //p-49 「リスト 4-2 ページ単位のコンテンツの描画」
            // グラフィックスコンテキストを取得する
            guard let currentContext = UIGraphicsGetCurrentContext() else { return }
            myImageView.layer.render(in: currentContext)
            //描画が終了したら、UIGraphicsEndPDFContextを呼び出して、PDFグラフィックスコンテキストを閉じます。
            UIGraphicsEndPDFContext()
            
//ここからプリントです
        //p-63 リスト 5-1 ページ範囲の選択が可能な単一のPDFドキュメント
        let pic = UIPrintInteractionController.shared
        if UIPrintInteractionController.canPrint(framePath as Data) {
            //pic.delegate = self;
            pic.delegate = self
            
            let printInfo = UIPrintInfo.printInfo()
            printInfo.outputType = .general
            printInfo.jobName = "Work Sheet"
            printInfo.duplex = .none
            pic.printInfo = printInfo
            //'showsPageRange' was deprecated in iOS 10.0: Pages can be removed from the print preview, so page range is always shown.
            pic.printingItem = framePath
    
            let completionHandler: (UIPrintInteractionController, Bool, NSError) -> Void = { (pic: UIPrintInteractionController, completed: Bool, error: Error?) in
                
                if !completed && (error != nil) {
                    print("FAILED! due to error in domain %@ with error code %u \(String(describing: error))")
                }
            }
            //p-79 印刷インタラクションコントローラを使って印刷オプションを提示
            //UIPrintInteractionControllerには、ユーザに印刷オプションを表示するために次の3つのメソッ ドが宣言されており、それぞれアニメーションが付属しています。
            if UIDevice.current.userInterfaceIdiom == .pad {
                //これらのうちの2つは、iPadデバイス上で呼び出されることを想定しています。
                //・presentFromBarButtonItem:animated:completionHandler:は、ナビゲーションバーまたは ツールバーのボタン(通常は印刷ボタン)からアニメーションでPopover Viewを表示します。
//                print("通過・printButton.frame -> \(button_print.frame)")
//                print("通過・printButton.bounds -> \(button_print.bounds)")
                //UIBarButtonItemの場合
                //pic.present(from: printUIButton, animated: true, completionHandler: nil)
                //・presentFromRect:inView:animated:completionHandler:は、アプリケーションのビューの任意の矩形からアニメーションでPopover Viewを表示します。
                pic.present(from: CGRect(x: 0, y: 0, width: 0, height: 0), in: self.view, animated: true, completionHandler: nil)
                print("iPadです")
            } else {
                //モーダル表示
                //・presentAnimated:completionHandler:は、画面の下端からスライドアップするページをアニ メーション化します。これはiPhoneおよびiPod touchデバイス上で呼び出されることを想定しています。
                pic.present(animated: true, completionHandler: completionHandler as? UIPrintInteractionController.CompletionHandler)
                print("iPhoneです")
            }
        }
        //余計なUIをキャプチャしないように隠したのを戻す
        TableView_WS.showsVerticalScrollIndicator = true
        self.TableView_WS.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) // 元の位置に戻す
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
        print(" pageSizeピクセル    -> \(pageSize)")
        let bestPaper = UIPrintPaper.bestPaper(forPageSize: pageSize, withPapersFrom: paperList)
        //mmで用紙サイズと印刷可能範囲を表示
        print(" paperSizeミリ      -> \(bestPaper.paperSize.width / 72.0 * 25.4), \(bestPaper.paperSize.height / 72.0 * 25.4)")
        print(" bestPaper         -> \(bestPaper.printableRect.origin.x / 72.0 * 25.4), \(bestPaper.printableRect.origin.y / 72.0 * 25.4), \(bestPaper.printableRect.size.width / 72.0 * 25.4), \(bestPaper.printableRect.size.height / 72.0 * 25.4)\n")
        return bestPaper
    }

}

