//
//  SettingsHelpViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/25.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import GoogleMobileAds // マネタイズ対応
import UIKit

class SettingsHelpViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    
    var gADBannerView: GADBannerView!
    var helpDetailKind: HelpDetailKind = .Link0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseString = textView.text
        let attributedString = NSMutableAttributedString(string: baseString!)
        // 複数の属性を一気に指定します.
        // 全体の文字サイズを指定
        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 19)
        ], range: NSString(string: baseString!).range(of: baseString!))
        // カテゴリタイトルの文字サイズを指定
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 30)
        ], range: NSString(string: baseString!).range(of: "1. 概要"))
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 30)
        ], range: NSString(string: baseString!).range(of: "2. 基礎知識"))
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 30)
        ], range: NSString(string: baseString!).range(of: "3. 初期設定"))
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 30)
        ], range: NSString(string: baseString!).range(of: "4. 帳簿に記帳する"))
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 30)
        ], range: NSString(string: baseString!).range(of: "5. 決算準備"))
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 30)
        ], range: NSString(string: baseString!).range(of: "6. 決算作業"))

        // リンクを設置
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link0.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link0.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link1.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link1.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link2.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link2.title)
        )
        //        attributedString.addAttribute(
        //            .link,
        //                                      value: HelpDetailKind.Link3.rawValue,
        //                                      range: NSString(string: baseString!).range(of: HelpDetailKind.Link3.)
        // )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link4.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link4.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link41.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link41.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link42.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link42.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link5.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link5.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link51.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link51.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link52.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link52.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link53.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link53.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link6.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link6.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link61.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link61.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link7.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link7.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link8.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link8.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link9.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link9.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link10.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link10.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link11.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link11.title)
        )
        attributedString.addAttribute(
            .link,
            value: HelpDetailKind.Link111.rawValue,
            range: NSString(string: baseString!).range(of: HelpDetailKind.Link111.title)
        )

        textView.attributedText = attributedString
        textView.textColor = .textColor
        textView.frame = CGRect(
            x: 0,
            y: 0,
            width: (UIApplication.shared.windows.first(
                where: { $0.isKeyWindow })?.bounds.width)!,
            height: (UIApplication.shared.windows.first(
                where: { $0.isKeyWindow })?.bounds.height)!
        )
        textView.center = view.center
        textView.isSelectable = true
        textView.isEditable = false
        textView.delegate = self
        view.addSubview(textView)
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
            addBannerViewToView(gADBannerView, constant: 30 * -1)
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
    
    // 画面遷移の準備　勘定科目画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // ③遷移先ViewCntrollerの取得
        if let navigationController = segue.destination as? UINavigationController,
           let viewController = navigationController.topViewController as? SettingsHelpDetailViewController {
            
            // 詳細画面を開く処理
            viewController.navigationItem.title = helpDetailKind.title
            viewController.helpDetailKind = helpDetailKind
        }
    }
}

extension SettingsHelpViewController: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if let helpDetailKind = HelpDetailKind(rawValue: URL.absoluteString) {
            self.helpDetailKind = helpDetailKind
        }
        // 別の画面に遷移
        performSegue(withIdentifier: "toDetailScreen", sender: nil)
        
        return false // 通常のURL遷移を行わない
    }
}

// extension SettingsHelpViewController: UITextViewDelegate {
//    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        let urlString = URL.absoluteString
//        if urlString == "TermOfUseLink" {
//            // Storyboardを呼び出し
//            let storyboard = UIStoryboard(name: "SettingsHelpDetailViewController", bundle: nil)
//            // Storyboard内のViewControllerをIDから呼び出し
//            let viewController = storyboard.instantiateViewController(withIdentifier: "TermOfUse")
//            // 画面遷移
//            navigationController?.pushViewController(viewController, animated: true)
//            return false // 通常のURL遷移を行わない
//        }
//        return true // 通常のURL遷移を行う
//    }
// }
