//
//  TableViewControllerCategory.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewControllerCategory: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        // データベース
//        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
//        if !databaseManagerSettings.checkInitialising() { // データベースにモデルオブフェクトが存在しない場合
//            let masterData = MasterData()
//            masterData.readMasterDataFromCSV()   // マスターデータを作成する
//        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCellCategory {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = databaseManagerSettings.getSettings(section: indexPath.section) // どのセクションに表示するセルかを判別するため引数で渡す
        //① UI部品を指定　TableViewCellCategory
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_category", for: indexPath) as! TableViewCellCategory
        // 勘定科目の名称をセルに表示する
        cell.textLabel?.text = " \(objects[indexPath.row].category as String)"
//        cell.label_category.text = " \(objects[indexPath.row].category as String)"
        // 勘定科目の連番
        cell.tag = objects[indexPath.row].number
        // 勘定科目の有効無効
        cell.ToggleButton.isOn = objects[indexPath.row].switching
        // 勘定科目の有効無効　変更時のアクションを指定
        cell.ToggleButton.addTarget(self, action: #selector(hundleSwitch), for: UIControl.Event.valueChanged)

        return cell
    }
    // 勘定科目の有効無効　変更時のアクション TableViewの中のどのTableViewCellに配置されたトグルスイッチかを探す
    @objc func hundleSwitch(sender: UISwitch) {
        // UISwitchが配置されたセルを探す
        var hoge = sender.superview // 親ビュー
        while(hoge!.isKind(of: TableViewCellCategory.self) == false) {
            hoge = hoge!.superview
        }
        let cell = hoge as! TableViewCellCategory
        // touchIndexは選択したセルが何番目かを記録しておくプロパティ
        let touchIndex: IndexPath = self.tableView.indexPath(for: cell)!
        print("トグルスイッチが変更されたセルのIndexPath:　\(touchIndex)")
        // ここからデータベースを更新する
        changeSwitch(tag: cell.tag, isOn: sender.isOn) // 引数：連番、トグルスイッチ.有効無効
    }
    // トグルスイッチの切り替え　データベースを更新
    func changeSwitch(tag: Int, isOn: Bool) {
        // データベース
        let databaseManagerSettingsCategory = DatabaseManagerSettingsCategory() //データベースマネジャー
        databaseManagerSettingsCategory.setSettingsCategorySwitching(tag: tag, isOn: isOn)
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
