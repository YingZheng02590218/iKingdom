//
//  SettingsUpgradeViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/02/13.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import MXParallaxHeader
import SafariServices // アプリ内でブラウザ表示
import StoreKit // アップグレード機能
import SwiftyStoreKit // アップグレード機能
import UIKit

// アップグレード画面
class SettingsUpgradeViewController: UIViewController {
    
    @IBOutlet private var scrollView: UIScrollView!
    // 【Xcode11】いつもスクロールしなかったUIScrollView + AutoLayoutをやっと攻略できた
    // https://swallow-incubate.com/archives/blog/20200805
    //    手順
    //    UIScrollViewを設置する
    //    UIScrollViewとViewに制約を設定する
    //    UIScrollViewにUIView（ContentView）を配置する
    //    UIScrollViewとContentViewに制約を設定する
    //    ContentViewに高さを設定する
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var headerView: UIView!
    var posX: CGFloat = 0
    
    // サブスクリプション プラン名
    @IBOutlet var titleLabel: UILabel!
    // 広告なし
    @IBOutlet var invisibileAdsTitleLabel: UILabel!
    @IBOutlet var invisibileAdsSubTitleLabel: UILabel!
    // 購入
    @IBOutlet var button: EMTNeumorphicButton!
    @IBOutlet var explainLabel: UILabel!
    // 復元
    @IBOutlet var restoreButton: EMTNeumorphicButton!
    @IBOutlet var restoreExplainLabel: UILabel!
    // 解約
    @IBOutlet var howToCancelButton: UIButton!
    // プラポリ
    @IBOutlet var privacyPolicyButton: UIButton!
    // フィードバック
    private let feedbackGeneratorHeavy: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    // インジゲーター
    var activityIndicatorView = UIActivityIndicatorView()
    let backView = UIView()
    
