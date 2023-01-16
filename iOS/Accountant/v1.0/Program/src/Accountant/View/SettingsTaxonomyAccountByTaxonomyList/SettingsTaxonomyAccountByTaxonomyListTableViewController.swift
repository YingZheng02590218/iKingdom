//
//  TableViewControllerCategoryBSAndPLList.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/09/12.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import AudioToolbox // 効果音
import GoogleMobileAds // マネタイズ対応
import UIKit

// 表示科目別勘定科目一覧クラス
class SettingsTaxonomyAccountByTaxonomyListTableViewController: UITableViewController {

    var gADBannerView: GADBannerView!

    // セグメントスイッチ
    @IBOutlet var segmentedControl: UISegmentedControl!

    @IBAction func segmentedControl(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize: GADAdSizeLargeBanner)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOBID
            
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            print(tableView.visibleCells[tableView.visibleCells.count - 1].frame.height)
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: tableView.visibleCells[tableView.visibleCells.count - 1].frame.height * -1)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            view.bringSubviewToFront(gADBannerView)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // データベース
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        //        let objects = dataBaseManagerSettingsCategoryBSAndPL.getAllSettingsCategoryBSAndPLSwitichON() // どのセクションに表示するセルかを判別するため引数で渡す
        var sheet = 0
        if segmentedControl.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        } else if segmentedControl.selectedSegmentIndex == 1 {
            sheet = 1 // PL
            //        } else if segmentedControl.selectedSegmentIndex == 2 {
            //            sheet = 4 // CF
        }
        let objects = DataBaseManagerSettingsTaxonomy.shared.getBigCategoryAll(section: sheet) // どのセクションに表示するセルかを判別するため引数で渡す

        return objects.count
    }
    // セクションヘッダーの高さを決める
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        13 // セクションヘッダーの高さを設定　セルの高さより高くしてメリハリをつける セル(Row Hight )
    }
    // セクションヘッダーの色とか調整する
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // データベース
        var sheet = 0
        if segmentedControl.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        } else if segmentedControl.selectedSegmentIndex == 1 {
            sheet = 1 // PL
            //        } else if segmentedControl.selectedSegmentIndex == 2 {
            //            sheet = 4 // CF
        }
        let objects = DataBaseManagerSettingsTaxonomy.shared.getBigCategoryAll(section: sheet) // どのセクションに表示するセルかを判別するため引数で渡す
        guard let header = view as? UITableViewHeaderFooterView else { return }
        //        header.textLabel?.textColor = UIColor.gray
        // 階層毎にスペースをつける
        if objects[section].category1.isEmpty {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.darkGray
        } else if objects[section].category2.isEmpty {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.darkGray
            
        } else if objects[section].category3.isEmpty { // 資産の部　など
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.gray
        } else if objects[section].category4.isEmpty {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.gray
        } else if objects[section].category5.isEmpty {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.gray
            
        } else if objects[section].category6.isEmpty {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.lightGray
        } else if objects[section].category7.isEmpty {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.lightGray
        } else {
            header.textLabel?.textAlignment = .left
            header.textLabel?.textColor = UIColor.lightGray
        }

        //        let attributedStr = NSMutableAttributedString(string: header.textLabel?.text)
        //        let crossAttr = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        //        header.textLabel?.text = attributedStr
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // データベース
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        //        let objects = dataBaseManagerSettingsCategoryBSAndPL.getAllSettingsCategoryBSAndPLSwitichON() // どのセクションに表示するセルかを判別するため引数で渡す
        var sheet = 0
        if segmentedControl.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        } else if segmentedControl.selectedSegmentIndex == 1 {
            sheet = 1 // PL
            //        } else if segmentedControl.selectedSegmentIndex == 2 {
            //            sheet = 4 // CF
        }
        let objects = DataBaseManagerSettingsTaxonomy.shared.getBigCategoryAll(section: sheet) // どのセクションに表示するセルかを判別するため引数で渡す

        // 階層毎にスペースをつける
        if objects[section].category1.isEmpty {
            return "\(objects[section].number), \(objects[section].category as String)"
        } else if objects[section].category2.isEmpty {
            return "\(objects[section].number),   \(objects[section].category as String)"
        } else if objects[section].category3.isEmpty { // 資産の部　など
            return "\(objects[section].number),     \(objects[section].category as String)"
        } else if objects[section].category4.isEmpty {
            return "\(objects[section].number),       \(objects[section].category as String)"
        } else if objects[section].category5.isEmpty {
            return "\(objects[section].number),         \(objects[section].category as String)"
        } else if objects[section].category6.isEmpty {
            return "\(objects[section].number),           \(objects[section].category as String)"
        } else if objects[section].category7.isEmpty {
            return "\(objects[section].number),             \(objects[section].category as String)"
        } else {
            return "\(objects[section].number),               \(objects[section].category as String)"
        }
        // 勘定科目の名称をセルに表示する 丁数(元丁) 勘定名
        //        return "\(objects[section].category as String)"
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応 bringSubViewToFrontメソッドを使い、広告を最前面に表示します。
            tableView.bringSubviewToFront(gADBannerView)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース　表示科目
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        //        let objects = dataBaseManagerSettingsCategoryBSAndPL.getAllSettingsCategoryBSAndPLSwitichON() // どのセクションに表示するセルかを判別するため引数で渡す
        var sheet = 0
        if segmentedControl.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        } else if segmentedControl.selectedSegmentIndex == 1 {
            sheet = 1 // PL
            //        } else if segmentedControl.selectedSegmentIndex == 2 {
            //            sheet = 4 // CF
        }
        let objects = DataBaseManagerSettingsTaxonomy.shared.getBigCategoryAll(section: sheet) // どのセクションに表示するセルかを判別するため引数で渡す

        // データベース　勘定科目
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objectss = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: String(objects[section].number))
        return objectss.count
    }
    // セルを生成して返却するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース　表示科目
        var sheet = 0
        if segmentedControl.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        } else if segmentedControl.selectedSegmentIndex == 1 {
            sheet = 1 // PL
        } else if segmentedControl.selectedSegmentIndex == 2 {
            sheet = 4 // CF
        }
        let objectssss = DataBaseManagerSettingsTaxonomy.shared.getBigCategoryAll(section: sheet) // どのセクションに表示するセルかを判別するため引数で渡す

        // データベース 勘定科目
        let objects = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: String(objectssss[indexPath.section].number))
        // ① UI部品を指定　TableViewCellCategory
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_category_BSandPL", for: indexPath) as? CategoryListTableViewCell else { return UITableViewCell() }
        // 勘定科目の名称をセルに表示する 丁数(元丁) 勘定名
        cell.textLabel?.text = " \(objects[indexPath.row].number). \(objects[indexPath.row].category as String)"
        cell.textLabel?.textColor = .textColor

        //        cell.label_category.text = " \(objects[indexPath.row].category as String)"
        cell.textLabel?.textAlignment = NSTextAlignment.center
        // 勘定科目の連番
        cell.tag = objects[indexPath.row].number
        // 勘定科目の有効無効
        cell.toggleButton.isOn = objects[indexPath.row].switching
        // 勘定科目の有効無効　変更時のアクションを指定
        cell.toggleButton.addTarget(self, action: #selector(hundleSwitch), for: UIControl.Event.valueChanged)
        // モデルオブフェクトの取得 勘定別に取得
        let objectss = DataBaseManagerJournalEntry.shared.getAllJournalEntryInAccountAll(
            account: objects[indexPath.row].category as String
        ) // 通常仕訳
        let objectsss = DataBaseManagerAdjustingEntry.shared.getAllAdjustingEntryInAccountAll(
            account: objects[indexPath.row].category as String
        ) // 決算整理仕訳
        // 仕訳データが存在する場合、トグルスイッチはOFFにできないように、無効化する
        if objectss.isEmpty && objectsss.isEmpty {
            // UIButtonを有効化
            cell.toggleButton.isEnabled = true
        } else {
            // UIButtonを無効化
            cell.toggleButton.isEnabled = false
        }

        // Accessory Color
        let disclosureImage = UIImage(named: "navigate_next")?.withRenderingMode(.alwaysTemplate)
        let disclosureView = UIImageView(image: disclosureImage)
        disclosureView.tintColor = UIColor.accentColor
        cell.accessoryView = disclosureView

        return cell
    }
    // 勘定科目の有効無効　変更時のアクション TableViewの中のどのTableViewCellに配置されたトグルスイッチかを探す
    @objc func hundleSwitch(sender: UISwitch) {
        // UISwitchが配置されたセルを探す
        var hoge = sender.superview // 親ビュー
        while hoge?.isKind(of: CategoryListTableViewCell.self) == false {
            hoge = hoge?.superview
        }
        guard let cell = hoge as? CategoryListTableViewCell else { return }
        // ここからデータベースを更新する
        print(cell.tag)
        changeSwitch(tag: cell.tag, isOn: sender.isOn) // 引数：連番、トグルスイッチ.有効無効
        // UIButtonを有効化
        sender.isEnabled = true
        //        tableView.reloadData() // 不要　注意：ここでリロードすると、トグルスイッチが深緑色となり元の緑色に戻らなくなる
    }
    // トグルスイッチの切り替え　データベースを更新
    func changeSwitch(tag: Int, isOn: Bool) {
        // 勘定科目のスイッチを設定する 末端科目が一つも存在しない表示科目はスイッチOFFとなり、表示科目をOFFにできない。2020/09/12
        DatabaseManagerSettingsTaxonomyAccount.shared.updateSettingsCategorySwitching(tag: tag, isOn: isOn)
        // 表示科目のスイッチを設定する　勘定科目がひとつもなければOFFにする
        DataBaseManagerSettingsTaxonomy.shared.updateSettingsCategoryBSAndPLSwitching(number: tag)
    }
    // 画面遷移の準備　勘定科目画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        guard let indexPath: IndexPath = self.tableView.indexPathForSelectedRow else { return } // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
        // 表示科目
        //        let objects = dataBaseManagerSettingsCategoryBSAndPL.getAllSettingsCategoryBSAndPLSwitichON() // どのセクションに表示するセルかを判別するため引数で渡す
        var sheet = 0
        if segmentedControl.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        } else if segmentedControl.selectedSegmentIndex == 1 {
            sheet = 1 // PL
        } else if segmentedControl.selectedSegmentIndex == 2 {
            sheet = 4 // CF
        }
        let objectssss = DataBaseManagerSettingsTaxonomy.shared.getBigCategoryAll(section: sheet)
        // 勘定科目
        // let objects = databaseManagerSettings.getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: String(objectssss[indexPath.row].number))
        let objects = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: String(objectssss[indexPath.section].number))
        // segue.destinationの型はUIViewController
        if let tableViewController = segue.destination as? SettingsCategoryDetailTableViewController {
            // 遷移先のコントローラに値を渡す
            tableViewController.numberOfAccount = objects[indexPath.row].number // セルに表示した勘定科目を取得
        }
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
