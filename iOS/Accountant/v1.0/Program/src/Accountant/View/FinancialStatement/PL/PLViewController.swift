//
//  PLViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/01/30.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import UIKit
import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応

// 損益計算書クラス
class PLViewController: UIViewController, UIPrintInteractionControllerDelegate {

    // MARK: - var let

    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    #if DEBUG
    let AdMobTest:Bool = true    // true:テスト
    #else
    let AdMobTest:Bool = false
    #endif
    @IBOutlet var gADBannerView: GADBannerView!
    /// 損益計算書　上部
    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    @IBOutlet var label_closingDate_previous: UILabel!
    @IBOutlet var label_closingDate_thisYear: UILabel!
    /// 損益計算書　下部
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: EMTNeumorphicView!
    
    let LIGHTSHADOWOPACITY: Float = 0.5
    
    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 4
    let edged = false

    fileprivate let refreshControl = UIRefreshControl()
    
    var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
    /// GUIアーキテクチャ　MVP
    private var presenter: PLPresenterInput!
    func inject(presenter: PLPresenterInput) {
        self.presenter = presenter
    }
    
    // MARK: - Life cycle
    // TODO: Model へ移動
    let dataBaseManagerTaxonomy = DataBaseManagerTaxonomy() // Use of undeclared type ''が発生した。2020/07/24
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = PLPresenter.init(view: self, model: PLModel())
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
            backgroundView.neumorphicLayer?.cornerRadius = 0.1
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

    @objc func refreshTable() {

        presenter.refreshTable()
    }

