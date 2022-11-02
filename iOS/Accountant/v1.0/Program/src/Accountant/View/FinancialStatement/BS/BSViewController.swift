//
//  BSViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/01/28.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import UIKit
import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応
import AudioToolbox // 効果音

class BSViewController: UIViewController, UIPrintInteractionControllerDelegate {

    // MARK: - var let

    @IBOutlet var gADBannerView: GADBannerView!
    /// 貸借対照表　上部
    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    @IBOutlet var label_closingDate_previous: UILabel!
    @IBOutlet var label_closingDate_thisYear: UILabel!
    /// 貸借対照表　下部
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: EMTNeumorphicView!
    
    let LIGHTSHADOWOPACITY: Float = 0.5
    
    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
    let edged = false

    fileprivate let refreshControl = UIRefreshControl()
    
    var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    /// GUIアーキテクチャ　MVP
    private var presenter: BSPresenterInput!
    func inject(presenter: BSPresenterInput) {
        self.presenter = presenter
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = BSPresenter.init(view: self, model: BSModel())
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
    
    private func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "BSTableViewCell", bundle: nil), forCellReuseIdentifier: "BSTableViewCell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    // ボタンのデザインを指定する
    private func createButtons() {
        
        if let backgroundView = backgroundView {
            backgroundView.neumorphicLayer?.cornerRadius = 15
            backgroundView.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
            backgroundView.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
            backgroundView.neumorphicLayer?.edged = edged
            backgroundView.neumorphicLayer?.elementDepth = ELEMENTDEPTH
            backgroundView.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
            backgroundView.neumorphicLayer?.depthType = .convex
        }
    }
    
