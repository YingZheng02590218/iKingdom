//
//  SettingsTaxonomyListTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/09/12.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import GoogleMobileAds // マネタイズ対応
import UIKit

// 表示科目一覧クラス
class SettingsTaxonomyListTableViewController: UITableViewController {

    var gADBannerView: GADBannerView!

    // セグメントスイッチ
    @IBOutlet var segmentedControl: UISegmentedControl!

    var howToUse = false // 勘定科目　詳細　設定画面からの遷移の場合はtrue
    var numberOfTaxonomyAccount: Int = 0 // 設定勘定科目番号
    var addAccount = false // 勘定科目　詳細　設定画面からの遷移で勘定科目追加の場合はtrue

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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        1 // 5
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return "貸借対照表"
        case 1:
            return "損益計算書"
        case 2:
            //            return "包括利益計算書"
            //        case 3:
            //            return "株主資本変動計算書"
            //        case 4:
            return "キャッシュ・フロー計算書"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース　表示科目
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
    // セルを生成して返却するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 決算書別に表示科目を取得
        var sheet = 0
        if segmentedControl.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        } else if segmentedControl.selectedSegmentIndex == 1 {
            sheet = 1 // PL
            //        } else if segmentedControl.selectedSegmentIndex == 2 {
            //            sheet = 4 // CF
        }
        let objects = DataBaseManagerSettingsTaxonomy.shared.getBigCategoryAll(section: sheet)

        // ① UI部品を指定　TableViewCellCategory
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_category_BSandPL", for: indexPath) as? CategoryListTableViewCell else { return UITableViewCell() }
        // 勘定科目の名称をセルに表示する 丁数(元丁) 勘定名
        // 表示科目に紐づけられている勘定科目の数を表示する
        // 勘定科目モデルの階層と同じ勘定科目モデルを取得
        //        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        //        let objectss = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: String(objects[indexPath.row].number))
        //        let objectsss = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccountSWInTaxonomy(numberOfTaxonomy: String(objects[indexPath.row].number), switching: true)
        //        let objectssss = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccountSWInTaxonomy(numberOfTaxonomy: String(objects[indexPath.row].number), switching: false)
        cell.textLabel?.textColor = .textColor
        // 階層毎にスペースをつける
        if objects[indexPath.row].category1.isEmpty {
            cell.textLabel?.text = "\(objects[indexPath.row].number), \(objects[indexPath.row].category as String)"
        } else if objects[indexPath.row].category2.isEmpty {
            cell.textLabel?.text = "\(objects[indexPath.row].number),   \(objects[indexPath.row].category as String)"
        } else if objects[indexPath.row].category3.isEmpty { // 資産の部　など
            cell.textLabel?.text = "\(objects[indexPath.row].number),     \(objects[indexPath.row].category as String)"
        } else if objects[indexPath.row].category4.isEmpty {
            cell.textLabel?.text = "\(objects[indexPath.row].number),       \(objects[indexPath.row].category as String)"
            //            cell.label.text = "ON: \(objectsss.count),  OFF: \(objectssss.count), DB: \(objects[indexPath.row].switching)"
        } else if objects[indexPath.row].category5.isEmpty {
            cell.textLabel?.text = "\(objects[indexPath.row].number),         \(objects[indexPath.row].category as String)"
            //            cell.label.text = "ON: \(objectsss.count),  OFF: \(objectssss.count), DB: \(objects[indexPath.row].switching)"
        } else if objects[indexPath.row].category6.isEmpty {
            cell.textLabel?.text = "\(objects[indexPath.row].number),           \(objects[indexPath.row].category as String)"
            //            cell.label.text = "ON: \(objectsss.count),  OFF: \(objectssss.count), DB: \(objects[indexPath.row].switching)"
        } else if objects[indexPath.row].category7.isEmpty {
            cell.textLabel?.text = "\(objects[indexPath.row].number),             \(objects[indexPath.row].category as String)"
            //            cell.label.text = "ON: \(objectsss.count),  OFF: \(objectssss.count), DB: \(objects[indexPath.row].switching)"
        } else {
            cell.textLabel?.text = "\(objects[indexPath.row].number),               \(objects[indexPath.row].category as String)"
            //            cell.label.text = "ON: \(objectsss.count),  OFF: \(objectssss.count), DB: \(objects[indexPath.row].switching)"
        }

        cell.label.textAlignment = .right
        cell.label.textColor = .systemGreen
        // UIButtonを非表示
        cell.toggleButton.isHidden = true
        // UIButtonを無効化
        cell.toggleButton.isEnabled = false
        if objects[indexPath.row].abstract { // 抽象区分の場合
            // 背景色
            cell.backgroundColor = .baseColor
            // UILabelを非表示
            cell.label.isHidden = true
            // セルの選択不可にする
            cell.selectionStyle = .none
        } else {
            // 背景色
            cell.backgroundColor = .mainColor2
            // 表示科目の連番
            cell.tag = objects[indexPath.row].number
            // UILabelを表示
            cell.label.isHidden = objects[indexPath.row].switching ? false : true // 表示科目の有効無効
            // 表示科目選択　の場合
            if howToUse {
                // セルの選択を許可
                cell.selectionStyle = .default
            }
        }
        // チェックマークを外す
        cell.accessoryType = .none
        // 勘定科目を編集する場合　勘定科目の連番から勘定科目を取得　表示科目を知るため
        if let dataBaseSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount.shared.getSettingsTaxonomyAccount(number: numberOfTaxonomyAccount) {
            let numberOfTaxonomy = Int(dataBaseSettingsTaxonomyAccount.numberOfTaxonomy) // 表示科目
            // 設定勘定科目に紐づけられている設定表示科目に、チェックマークをつける
            if objects[indexPath.row].number == numberOfTaxonomy {
                // チェックマークを入れる
                cell.accessoryType = .checkmark
            }
        }
        print(objects[indexPath.row].number, objects[indexPath.row].switching)
        return cell
    }
    // 勘定科目の有効無効　変更時のアクション TableViewの中のどのTableViewCellに配置されたトグルスイッチかを探す
    @objc func hundleSwitch(sender: UISwitch) {
        // UISwitchが配置されたセルを探す
        var hoge = sender.superview // 親ビュー
        while hoge?.isKind(of: CategoryListTableViewCell.self) == false {
            hoge = hoge?.superview
        }
    }
    // トグルスイッチの切り替え　データベースを更新
    func changeSwitch(tag: Int, isOn: Bool) {
        // 勘定科目のスイッチを設定する 末端科目が一つも存在しない表示科目はスイッチOFFとなり、表示科目をOFFにできない。2020/09/12
        //        // データベース
        //        let databaseManagerSettingsCategory = DatabaseManagerSettingsCategory() //データベースマネジャー
        //        databaseManagerSettingsCategory.updateSettingsCategorySwitching(tag: tag, isOn: isOn)
        //        // 表示科目のスイッチを設定する　勘定科目がひとつもなければOFFにする
        //        // データベース
        //        let dataBaseSettingsCategoryBSAndPL = DataBaseManagerSettingsTaxonomy() //データベースマネジャー
        //        dataBaseSettingsCategoryBSAndPL.updateSettingsCategoryBSAndPLSwitching()
    }
    // 追加・編集機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // 画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if IndexPath(row: 0, section: 1) != self.tableView.indexPathForSelectedRow! { // 表示科目名以外は遷移しない
            return false // false:画面遷移させない
        }
        return true
    }
    // セルが選択された時に呼び出される
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 表示科目選択　の場合
        if howToUse {
            // 選択されたセルを取得
            let cell = tableView.cellForRow(at: indexPath)
            if cell?.selectionStyle == UITableViewCell.SelectionStyle.none { // セルが選択不可
                print("抽象区分　表示科目")
            } else {
                // 確認のポップアップを表示したい
                self.showPopover(indexPath: indexPath)
            }
        }
    }
    // 編集機能 アラートのポップアップを表示
    private func showPopover(indexPath: IndexPath) {
        // 選択されたセルに表示された表示科目のプライマリーキーを取得
        // 決算書別に表示科目を取得
        var sheet = 0
        if segmentedControl.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        } else if segmentedControl.selectedSegmentIndex == 1 {
            sheet = 1 // PL
            //        } else if segmentedControl.selectedSegmentIndex == 2 {
            //            sheet = 4 // CF
        }
        let objects = DataBaseManagerSettingsTaxonomy.shared.getBigCategoryAll(section: sheet)
        // 呼び出し元のコントローラを取得
        if addAccount { // 新規で設定勘定科目を追加する場合　addButtonを押下
            if let presentingViewController = self.presentingViewController as? SettingsCategoryDetailTableViewController { // 勘定科目詳細コントローラーを取得
                let alert = UIAlertController(title: "変更", message: "勘定科目に紐付ける表示科目を変更しますか？", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    print("OK アクションをタップした時の処理")
                    // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
                    self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                        presentingViewController.numberOfTaxonomy = objects[indexPath.row].number // 選択された表示科目の番号を渡す
                        presentingViewController.numberOfAccount = self.numberOfTaxonomyAccount // 勘定科目　詳細画面 の勘定科目番号に代入
                        presentingViewController.showNumberOfTaxonomy() // 選択された表示科目名を表示
                        //                    let num = presentingViewController.changeTaxonomyOfTaxonomyAccount(number: self.numberOfTaxonomyAccount, numberOfTaxonomy: objects[indexPath.row].number)
                        //                    presentingViewController.numberOfAccount = num // 勘定科目　詳細画面 の勘定科目番号に代入
                        //                    presentingViewController.viewWillAppear(true) // TableViewをリロードする処理がある
                        self.addAccount = false // 新規追加後にフラグを倒す
                    })
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Cancel アクションをタップした時の処理")
                    self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                        self.addAccount = false // 新規追加後にフラグを倒す
                    })
                }))
                present(alert, animated: true, completion: nil)
                //            addAccount = false // 新規追加後にフラグを倒す
            }
        } else { // 既存の設定勘定科目を選択された場合
            var presentingViewController: SettingsCategoryDetailTableViewController?
            
            if let settingsCategoryDetailTableViewController = self.presentingViewController as? SettingsCategoryDetailTableViewController {
                presentingViewController = settingsCategoryDetailTableViewController
            } else {
                
                if let tabBarController = self.presentingViewController as? UITabBarController, // 基底となっているコントローラ
                   let splitViewController = tabBarController.selectedViewController as? UISplitViewController, // 基底のコントローラから、選択されているを取得する
                   let navigationController = splitViewController.viewControllers[0]  as? UINavigationController, // スプリットコントローラから、現在選択されているコントローラを取得する
                   let navigationController2 = navigationController.viewControllers[1] as? UINavigationController {
                    print(navigationController2.viewControllers.count)
                    print(navigationController2.viewControllers[0]) // SettingsCategoryTableViewController
                    print(navigationController2.viewControllers[1]) // CategoryListCarouselAndPageViewController
                    print(navigationController2.viewControllers[2]) // SettingsCategoryDetailTableViewController

                    presentingViewController = navigationController2.viewControllers[2] as? SettingsCategoryDetailTableViewController // 勘定科目詳細コントローラーを取得
                }
            }
            let alert = UIAlertController(title: "変更", message: "勘定科目に紐付ける表示科目を変更しますか？", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                print("OK アクションをタップした時の処理")
                // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
                self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                    presentingViewController?.changeTaxonomyOfTaxonomyAccount(number: self.numberOfTaxonomyAccount, numberOfTaxonomy: objects[indexPath.row].number)
                    presentingViewController?.numberOfAccount = self.numberOfTaxonomyAccount // 勘定科目　詳細画面 の勘定科目番号に代入
                    presentingViewController?.viewWillAppear(true) // TableViewをリロードする処理がある
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            present(alert, animated: true, completion: nil)
        }
    }
}
