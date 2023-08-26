//
//  SettingsHelpDetailViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/25.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import GoogleMobileAds // マネタイズ対応
import UIKit
import WebKit

class SettingsHelpDetailViewController: UIViewController {
    
    var gADBannerView: GADBannerView!
    
    @IBOutlet private var journalsTextView: UITextView!
    @IBOutlet var baseView: UIView!
    
    var webView: WKWebView?
    
    var helpDetailKind: HelpDetailKind = .Link0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        switch textViewSwitchNumber {
//        case 11: // 入力した取引を確認しよう
//            journalsTextView.isHidden = false
//            if let baseString = journalsTextView.text {
//                let attributedString = NSMutableAttributedString(string: journalsTextView.text)
//                // 仕訳帳 ①
//                let textAttachment666 = NSTextAttachment()
//                textAttachment666.image = UIImage(named: "TableViewControllerJournals4.png")!
//                var oldWidth = textAttachment666.image!.size.width
//                var scaleFactor = oldWidth / (journalsTextView.frame.size.width - 20) * 3 // for the padding inside the textView
//                textAttachment666.image = UIImage.init(cgImage: textAttachment666.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
//                var attrStringWithImage = NSAttributedString(attachment: textAttachment666)
//                print(journalsTextView.text.unicodeScalars.count)
//                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "* 総勘定元帳").location-3, 1), with: attrStringWithImage)
//                // 総勘定元帳　①
//                let textAttachment777 = NSTextAttachment()
//                textAttachment777.image = UIImage(named: "TableViewControllerGeneralLedger.png")!
//                oldWidth = textAttachment777.image!.size.width
//                scaleFactor = oldWidth / (journalsTextView.frame.size.width - 20) * 3 // for the padding inside the textView
//                textAttachment777.image = UIImage.init(cgImage: textAttachment777.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
//                attrStringWithImage = NSAttributedString(attachment: textAttachment777)
//                print(journalsTextView.text.unicodeScalars.count)
//                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "② 任意の勘定").location - 3, 1), with: attrStringWithImage)
//                // 総勘定元帳　②
//                let textAttachment888 = NSTextAttachment()
//                textAttachment888.image = UIImage(named: "TableViewControllerGeneralLedger1.png")!
//                oldWidth = textAttachment888.image!.size.width
//                scaleFactor = oldWidth / (journalsTextView.frame.size.width - 20) * 3 // for the padding inside the textView
//                textAttachment888.image = UIImage.init(cgImage: textAttachment888.image!.cgImage!, scale: scaleFactor, orientation: UIImage.Orientation.up)
//                attrStringWithImage = NSAttributedString(attachment: textAttachment888)
//                print(journalsTextView.text.unicodeScalars.count)
//                attributedString.replaceCharacters(in: NSMakeRange(NSString(string: baseString).range(of: "② 任意の勘定").location - 2, 1), with: attrStringWithImage)
//                // 複数の属性を一気に指定します.
//                // 全体の文字サイズを指定
//                attributedString.addAttributes([
//                    .font: UIFont.systemFont(ofSize: 19)
//                ], range: NSString(string: baseString).range(of: baseString))
//                // カテゴリタイトルの文字サイズを指定
//                attributedString.addAttributes([
//                    .font: UIFont.boldSystemFont(ofSize: 30)
//                ], range: NSString(string: baseString).range(of: "4. 帳簿に記帳する"))
//                attributedString.addAttributes([
//                    .font: UIFont.boldSystemFont(ofSize: 20)
//                ], range: NSString(string: baseString).range(of: "4. 入力した取引を確認しよう"))
//                journalsTextView.attributedText = attributedString
//                journalsTextView.textColor = .textColor
//                self.view.layoutIfNeeded()    // 追加
//                journalsTextView.setContentOffset(
//                    CGPoint(x: 0, y: -journalsTextView.contentInset.top),
//                    animated: false
//                )
//            }
//        default:
//            break
//        }
    }
    
