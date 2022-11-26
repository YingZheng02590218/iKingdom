//
//  WSViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応

// 精算表クラス
class WSViewController: UIViewController, UIPrintInteractionControllerDelegate {

    // MARK: - var let

    @IBOutlet var gADBannerView: GADBannerView!
    /// 精算表　上部
    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    /// 精算表　下部
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: EMTNeumorphicView!
    
    let LIGHTSHADOWOPACITY: Float = 0.5
//    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
//    let edged = false

    fileprivate let refreshControl = UIRefreshControl()

    var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    /// GUIアーキテクチャ　MVP
    private var presenter: WSPresenterInput!
    func inject(presenter: WSPresenterInput) {
        self.presenter = presenter
    }
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = WSPresenter.init(view: self, model: WSModel())
        inject(presenter: presenter)
        
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        presenter.viewDidAppear()
    }
    
    override func viewDidLayoutSubviews() {
        // ボタン作成
        createButtons()
    }
    
    // MARK: - Setting

    // ボタンのデザインを指定する
    private func createButtons() {
        
        if let backgroundView = backgroundView {
            backgroundView.neumorphicLayer?.cornerRadius = 15
            backgroundView.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
            backgroundView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            backgroundView.neumorphicLayer?.edged = Constant.edged
            backgroundView.neumorphicLayer?.elementDepth = ELEMENTDEPTH
            backgroundView.neumorphicLayer?.elementBackgroundColor = UIColor.BaseColor.cgColor
            backgroundView.neumorphicLayer?.depthType = .convex
        }
    }
    
    private func setRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
    }
    
    // チュートリアル対応 コーチマーク型
    private func presentAnnotation() {
        //タブの無効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
            }
        }
        let viewController = UIStoryboard(name: "WSViewController", bundle: nil).instantiateViewController(withIdentifier: "Annotation_WorkSheet") as! AnnotationViewController
        viewController.alpha = 0.7
        present(viewController, animated: true, completion: nil)
    }
    
    func finishAnnotation() {
        //タブの有効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = true
                }
            }
        }
    }
    
    // MARK: - Action

    @objc private func refreshTable() {

        presenter.refreshTable()
    }
    
    var printing: Bool = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
    // 精算表画面で押下された場合は、決算整理仕訳とする
    @IBOutlet weak var barButtonItem_add: UIBarButtonItem!//ヘッダー部分の追加ボタン
    @IBOutlet var button_print: UIButton!
    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func button_print(_ sender: UIButton) {
        let indexPath = tableView.indexPathsForVisibleRows // テーブル上で見えているセルを取得する
        print("tableView.indexPathsForVisibleRows: \(String(describing: indexPath))")
//        self.        tableView.scrollToRow(at: indexPath![0], at: UITableView.ScrollPosition.bottom, animated: false)
        self.tableView.scrollToRow(at: IndexPath(row: indexPath!.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)// 一度最下行までレイアウトを描画させる
        printing = true
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        tableView.overrideUserInterfaceStyle = .light
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            if let gADBannerView = gADBannerView {
                gADBannerView.isHidden = true
            }
        }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする

        // 第三の方法
        //余計なUIをキャプチャしないように隠す
        tableView.showsVerticalScrollIndicator = false
        while self.tableView.indexPathForSelectedRow?.count ?? 0 > 0 {
            if let tappedIndexPath: IndexPath = self.tableView.indexPathForSelectedRow { // タップされたセルの位置を取得
                tableView.deselectRow(at: tappedIndexPath, animated: true)// セルの選択を解除
            }
        }
//            pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
//        pageSize = CGSize(width:         tableView.contentSize.width / 25.4 * 72, height:         tableView.contentSize.height / 25.4 * 72)
        pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
        print("TableView_WS.contentSize:\(tableView.contentSize)")
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
        let newImage = self.tableView.captureImagee()
        //4. UIGraphicsEndImageContextを呼び出してグラフィックススタックからコンテキストをポップします。
        UIGraphicsEndImageContext()
        printing = false
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            gADBannerView.isHidden = false
        }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)// 元の位置に戻す //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
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
//            UIGraphicsBeginPDFPage()
//        UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:0, width:myImageView.bounds.width, height:myImageView.bounds.width*1.414516129), nil) //高さはA4コピー用紙と同じ比率にするために、幅×1.414516129とする

         /* PDFページの描画
           UIGraphicsBeginPDFPageは、デフォルトのサイズを使用して新しいページを作成します。一方、
           UIGraphicsBeginPDFPageWithInfo関数を利用す ると、ページサイズや、PDFページのその他の属性をカスタマイズできます。
        */
        //p-49 「リスト 4-2 ページ単位のコンテンツの描画」
            // グラフィックスコンテキストを取得する
        // ビューイメージを全て印刷できるページ数を用意する
        var pageCounts: CGFloat = 0
        while myImageView.bounds.height > (myImageView.bounds.width*1.414516129) * pageCounts {
            //            if myImageView.bounds.height > (myImageView.bounds.width*1.414516129)*2 {
            UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:-(myImageView.bounds.width*1.414516129)*pageCounts, width:myImageView.bounds.width, height:myImageView.bounds.width*1.414516129), nil) //高さはA4コピー用紙と同じ比率にするために、幅×1.414516129とする
            // グラフィックスコンテキストを取得する
            guard let currentContext = UIGraphicsGetCurrentContext() else { return }
            myImageView.layer.render(in: currentContext)
            // ページを増加
            pageCounts += 1
        }
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
        tableView.showsVerticalScrollIndicator = true
        // ダークモード回避を解除
        tableView.overrideUserInterfaceStyle = .unspecified
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) // 元の位置に戻す
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
    
    // MARK: - Navigation

    // 画面遷移の準備　勘定科目画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue.destinationの型はUIViewController
        let controller = segue.destination as! JournalEntryViewController
        // 遷移先のコントローラに値を渡す
        controller.journalEntryType = "AdjustingAndClosingEntries" // セルに表示した仕訳タイプを取得
    }
}

