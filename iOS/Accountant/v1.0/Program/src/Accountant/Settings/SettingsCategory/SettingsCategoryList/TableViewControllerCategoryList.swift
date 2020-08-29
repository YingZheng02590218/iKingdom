//
//  TableViewControllerCategory.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import AudioToolbox // 効果音

class TableViewControllerCategoryList: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        // データベース
//        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
//        if !databaseManagerSettings.checkInitialising() { // データベースにモデルオブフェクトが存在しない場合
//            let masterData = MasterData()
//            masterData.readMasterDataFromCSV()   // マスターデータを作成する
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 勘定科目画面から、仕訳帳画面へ遷移して仕訳を追加した後に、戻ってきた場合はリロードする
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "資産の部"
        case 1:
            return "負債の部"
        case 2:
            return "純資産の部"
        case 3:
            return "費用の部"
        case 4:
            return "収益の部"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = databaseManagerSettings.getSettings(section: section) // どのセクションに表示するセルかを判別するため引数で渡す
        return objects.count
    }
    //セルを生成して返却するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCellCategoryList {
    // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = databaseManagerSettings.getSettings(section: indexPath.section) // どのセクションに表示するセルかを判別するため引数で渡す
        //① UI部品を指定　TableViewCellCategory
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_category", for: indexPath) as! TableViewCellCategoryList
        // 勘定科目の名称をセルに表示する 丁数(元丁) 勘定名
        cell.textLabel?.text = " \(objects[indexPath.row].number). \(objects[indexPath.row].category as String)"
//        cell.label_category.text = " \(objects[indexPath.row].category as String)"
        // 勘定科目の連番
        cell.tag = objects[indexPath.row].number
        // 勘定科目の有効無効
        cell.ToggleButton.isOn = objects[indexPath.row].switching
        // 勘定科目の有効無効　変更時のアクションを指定
        cell.ToggleButton.addTarget(self, action: #selector(hundleSwitch), for: UIControl.Event.valueChanged)
    // データベース
        let dataBaseManagerAccount = DataBaseManagerAccount() //データベースマネジャー
        // モデルオブフェクトの取得 勘定別に取得
        let objectss = dataBaseManagerAccount.getAllJournalEntryInAccount(account: objects[indexPath.row].category as String)//通常仕訳
        let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccount(account: objects[indexPath.row].category as String)//決算整理仕訳
        // 仕訳データが存在する場合、トグルスイッチはOFFにできないように、無効化する
        if objectss.count <= 0 && objectsss.count <= 0 {
            //UIButtonを有効化
            cell.ToggleButton.isEnabled = true
        }else {
            //UIButtonを無効化
            cell.ToggleButton.isEnabled = false
        }

        return cell
    }
    // 勘定科目の有効無効　変更時のアクション TableViewの中のどのTableViewCellに配置されたトグルスイッチかを探す
    @objc func hundleSwitch(sender: UISwitch) {
        // UISwitchが配置されたセルを探す
        var hoge = sender.superview // 親ビュー
        while(hoge!.isKind(of: TableViewCellCategoryList.self) == false) {
            hoge = hoge!.superview
        }
        let cell = hoge as! TableViewCellCategoryList
        // touchIndexは選択したセルが何番目かを記録しておくプロパティ
        let touchIndex: IndexPath = self.tableView.indexPath(for: cell)!
//        print("トグルスイッチが変更されたセルのIndexPath:　\(touchIndex)")
        // データベース
        let databaseManagerSettingsCategory = DatabaseManagerSettingsCategory() //データベースマネジャー
        let objects = databaseManagerSettingsCategory.getSettingsSwitchingOn(section: touchIndex.section)
        // セクション内でonとなっているスイッチが残りひとつの場合は、offにさせない
        if objects.count <= 1 {
            if !sender.isOn { // ON から　OFF に切り替えようとした時は効果音を鳴らす
                print(objects.count)
                // 効果音
                let soundIdRing: SystemSoundID = 1000 //
                AudioServicesPlaySystemSound(soundIdRing)
            }
            // ONに強制的に戻す
            sender.isOn = true
            changeSwitch(tag: cell.tag, isOn: sender.isOn) // 引数：連番、トグルスイッチ.有効無効
            //UIButtonを無効化　はしないで、強制的にONに戻す
//            sender.isEnabled = false
            sender.isEnabled = true
        }else {
            // ここからデータベースを更新する
            changeSwitch(tag: cell.tag, isOn: sender.isOn) // 引数：連番、トグルスイッチ.有効無効
            //UIButtonを有効化
            sender.isEnabled = true
        }
//        tableView.reloadData() // 不要　注意：ここでリロードすると、トグルスイッチが深緑色となり元の緑色に戻らなくなる
    }
    // トグルスイッチの切り替え　データベースを更新
    func changeSwitch(tag: Int, isOn: Bool) {
        // 勘定科目のスイッチを設定する
        // データベース
        let databaseManagerSettingsCategory = DatabaseManagerSettingsCategory() //データベースマネジャー
        databaseManagerSettingsCategory.updateSettingsCategorySwitching(tag: tag, isOn: isOn)
        // 表記名のスイッチを設定する　勘定科目がひとつもなければOFFにする
        // データベース
        let dataBaseSettingsCategoryBSAndPL = DataBaseManagerSettingsCategoryBSAndPL() //データベースマネジャー
        dataBaseSettingsCategoryBSAndPL.updateSettingsCategoryBSAndPLSwitching()
    }
}