    override func loadView() {
        super.loadView() // 重要
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        guard let webView = webView else {
            return
        }
        webView.translatesAutoresizingMaskIntoConstraints = false
        // 背景色が白くなるので透明にする
        webView.isOpaque = false
        webView.backgroundColor = .cellBackground
        webView.scrollView.backgroundColor = .clear
        // バウンスを禁止する
        webView.scrollView.bounces = false
        webView.navigationDelegate = self
        
        baseView.addSubview(webView)
        baseView.bringSubviewToFront(webView)
        
        // 親Viewを覆うように制約をつける
        webView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 0).isActive = true
        webView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: 0).isActive = true
        webView.layoutIfNeeded()
        
        // HTML を読み込む
        if let url = Bundle.main.url(forResource: helpDetailKind.fileName, withExtension: "html") {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // ダークモード対応 HTML上の文字色を変更する
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.webView?.evaluateJavaScript(
                "changeFontColor('\(UITraitCollection.isDarkMode ? "#F2F2F2" : "#0C0C0C")')",
                completionHandler: { _, _ in
                    print("Completed Javascript evaluation.")
                }
            )
            // HTML上の画像を指定する
            self.updateHtmlImage()
        }
    }
    
    // HTML上の画像を指定する
    func updateHtmlImage() {
        switch self.helpDetailKind {
        case .Link0:
            break
        case .Link1:
            break
        case .Link2:
            // 画像を表示させる
            if let path = Bundle.main.url(forResource: "簿記一巡", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
        case .Link3:
            break
            // 基本情報の登録をしよう
        case .Link4:
            // 基本情報の登録　事業者名を設定しよう 設定画面
            if let path = Bundle.main.url(forResource: "TableViewControllerSettings_cell_user", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 基本情報の登録 事業者名を設定しよう 帳簿情報画面
            if let path = Bundle.main.url(forResource: "TableViewControllerSettingsInformation", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
        case .Link41:
            // 基本情報の登録 決算日を設定しよう ①
            if let path = Bundle.main.url(forResource: "TableViewControllerSettings_cell_list_settings_term", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 基本情報の登録 決算日を設定しよう ②
            if let path = Bundle.main.url(forResource: "Text View set Up basic Info2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
        case .Link42:
            // 基本情報の登録 会計帳簿を作成しよう
            if let path = Bundle.main.url(forResource: "TableViewControllerSettings_cell_list_settings_term", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 基本情報の登録 会計帳簿を作成しよう ③
            if let path = Bundle.main.url(forResource: "Text View set Up basic Info3", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 基本情報の登録 会計帳簿を作成しよう ④
            if let path = Bundle.main.url(forResource: "Text View set Up basic Info4", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
        case .Link5:
            break
        case .Link51:
            // 勘定科目体系の登録 勘定科目を一覧で表示 ①
            if let path = Bundle.main.url(forResource: "Text View set Up1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 勘定科目体系の登録 勘定科目を一覧で表示 ②
            if let path = Bundle.main.url(forResource: "Text View set Up2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 勘定科目体系の登録 勘定科目を一覧で表示 ③
            if let path = Bundle.main.url(forResource: "TableViewControllerCategoryList", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
            
            // 勘定科目体系の登録 表示科目別に勘定科目を表示 ①
            if let path = Bundle.main.url(forResource: "Text View set Up1", withExtension: "png") {
                print(path)
                changeImageForth(path: path)
            }
            // 勘定科目体系の登録　表示科目別に勘定科目を表示 ②
            if let path = Bundle.main.url(forResource: "TableViewControllerSettingsCategory_categoriesBSandPL", withExtension: "png") {
                print(path)
                changeImageFifth(path: path)
            }
            // 勘定科目体系の登録　表示科目別に勘定科目を表示 ③
            if let path = Bundle.main.url(forResource: "TableViewControllerSettingsTaxonomyAccountByTaxonomyList", withExtension: "png") {
                print(path)
                changeImageSixth(path: path)
            }
        case .Link52:
            break
        case .Link53:
            // 勘定科目体系の登録　新規に追加登録する ①設定画面
            if let path = Bundle.main.url(forResource: "Text View set Up1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 勘定科目体系の登録　新規に追加登録する ②
            if let path = Bundle.main.url(forResource: "Text View set Up2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 勘定科目体系の登録　新規に追加登録する ③
            if let path = Bundle.main.url(forResource: "Text View set Up3", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
            
            // 勘定科目体系の登録　新規に追加登録する ④
            if let path = Bundle.main.url(forResource: "Text View set Up4", withExtension: "png") {
                print(path)
                changeImageForth(path: path)
            }
            // 勘定科目体系の登録　新規に追加登録する ⑤
            if let path = Bundle.main.url(forResource: "Text View set Up5", withExtension: "png") {
                print(path)
                changeImageFifth(path: path)
            }
            // 勘定科目体系の登録　新規に追加登録する ⑥
            if let path = Bundle.main.url(forResource: "Text View set Up6", withExtension: "png") {
                print(path)
                changeImageSixth(path: path)
            }
            // 勘定科目の編集しよう
        case .Link6:
            // 勘定科目体系の登録 修正をする ①
            if let path = Bundle.main.url(forResource: "Text View set Up1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 勘定科目体系の登録 修正をする ②
            if let path = Bundle.main.url(forResource: "Text View set Up2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 勘定科目体系の登録 修正をする ③
            if let path = Bundle.main.url(forResource: "TableViewControllerCategoryList1", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
            // 勘定科目体系の登録 修正をする ④
            if let path = Bundle.main.url(forResource: "TableViewControllerCategoryList2", withExtension: "png") {
                print(path)
                changeImageForth(path: path)
            }
            // 勘定科目体系の登録 修正をする ⑤
            if let path = Bundle.main.url(forResource: "TableViewControllerCategoryList3", withExtension: "png") {
                print(path)
                changeImageFifth(path: path)
            }
            // 勘定科目体系の登録 修正をする ⑥
            if let path = Bundle.main.url(forResource: "TableViewControllerCategoryList4", withExtension: "png") {
                print(path)
                changeImageSixth(path: path)
            }
        case .Link61:
            // 勘定科目体系の登録 削除をする ①
            if let path = Bundle.main.url(forResource: "Text View set Up1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 勘定科目体系の登録 削除をする ②
            if let path = Bundle.main.url(forResource: "Text View set Up2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 勘定科目体系の登録 削除をする ③
            if let path = Bundle.main.url(forResource: "Text View set Up3", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
            // 勘定科目体系の登録 削除をする ④
            if let path = Bundle.main.url(forResource: "TableViewControllerCategoryList_delete1", withExtension: "png") {
                print(path)
                changeImageForth(path: path)
            }
            // 勘定科目体系の登録 削除をする ⑤
            if let path = Bundle.main.url(forResource: "TableViewControllerCategoryList_delete2", withExtension: "png") {
                print(path)
                changeImageFifth(path: path)
            }
            // 勘定科目体系の登録 削除をする ⑥
            if let path = Bundle.main.url(forResource: "TableViewControllerCategoryList_delete3", withExtension: "png") {
                print(path)
                changeImageSixth(path: path)
            }
            // 勘定科目体系の登録 削除をする ⑦
            // TableViewControllerCategoryList_delete4
            // 不要
        case .Link7:
            //
            if let path = Bundle.main.url(forResource: "TableViewControllerSettings_cell_list_settings_Journals", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            //
            if let path = Bundle.main.url(forResource: "TableViewControllerSettings_cell_list_settings_Journals1", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
        case .Link8:
            //
            if let path = Bundle.main.url(forResource: "ViewControllerJournalEntry", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
        case .Link9:
            // 4. 帳簿に記帳する 2. 仕訳を修正する ①
            if let path = Bundle.main.url(forResource: "TableViewControllerJournals", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 4. 帳簿に記帳する 2. 仕訳を修正する　②
            if let path = Bundle.main.url(forResource: "TableViewControllerJournals1", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }

        case .Link10:
            // 4. 帳簿に記帳する 2. 仕訳を修正する ①
            if let path = Bundle.main.url(forResource: "TableViewControllerJournals", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 4. 帳簿に記帳する 2. 仕訳を修正する　②
            if let path = Bundle.main.url(forResource: "TableViewControllerJournals2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 4. 帳簿に記帳する 2. 仕訳を修正する　③
            if let path = Bundle.main.url(forResource: "TableViewControllerJournals3", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }

        default:
            break
        }
    }
    
    func changeImage(path: URL) {
        self.webView?.evaluateJavaScript(
            "changeImage('\(path)')",
            completionHandler: { _, _ in
                print("Completed Javascript evaluation.")
            }
        )
    }
    
    func changeImageSecond(path: URL) {
        self.webView?.evaluateJavaScript(
            "changeImageSecond('\(path)')",
            completionHandler: { _, _ in
                print("Completed Javascript evaluation.")
            }
        )
    }
    
    func changeImageThird(path: URL) {
        self.webView?.evaluateJavaScript(
            "changeImageThird('\(path)')",
            completionHandler: { _, _ in
                print("Completed Javascript evaluation.")
            }
        )
    }
    
    func changeImageForth(path: URL) {
        self.webView?.evaluateJavaScript(
            "changeImageForth('\(path)')",
            completionHandler: { _, _ in
                print("Completed Javascript evaluation.")
            }
        )
    }
    
    func changeImageFifth(path: URL) {
        self.webView?.evaluateJavaScript(
            "changeImageFifth('\(path)')",
            completionHandler: { _, _ in
                print("Completed Javascript evaluation.")
            }
        )
    }
    
    func changeImageSixth(path: URL) {
        self.webView?.evaluateJavaScript(
            "changeImageSixth('\(path)')",
            completionHandler: { _, _ in
                print("Completed Javascript evaluation.")
            }
        )
    }
    // ビューが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize: GADAdSizeLargeBanner)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOBID
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: 50 * -1)
        } else {
            if let gADBannerView = gADBannerView {
                // GADBannerView を外す
                removeBannerViewToView(gADBannerView)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // アップグレード機能　スタンダードプラン
        if let gADBannerView = gADBannerView {
            // GADBannerView を外す
            removeBannerViewToView(gADBannerView)
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SettingsHelpDetailViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 長押しによる選択、コールアウト表示を禁止する
        webView.prohibitTouchCalloutAndUserSelect()
    }
}

enum HelpDetailKind: String {
    
    case Link0
    case Link1
    case Link2
    // 初期設定の手順
    case Link3
    // 基本情報の登録をしよう
    case Link4
    case Link41
    case Link42
    // 勘定科目を設定しよう
    case Link5
    case Link51
    case Link52
    case Link53
    // 勘定科目の編集しよう
    case Link6
    case Link61
    // 環境設定を確認・変更しよう
    case Link7
    // 仕訳を入力する
    case Link8
    // 仕訳を修正する
    case Link9
    // 仕訳を削除する
    case Link10
    // 入力した取引を確認しよう
    case Link11
    
    var fileName: String {
        switch self {
        case .Link0:
            return "About_This_App"
        case .Link1:
            return "Thought"
        case .Link2:
            return "Basic_Of_Bookkeeping"
        case .Link3:
            return ""
        case .Link4:
            return "Set_Up_Basic_Info"
        case .Link41:
            return "Set_Up_Basic_Info2"
        case .Link42:
            return "Set_Up_Basic_Info3"
        case .Link5:
            return "Set_Up_Account"
        case .Link51:
            return "Set_Up_Account2"
        case .Link52:
            return "Set_Up_Account3"
        case .Link53:
            return "Set_Up_Account4"
        case .Link6:
            return "Set_Up_Account_Edit"
        case .Link61:
            return "Set_Up_Account_Edit2"
        case .Link7:
            return "Configuration"
        case .Link8:
            return "Journal_Entry"
        case .Link9:
            return "Journal_Entry_Edit"
        case .Link10:
            return "Journal_Entry_Delete"
        case .Link11:
            return ""
        }
    }
    
    var title: String {
        switch self {
        case .Link0:
            return "このアプリについて"
        case .Link1:
            return "当アプリで採用した会計概念"
        case .Link2:
            return "簿記の基礎"
        case .Link3:
            return "初期設定の手順"
        case .Link4:
            return "事業者名を設定しよう"
        case .Link41:
            return "決算日を設定しよう"
        case .Link42:
            return "会計帳簿を作成しよう"
        case .Link5:
            return "準備する資料"
        case .Link51:
            return "勘定科目の確認"
        case .Link52:
            return "勘定科目体系の図"
        case .Link53:
            return "新規に追加登録する"
        case .Link6:
            return "修正をする"
        case .Link61:
            return "削除をする"
        case .Link7:
            return "環境設定を確認・変更しよう"
        case .Link8:
            return "仕訳を入力する"
        case .Link9:
            return "仕訳を修正する"
        case .Link10:
            return "仕訳を削除する"
        case .Link11:
            return "入力した取引を確認しよう"
        }
    }
}