    var printing: Bool = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
    /**
     * 印刷ボタン押下時メソッド
     */
    @IBAction func button_print(_ sender: UIButton) {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
        printing = true
        // 常にライトモード（明るい外観）を指定することでダークモード適用を回避
        tableView.overrideUserInterfaceStyle = .light
        // アップグレード機能　スタンダードプラン
        if !inAppPurchaseFlag {
            gADBannerView.isHidden = true
        }
//            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
        // 第三の方法
        //余計なUIをキャプチャしないように隠す
        tableView.showsVerticalScrollIndicator = false
        while self.tableView.indexPathForSelectedRow?.count ?? 0 > 0 {
            if let tappedIndexPath: IndexPath = self.tableView.indexPathForSelectedRow { // タップされたセルの位置を取得
                tableView.deselectRow(at: tappedIndexPath, animated: true)// セルの選択を解除
            }
        }
//            pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
        pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
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
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
        //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
        printing = false
        // アップグレード機能　スタンダードプラン
        if !inAppPurchaseFlag {
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
        print(" myImageView.bounds : \(myImageView.bounds)")
        //p-46 「UIGraphicsBeginPDFPage関数は、デフォルトのサイズを使用してページを作成します。」
//                UIGraphicsBeginPDFPage()
//            UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:0, width:myImageView.bounds.width, height:myImageView.bounds.width*1.414516129), nil) //高さはA4コピー用紙と同じ比率にするために、幅×1.414516129とする

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
            printInfo.jobName = "Profit And Loss Statement"
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
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
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

extension PLViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // アップグレード機能　スタンダードプラン
        if !inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 7:5大利益　8:小分類のタイトル　5:小分類の合計
        return 7 + 8 + 5 +
        presenter.numberOfmid_category10 +
        presenter.numberOfobjects9 +
        presenter.numberOfmid_category6 +
        presenter.numberOfmid_category11 +
        presenter.numberOfmid_category7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BSTableViewCell", for: indexPath) as! BSTableViewCell
        cell.labelForThisYear.font = UIFont.systemFont(ofSize: 14)
        cell.labelForPrevious.font = UIFont.systemFont(ofSize: 14)
        cell.labelForThisYear.attributedText = nil
        cell.labelForPrevious.attributedText = nil
        // TODO: Model へ移動
        let han =           3 + presenter.numberOfobjects9 + 1 //販売費及び一般管理費合計
        let ei =            3 + presenter.numberOfobjects9 + 2 //営業利益
        let eigai =         3 + presenter.numberOfobjects9 + 3 //営業外収益10
        let eigaiTotal =    3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + 4 //営業外収益合計
        let eigaih =        3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + 5 //営業外費用6
        let eigaihTotal =   3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + presenter.numberOfmid_category6 + 6 //営業外費用合計
        let kei =           3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + presenter.numberOfmid_category6 + 7 //経常利益
        let toku =          3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + presenter.numberOfmid_category6 + 8 //特別利益11
        let tokuTotal =     3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + presenter.numberOfmid_category6 + presenter.numberOfmid_category11 + 9 //特別利益合計
        let tokus =         3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + presenter.numberOfmid_category6 + presenter.numberOfmid_category11 + 10 //特別損失7
        let tokusTotal =    3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + presenter.numberOfmid_category6 + presenter.numberOfmid_category11 + presenter.numberOfmid_category7 + 11 //特別損失合計
        let zei =           3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + presenter.numberOfmid_category6 + presenter.numberOfmid_category11 + presenter.numberOfmid_category7 + 12 //税金等調整前当期純利益
        let zeikin =        3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + presenter.numberOfmid_category6 + presenter.numberOfmid_category11 + presenter.numberOfmid_category7 + 13 //法人税等8
        let touki =         3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + presenter.numberOfmid_category6 + presenter.numberOfmid_category11 + presenter.numberOfmid_category7 + 14 //当期純利益
        let htouki =        3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + presenter.numberOfmid_category6 + presenter.numberOfmid_category11 + presenter.numberOfmid_category7 + 15 //非支配株主に帰属する当期純利益
        let otouki =        3 + presenter.numberOfobjects9 + presenter.numberOfmid_category10 + presenter.numberOfmid_category6 + presenter.numberOfmid_category11 + presenter.numberOfmid_category7 + 16 //親会社株主に帰属する当期純利益

        switch indexPath.row {
        case 0: //売上高10
            cell.textLabel?.text = "売上高"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.labelForThisYear.text = presenter.getTotalRank0(big5: 4, rank0: 6, lastYear: false)
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                cell.labelForPrevious.text = presenter.getTotalRank0(big5: 4, rank0: 6, lastYear: true)
            }else {
                cell.labelForPrevious.text = "-"
            }
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case 1: //売上原価8
            cell.textLabel?.text = "売上原価"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.labelForThisYear.text = presenter.getTotalRank0(big5: 3, rank0: 7, lastYear: false)
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                cell.labelForPrevious.text = presenter.getTotalRank0(big5: 3, rank0: 7, lastYear: true)
            }else {
                cell.labelForPrevious.text = "-"
            }
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case 2: //売上総利益
            cell.textLabel?.text = "売上総利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            let text:String = presenter.getBenefitTotal(benefit: 0, lastYear: false)
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
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getBenefitTotal(benefit: 0, lastYear: true)
            }
            else {
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
        case 3: //販売費及び一般管理費9
            cell.textLabel?.text = "販売費及び一般管理費"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.labelForThisYear.text = ""
            cell.labelForPrevious.text = ""
            return cell
        case han: //販売費及び一般管理費合計
            cell.textLabel?.text = "販売費及び一般管理費合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            let text:String = presenter.getTotalRank0(big5: 3, rank0: 8, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            var textt:String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getTotalRank0(big5: 3, rank0: 8, lastYear: true)
            }
            else {
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
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case ei: //営業利益
            cell.textLabel?.text = "営業利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            let text:String = presenter.getBenefitTotal(benefit: 1, lastYear: false)
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
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getBenefitTotal(benefit: 1, lastYear: true)
            }
            else {
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
        case eigai: //営業外収益10
            cell.textLabel?.text = "営業外収益"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.labelForThisYear.text = ""
            cell.labelForPrevious.text = ""
            return cell
        case eigaiTotal: //営業外収益合計
            cell.textLabel?.text = "営業外収益合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            let text:String = presenter.getTotalRank1(big5: 4, rank1: 15, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            var textt:String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getTotalRank1(big5: 4, rank1: 15, lastYear: true)
            }
            else {
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
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case eigaih: //営業外費用6
            cell.textLabel?.text = "営業外費用"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.labelForThisYear.text = ""
            cell.labelForPrevious.text = ""
            return cell
        case eigaihTotal: //営業外費用合計
            cell.textLabel?.text = "営業外費用合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            let text:String = presenter.getTotalRank1(big5: 3, rank1: 16, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            var textt:String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getTotalRank1(big5: 3, rank1: 16, lastYear: true)
            }
            else {
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
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case kei: //経常利益
            cell.textLabel?.text = "経常利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            let text:String = presenter.getBenefitTotal(benefit: 2, lastYear: false)
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
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getBenefitTotal(benefit: 2, lastYear: true)
            }
            else {
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
        case toku: //特別利益11
            cell.textLabel?.text = "特別利益"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.labelForThisYear.text = ""
            cell.labelForPrevious.text = ""
            return cell
        case tokuTotal: //特別利益合計
            cell.textLabel?.text = "特別利益合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            let text:String = presenter.getTotalRank1(big5: 4, rank1: 17, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            var textt:String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getTotalRank1(big5: 4, rank1: 17, lastYear: true)
            }
            else {
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
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case tokus: //特別損失7
            cell.textLabel?.text = "特別損失"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.labelForThisYear.text = ""
            cell.labelForPrevious.text = ""
            return cell
        case tokusTotal: //特別損失合計
            cell.textLabel?.text = "特別損失合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            let text:String = presenter.getTotalRank1(big5: 3, rank1: 18, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            var textt:String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getTotalRank1(big5: 3, rank1: 18, lastYear: true)
            }
            else {
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
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case zei: //税金等調整前当期純利益
            cell.textLabel?.text = "税金等調整前当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            let text:String = presenter.getBenefitTotal(benefit: 3, lastYear: false)
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
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getBenefitTotal(benefit: 3, lastYear: true)
            }
            else {
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
        case zeikin: //税等8
            cell.textLabel?.text = "法人税等"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            let text:String = presenter.getTotalRank0(big5: 3, rank0: 11, lastYear: false)
            // テキストをカスタマイズするために、NSMutableAttributedStringにする
            let attributeText = NSMutableAttributedString(string: text)
            // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
            attributeText.addAttribute(
                NSAttributedString.Key.underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSMakeRange(0, text.count)
            )
            cell.labelForThisYear.attributedText = attributeText
            cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
            var textt:String = ""
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getTotalRank0(big5: 3, rank0: 11, lastYear: true)
            }
            else {
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
            cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
            return cell
        case touki: //当期純利益
            cell.textLabel?.text = "当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            let text:String = presenter.getBenefitTotal(benefit: 4, lastYear: false)
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
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                textt = presenter.getBenefitTotal(benefit: 4, lastYear: true)
            }
            else {
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
        case htouki: //非支配株主に帰属する当期純利益
            cell.textLabel?.text = "非支配株主に帰属する当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.labelForThisYear.text = "0"// TODO: presenter.getBenefitTotal(benefit: 4)
            cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                cell.labelForPrevious.text = "0"// TODO: presenter.getBenefitTotal(benefit: 4)
            }else {
                cell.labelForPrevious.text = "-"
            }
            cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
            return cell
        case otouki: //親会社株主に帰属する当期純利益
            cell.textLabel?.text = "親会社株主に帰属する当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.labelForThisYear.text = "0"// TODO: presenter.getBenefitTotal(benefit: 4)
            cell.labelForThisYear.font = UIFont.boldSystemFont(ofSize: 14)
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                cell.labelForPrevious.text = "0"// TODO: presenter.getBenefitTotal(benefit: 4) 
            }else {
                cell.labelForPrevious.text = "-"
            }
            cell.labelForPrevious.font = UIFont.boldSystemFont(ofSize: 14)
            return cell
        default:
            // 勘定科目
            if       indexPath.row > 3 &&                // 販売費及び一般管理費9
                     indexPath.row < han {                // 販売費及び一般管理費合計　タイトルより下の行から、合計の行より上
                cell.textLabel?.text = "    "+presenter.objects9(forRow:indexPath.row - (3+1)).category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.labelForThisYear.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects9(forRow:indexPath.row - (3+1)).number, lastYear: false) // BSAndPL_category を number に変更する 2020/09/17
                cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
                if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.objects9(forRow:indexPath.row - (3+1)).number, lastYear: true)
                }else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
                return cell
            }else if indexPath.row > eigai &&             // 営業外収益10
                      indexPath.row < eigaiTotal {          // 営業外収益合計
                cell.textLabel?.text = "    "+presenter.mid_category10(forRow:indexPath.row - (eigai + 1)).category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.labelForThisYear.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.mid_category10(forRow:indexPath.row - (eigai + 1)).number, lastYear: false) //収益:4
                cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
                if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.mid_category10(forRow:indexPath.row - (eigai + 1)).number, lastYear: true) //収益:4
                }else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
                return cell
            }else if indexPath.row > eigaih &&          // 営業外費用
                      indexPath.row < eigaihTotal {      // 営業外費用合計
                cell.textLabel?.text = "    "+presenter.mid_category6(forRow:indexPath.row - (eigaih + 1)).category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.labelForThisYear.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.mid_category6(forRow:indexPath.row - (eigaih + 1)).number, lastYear: false)
                cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
                if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.mid_category6(forRow:indexPath.row - (eigaih + 1)).number, lastYear: true)
                }else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
                return cell
            }else if indexPath.row > toku &&                       // 特別利益
                      indexPath.row < tokuTotal {                   // 特別利益合計
                cell.textLabel?.text = "    "+presenter.mid_category11(forRow:indexPath.row - (toku + 1)).category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.labelForThisYear.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.mid_category11(forRow:indexPath.row - (toku+1)).number, lastYear: false) //収益:4
                cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
                if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.mid_category11(forRow:indexPath.row - (toku+1)).number, lastYear: true) //収益:4
                }else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
                return cell
            }else if indexPath.row > tokus &&                   // 特別損失
                      indexPath.row < tokusTotal {               // 特別損失合計
                cell.textLabel?.text = "    "+presenter.mid_category7(forRow:indexPath.row - (tokus + 1)).category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.labelForThisYear.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.mid_category7(forRow:indexPath.row - (tokus+1)).number, lastYear: false)
                cell.labelForThisYear.font = UIFont.systemFont(ofSize: 13)
                if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                    cell.labelForPrevious.text = dataBaseManagerTaxonomy.getTotalOfTaxonomy(numberOfSettingsTaxonomy: presenter.mid_category7(forRow:indexPath.row - (tokus+1)).number, lastYear: true)
                }else {
                    cell.labelForPrevious.text = "-"
                }
                cell.labelForPrevious.font = UIFont.systemFont(ofSize: 13)
                return cell
    // 税金　勘定科目を表示する必要はない
                // 法人税、住民税及び事業税
                // 法人税等調整額
            }else{
                return cell
            }
        }
    }
}

extension PLViewController: PLPresenterOutput {

    func reloadData() {
        // 更新処理
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
        self.navigationItem.title = "損益計算書"
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
        label_title.text = "損益計算書"
        label_title.font = UIFont.boldSystemFont(ofSize: 21)
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // アップグレード機能　スタンダードプラン
        if !inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
    //        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize:kGADAdSizeLargeBanner)
            // GADBannerView プロパティを設定する
            if AdMobTest {
                gADBannerView.adUnitID = TEST_ID
            }
            else{
                gADBannerView.adUnitID = AdMobID
            }
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            print(tableView.rowHeight)
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: tableView!.rowHeight * -1)
        }
        // ナビゲーションを透明にする処理
        if let navigationController = self.navigationController {
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController.navigationBar.shadowImage = UIImage()
        }
    }
    
    func setupViewForViewDidAppear() {
        // アップグレード機能　スタンダードプラン
        if !inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            view.bringSubviewToFront(gADBannerView)
        }
    }
}
