//
//  SettingsCategoryTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/08/07.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import GoogleMobileAds // マネタイズ対応
import UIKit

// 勘定科目体系クラス
class SettingsCategoryTableViewController: UITableViewController {

    var gADBannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // title設定
        navigationItem.title = "勘定科目体系"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
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
            print(tableView.visibleCells[tableView.visibleCells.count - 1].frame.height)
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: self.tableView.visibleCells[self.tableView.visibleCells.count - 1].frame.height * -1)
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
        // チュートリアル対応 コーチマーク型　初回起動時　7行を追加
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunch_SettingsCategory"
        if userDefaults.bool(forKey: firstLunchKey) {
            // チュートリアル対応 コーチマーク型
            presentAnnotation()
        }
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            view.bringSubviewToFront(gADBannerView)
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
        if let viewController = UIStoryboard(
            name: "SettingsCategoryTableViewController",
            bundle: nil
        ).instantiateViewController(withIdentifier: "Annotation_SettingsCategory") as? AnnotationViewControllerSettingsCategory {
            viewController.alpha = 0.7
            present(viewController, animated: true, completion: nil)
        }
    }
    // コーチマーク画面からコール
    func finishAnnotation() {
        // フラグを倒す
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunch_SettingsCategory"
        userDefaults.set(false, forKey: firstLunchKey)
        userDefaults.synchronize()

        // タブの有効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = true
                }
            }
        }
        // チュートリアル対応 赤ポチ型
        // 赤ポチを終了
        self.tabBarController?.viewControllers?[4].tabBarItem.badgeValue = nil
    }

    // 勘定科目体系　設定スイッチ 切り替え
    @objc func onSegment(sender: UISegmentedControl) {
        // セグメントコントロール　0: 法人, 1:個人
        let segStatus = sender.selectedSegmentIndex == 0 ? true : false
        print("Segment \(segStatus)")

        let alert = UIAlertController(
            title: "変更",
            message: "勘定科目体系を変更しますか？",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .destructive,
                handler: { _ in
                    // 法人/個人フラグ　設定スイッチ
                    UserDefaults.standard.set(segStatus, forKey: "corporation_switch")
                    UserDefaults.standard.synchronize()
                    // 法人/個人フラグ
                    if UserDefaults.standard.bool(forKey: "corporation_switch") {
                        // 更新　スイッチの切り替え
                        // 法人対応 ONに切り替える
                        if let settingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccount(category: "繰越利益") {
                            DatabaseManagerSettingsTaxonomyAccount.shared.updateSettingsCategorySwitching(tag: settingsTaxonomyAccount.number, isOn: true)
                        }
                    } else {
                        // 更新　スイッチの切り替え
                        // 個人事業主対応 ONに切り替える
                        if let settingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccount(category: "元入金") {
                            DatabaseManagerSettingsTaxonomyAccount.shared.updateSettingsCategorySwitching(tag: settingsTaxonomyAccount.number, isOn: true)
                        }
                        if let settingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccount(category: "事業主貸") {
                            DatabaseManagerSettingsTaxonomyAccount.shared.updateSettingsCategorySwitching(tag: settingsTaxonomyAccount.number, isOn: true)
                        }
                        if let settingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccount(category: "事業主借") {
                            DatabaseManagerSettingsTaxonomyAccount.shared.updateSettingsCategorySwitching(tag: settingsTaxonomyAccount.number, isOn: true)
                        }
                    }
                    // 全勘定の合計と残高を計算する　注意：決算日設定機能で決算日を変更後に損益勘定と繰越利益の日付を更新するために必要な処理である
                    let databaseManager = TBModel()
                    databaseManager.setAllAccountTotal()            // 集計　合計残高試算表(残高、合計(決算整理前、決算整理仕訳、決算整理後))
                    databaseManager.calculateAmountOfAllAccount()   // 合計額を計算

                    // リロード
                    self.tableView.reloadData()
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { _ in
                    DispatchQueue.main.async {
                        // 法人/個人フラグ　スイッチを元に戻す
                        sender.selectedSegmentIndex = UserDefaults.standard.bool(forKey: "corporation_switch") ? 0 : 1
                    }
                }
            )
        )
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            // 法人/個人フラグ
            return UserDefaults.standard.bool(forKey: "corporation_switch") ? 2 : 1
        case 2:
            // 法人/個人フラグ
            return UserDefaults.standard.bool(forKey: "corporation_switch") ? 1 : 0
        default:
            return 0
        }
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "勘定科目"
        case 2:
            // 法人/個人フラグ
            return UserDefaults.standard.bool(forKey: "corporation_switch") ? "表示科目" : nil
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            // 法人/個人フラグ
            return UserDefaults.standard.bool(forKey: "corporation_switch") ? "法人：資本振替仕訳は「繰越利益」勘定を使用し、財務諸表に「表示科目」を表示します。" : "個人事業主：資本振替仕訳は「元入金」勘定を使用し、財務諸表に「勘定科目」を表示します。"
        case 1:
            return "使用する勘定科目を設定することができます。"
        case 2:
            // 法人/個人フラグ
            return UserDefaults.standard.bool(forKey: "corporation_switch") ? "決算書上に表示される表示科目を参照することができます。" : nil
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
    }

    override func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = UITableViewCell()

        if indexPath.section == 0 {
            if cell.accessoryView == nil {
                // 法人/個人フラグ　設定スイッチ
                let segment = UISegmentedControl(items: ["法人", "個人"])
                segment.selectedSegmentIndex = UserDefaults.standard.bool(forKey: "corporation_switch") ? 0 : 1
                segment.addTarget(self, action: #selector(onSegment), for: .valueChanged)
                cell.accessoryView = UIView(frame: segment.frame)
                cell.accessoryView?.addSubview(segment)
            }
            cell.textLabel?.text = "勘定科目体系"
            cell.textLabel?.textColor = .textColor
            cell.backgroundColor = .mainColor2
            // セルの選択不可にする
            cell.selectionStyle = .none
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
                cell.textLabel?.text = "勘定科目一覧"
                cell.textLabel?.textColor = .textColor
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "categoriesBSandPL", for: indexPath)
                cell.textLabel?.text = "表示科目別勘定科目一覧"
                cell.textLabel?.textColor = .textColor
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
                cell.textLabel?.text = ""
                cell.textLabel?.textColor = .textColor
            }
        } else {
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "BSandPL", for: indexPath)
                cell.textLabel?.text = "表示科目一覧"
                cell.textLabel?.textColor = .textColor
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
                cell.textLabel?.textColor = .textColor
                cell.textLabel?.text = ""
            }
        }
        if indexPath.section != 0 {
            // Accessory Color
            let disclosureImage = UIImage(named: "navigate_next")?.withRenderingMode(.alwaysTemplate)
            let disclosureView = UIImageView(image: disclosureImage)
            disclosureView.tintColor = UIColor.accentColor
            cell.accessoryView = disclosureView
        }

        return cell
    }
}
