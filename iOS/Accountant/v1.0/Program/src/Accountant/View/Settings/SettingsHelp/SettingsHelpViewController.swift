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
    var urlString: String = ""
    
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
            value: "Link0",
            range: NSString(string: baseString!).range(of: "このアプリについて")
        )
        attributedString.addAttribute(
            .link,
            value: "Link1",
            range: NSString(string: baseString!).range(of: "当アプリで採用した会計概念")
        )
        attributedString.addAttribute(
            .link,
            value: "Link2",
            range: NSString(string: baseString!).range(of: "簿記の基礎")
        )
        //        attributedString.addAttribute(
        //            .link,
        //                                      value: "Link3",
        //                                      range: NSString(string: baseString!).range(of: "初期設定の手順")
        // )
        attributedString.addAttribute(
            .link,
            value: "Link4",
            range: NSString(string: baseString!).range(of: "事業者名を設定しよう")
        )
        attributedString.addAttribute(
            .link,
            value: "Link4-1",
            range: NSString(string: baseString!).range(of: "決算日を設定しよう")
        )
        attributedString.addAttribute(
            .link,
            value: "Link4-2",
            range: NSString(string: baseString!).range(of: "会計帳簿を作成しよう")
        )
        attributedString.addAttribute(
            .link,
            value: "Link5",
            range: NSString(string: baseString!).range(of: "勘定科目を設定しよう")
        )
        attributedString.addAttribute(
            .link,
            value: "Link6",
            range: NSString(string: baseString!).range(of: "勘定科目の編集しよう")
        )
        attributedString.addAttribute(
            .link,
            value: "Link7",
            range: NSString(string: baseString!).range(of: "環境設定を確認・変更しよう")
        )
        attributedString.addAttribute(
            .link,
            value: "Link8",
            range: NSString(string: baseString!).range(of: "仕訳を入力する")
        )
        attributedString.addAttribute(
            .link,
            value: "Link9",
            range: NSString(string: baseString!).range(of: "仕訳を修正する")
        )
        attributedString.addAttribute(
            .link,
            value: "Link10",
            range: NSString(string: baseString!).range(of: "仕訳を削除する")
        )
        attributedString.addAttribute(
            .link,
            value: "Link11",
            range: NSString(string: baseString!).range(of: "入力した取引を確認しよう")
        )
        textView.attributedText = attributedString
        textView.textColor = .textColor
        textView.frame = CGRect(
            x: 0,
            y: 0,
            width: (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)!,
            height: (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.height)!
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
            
            if urlString == "Link0" {
                print("このアプリについてのリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "このアプリについて"
                viewController.textViewSwitchNumber = 0
            }
            
            if urlString == "Link1" {
                print("当アプリで採用した会計概念のリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "当アプリで採用した会計概念"
                viewController.textViewSwitchNumber = 1
            }
            
            if urlString == "Link2" {
                print("簿記の基礎のリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "簿記の基礎"
                viewController.textViewSwitchNumber = 2
            }
            
            if urlString == "Link3" {
                print("初期設定の手順のリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "初期設定の手順"
                viewController.textViewSwitchNumber = 3
            }
            if urlString == "Link4" {
                print("事業者名を設定しようのリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "事業者名を設定しよう"
                viewController.textViewSwitchNumber = 4
            }
            if urlString == "Link4-1" {
                print("決算日を設定しようのリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "決算日を設定しよう"
                viewController.textViewSwitchNumber = 41
            }
            if urlString == "Link4-2" {
                print("会計帳簿を作成しようのリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "会計帳簿を作成しよう"
                viewController.textViewSwitchNumber = 42
            }
            if urlString == "Link5" {
                print("勘定科目を設定しようのリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "勘定科目を設定しよう"
                viewController.textViewSwitchNumber = 5
            }
            if urlString == "Link6" {
                print("勘定科目の編集しようのリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "勘定科目の編集しよう"
                viewController.textViewSwitchNumber = 6
            }
            if urlString == "Link7" {
                print("環境設定を確認・変更しようのリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "環境設定を確認・変更しよう"
                viewController.textViewSwitchNumber = 7
            }
            if urlString == "Link8" {
                print("仕訳を入力するのリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "仕訳を入力する"
                viewController.textViewSwitchNumber = 8
            }
            if urlString == "Link9" {
                print("仕訳を修正するのリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "仕訳を修正する"
                viewController.textViewSwitchNumber = 9
            }
            if urlString == "Link10" {
                print("仕訳を削除するのリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "仕訳を削除する"
                viewController.textViewSwitchNumber = 10
            }
            if urlString == "Link11" {
                print("入力した取引を確認しようのリンクがタップされました")
                // ログ送信処理
                // 詳細画面を開く処理
                viewController.navigationItem.title = "入力した取引を確認しよう"
                viewController.textViewSwitchNumber = 11
            }
        }
    }
}

extension SettingsHelpViewController: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        self.urlString = URL.absoluteString
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