extension WSViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return presenter.numberOfobjects + 1 + presenter.numberOfobjectss + 1 + 1  //+ 試算表合計の行の分+修正記入の行の分+当期純利益+修正記入、損益計算書、貸借対照表の合計の分
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セル　決算整理前残高試算表の行
        if indexPath.row < presenter.numberOfobjects {
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as! WSTableViewCell
            // 勘定科目をセルに表示する
            cell.label_account.text = "\(presenter.objects(forRow:indexPath.row).category as String)"
            cell.label_account.textAlignment = NSTextAlignment.center
            // 決算整理前残高試算表
            cell.label_debit.text = presenter.getTotalAmount(account: "\(presenter.objects(forRow:indexPath.row).category as String)", leftOrRight: 2)
            cell.label_debit.textAlignment = NSTextAlignment.right
            cell.label_credit.text = presenter.getTotalAmount(account: "\(presenter.objects(forRow:indexPath.row).category as String)", leftOrRight: 3)
            cell.label_credit.textAlignment = NSTextAlignment.right
            cell.label_debit.backgroundColor = .clear
            cell.label_credit.backgroundColor = .clear
            switch Int(presenter.objects(forRow:indexPath.row).Rank0) {
            case 0,1,2,3,4,5,12: //大分類　貸借対照表：0,1,2
                // 修正記入
                cell.label_debit1.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objects(forRow:indexPath.row).category as String)", leftOrRight: 0)
                cell.label_debit1.textAlignment = NSTextAlignment.right
                cell.label_credit1.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objects(forRow:indexPath.row).category as String)", leftOrRight: 1)
                cell.label_credit1.textAlignment = NSTextAlignment.right
                cell.label_debit1.backgroundColor = .clear
                cell.label_credit1.backgroundColor = .clear
                // 損益計算書
                cell.label_debit2.text = ""
                cell.label_credit2.text = ""
                cell.label_debit2.backgroundColor = .lightGray
                cell.label_credit2.backgroundColor = .lightGray
                // 貸借対照表 修正記入の分を差し引きして、表示する　WSModelを作成して処理を記述する
                cell.label_debit3.text = presenter.getTotalAmountAfterAdjusting(account: "\(presenter.objects(forRow:indexPath.row).category as String)", leftOrRight: 2)
                cell.label_debit3.textAlignment = NSTextAlignment.right
                cell.label_credit3.text = presenter.getTotalAmountAfterAdjusting(account: "\(presenter.objects(forRow:indexPath.row).category as String)", leftOrRight: 3)
                cell.label_credit3.textAlignment = NSTextAlignment.right
                cell.label_debit3.backgroundColor = .clear
                cell.label_credit3.backgroundColor = .clear
            case 6,7,8,9,10,11: //大分類 損益計算書：3,4
                // 修正記入
                cell.label_debit1.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objects(forRow:indexPath.row).category as String)", leftOrRight: 0)
                cell.label_debit1.textAlignment = NSTextAlignment.right
                cell.label_credit1.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objects(forRow:indexPath.row).category as String)", leftOrRight: 1)
                cell.label_credit1.textAlignment = NSTextAlignment.right
                cell.label_debit1.backgroundColor = .clear
                cell.label_credit1.backgroundColor = .clear
                // 損益計算書
                cell.label_debit2.text = presenter.getTotalAmountAfterAdjusting(account: "\(presenter.objects(forRow:indexPath.row).category as String)", leftOrRight: 2)
                cell.label_debit2.textAlignment = NSTextAlignment.right
                cell.label_credit2.text = presenter.getTotalAmountAfterAdjusting(account: "\(presenter.objects(forRow:indexPath.row).category as String)", leftOrRight: 3)
                cell.label_credit2.textAlignment = NSTextAlignment.right
                cell.label_debit2.backgroundColor = .clear
                cell.label_credit2.backgroundColor = .clear
                // 貸借対照表
                cell.label_debit3.text = ""
                cell.label_credit3.text = ""
                cell.label_debit3.backgroundColor = .lightGray
                cell.label_credit3.backgroundColor = .lightGray
            default: //大分類　貸借対照表：0,1,2 損益計算書：3,4
                print("a")
            }
            return cell
        }
        else if indexPath.row == presenter.numberOfobjects { // セル　試算表の合計の行
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS_total", for: indexPath) as! WSTableViewCell
            cell.label_account.text = ""
            // 決算整理前残高試算表
            cell.label_debit.text = presenter.debit_balance_total()
            cell.label_credit.text = presenter.credit_balance_total()
            return cell
        }else if indexPath.row < presenter.numberOfobjects + 1 + presenter.numberOfobjectss { // セル　修正記入の行
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as! WSTableViewCell
            // 勘定科目をセルに表示する
            cell.label_account.text = "\(presenter.objectss(forRow:indexPath.row-(presenter.numberOfobjects + 1)).category as String)"
            cell.label_account.textAlignment = NSTextAlignment.center
            // 決算整理前残高試算表
            cell.label_debit.text = ""
            cell.label_credit.text = ""
            cell.label_debit.backgroundColor = .lightGray
            cell.label_credit.backgroundColor = .lightGray
            switch Int(presenter.objectss(forRow:indexPath.row-(presenter.numberOfobjects + 1)).Rank2) {
            case 0,1,2,3,4,5,12: //大分類　貸借対照表：0,1,2
                // 修正記入
                cell.label_debit1.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow:indexPath.row-(presenter.numberOfobjects + 1)).category as String)", leftOrRight: 0)
                cell.label_debit1.textAlignment = NSTextAlignment.right
                cell.label_credit1.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow:indexPath.row-(presenter.numberOfobjects + 1)).category as String)", leftOrRight: 1)
                cell.label_credit1.textAlignment = NSTextAlignment.right
                cell.label_debit1.backgroundColor = .clear
                cell.label_credit1.backgroundColor = .clear
                // 損益計算書
                cell.label_debit2.text = ""
                cell.label_credit2.text = ""
                cell.label_debit2.backgroundColor = .clear
                cell.label_credit2.backgroundColor = .clear
                // 貸借対照表
                cell.label_debit3.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow:indexPath.row-(presenter.numberOfobjects + 1)).category as String)", leftOrRight: 2)
                cell.label_debit3.textAlignment = NSTextAlignment.right
                cell.label_credit3.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow:indexPath.row-(presenter.numberOfobjects + 1)).category as String)", leftOrRight: 3)
                cell.label_credit3.textAlignment = NSTextAlignment.right
                cell.label_debit3.backgroundColor = .clear
                cell.label_credit3.backgroundColor = .clear
            case 6,7,8,9,10,11: //大分類 損益計算書：3,4
                // 修正記入
                cell.label_debit1.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow:indexPath.row-(presenter.numberOfobjects + 1)).category as String)", leftOrRight: 0)
                cell.label_debit1.textAlignment = NSTextAlignment.right
                cell.label_credit1.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow:indexPath.row-(presenter.numberOfobjects + 1)).category as String)", leftOrRight: 1)
                cell.label_credit1.textAlignment = NSTextAlignment.right
                cell.label_debit1.backgroundColor = .clear
                cell.label_credit1.backgroundColor = .clear
                // 損益計算書
                cell.label_debit2.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow:indexPath.row-(presenter.numberOfobjects + 1)).category as String)", leftOrRight: 2)
                cell.label_debit2.textAlignment = NSTextAlignment.right
                cell.label_credit2.text = presenter.getTotalAmountAdjusting(account: "\(presenter.objectss(forRow:indexPath.row-(presenter.numberOfobjects + 1)).category as String)", leftOrRight: 3)
                cell.label_credit2.textAlignment = NSTextAlignment.right
                cell.label_debit2.backgroundColor = .clear
                cell.label_credit2.backgroundColor = .clear
                // 貸借対照表
                cell.label_debit3.text = ""
                cell.label_credit3.text = ""
                cell.label_debit3.backgroundColor = .clear
                cell.label_credit3.backgroundColor = .clear
            default: //大分類　貸借対照表：0,1,2 損益計算書：3,4
                print("aa")
            }
            return cell
        }else if indexPath.row < presenter.numberOfobjects + 1 + presenter.numberOfobjectss + 1  { // セル　当期純利益の行
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as! WSTableViewCell
            // 勘定科目をセルに表示する
            cell.label_account.text = "当期純利益"
            cell.label_account.textAlignment = NSTextAlignment.center
            // 決算整理前残高試算表
            cell.label_debit.text = ""
            cell.label_credit.text = ""
            cell.label_debit.backgroundColor = .lightGray
            cell.label_credit.backgroundColor = .lightGray
            // 修正記入
            cell.label_debit1.text = ""
            cell.label_credit1.text = ""
            cell.label_debit1.backgroundColor = .clear
            cell.label_credit1.backgroundColor = .clear
            // 損益計算書
            cell.label_debit2.text = presenter.netIncomeOrNetLossLoss()//0でも空白にしない
            cell.label_debit2.textAlignment = NSTextAlignment.right
            cell.label_credit2.text = presenter.netIncomeOrNetLossIncome()//0でも空白にしない
            cell.label_credit2.textAlignment = NSTextAlignment.right
            cell.label_debit2.backgroundColor = .clear
            cell.label_credit2.backgroundColor = .clear
            // 貸借対照表
            cell.label_debit3.text = presenter.netIncomeOrNetLossIncome()//0でも空白にしない //損益計算書とは反対の方に記入する//0でも空白にしない
            cell.label_debit3.textAlignment = NSTextAlignment.right
            cell.label_credit3.text = presenter.netIncomeOrNetLossLoss()//0でも空白にしない //損益計算書とは反対の方に記入する//0でも空白にしない
            cell.label_credit3.textAlignment = NSTextAlignment.right
            cell.label_debit3.backgroundColor = .clear
            cell.label_credit3.backgroundColor = .clear
            return cell
        }else if indexPath.row < presenter.numberOfobjects + 1 + presenter.numberOfobjectss + 1 + 1 { // セル　修正記入と損益計算書、貸借対照表の合計の行
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_WS_total_2", for: indexPath) as! WSTableViewCell
            cell.label_account.text = ""
            // 決算整理前残高試算表
            cell.label_debit.text = ""
            cell.label_credit.text = ""
            cell.label_debit.backgroundColor = .lightGray
            cell.label_credit.backgroundColor = .lightGray
            // 修正記入
            cell.label_debit1.text = presenter.debit_adjustingEntries_total_total() // 残高ではなく合計
            cell.label_debit1.textAlignment = NSTextAlignment.right
            cell.label_credit1.text = presenter.credit_adjustingEntries_total_total() // 残高ではなく合計
            cell.label_credit1.textAlignment = NSTextAlignment.right
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.label_debit1.text != cell.label_credit1.text {
                cell.label_debit1.textColor = .red
                cell.label_credit1.textColor = .red
            }
            // 損益計算書
            cell.label_debit2.text = presenter.debit_PL_balance_total()// 当期純利益と合計借方とを足す
            cell.label_debit2.textAlignment = NSTextAlignment.right
            cell.label_credit2.text = presenter.credit_PL_balance_total()// 当期純損失と合計貸方とを足す
            cell.label_credit2.textAlignment = NSTextAlignment.right
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.label_debit2.text != cell.label_credit2.text {
                cell.label_debit2.textColor = .red
                cell.label_credit2.textColor = .red
            }
            // 貸借対照表
            cell.label_debit3.text = presenter.debit_BS_balance_total() //損益計算書とは反対の方に記入する
            cell.label_debit3.textAlignment = NSTextAlignment.right
            cell.label_credit3.text = presenter.credit_BS_balance_total() //損益計算書とは反対の方に記入する
            cell.label_credit3.textAlignment = NSTextAlignment.right
            // 借方貸方の金額が不一致の場合、文字色を赤
            if cell.label_debit3.text != cell.label_credit3.text {
                cell.label_debit3.textColor = .red
                cell.label_credit3.textColor = .red
            }
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "cell_WS", for: indexPath) as! WSTableViewCell
    }
}

