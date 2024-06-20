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
    
    // インジゲーター
    var activityIndicatorView = UIActivityIndicatorView()
    let backView = UIView()
    // フィードバック
    private let feedbackGeneratorMedium: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    @objc
    func onSegment(sender: UISegmentedControl) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
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
                    // 勘定科目体系を変更
                    self.change(segStatus: segStatus)
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
    // 勘定科目体系を変更
    func change(segStatus: Bool) {
        // インジゲーターを開始
        self.showActivityIndicatorView()
        DispatchQueue.global(qos: .default).async {
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
            
            // インジケーターを終了
            self.finishActivityIndicatorView()
            Thread.sleep(forTimeInterval: 0.5)
            DispatchQueue.main.async {
                // リロード
                self.tableView.reloadData()
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
            // 非同期処理などを実行（今回は2秒間待つだけ）
            Thread.sleep(forTimeInterval: 1.0)
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
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
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "法人：資本振替仕訳は「繰越利益」勘定を使用します。\n個人事業主：資本振替仕訳は「元入金」勘定を使用します。"
        case 1:
            return "使用する勘定科目を設定することができます。"
        default:
            return nil
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
            cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
            cell.textLabel?.text = "勘定科目一覧"
            cell.textLabel?.textColor = .textColor
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
