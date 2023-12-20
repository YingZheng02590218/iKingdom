//
//  SettingsOperatingTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/06.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import GoogleMobileAds // マネタイズ対応
import UIKit

// 操作設定クラス
class SettingsOperatingTableViewController: UITableViewController {
    
    @IBOutlet private var gADBannerView: GADBannerView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = .accentColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 年度を追加後に会計期間画面を更新する
        tableView.reloadData()
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize: GADAdSizeMediumRectangle)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOBID
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: -10)
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
    
    // ビューが表示された後に呼ばれる
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            view.bringSubviewToFront(gADBannerView)
        }
        // チュートリアル対応 コーチマーク型　初回起動時　7行を追加
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunch_SettingsJournals"
        if userDefaults.bool(forKey: firstLunchKey) {
            userDefaults.set(false, forKey: firstLunchKey)
            userDefaults.synchronize()
            // FIXME: チュートリアル対応 コーチマーク型
            //            presentAnnotation()
        } else {
            // チュートリアル対応 コーチマーク型
            finishAnnotation()
        }
    }
    // チュートリアル対応 コーチマーク型
    func presentAnnotation() {
        // タブの無効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
            }
        }
        // FIXME: 設定仕訳帳画面のためのAnnotationViewControllerクラスを作成する
        if let viewController = UIStoryboard(
            name: "SettingsOperatingTableViewController",
            bundle: nil
        ).instantiateViewController(withIdentifier: "Annotation_SettingJournals") as? AnnotationViewControllerSettingJournals {
            viewController.alpha = 0.7
            present(viewController, animated: true, completion: nil)
        }
    }
    
    func finishAnnotation() {
        // タブの有効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = true
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        default:
            return 0
        }
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "決算振替仕訳"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "仕訳帳と諸勘定に決算振替仕訳を表示するかどうかを設定することができます。"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? CategoryListTableViewCell else {
            return UITableViewCell()
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18.0)

        cell.label.text = nil
        // 設定操作
        let object = DataBaseManagerSettingsOperating.shared.getSettingsOperating() // 決算整理仕訳 損益振替仕訳 資本振替仕訳
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "損益振替仕訳を表示"
            if let englishFromOfClosingTheLedger0 = object?.EnglishFromOfClosingTheLedger0 {
                // 勘定科目の有効無効
                cell.toggleButton.isOn = englishFromOfClosingTheLedger0
            }
            // 勘定科目の有効無効　変更時のアクションを指定
            cell.toggleButton.addTarget(self, action: #selector(hundleSwitch), for: UIControl.Event.valueChanged)
            cell.toggleButton.tag = 0
            return cell
        case 1:
            cell.textLabel?.text = "資本振替仕訳を表示"
            if let englishFromOfClosingTheLedger1 = object?.EnglishFromOfClosingTheLedger1 {
                // 勘定科目の有効無効
                cell.toggleButton.isOn = englishFromOfClosingTheLedger1
            }
            // 勘定科目の有効無効　変更時のアクションを指定
            cell.toggleButton.addTarget(self, action: #selector(hundleSwitch), for: UIControl.Event.valueChanged)
            cell.toggleButton.tag = 1
            return cell
        case 2:
            cell.textLabel?.text = "残高振替仕訳を表示"
            cell.label.text = "前期繰越、次期繰越"
            if let englishFromOfClosingTheLedger2 = object?.EnglishFromOfClosingTheLedger2 {
                // 勘定科目の有効無効
                cell.toggleButton.isOn = englishFromOfClosingTheLedger2
            }
            // 勘定科目の有効無効　変更時のアクションを指定
            cell.toggleButton.addTarget(self, action: #selector(hundleSwitch), for: UIControl.Event.valueChanged)
            cell.toggleButton.tag = 2
            return cell
        default:
            cell.textLabel?.text = ""
            return cell
        }
    }
    // 有効無効　変更時のアクション
    @objc
    func hundleSwitch(sender: UISwitch) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorHeavy as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // 設定操作        
        if sender.tag == 0 { // 損益振替仕訳
            DataBaseManagerSettingsOperating.shared.updateSettingsOperating(englishFromOfClosingTheLedger: "EnglishFromOfClosingTheLedger0", isOn: sender.isOn)
        } else if sender.tag == 1 { // 資本振替仕訳
            DataBaseManagerSettingsOperating.shared.updateSettingsOperating(englishFromOfClosingTheLedger: "EnglishFromOfClosingTheLedger1", isOn: sender.isOn)
        } else if sender.tag == 2 { // 残高振替仕訳
            DataBaseManagerSettingsOperating.shared.updateSettingsOperating(englishFromOfClosingTheLedger: "EnglishFromOfClosingTheLedger2", isOn: sender.isOn)
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
    }
}
