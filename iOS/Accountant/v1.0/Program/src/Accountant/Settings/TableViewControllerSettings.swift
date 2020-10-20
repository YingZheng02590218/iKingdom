//
//  TableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 設定
class TableViewControllerSettings: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
//            return "会計期間"
//        case 1:
//            return "勘定科目"
//        case 2:
            return "情報"
        default:
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
//            return "会計期間を設定することができます。"
//        case 1:
//            return "利用する勘定科目を設定することができます。"
//        case 2:
            return "帳簿情報を設定することができます。"
        default:
            return ""
        }
    }
    //セルを生成して返却するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCellSettings {
        var cell = TableViewCellSettings()
        switch indexPath.row {
        case 0:
            //① UI部品を指定　TableViewCell
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_user", for: indexPath) as! TableViewCellSettings
            cell.textLabel?.text = "帳簿情報" // 注意：UITableViewCell内のViewに表示している。AttributesInspectorでHiddenをONにすると見えなくなる。
            return cell
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_settings_term", for: indexPath) as! TableViewCellSettings
            cell.textLabel?.text = "会計期間"
            return cell
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_settings", for: indexPath) as! TableViewCellSettings
            cell.textLabel?.text = "勘定科目" 
            return cell
        default:
            return cell
        }
    }
// 不採用
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択されたセルを取得
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_settings", for: indexPath) as! TableViewCellSettings
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        // 別の画面に遷移
//        if indexPath.section == 0 {
//            performSegue(withIdentifier: "identifier_term", sender: nil)
//        }
    }
}