    private func setRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTable), for: UIControl.Event.valueChanged)
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView, constant: CGFloat) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bannerView)
      view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: constant),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
     }
    
    // MARK: - Action
    
    @objc private func refreshTable() {
        
        presenter.refreshTable()
    }
    
    var printing: Bool = false { // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
        didSet(oldValue){
            if !(oldValue) {
//                if self.overrideUserInterfaceStyle != .light  {
//                    // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
//                    tableView.overrideUserInterfaceStyle = .light
//                }
//            }else {
//                // ダークモード回避を解除
//                tableView.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    /**
     * 印刷ボタン押下時メソッド
     */
    @objc private func button_print() {
        printing = true
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        tableView.overrideUserInterfaceStyle = .light
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            if let gADBannerView = gADBannerView {
                gADBannerView.isHidden = true
            }
        }
        // 第三の方法
        //余計なUIをキャプチャしないように隠す
        tableView.showsVerticalScrollIndicator = false
        while self.tableView.indexPathForSelectedRow?.count ?? 0 > 0 {
            if let tappedIndexPath: IndexPath = self.tableView.indexPathForSelectedRow { // タップされたセルの位置を取得
                tableView.deselectRow(at: tappedIndexPath, animated: true)// セルの選択を解除
            }
        }
//        CGRectMake(0, 0, tableView.contentSize.width, tableView.contentSize.height)
        //A4, 210x297mm, 8.27x11.68インチ,595x841ピクセル
        pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
        //viewと同じサイズのコンテキスト（オフスクリーンバッファ）を作成
//        var rect = self.view.bounds
        //p-41 「ビットマップグラフィックスコンテキストを使って新しい画像を生成」
        //1. UIGraphicsBeginImageContextWithOptions関数でビットマップコンテキストを生成し、グラフィックススタックにプッシュします。
        UIGraphicsBeginImageContextWithOptions(pageSize, false, 0.0)
        //2. UIKitまたはCore Graphicsのルーチンを使って、新たに生成したグラフィックスコンテキストに画像を描画します。
//        imageRect.draw(in: CGRect(origin: .zero, size: pageSize))
        //3. UIGraphicsGetImageFromCurrentImageContext関数を呼び出すと、描画した画像に基づく UIImageオブジェクトが生成され、返されます。必要ならば、さらに描画した上で再びこのメソッ ドを呼び出し、別の画像を生成することも可能です。
        //p-43 リスト 3-1 縮小画像をビットマップコンテキストに描画し、その結果の画像を取得する
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let newImage = self.tableView.captureImagee()
        //4. UIGraphicsEndImageContextを呼び出してグラフィックススタックからコンテキストをポップします。
        UIGraphicsEndImageContext()
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            gADBannerView.isHidden = false
        }
        /*
        ビットマップグラフィックスコンテキストでの描画全体にCore Graphicsを使用する場合は、
         CGBitmapContextCreate関数を使用して、コンテキストを作成し、
         それに画像コンテンツを描画します。
         描画が完了したら、CGBitmapContextCreateImage関数を使用し、そのビットマップコンテキストからCGImageRefを作成します。
         Core Graphicsの画像を直接描画したり、この画像を使用して UIImageオブジェクトを初期化することができます。
         完了したら、グラフィックスコンテキストに対 してCGContextRelease関数を呼び出します。
        */
        let myImageView = UIImageView(image: newImage)
        myImageView.layer.position = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
//PDF
        //p-49 リスト 4-2 ページ単位のコンテンツの描画
            let framePath = NSMutableData()
        //p-45 「PDFコンテキストの作成と設定」
            // PDFグラフィックスコンテキストは、UIGraphicsBeginPDFContextToData関数、
            //  または UIGraphicsBeginPDFContextToFile関数のいずれかを使用して作成します。
            //  UIGraphicsBeginPDFContextToData関数の場合、
            //  保存先はこの関数に渡される NSMutableDataオブジェクトです。
            UIGraphicsBeginPDFContextToData(framePath, myImageView.bounds, nil)
        //p-46 「UIGraphicsBeginPDFPage関数は、デフォルトのサイズを使用してページを作成します。」
//            UIGraphicsBeginPDFPage()
        // 新しいページを開始する
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
            printInfo.jobName = "Balance Sheet"
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
        printing = false
        //余計なUIをキャプチャしないように隠したのを戻す
        tableView.showsVerticalScrollIndicator = true
        // ダークモード回避を解除
        tableView.overrideUserInterfaceStyle = .unspecified
    }
    /**
     * 印刷メソッド
     */
    private func printToPrinter(printer: UIPrinter) {
        //　プリント設定を行う
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "Accounting Print"
        printInfo.orientation = .portrait
        printInfo.outputType = .grayscale
        // プリンターコントローラーを生成
        let printInteractionController = UIPrintInteractionController.shared
        printInteractionController.printInfo = printInfo
        // 印刷内容設定
        //  (a) 画像もしくはPDFに変換する この方法では画面上に写っている範囲のみ印刷可能
//        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0);
//        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        printInteractionController.printingItem = image
        //  (b) printPageRendererを設定する
        //printInteractionController.printingItem = view.viewPrintFormatter()//UIImage(named: "flower.jpg")
        let viewPrintFormatter = view.viewPrintFormatter()
        let renderer = PrintPageRendererBS()
//        let renderer = UIPrintPageRenderer()
//        let renderer = UISimpleTextPrintFormatter() //プレインテキストドキュメントを自動的に描画、レイアウト します。テキストのグローバルプロパティ(フォント、色、配置、改行モードなど)も設定でき ます。
        //renderer.jobTitle = printInfo.jobName
        renderer.addPrintFormatter(viewPrintFormatter, startingAtPageAt: 0)
        printInteractionController.printPageRenderer = renderer

        printInteractionController.print(to: printer) { (controller:UIPrintInteractionController, completed:Bool, error:Error?) in
            if error == nil {
                print("Print Completed.")
            }
        }
//        printInteractionController.print(to: printer, completionHandler: {
//            controller, completed, error in
//        })
        
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

extension BSViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // 資産の部、負債の部、純資産の部
        return 3
    }
    // セクションヘッダーの高さを決める
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35 //セクションヘッダーの高さを設定　セルの高さより高くしてメリハリをつける セル(Row Hight 30)
    }
    // セクションヘッダーの色とか調整する
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .TextColor
        header.textLabel?.textAlignment = .left
        // システムフォントのサイズを設定
        header.textLabel?.font = UIFont.systemFont(ofSize: 17)
    }
    // セクションヘッダーのテキスト決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "資産の部"
        case 1:
            return "負債の部"
        case 2:
            return "純資産の部"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            // 大分類のタイトルはセクションヘッダーに表示する
        case 0://資産の部
            print("資産の部", 1 + 6 + 3 +
                  presenter.numberOfobjects0100 +
                  presenter.numberOfobjects0102 +
                  presenter.numberOfobjects010142 +
                  presenter.numberOfobjects010143 +
                  presenter.numberOfobjects010144 )
            return 1 + 6 + 3 +
            presenter.numberOfobjects0100 +
            presenter.numberOfobjects0102 +
            presenter.numberOfobjects010142 +
            presenter.numberOfobjects010143 +
            presenter.numberOfobjects010144 // 大分類合計1・中分類(タイトル、合計)6・小分類(タイトル、合計)6・表示科目の数
        case 1://負債の部
            print("負債の部", 1 + 4 +
                  presenter.numberOfobjects0114 +
                  presenter.numberOfobjects0115 )
            return 1 + 4 +
            presenter.numberOfobjects0114 +
            presenter.numberOfobjects0115
        case 2://純資産の部
            print("純資産の部", 1 + 4 + 0 +
                  presenter.numberOfobjects0129 +
                  presenter.numberOfobjects01210 +
                  presenter.numberOfobjects01211 +
                  presenter.numberOfobjects01213 + 1)
            return 1 + 4 + 0 +
            presenter.numberOfobjects0129 +
            presenter.numberOfobjects01210 +
            presenter.numberOfobjects01211 +
            presenter.numberOfobjects01213 + 1 //+1は、負債純資産合計　の分
        default:
            print("default")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 22
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BSTableViewCell", for: indexPath) as! BSTableViewCell
        cell.labelForThisYear.font = UIFont.systemFont(ofSize: 14)
        cell.labelForPrevious.font = UIFont.systemFont(ofSize: 14)
        cell.labelForThisYear.attributedText = nil
        cell.labelForPrevious.attributedText = nil
        
        switch indexPath.section { // 大区分
        case 0: // MARK: - 資産の部
            
            switch indexPath.row { // 中区分
            case 0:
                // MARK: - "  流動資産"
                cell.textLabel?.text = "  流動資産" // 注意：UITableViewCell内のViewに表示している。AttributesInspectorでHiddenをONにすると見えなくなる。
                print("BS", indexPath.row, "  流動資産"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0100 + 1: // 中区分タイトルの分を1行追加　流動資産に属する勘定科目の数
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    流動資産合計"
                cell.textLabel?.text = "    流動資産合計"
                print("BS", indexPath.row, "    流動資産合計"+"★")
                let text:String = presenter.getTotalRank0(big5: indexPath.section, rank0: 0, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank0(big5: indexPath.section, rank0: 0, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.labelForPrevious.attributedText = attributeTextt
                return cell
            case presenter.numberOfobjects0100 + 1 + 1:
                // MARK: - "  固定資産"
                cell.textLabel?.text = "  固定資産"
                print("BS", indexPath.row, "  固定資産"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
// 小区分
                // MARK: - 有形固定資産3
            case presenter.numberOfobjects0100 + 1 + 1 + 1: // 112
                cell.textLabel?.text = "        "+translateSmallCategory(small_category: 3)
                print("BS", indexPath.row, "        "+translateSmallCategory(small_category: 3)+"★")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                return cell
                // MARK: - 無形固定資産
            case presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1:
                cell.textLabel?.text = "        "+translateSmallCategory(small_category: 4)
                print("BS", indexPath.row, "        "+translateSmallCategory(small_category: 4)+"★")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                return cell
                // MARK: - 投資その他資産　投資その他の資産
            case presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1:
                cell.textLabel?.text = "        "+translateSmallCategory(small_category: 5)
                print("BS", indexPath.row, "        "+translateSmallCategory(small_category: 5)+"★")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144 + 1: //最後の行の前
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    固定資産合計"
                cell.textLabel?.text = "    固定資産合計"
                print("BS", indexPath.row, "    固定資産合計"+"★")
                let text:String = presenter.getTotalRank0(big5: indexPath.section, rank0: 1, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank0(big5: indexPath.section, rank0: 1, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.labelForPrevious.attributedText = attributeTextt
                return cell
            case presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144 + 1 + 1:
                // MARK: - "  繰越資産"
                cell.textLabel?.text = "  繰越資産"
                print("BS", indexPath.row, "  繰越資産"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144 + 1 + 1 + presenter.numberOfobjects0102 + 1:
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    繰越資産合計"
                cell.textLabel?.text = "    繰越資産合計"
                print("BS", indexPath.row, "    繰越資産合計"+"★")
                let text:String = presenter.getTotalRank0(big5: indexPath.section, rank0: 2, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank0(big5: indexPath.section, rank0: 2, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.labelForPrevious.attributedText = attributeTextt
                return cell
            case presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144 + 1 + 1 + presenter.numberOfobjects0102 + 1 + 1: //最後の行
                // MARK: - "資産合計"
                cell.textLabel?.text = "資産合計"
                print("BS", indexPath.row, "資産合計"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                let text:String = presenter.getTotalBig5(big5: 0, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalBig5(big5: 0, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.labelForPrevious.attributedText = attributeTextt
                cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
                // 資産合計と純資産負債合計の金額が不一致の場合、文字色を赤
                if presenter.getTotalBig5(big5: 0, lastYear: false) != presenter.getTotalBig5(big5: 3, lastYear: false) {
                    cell.labelForThisYear.textColor = .red
                }else {
                    
                }
                return cell
            default:
// 勘定科目
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                if       indexPath.row >= 1 &&                           // 流動資産タイトルの1行下 中区分タイトルより下の行から、中区分合計の行より上
                            indexPath.row <  presenter.numberOfobjects0100 + 1 + 1 {   // 流動資産合計　　　　中区分タイトル + 流動資産 + 合計
                    cell.textLabel?.text = "        "+presenter.objects0100(forRow: indexPath.row-(1)).category
                    print("BS", indexPath.row, "        "+presenter.objects0100(forRow: indexPath.row-(1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0100(forRow: indexPath.row-(1 )).number, lastYear: false) // 勘定別の合計　計算
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0100(forRow: indexPath.row-(1 )).number, lastYear: true) // 勘定別の合計　計算
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }
                else if indexPath.row >= presenter.numberOfobjects0100 + 1 + 1 + 1 + 1 &&  // 有形固定資産タイトルの1行下
                            indexPath.row <  presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 { // 無形固定資産
                    cell.textLabel?.text = "        "+presenter.objects010142(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + 1)).category
                    print("BS", indexPath.row, "        "+presenter.objects010142(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + 1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects010142(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + 1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects010142(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + 1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                    
                }
                else if indexPath.row >= presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + 1 && // 無形固定資産タイトルの1行下
                            indexPath.row <  presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1 { // 投資その他資産
                    cell.textLabel?.text = "        "+presenter.objects010143(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + 1)).category
                    print("BS", indexPath.row, "        "+presenter.objects010143(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + 1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects010143(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + 1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects010143(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + 1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                    
                }
                else if indexPath.row >= presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1 + 1 && // 投資その他資産タイトルの1行下
                            indexPath.row <  presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 { // 固定資産合計
                    cell.textLabel?.text = "        "+presenter.objects010144(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1 + 1)).category
                    print("BS", indexPath.row, "        "+presenter.objects010144(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1 + 1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects010144(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1 + 1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects010144(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + 1 + presenter.numberOfobjects010142 + 1 + presenter.numberOfobjects010143 + 1 + 1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }
                else if indexPath.row >= presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 + 1 + 1 && // 繰延資産タイトルの1行下
                            indexPath.row < presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 + 1 + presenter.numberOfobjects0102 + 1 { // 繰延資産合計
                    cell.textLabel?.text = "        "+presenter.objects0102(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 + 1 + 1)).category
                    print("BS", indexPath.row, "        "+presenter.objects0102(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 + 1 + 1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0102(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 + 1 + 1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0102(forRow: indexPath.row-(presenter.numberOfobjects0100 + 1 + 1 + presenter.numberOfobjects010142  + 1 + presenter.numberOfobjects010143  + 1 + presenter.numberOfobjects010144  + 1 + 1 + 1 + 1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }
                else {
                    cell.textLabel?.text = "default"
                    print("BS", indexPath.row, "default")
                    cell.labelForThisYear.text = "default"
                    cell.labelForThisYear.textAlignment = .right
                }
                return cell
            }
        case 1: // MARK: - 負債の部
            switch indexPath.row {
            case 0:
                // MARK: - "  流動負債"
                cell.textLabel?.text = "  流動負債"
                print("BS", indexPath.row, "  流動負債"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0114 + 1:
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    流動負債合計"
                cell.textLabel?.text = "    流動負債合計"
                print("BS", indexPath.row, "    流動負債合計"+"★")
                let text:String = presenter.getTotalRank0(big5: indexPath.section, rank0: 3, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank0(big5: indexPath.section, rank0: 3, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.labelForPrevious.attributedText = attributeTextt
                return cell
            case presenter.numberOfobjects0114 + 1 + 1: // 中分類名の分を1行追加 合計の行を追加
                // MARK: - "  固定負債"
                cell.textLabel?.text = "  固定負債"
                print("BS", indexPath.row, "  固定負債"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0114 + 1 + 1 + presenter.numberOfobjects0115 + 1: //最後の行の前 22
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    固定負債合計"
                cell.textLabel?.text = "    固定負債合計"
                print("BS", indexPath.row, "    固定負債合計"+"★")
                let text:String = presenter.getTotalRank0(big5: indexPath.section, rank0: 4, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank0(big5: indexPath.section, rank0: 4, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.labelForPrevious.attributedText = attributeTextt
                return cell
            case presenter.numberOfobjects0114 + 1 + 1 + presenter.numberOfobjects0115 + 1 + 1: //最後の行
                // MARK: - "負債合計"
                cell.textLabel?.text = "負債合計"
                print("BS", indexPath.row, "負債合計"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                let text:String = presenter.getTotalBig5(big5: 1, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalBig5(big5: 1, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.labelForPrevious.attributedText = attributeTextt
                cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
                return cell
            default:
                // 勘定科目
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                if       indexPath.row >= 1 &&                     // 流動負債タイトルの1行下
                            indexPath.row <  presenter.numberOfobjects0114 + 1 {  // 流動負債合計 中区分のタイトルより下の行から、中区分合計の行より上
                    cell.textLabel?.text = "        "+presenter.objects0114(forRow: indexPath.row-(1)).category
                    print("BS", indexPath.row, "        "+presenter.objects0114(forRow: indexPath.row-(1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0114(forRow: indexPath.row-(1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0114(forRow: indexPath.row-(1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }
                else if indexPath.row >= presenter.numberOfobjects0114 + 1 + 1 + 1 && // 固定負債タイトルの1行下
                            indexPath.row <  presenter.numberOfobjects0114 + 1 + 1 + presenter.numberOfobjects0115 + 1 { // 固定負債合計
                    cell.textLabel?.text = "        "+presenter.objects0115(forRow: indexPath.row-(presenter.numberOfobjects0114 + 1 + 1 + 1)).category
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0115(forRow: indexPath.row-(presenter.numberOfobjects0114 + 1 + 1 + 1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0115(forRow: indexPath.row-(presenter.numberOfobjects0114 + 1 + 1 + 1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }
                else {
                    cell.textLabel?.text = "default"
                    print("BS", indexPath.row, "default")
                    cell.labelForThisYear.text = "default"
                    cell.labelForThisYear.textAlignment = .right
                }
                return cell
            }
        case 2: // MARK: - 純資産の部
// 中区分
            switch indexPath.row {
            case 0:
                // MARK: - "  株主資本"
                cell.textLabel?.text = "  株主資本"
                print("BS", indexPath.row, "  株主資本"+"★")
                //                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0129 + 1:
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    株主資本合計"
                cell.textLabel?.text = "    株主資本合計"
                print("BS", indexPath.row, "    株主資本合計"+"★")
                let text:String = presenter.getTotalRank1(big5: indexPath.section, rank1: 10, lastYear: false) // 中区分の合計を取得
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank1(big5: indexPath.section, rank1: 10, lastYear: true) // 中区分の合計を取得
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.labelForPrevious.attributedText = attributeTextt
                return cell
            case presenter.numberOfobjects0129 + 2: // 中分類名の分を1行追加 合計の行を追加
                // MARK: - "  その他の包括利益累計額"
                cell.textLabel?.text = "  その他の包括利益累計額"
                print("BS", indexPath.row, "  その他の包括利益累計額"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                return cell
            case presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1:
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // MARK: - "    その他の包括利益累計額合計"
                cell.textLabel?.text = "    その他の包括利益累計額合計"
                print("BS", indexPath.row, "    その他の包括利益累計額合計"+"★")
                let text:String = presenter.getTotalRank1(big5: indexPath.section, rank1: 11, lastYear: false) // 中区分の合計を取得
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalRank1(big5: indexPath.section, rank1: 11, lastYear: true) // 中区分の合計を取得
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.labelForPrevious.attributedText = attributeTextt
                return cell
            case presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1: //新株予約権16
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // セルに表示する内容がデータベースに0件しかない場合、エラー回避する　2020/10/19
                guard 0 < presenter.numberOfobjects01211 else { //新株予約権16 が0件の場合
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    cell.textLabel?.minimumScaleFactor = 0.05
                    cell.textLabel?.adjustsFontSizeToFitWidth = true
                    
                    // セルに表示する内容がデータベースに0件しかない場合、エラー回避する　2020/08/03
                    guard 0 < presenter.numberOfobjects01213 else { //非支配株主持分22 が0件の場合
                        // MARK: - "純資産合計"
                        cell.textLabel?.text = "純資産合計"
                        print("BS", indexPath.row, "純資産合計"+"★")
                        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                        let text:String = presenter.getTotalBig5(big5: 2, lastYear: false)
                        // テキストをカスタマイズするために、NSMutableAttributedStringにする
                        let attributeText = NSMutableAttributedString(string: text)
                        // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                        attributeText.addAttribute(
                            NSAttributedString.Key.underlineStyle,
                            value: NSUnderlineStyle.single.rawValue,
                            range: NSMakeRange(0, text.count)
                        )
                        cell.labelForThisYear.attributedText = attributeText
                        cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
                        var textt:String = ""
                        if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                            textt = presenter.getTotalBig5(big5: 2, lastYear: true)
                        }else {
                            textt = "-"
                        }
                        // テキストをカスタマイズするために、NSMutableAttributedStringにする
                        let attributeTextt = NSMutableAttributedString(string: textt)
                        // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                        attributeTextt.addAttribute(
                            NSAttributedString.Key.underlineStyle,
                            value: NSUnderlineStyle.single.rawValue,
                            range: NSMakeRange(0, textt.count)
                        )
                        cell.labelForPrevious.attributedText = attributeTextt
                        cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
                        return cell
                    } // 1. array.count（要素数）を利用する
                    
                    cell.textLabel?.text = "  "+presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).category
                    print("BS", indexPath.row, "  "+presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).category)

                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                    return cell
                }
                cell.textLabel?.text = "  "+presenter.objects01211(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1)).category
                print("BS", indexPath.row, "  "+presenter.objects01211(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1)).category)

                cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01211(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1)).number, lastYear: false)
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01211(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1)).number, lastYear: true)
                }else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForThisYear.textAlignment = .right
                return cell
            case presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211: //非支配株主持分22
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                // セルに表示する内容がデータベースに0件しかない場合、エラー回避する　2020/10/19
                guard 0 < presenter.numberOfobjects01213 else {
                    // MARK: - "純資産合計"
                    cell.textLabel?.text = "純資産合計"
                    print("BS", indexPath.row, "純資産合計"+"★")
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                    let text:String = presenter.getTotalBig5(big5: 2, lastYear: false)
                    // テキストをカスタマイズするために、NSMutableAttributedStringにする
                    let attributeText = NSMutableAttributedString(string: text)
                    // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                    attributeText.addAttribute(
                        NSAttributedString.Key.underlineStyle,
                        value: NSUnderlineStyle.single.rawValue,
                        range: NSMakeRange(0, text.count)
                    )
                    cell.labelForThisYear.attributedText = attributeText
                    cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
                    var textt:String = ""
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        textt = presenter.getTotalBig5(big5: 2, lastYear: true)
                    }else {
                        textt = "-"
                    }
                    // テキストをカスタマイズするために、NSMutableAttributedStringにする
                    let attributeTextt = NSMutableAttributedString(string: textt)
                    // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                    attributeTextt.addAttribute(
                        NSAttributedString.Key.underlineStyle,
                        value: NSUnderlineStyle.single.rawValue,
                        range: NSMakeRange(0, textt.count)
                    )
                    cell.labelForPrevious.attributedText = attributeTextt
                    cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
                    return cell
                } // 1. array.count（要素数）を利用する
                cell.textLabel?.text = "  "+presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).category
                print("BS", indexPath.row, "  "+presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).category)
                
                cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).number, lastYear: false)
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01213(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211)).number, lastYear: true)
                }else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForThisYear.textAlignment = .right
                return cell
            case presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211 + presenter.numberOfobjects01213: //最後の行
                // MARK: - "純資産合計"
                cell.textLabel?.text = "純資産合計"
                print("BS", indexPath.row, "純資産合計"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                let text:String = presenter.getTotalBig5(big5: 2, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalBig5(big5: 2, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.labelForPrevious.attributedText = attributeTextt
                cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
                return cell
            case presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 + 1 + presenter.numberOfobjects01211 + presenter.numberOfobjects01213 + 1: //最後の行の下
                // MARK: - "負債純資産合計"
                cell.textLabel?.text = "負債純資産合計"
                print("BS", indexPath.row, "負債純資産合計"+"★")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                let text:String = presenter.getTotalBig5(big5: 3, lastYear: false)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, text.count)
                )
                cell.labelForThisYear.attributedText = attributeText
                cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
                var textt:String = ""
                if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    textt = presenter.getTotalBig5(big5: 3, lastYear: true)
                }else {
                    textt = "-"
                }
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeTextt = NSMutableAttributedString(string: textt)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeTextt.addAttribute(
                    NSAttributedString.Key.underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSMakeRange(0, textt.count)
                )
                cell.labelForPrevious.attributedText = attributeTextt
                cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
                // 資産合計と純資産負債合計の金額が不一致の場合、文字色を赤
                if presenter.getTotalBig5(big5: 0, lastYear: false) != presenter.getTotalBig5(big5: 3, lastYear: false) {
                    cell.labelForThisYear.textColor = .red
                }else {
                    
                }
                return cell
            default:
                // 勘定科目
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.textLabel?.minimumScaleFactor = 0.05
                cell.textLabel?.adjustsFontSizeToFitWidth = true
                if       indexPath.row >= 1 &&                       // 株主資本
                            indexPath.row <  presenter.numberOfobjects0129 + 1 {      // 株主資本合計
                    cell.textLabel?.text = "        "+presenter.objects0129(forRow: indexPath.row-1).category
                    print("BS", indexPath.row, "        "+presenter.objects0129(forRow: indexPath.row-1).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0129(forRow: indexPath.row-1).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects0129(forRow: indexPath.row-1).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }else if indexPath.row >= presenter.numberOfobjects0129 + 2 + 1 &&                     //その他の包括利益累計額
                            indexPath.row <   presenter.numberOfobjects0129 + 2 + presenter.numberOfobjects01210 + 1 {    //その他の包括利益累計額合計
                    cell.textLabel?.text = "        "+presenter.objects01210(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + 1)).category
                    print("BS", indexPath.row, "        "+presenter.objects01210(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + 1)).category)
                    cell.labelForThisYear.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01210(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + 1)).number, lastYear: false)
                    if presenter.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                        cell.labelForPrevious.text = presenter.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects01210(forRow: indexPath.row-(presenter.numberOfobjects0129 + 2 + 1)).number, lastYear: true)
                    }else {
                        cell.labelForPrevious.text = "-"
                    }
                    cell.labelForThisYear.textAlignment = .right
                }else {
                    print("??")
                    let soundIdRing: SystemSoundID = 1000 //鐘
                    AudioServicesPlaySystemSound(soundIdRing)
                }
                return cell
            }
        default:
            return cell
        }
    }

    private func translateSmallCategory(small_category: Int) -> String {
        var small_category_name: String
        switch small_category {
        case 0:
            small_category_name = " 当座資産"
            break
        case 1:
            small_category_name = " 棚卸資産"
            break
        case 2:
            small_category_name = " その他流動資産"
            break
            
            
            
        case 3:
            small_category_name = " 有形固定資産"
            break
        case 4:
            small_category_name = " 無形固定資産"
            break
        case 5:
            small_category_name = " 投資その他資産"
            break
            
            
            
        case 6:
            small_category_name = " 仕入負債" // 仕入債務
            break
        case 7:
            small_category_name = " その他流動負債" // 短期借入金
            break
            
            
            
        case 8:
            small_category_name = " 売上原価"
            break
        case 9:
            small_category_name = " 販売費及び一般管理費"
            break
        case 10:
            small_category_name = " 売上高"
            break
        default:
            small_category_name = " 小分類なし"
            break
        }
        return small_category_name
    }
}

extension BSViewController: BSPresenterOutput {
    
    func reloadData() {
        
        tableView.reloadData()
        // クルクルを止める
        refreshControl.endRefreshing()
    }
    
    func setupViewForViewDidLoad() {
        // UI
        setTableView()
        createButtons() // ボタン作成
        setRefreshControl()
        // TODO: 印刷機能を一時的に蓋をする。あらためてHTMLで作る。 印刷ボタンを定義
//        let printoutButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(button_print))
//        //ナビゲーションに定義したボタンを置く
//        self.navigationItem.rightBarButtonItem = printoutButton
        self.navigationItem.title = "貸借対照表"
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
                    label_closingDate_previous.text = "前年度\n(" + String(fiscalYear-1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日)" // 前年度　決算日を表示する
                    label_closingDate_thisYear.text = "今年度\n(" + String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日)" // 今年度　決算日を表示する
                }
                else {
                    label_closingDate.text = String(fiscalYear+1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日" // 決算日を表示する
                    label_closingDate_previous.text = "前年度\n(" + String(fiscalYear) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日)" // 前年度　決算日を表示する
                    label_closingDate_thisYear.text = "今年度\n(" + String(fiscalYear+1) + "年\(theDayOfReckoning.prefix(2))月\(theDayOfReckoning.suffix(2))日)" // 今年度　決算日を表示する
                }
            }
        }
        label_title.text = "貸借対照表"
        label_title.font = UIFont.boldSystemFont(ofSize: 21)
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
    //        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
            // GADBannerView を作成する
            if gADBannerView == nil {
                gADBannerView = GADBannerView(adSize:kGADAdSizeLargeBanner)
                // GADBannerView プロパティを設定する
                gADBannerView.adUnitID = Constant.ADMOB_ID
                
                gADBannerView.rootViewController = self
                // 広告を読み込む
                gADBannerView.load(GADRequest())
                print("rowHeight", tableView.rowHeight)
                // GADBannerView を作成する
                addBannerViewToView(gADBannerView, constant: tableView.rowHeight * -1)
            }
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
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            view.bringSubviewToFront(gADBannerView)
        }
    }
}

class PrintPageRendererBS: UIPrintPageRenderer {
    
}
