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
    
    @IBOutlet var baseView: UIView!
    
    var webView: WKWebView?
    
    var helpDetailKind: HelpDetailKind = .Link0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // largeTitle表示させない
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
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
            if let path = Bundle.main.url(forResource: "Pacioli", withExtension: "jpg") {
                print(path)
                changeImage(path: path)
            }
        case .Link1:
            break
        case .Link2:
            if let path = Bundle.main.url(forResource: "簿記一巡", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 基本情報の登録をしよう
        case .Link4:
            // 基本情報の登録　事業者名を設定しよう 設定画面
            if let path = Bundle.main.url(forResource: "BasicInfo1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 基本情報の登録 事業者名を設定しよう 帳簿情報画面
            if let path = Bundle.main.url(forResource: "BasicInfo2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
        case .Link41:
            // 基本情報の登録 決算日を設定しよう ①
            if let path = Bundle.main.url(forResource: "BasicInfo3", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 基本情報の登録 決算日を設定しよう ②
            if let path = Bundle.main.url(forResource: "BasicInfo4", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
        case .Link42:
            // 基本情報の登録 会計帳簿を作成しよう
            if let path = Bundle.main.url(forResource: "BasicInfo3", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 基本情報の登録 会計帳簿を作成しよう ③
            if let path = Bundle.main.url(forResource: "BasicInfo5", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 基本情報の登録 会計帳簿を作成しよう ④
            if let path = Bundle.main.url(forResource: "BasicInfo6", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
            // 基本情報の登録 会計帳簿を作成しよう ⑤
            if let path = Bundle.main.url(forResource: "BasicInfo7", withExtension: "png") {
                print(path)
                changeImageForth(path: path)
            }
            // 基本情報の登録 会計帳簿を作成しよう ⑥
            if let path = Bundle.main.url(forResource: "BasicInfo8", withExtension: "png") {
                print(path)
                changeImageFifth(path: path)
            }
            // 基本情報の登録 会計帳簿を作成しよう ⑦
            if let path = Bundle.main.url(forResource: "BasicInfo9", withExtension: "png") {
                print(path)
                changeImageSixth(path: path)
            }
        case .Link5:
            break
        case .Link51:
            // 勘定科目体系の登録 勘定科目を一覧で表示 ①
            if let path = Bundle.main.url(forResource: "AccountItem1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 勘定科目体系の登録 勘定科目を一覧で表示 ②
            if let path = Bundle.main.url(forResource: "AccountItem2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 勘定科目体系の登録 勘定科目を一覧で表示 ③
            if let path = Bundle.main.url(forResource: "AccountItem4", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
            
            // 勘定科目体系の登録 表示科目別に勘定科目を表示 ①
            if let path = Bundle.main.url(forResource: "AccountItem1", withExtension: "png") {
                print(path)
                changeImageForth(path: path)
            }
            // 勘定科目体系の登録　表示科目別に勘定科目を表示 ②
            if let path = Bundle.main.url(forResource: "AccountItem5", withExtension: "png") {
                print(path)
                changeImageFifth(path: path)
            }
            // 勘定科目体系の登録　表示科目別に勘定科目を表示 ③
            if let path = Bundle.main.url(forResource: "AccountItem6", withExtension: "png") {
                print(path)
                changeImageSixth(path: path)
            }
        case .Link52:
            break
        case .Link53:
            // 勘定科目体系の登録　新規登録する ①設定画面
            if let path = Bundle.main.url(forResource: "AccountItem1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 勘定科目体系の登録　新規登録する ②
            if let path = Bundle.main.url(forResource: "AccountItem2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 勘定科目体系の登録　新規登録する ③
            if let path = Bundle.main.url(forResource: "AccountItem7", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
            // 勘定科目体系の登録　新規登録する ④
            if let path = Bundle.main.url(forResource: "AccountItem8", withExtension: "png") {
                print(path)
                changeImageForth(path: path)
            }
            // 勘定科目の編集しよう
        case .Link6:
            // 勘定科目体系の登録 修正をする ①
            if let path = Bundle.main.url(forResource: "AccountItem1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 勘定科目体系の登録 修正をする ②
            if let path = Bundle.main.url(forResource: "AccountItem2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 勘定科目体系の登録 修正をする ③
            if let path = Bundle.main.url(forResource: "AccountItem9", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
            // 勘定科目体系の登録 修正をする ④
            if let path = Bundle.main.url(forResource: "AccountItem10", withExtension: "png") {
                print(path)
                changeImageForth(path: path)
            }
            // 勘定科目体系の登録 修正をする ⑤
            if let path = Bundle.main.url(forResource: "AccountItem11", withExtension: "png") {
                print(path)
                changeImageFifth(path: path)
            }
            // 勘定科目体系の登録 修正をする ⑥
            if let path = Bundle.main.url(forResource: "AccountItem12", withExtension: "png") {
                print(path)
                changeImageSixth(path: path)
            }
        case .Link61:
            // 勘定科目体系の登録 削除をする ①
            if let path = Bundle.main.url(forResource: "AccountItem1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 勘定科目体系の登録 削除をする ②
            if let path = Bundle.main.url(forResource: "AccountItem2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 勘定科目体系の登録 削除をする ③
            if let path = Bundle.main.url(forResource: "AccountItem3", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
            // 勘定科目体系の登録 削除をする ④
            if let path = Bundle.main.url(forResource: "AccountItem13", withExtension: "png") {
                print(path)
                changeImageForth(path: path)
            }
            // 勘定科目体系の登録 削除をする ⑤
            if let path = Bundle.main.url(forResource: "AccountItem14", withExtension: "png") {
                print(path)
                changeImageFifth(path: path)
            }
            // 勘定科目体系の登録 削除をする ⑥
            if let path = Bundle.main.url(forResource: "AccountItem15", withExtension: "png") {
                print(path)
                changeImageSixth(path: path)
            }
        case .Link3:
            // 開始残高を設定しよう ①
            if let path = Bundle.main.url(forResource: "OpeningJournalEntry1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 開始残高を設定しよう ②
            if let path = Bundle.main.url(forResource: "OpeningJournalEntry2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 開始残高を設定しよう ③
            if let path = Bundle.main.url(forResource: "OpeningJournalEntry3", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
            // 開始残高を設定しよう ④
            if let path = Bundle.main.url(forResource: "OpeningJournalEntry4", withExtension: "png") {
                print(path)
                changeImageForth(path: path)
            }
            // 開始残高を設定しよう ⑤
            if let path = Bundle.main.url(forResource: "OpeningJournalEntry5", withExtension: "png") {
                print(path)
                changeImageFifth(path: path)
            }
            // 開始残高を設定しよう ⑥
            if let path = Bundle.main.url(forResource: "OpeningJournalEntry6", withExtension: "png") {
                print(path)
                changeImageSixth(path: path)
            }
        case .Link7:
            // 環境設置を確認・変更しよう
            if let path = Bundle.main.url(forResource: "Configuration1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 環境設置を確認・変更しよう
            if let path = Bundle.main.url(forResource: "Configuration2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
        case .Link8:
            // 仕訳を入力する
            if let path = Bundle.main.url(forResource: "JournalEntry1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 仕訳を入力する
            if let path = Bundle.main.url(forResource: "JournalEntry2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
        case .Link9:
            // 4. 帳簿に記帳する 仕訳を修正する ①
            if let path = Bundle.main.url(forResource: "Journals1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 4. 帳簿に記帳する 仕訳を修正する　②
            if let path = Bundle.main.url(forResource: "Journals2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 4. 帳簿に記帳する 仕訳を修正する　③
            if let path = Bundle.main.url(forResource: "Journals3", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
        case .Link10:
            // 4. 帳簿に記帳する 仕訳を削除する ①
            if let path = Bundle.main.url(forResource: "Journals1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 4. 帳簿に記帳する 仕訳を削除する　②
            if let path = Bundle.main.url(forResource: "Journals2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 4. 帳簿に記帳する 仕訳を削除する　③
            if let path = Bundle.main.url(forResource: "Journals4", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
        case .Link11:
            // 仕訳帳 ①
            if let path = Bundle.main.url(forResource: "Journals5", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 仕訳帳 ②
            if let path = Bundle.main.url(forResource: "Journals6", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
        case .Link111:
            // 総勘定元帳　①
            if let path = Bundle.main.url(forResource: "GeneralLedger1", withExtension: "png") {
                print(path)
                changeImage(path: path)
            }
            // 総勘定元帳　②
            if let path = Bundle.main.url(forResource: "GeneralLedger2", withExtension: "png") {
                print(path)
                changeImageSecond(path: path)
            }
            // 総勘定元帳　③
            if let path = Bundle.main.url(forResource: "GeneralLedger3", withExtension: "png") {
                print(path)
                changeImageThird(path: path)
            }
            // 総勘定元帳　④
            if let path = Bundle.main.url(forResource: "GeneralLedger4", withExtension: "png") {
                print(path)
                changeImageForth(path: path)
            }
            // 総勘定元帳　⑤
            if let path = Bundle.main.url(forResource: "GeneralLedger5", withExtension: "png") {
                print(path)
                changeImageFifth(path: path)
            }
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
    // 開始残高を設定しよう
    case Link3
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
    case Link111

    // HTMLファイル名
    var fileName: String {
        switch self {
        case .Link0:
            return "About_This_App"
        case .Link1:
            return "Thought"
        case .Link2:
            return "Basic_Of_Bookkeeping"
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
        case .Link3:
            return "Opening_Journal_Entry"
        case .Link7:
            return "Configuration"
        case .Link8:
            return "Journal_Entry"
        case .Link9:
            return "Journal_Entry_Edit"
        case .Link10:
            return "Journal_Entry_Delete"
        case .Link11:
            return "Journals"
        case .Link111:
            return "Journals2"
        }
    }
    
    // リンクを設定する文字列
    var title: String {
        switch self {
        case .Link0:
            return "このアプリについて"
        case .Link1:
            return "採用した会計概念"
        case .Link2:
            return "簿記の基礎"
        case .Link4:
            return "事業者名を設定する"
        case .Link41:
            return "決算日を設定する"
        case .Link42:
            return "新たな年度の帳簿を作成する"
        case .Link5:
            return "準備する資料"
        case .Link51:
            return "勘定科目を確認する"
        case .Link52:
            return "勘定科目体系の図"
        case .Link53:
            return "勘定科目を新規に登録する"
        case .Link6:
            return "勘定科目を修正する"
        case .Link61:
            return "勘定科目を削除する"
        case .Link3:
            return "開始残高を設定しよう"
        case .Link7:
            return "環境設定を確認・変更しよう"
        case .Link8:
            return "仕訳を入力する"
        case .Link9:
            return "仕訳を修正する"
        case .Link10:
            return "仕訳を削除する"
        case .Link11:
            return "仕訳帳を確認する"
        case .Link111:
            return "総勘定元帳を確認する"
        }
    }
}
