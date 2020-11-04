//
//  TableViewControllerSettingsTaxonomyList.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/09/12.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 表示科目一覧　画面
class TableViewControllerSettingsTaxonomyList: UITableViewController {

    // セグメントスイッチ
    @IBOutlet weak var segmentedControl_switch: UISegmentedControl!
    @IBAction func segmentedControl(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        // 設定表示科目　初期化　表示科目のスイッチを設定する　勘定科目のスイッチONが、ひとつもなければOFFにする
//        let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
//        dataBaseManagerSettingsTaxonomy.initializeSettingsTaxonomy()
//        if segmentedControl_switch.selectedSegmentIndex == 0 {
//        }else if segmentedControl_switch.selectedSegmentIndex == 1 {
//        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1 //5
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            return "資産の部"
//        case 1:
//            return "負債の部"
//        case 2:
//            return "純資産の部"
//        case 3:
//            return "費用の部"
//        case 4:
//            return "収益の部"
//        default:
//            return ""
//        }
        switch segmentedControl_switch.selectedSegmentIndex {
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
        let dataBaseManagerSettingsCategoryBSAndPL = DataBaseManagerSettingsTaxonomy() //データベースマネジャー
        var sheet = 0
        if segmentedControl_switch.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        }else if segmentedControl_switch.selectedSegmentIndex == 1 {
            sheet = 1 // PL
//        }else if segmentedControl_switch.selectedSegmentIndex == 2 {
//            sheet = 4 // CF
        }
        let objects = dataBaseManagerSettingsCategoryBSAndPL.getBigCategoryAll(section: sheet) // どのセクションに表示するセルかを判別するため引数で渡す
        return objects.count
    }
    //セルを生成して返却するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCellCategoryList {
        // 決算書別に表示科目を取得
        let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
        var sheet = 0
        if segmentedControl_switch.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        }else if segmentedControl_switch.selectedSegmentIndex == 1 {
            sheet = 1 // PL
//        }else if segmentedControl_switch.selectedSegmentIndex == 2 {
//            sheet = 4 // CF
        }
        let objects = dataBaseManagerSettingsTaxonomy.getBigCategoryAll(section: sheet)
    
        //① UI部品を指定　TableViewCellCategory
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_category_BSandPL", for: indexPath) as! TableViewCellCategoryList
        // 勘定科目の名称をセルに表示する 丁数(元丁) 勘定名
        // 表示科目に紐づけられている勘定科目の数を表示する
        // 勘定科目モデルの階層と同じ勘定科目モデルを取得