extension WSViewController: WSPresenterOutput {

    func reloadData() {
        // 更新処理
        tableView.reloadData()
        // クルクルを止める
        refreshControl.endRefreshing()
    }
    
    func setupViewForViewDidLoad() {
        // UI
//        setTableView()
        createButtons() // ボタン作成
        setRefreshControl()
        // TODO: 印刷機能を一時的に蓋をする。あらためてHTMLで作る。 印刷ボタンを定義
//        let printoutButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(button_print))
//        //ナビゲーションに定義したボタンを置く
//        self.navigationItem.rightBarButtonItem = printoutButton
        button_print.isHidden = true
        self.navigationItem.title = "精算表"
    }
    
    func setupViewForViewWillAppear() {
        
        if let company = presenter.company {
            // 月末、年度末などの決算日をラベルに表示する
            label_company_name.text = company // 社名
        }
        if let theDayOfReckoning = presenter.theDayOfReckoning {
            if let fiscalYear = presenter.fiscalYear {
                if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                    label_closingDate.text = String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
                }
                else {
                    label_closingDate.text = String(fiscalYear+1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
                }
            }
        }
        label_title.text = "精算表"
        label_title.font = UIFont.boldSystemFont(ofSize: 18)
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
    //        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize:kGADAdSizeLargeBanner)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOB_ID
            
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: (self.tableView.visibleCells[self.tableView.visibleCells.count-3].frame.height + self.tableView.visibleCells[self.tableView.visibleCells.count-2].frame.height + self.tableView.visibleCells[self.tableView.visibleCells.count-1].frame.height) * -1) // 一番したから3行分のスペースを空ける
        }
        else {
            if let gADBannerView = gADBannerView {
                gADBannerView.isHidden = true
            }
        }
        // ナビゲーションを透明にする処理
        if let navigationController = self.navigationController {
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController.navigationBar.shadowImage = UIImage()
        }
    }
    
    func setupViewForViewDidAppear() {
        // チュートリアル対応 コーチマーク型　初回起動時　7行を追加
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch_WorkSheet"
        if ud.bool(forKey: firstLunchKey) {
            ud.set(false, forKey: firstLunchKey)
            ud.synchronize()
            // チュートリアル対応 コーチマーク型
            presentAnnotation()
        }
        else {
            // チュートリアル対応 コーチマーク型
            finishAnnotation()
        }
    }
    
}