    private var products: [SKProduct] = [] {
        didSet {
            // ラベル レスポンスの値
            setupExplainLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "アップグレード"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
        // ラベル 初期値
        setupExplainLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 価格を取得
        UpgradeManager.shared.purchaseGetInfo(
            productId: [UpgradeManager.PRODUCTIDSTANDARDPLAN],
            completion: { products in
                self.products = products
            }
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // ニューモフィズム　ボタンとビューのデザインを指定する
        createEMTNeumorphicView()
        // ヘッダービュー
        scrollView.parallaxHeader.view = headerView
        scrollView.parallaxHeader.height = self.view.frame.width * 0.7
        scrollView.parallaxHeader.mode = .top
        scrollView.parallaxHeader.minimumHeight = 0
        scrollView.contentSize = contentView.frame.size
        scrollView.flashScrollIndicators()
    }
    
    // MARK: EMTNeumorphicView
    // ニューモフィズム　ボタンとビューのデザインを指定する
    private func createEMTNeumorphicView() {
        // 購入
        button.setTitleColor(.accentColor, for: .normal)
        button.neumorphicLayer?.cornerRadius = 15
        button.setTitleColor(.accentColor, for: .selected)
        button.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button.neumorphicLayer?.edged = Constant.edged
        button.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        // 復元
        restoreButton.setTitleColor(.accentColor, for: .normal)
        restoreButton.neumorphicLayer?.cornerRadius = 15
        restoreButton.setTitleColor(.accentColor, for: .selected)
        restoreButton.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        restoreButton.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        restoreButton.neumorphicLayer?.edged = Constant.edged
        restoreButton.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        restoreButton.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
    }
    // ラベル
    func setupExplainLabel() {
        guard let language = Locale.preferredLanguages.first else { return } // FIXME: language    String    "en-JP"
        var localizedTitle = "----"
        var localizedPrice = language == "ja-JP" ? "----円" : "¥----"
        var localizedSubscriptionPeriod = language == "ja-JP" ? "-年" : "-yr"
        if let product = products.first,
           let price = product.localizedPrice {
            localizedTitle = product.localizedTitle
            localizedPrice = price
            localizedSubscriptionPeriod = product.localizedSubscriptionPeriod
        }
        print(localizedTitle, localizedPrice, localizedSubscriptionPeriod)
        // サブスクリプション　タイトル「Standard Plan」
        titleLabel.text = localizedTitle
        // 広告なし
        invisibileAdsTitleLabel.text = language == "ja-JP" ? "広告なし" : "Go ad-free"
        invisibileAdsSubTitleLabel.text = language == "ja-JP" ? "作業に集中することができます" : "You can more focus"
        // 購入済みを表すアイコンの色を緑色へ切り替えるためにリロードする
        if UpgradeManager.shared.inAppPurchaseFlag {
            self.button.setImage(UIImage(systemName: "checkmark.seal.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.button.imageView?.tintColor = .green
        } else {
            self.button.setImage(UIImage(systemName: "checkmark.seal", withConfiguration: UIImage.SymbolConfiguration(scale: .large))?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.button.imageView?.tintColor = .mainColor
        }
        // 購入
        button.setTitle("\(localizedPrice) / \(localizedSubscriptionPeriod)　", for: .normal)
        // 復元
        if language == "ja-JP" {
            restoreButton.setTitle("購入を復元する", for: .normal)
        } else {
            restoreButton.setTitle("Restore Purchases", for: .normal)
        }
        // 購入の説明
        if language == "ja-JP" {
            explainLabel.text = """
                                ● 有料版：スタンダードプラン
                                年間払い \(localizedPrice) / \(localizedSubscriptionPeriod)
                                スタンダードプランは、アプリ内の全ての広告が表示されなくなり、ユーザービリティを高めることができます。
                                
                                ● 自動継続課金について
                                期間終了日の24時間以上前に自動更新の解除をされない場合、契約期間が自動更新されます。自動更新の課金は、契約期間の終了後24時間以内に行われます。
                                
                                ● 注意点
                                ・アプリ内で課金された方は上記以外の方法での解約できません。
                                ・当月分のキャンセルについては受け付けておりません。
                                ・iTunesアカウントを経由して課金されます。
                                """
        } else {
            explainLabel.text = """
                                ● Paid version: Standard plan
                                Annual payment \(localizedPrice) / \(localizedSubscriptionPeriod) With the standard plan, all advertisements in the app will not be displayed, and usability can be improved.
                                
                                ● About automatic renewal billing
                                If you do not cancel the automatic renewal more than 24 hours before the end date of the period, the contract period will be automatically renewed. You will be charged for automatic renewal within 24 hours of the end of the contract period.
                                
                                ● Notes
                                ・ Those who have been charged within the app cannot cancel the contract by any method other than the above.
                                ・ We do not accept cancellations for the current month.
                                ・ You will be charged via your iTunes account.
                                """
        }
        //            cell.textLabel?.text = "プレミアムプラン"
        //            cell.label.text = "￥ 6,000 / 年"
        //            cell.textLabel?.text = "オプショナルプラン"
        //            cell.label.text = "￥ 3,600 / 年"
        // "プレミアムプランは、クラウド機能が解放されます。アプリ内に保存された大切な仕訳データをiCloud上にバックアップを取ることで、iPhone本体が破損した場合などの、万が一に備えてデータの復元が可能な状態を保ちます。他には、iPadなどのタブレット端末など、同じAppleアカウントでログインしているデバイスと、データを同期させることができるので、複数のデバイスから仕訳入力ができます。\n(スタンダードプランとオプショナルプランの機能を含みます)"
        // "オプショナルプランは、さらにユーザービリティを高めるための、細かな操作設定が可能となります。\n(スタンダードプランの機能を含みます)"
        // 復元の説明
        if language == "ja-JP" {
            restoreExplainLabel.text = """
                                        ● 機種変更時の復元
                                        機種変更時には、以前購入した有料版を復元することができます。
                                        購入時と同じAppleIDでiPhone・iPad端末のiTunesにログインしてください。
                                        """
        } else {
            restoreExplainLabel.text = """
                                        ● Restoration when changing models
                                        When changing models, you can restore the previously purchased paid version for free.
                                        Please log in to iTunes on your iPhone / iPad device with the same Apple ID as when you purchased it.
                                        """
        }
        // 解約方法
        if language == "ja-JP" {
            howToCancelButton.setTitle("解約方法", for: .normal)
        } else {
            howToCancelButton.setTitle("How to cancel", for: .normal)
        }
        // プライバシーポリシー / 利用規約
        if language == "ja-JP" {
            privacyPolicyButton.setTitle("プライバシーポリシー / 利用規約", for: .normal)
        } else {
            privacyPolicyButton.setTitle("Privacy Policy / Terms of Use", for: .normal)
        }
    }
    // 購入
    @IBAction func purchaseButtonTapped(_ sender: EMTNeumorphicButton) {
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sender.isSelected = !sender.isSelected
            // フィードバック
            if #available(iOS 10.0, *), let generator = self.feedbackGeneratorHeavy as? UIImpactFeedbackGenerator {
                generator.impactOccurred()
            }
        }
        // インジゲーターを開始
        self.showActivityIndicatorView()
        DispatchQueue.global(qos: .default).async {
            // 購入
            UpgradeManager.shared.purchase(
                productId: UpgradeManager.PRODUCTIDSTANDARDPLAN,
                completion: { isSuccess in
                    // インジケーターを終了
                    self.finishActivityIndicatorView()
                    // ラベル レスポンスの値
                    self.setupExplainLabel()
                }
            )
        }
    }
    // リストア
    @IBAction func restoreButtonTapped(_ sender: EMTNeumorphicButton) {
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sender.isSelected = !sender.isSelected
            // フィードバック
            if #available(iOS 10.0, *), let generator = self.feedbackGeneratorHeavy as? UIImpactFeedbackGenerator {
                generator.impactOccurred()
            }
        }
        // インジゲーターを開始
        self.showActivityIndicatorView()
        DispatchQueue.global(qos: .default).async {
            // リストア
            UpgradeManager.shared.verifyPurchase(
                productId: UpgradeManager.PRODUCTIDSTANDARDPLAN,
                completion: { isSuccess in
                    // インジケーターを終了
                    self.finishActivityIndicatorView()
                    // フィードバック
                    let generator = UINotificationFeedbackGenerator()
                    if isSuccess {
                        generator.notificationOccurred(.success)
                    } else {
                        generator.notificationOccurred(.error)
                    }
                    let alert = UIAlertController(title: "復元", message: "\(isSuccess ? "成功しました" : "失敗しました")", preferredStyle: .alert)
                    self.present(alert, animated: true) { () -> Void in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            )
        }
    }
    // 解約
    @IBAction func howToCancelButtonTapped(_ sender: Any) {
        // アプリ内でブラウザを開く
        if Locale.current.regionCode == "JP" {
            let url = URL(
                string:
                    "https://support.apple.com/ja-jp/HT202039#:~:text=%E3%80%8C%E3%83%A6%E3%83%BC%E3%82%B6%E3%81%8A%E3%82%88%E3%81%B3%E3%82%A2%E3%82%AB%E3%82%A6%E3%83%B3%E3%83%88%E3%80%8D%E3%82%92%E9%81%B8%E6%8A%9E,%E3%81%95%E3%82%8C%E3%82%8B%E3%81%93%E3%81%A8%E3%82%82%E3%81%82%E3%82%8A%E3%81%BE%E3%81%9B%E3%82%93)%E3%80%82"
            )
            if let url = url {
                let vc = SFSafariViewController(url: url)
                present(vc, animated: true, completion: nil)
            }
        } else {
            // アプリ内でブラウザを開く
            let url = URL(string: "https://support.apple.com/en-us/HT202039")
            if let url = url {
                let vc = SFSafariViewController(url: url)
                present(vc, animated: true, completion: nil)
            }
        }
    }
    // プライバシーポリシー　利用規約
    @IBAction func privacyPolicyButtonTapped(_ sender: Any) {
        // iPad で、Facebookページを開けない現象の対応
//        // アプリ内でブラウザを開く
//        let url = URL(string: "https://www.facebook.com/profile.php?id=100064085410025")
//        if let url = url {
//            let vc = SFSafariViewController(url: url)
//            present(vc, animated: true, completion: nil)
//        }
        // 外部でブラウザを開く
        let url = URL(string: "https://www.facebook.com/profile.php?id=100064085410025")
        if let url = url {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    // インジゲーターを開始
    func showActivityIndicatorView() {
        DispatchQueue.main.async {
            // タブの無効化
            if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
                for tabBarItem in arrayOfTabBarItems {
                    if let tabBarItem = tabBarItem as? UITabBarItem {
                        tabBarItem.isEnabled = false
                    }
                }
            }
            // 背景になるView
            self.backView.backgroundColor = .mainColor
            // 表示位置を設定（画面中央）
            self.activityIndicatorView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            // インジケーターのスタイルを指定（白色＆大きいサイズ）
            self.activityIndicatorView.style = UIActivityIndicatorView.Style.large
            // インジケーターを View に追加
            self.backView.addSubview(self.activityIndicatorView)
            // インジケーターを表示＆アニメーション開始
            self.activityIndicatorView.startAnimating()
            
            // tabBarControllerのViewを使う
            guard let tabBarView = self.tabBarController?.view else {
                return
            }
            // 背景をNavigationControllerのViewに貼り付け
            tabBarView.addSubview(self.backView)
            
            // サイズ合わせはAutoLayoutで
            self.backView.translatesAutoresizingMaskIntoConstraints = false
            self.backView.topAnchor.constraint(equalTo: tabBarView.topAnchor).isActive = true
            self.backView.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor).isActive = true
            self.backView.leftAnchor.constraint(equalTo: tabBarView.leftAnchor).isActive = true
            self.backView.rightAnchor.constraint(equalTo: tabBarView.rightAnchor).isActive = true
        }
    }
    // インジケーターを終了
    func finishActivityIndicatorView() {
        // 非同期処理などが終了したらメインスレッドでアニメーション終了
        DispatchQueue.main.async {
            // アニメーション終了
            self.activityIndicatorView.stopAnimating()
            // タブの有効化
            if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
                for tabBarItem in arrayOfTabBarItems {
                    if let tabBarItem = tabBarItem as? UITabBarItem {
                        tabBarItem.isEnabled = true
                    }
                }
            }
            self.backView.removeFromSuperview()
        }
    }
}

extension SettingsUpgradeViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        posX = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = posX
    }
}