//        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
//        let objectss = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccountInTaxonomy(numberOfTaxonomy: String(objects[indexPath.row].number))
//        let objectsss = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccountSWInTaxonomy(numberOfTaxonomy: String(objects[indexPath.row].number), switching: true)
//        let objectssss = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccountSWInTaxonomy(numberOfTaxonomy: String(objects[indexPath.row].number), switching: false)
        cell.label.textAlignment = .right
        // 階層毎にスペースをつける
        if objects[indexPath.row].category1 as String == "" {
            cell.textLabel?.text = "\(objects[indexPath.row].number), \(objects[indexPath.row].category as String)"
        }else if objects[indexPath.row].category2 as String == "" {
            cell.textLabel?.text = "\(objects[indexPath.row].number),   \(objects[indexPath.row].category as String)"
        }else if objects[indexPath.row].category3 as String == "" { // 資産の部　など
            cell.textLabel?.text = "\(objects[indexPath.row].number),     \(objects[indexPath.row].category as String)"
        }else if objects[indexPath.row].category4 as String == "" {
            cell.textLabel?.text = "\(objects[indexPath.row].number),       \(objects[indexPath.row].category as String)"
//            cell.label.text = "ON: \(objectsss.count),  OFF: \(objectssss.count), DB: \(objects[indexPath.row].switching)"
        }else if objects[indexPath.row].category5 as String == "" {
            cell.textLabel?.text = "\(objects[indexPath.row].number),         \(objects[indexPath.row].category as String)"
//            cell.label.text = "ON: \(objectsss.count),  OFF: \(objectssss.count), DB: \(objects[indexPath.row].switching)"
        }else if objects[indexPath.row].category6 as String == "" {
            cell.textLabel?.text = "\(objects[indexPath.row].number),           \(objects[indexPath.row].category as String)"
//            cell.label.text = "ON: \(objectsss.count),  OFF: \(objectssss.count), DB: \(objects[indexPath.row].switching)"
        }else if objects[indexPath.row].category7 as String == "" {
            cell.textLabel?.text = "\(objects[indexPath.row].number),             \(objects[indexPath.row].category as String)"
//            cell.label.text = "ON: \(objectsss.count),  OFF: \(objectssss.count), DB: \(objects[indexPath.row].switching)"
        }else {
            cell.textLabel?.text = "\(objects[indexPath.row].number),               \(objects[indexPath.row].category as String)"
//            cell.label.text = "ON: \(objectsss.count),  OFF: \(objectssss.count), DB: \(objects[indexPath.row].switching)"
        }
        cell.label.text = ""
        if objects[indexPath.row].abstract { // 抽象区分の場合
            //UIButtonを非表示
            cell.ToggleButton.isHidden = true
            //UILabelを非表示
            cell.label.isHidden = true
            // セルの選択不可にする
            cell.selectionStyle = .none
        }else {
            // 表示科目の連番
            cell.tag = objects[indexPath.row].number
            // 表示科目の有効無効
            cell.ToggleButton.isOn = objects[indexPath.row].switching
            //UIButtonを無効化
            cell.ToggleButton.isEnabled = false
            //UIButtonを表示
            cell.ToggleButton.isHidden = false
            //UILabelを表示
            cell.label.isHidden = false
            // 表示科目選択　の場合
            if howToUse {
                // セルの選択を許可
                cell.selectionStyle = .default
            }
        }
        print(objects[indexPath.row].number, objects[indexPath.row].switching)
        return cell
    }
    // 勘定科目の有効無効　変更時のアクション TableViewの中のどのTableViewCellに配置されたトグルスイッチかを探す
    @objc func hundleSwitch(sender: UISwitch) {
        // UISwitchが配置されたセルを探す
        var hoge = sender.superview // 親ビュー
        while(hoge!.isKind(of: TableViewCellCategoryList.self) == false) {
            hoge = hoge!.superview
        }
//        let cell = hoge as! TableViewCellCategoryList
        // touchIndexは選択したセルが何番目かを記録しておくプロパティ
//        let touchIndex: IndexPath = self.tableView.indexPath(for: cell)!
//        print("トグルスイッチが変更されたセルのIndexPath:　\(touchIndex)")
//        // データベース
//        let dataBaseManagerSettingsCategoryBSAndPL = DataBaseManagerSettingsTaxonomy() //データベースマネジャー
//        let objects = dataBaseManagerSettingsCategoryBSAndPL.getBigCategoryAll(section: touchIndex.section)
//        // セクション内でonとなっているスイッチが残りひとつの場合は、offにさせない
//        if objects.count <= 1 {
//            if !sender.isOn { // ON から　OFF に切り替えようとした時は効果音を鳴らす
//                print(objects.count)
//                // 効果音
//                let soundIdRing: SystemSoundID = 1000 //
//                AudioServicesPlaySystemSound(soundIdRing)
//            }
//            // ONに強制的に戻す
//            sender.isOn = true
//            changeSwitch(tag: cell.tag, isOn: sender.isOn) // 引数：連番、トグルスイッチ.有効無効
//            //UIButtonを無効化　はしないで、強制的にONに戻す
////            sender.isEnabled = false
//            sender.isEnabled = true
//        }else {
//            // ここからデータベースを更新する
//            changeSwitch(tag: cell.tag, isOn: sender.isOn) // 引数：連番、トグルスイッチ.有効無効
//            //UIButtonを有効化
//            sender.isEnabled = true
//        }
//        tableView.reloadData() // 不要　注意：ここでリロードすると、トグルスイッチが深緑色となり元の緑色に戻らなくなる
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
        //画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if IndexPath(row: 0, section: 1) != self.tableView.indexPathForSelectedRow! { // 表示科目名以外は遷移しない
            return false //false:画面遷移させない
        }
        return true
    }
    var howToUse: Bool = false // 勘定科目　詳細　設定画面からの遷移の場合はtrue
    var numberOfTaxonomyAccount :Int = 0 // 設定勘定科目番号
    var addAccount: Bool = false // 勘定科目　詳細　設定画面からの遷移で勘定科目追加の場合はtrue
    // セルが選択された時に呼び出される
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 表示科目選択　の場合
        if howToUse {
            // 選択されたセルを取得
            let cell = tableView.cellForRow(at:indexPath)
            if cell?.selectionStyle == UITableViewCell.SelectionStyle.none { // セルが選択不可
                print("抽象区分　表示科目")
            }else {
                // チェックマークを入れる
                cell?.accessoryType = .checkmark
                // 確認のポップアップを表示したい
                self.showPopover(indexPath: indexPath)
            }
        }
    }
    // セルの選択が外れた時に呼び出される
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        // チェックマークを外す
        cell?.accessoryType = .none
    }
    // 編集機能 アラートのポップアップを表示
    private func showPopover(indexPath: IndexPath) {
        // 選択されたセルに表示された表示科目のプライマリーキーを取得
        // 決算書別に表示科目を取得
        let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
        var sheet = 0
        if segmentedControl_switch.selectedSegmentIndex == 0 {
            sheet = 0 // BS
        }else if segmentedControl_switch.selectedSegmentIndex == 1 {
            sheet = 1 // PL
//        }else if segmentedControl_switch.selectedSegmentIndex == 2 {
//            sheet = 4 // CF
        }
        let objects = dataBaseManagerSettingsTaxonomy.getBigCategoryAll(section: sheet)
        // 呼び出し元のコントローラを取得
        if addAccount { // 新規で設定勘定科目を追加する場合　addButtonを押下
            let presentingViewController = self.presentingViewController as! TableViewControllerSettingsCategoryDetail // 勘定科目詳細コントローラーを取得
            let alert = UIAlertController(title: "変更", message: "勘定科目に紐付ける表示科目を変更しますか？", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (action: UIAlertAction!) in
                print("OK アクションをタップした時の処理")
                // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
                self.dismiss(animated: true, completion: {
                    [presentingViewController] () -> Void in
                    presentingViewController.numberOfTaxonomy = objects[indexPath.row].number // 選択された表示科目の番号を渡す
                    presentingViewController.numberOfAccount = self.numberOfTaxonomyAccount // 勘定科目　詳細画面 の勘定科目番号に代入
                    presentingViewController.showNumberOfTaxonomy() // 選択された表示科目名を表示
//                    let num = presentingViewController.changeTaxonomyOfTaxonomyAccount(number: self.numberOfTaxonomyAccount, numberOfTaxonomy: objects[indexPath.row].number)
//                    presentingViewController.numberOfAccount = num // 勘定科目　詳細画面 の勘定科目番号に代入
//                    presentingViewController.viewWillAppear(true) // TableViewをリロードする処理がある
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            addAccount = false // 新規追加後にフラグを倒す
        }else { // 既存の設定勘定科目を選択された場合
            let tabBarController = self.presentingViewController as! UITabBarController // 一番基底となっているコントローラ
            let splitViewController = tabBarController.selectedViewController as! UISplitViewController // 基底のコントローラから、スプリットコントローラを取得する
    //        let navigationController1 = splitViewController.viewControllers[0]  as! UINavigationController // スプリットコントローラから、ナビゲーションコントローラを取得する
    //        let navigationController2 = splitViewController.viewControllers[1]  as! UINavigationController // スプリットコントローラから、ナビゲーションコントローラを取得する
    //            let tableViewControllerSettingsCategory = navigationController.viewControllers[0] as! TableViewControllerSettingsCategory // ナビゲーションコントローラから、勘定科目コントローラを取得する
    //            let tableViewControllerCategoryList = navigationController.viewControllers[1] as! TableViewControllerCategoryList // ナビゲーションコントローラから、勘定科目一覧コントローラを取得する
            // iPadとiPhoneで動きが変わるので分岐する
            
            var navigationController: UINavigationController
    //        if UIDevice.current.userInterfaceIdiom == .pad { // iPad
                let navigationController0 = splitViewController.viewControllers[0]  as! UINavigationController // スプリットコントローラから、ナビゲーションコントローラを取得する
    //            let tableViewControllerSettings = navigationController0.viewControllers[0]  as! TableViewControllerSettings
                if navigationController0.viewControllers.count > 1 {
                    // 画面　画面分割表示して幅を1/4に狭めると配列要素[1]にナビゲーションコントローラがある　（横向き）
                    navigationController = navigationController0.viewControllers[1]  as! UINavigationController
                }else {
                    // 画面　画面分割表示して幅を1/2に狭めると配列要素[0]にナビゲーションコントローラがある　（横向き）
                    navigationController = splitViewController.viewControllers[1]  as! UINavigationController // スプリットコントローラから、ナビゲーションコントローラを取得する
                }
    //            let tableViewControllerSettingsCategory = navigationController.viewControllers[0] as! TableViewControllerSettingsCategory
    //            let tableViewControllerCategoryList1 = navigationController.viewControllers[1] as! TableViewControllerCategoryList
    //            let tableViewControllerSettingsCategoryDetail = navigationController.viewControllers[2] as! TableViewControllerSettingsCategoryDetail
    //        }else { // iPhone
    //            navigationController = splitViewController.viewControllers[1]  as! UINavigationController // スプリットコントローラから、ナビゲーションコントローラを取得する
    //        }
            let presentingViewController = navigationController.viewControllers[2] as! TableViewControllerSettingsCategoryDetail // ナビゲーションコントローラから、勘定科目詳細コントローラーを取得
        let alert = UIAlertController(title: "変更", message: "勘定科目に紐付ける表示科目を変更しますか？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) in
            print("OK アクションをタップした時の処理")
            // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: {
                [presentingViewController] () -> Void in
                presentingViewController.changeTaxonomyOfTaxonomyAccount(number: self.numberOfTaxonomyAccount, numberOfTaxonomy: objects[indexPath.row].number)
                presentingViewController.numberOfAccount = self.numberOfTaxonomyAccount // 勘定科目　詳細画面 の勘定科目番号に代入
                presentingViewController.viewWillAppear(true) // TableViewをリロードする処理がある
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        }
    }
}
