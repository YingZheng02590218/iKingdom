//
//  TableViewControllerBS.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 貸借対照表クラス
class TableViewControllerBS: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // 資産の部、負債の部、純資産の部
        return 3
    }
    // セクションヘッダーの高さを決める
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 //セクションヘッダーの高さを設定　セルの高さより高くしてメリハリをつける セル(Row Hight 30)
    }
    // セクションヘッダーの色とか調整する
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.gray
        header.textLabel?.textAlignment = .left
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
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = databaseManagerSettings.getSettings(section: section) // どのセクションに表示するセルかを判別するため引数で渡す
        return objects.count + 5 // 分類名(流動資産,固定資産など)と合計の行
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = databaseManagerSettings.getSettings(section: indexPath.section) // どのセクションに表示するセルかを判別するため引数で渡す

        switch indexPath.section {
        case 0:
            // 中分類　中分類ごとの数を取得
            let objectsCounts0 = databaseManagerSettings.getMiddleCategory(section: indexPath.section,mid_category: 0)
            // 中分類　中分類ごとの数を取得
            let objectsCounts1 = databaseManagerSettings.getMiddleCategory(section: indexPath.section,mid_category: 1)
            switch indexPath.row {
            case 0:
                //① UI部品を指定　TableViewCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "流動資産" // 注意：UITableViewCell内のViewに表示している。AttributesInspectorでHiddenをONにすると見えなくなる。
                return cell
            case objectsCounts0+1: // 中分類名の分を1行追加
                let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath)
                cell.textLabel?.text = "流動資産合計"
                return cell
            case objectsCounts0+2: // 中分類名の分を1行追加 合計の行を追加
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "固定資産"
                return cell
            case objectsCounts0+3+objectsCounts1: //最後の行の前
                let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath)
                cell.textLabel?.text = "固定資産合計"
                return cell
            case objectsCounts0+3+objectsCounts1+1: //最後の行
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath)
                cell.textLabel?.text = "資産合計"
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            }
        case 1:
            // 中分類　中分類ごとの数を取得
            let objectsCounts2 = databaseManagerSettings.getMiddleCategory(section: indexPath.section,mid_category: 2)
            // 中分類　中分類ごとの数を取得
            let objectsCounts3 = databaseManagerSettings.getMiddleCategory(section: indexPath.section,mid_category: 3)
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "流動負債"
                return cell
            case objectsCounts2+1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath)
                cell.textLabel?.text = "流動負債合計"
                return cell
            case objectsCounts2+2: // 中分類名の分を1行追加 合計の行を追加
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "固定負債"
                return cell
            case objectsCounts2+3+objectsCounts3: //最後の行の前
                let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath)
                cell.textLabel?.text = "固定負債合計"
                return cell
            case objectsCounts2+3+objectsCounts3+1: //最後の行
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath)
                cell.textLabel?.text = "負債合計"
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            }
        case 2:
            // 中分類　中分類ごとの数を取得
            let objectsCounts4 = databaseManagerSettings.getMiddleCategory(section: indexPath.section,mid_category: 4)
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "株主資本"
                return cell
            case objectsCounts4+1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath)
                cell.textLabel?.text = "株主資本合計"
                return cell
            case objectsCounts4+2: // 中分類名の分を1行追加 合計の行を追加
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "その他の包括利益累計額"
                return cell
            case objectsCounts4+3+0: //最後の行 Todo
                let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath)
                cell.textLabel?.text = "その他の包括利益累計額合計"
                return cell
            case objectsCounts4+3+0+1: //最後の行
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath)
                cell.textLabel?.text = "純資産合計"
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }


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
