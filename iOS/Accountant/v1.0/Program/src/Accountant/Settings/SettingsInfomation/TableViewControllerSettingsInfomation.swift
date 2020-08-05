//
//  TableViewControllerSettingsInfomation.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/28.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewControllerSettingsInfomation: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "事業者名"
        default:
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "仕訳帳、勘定、財務諸表に表示されます。"
        default:
            return ""
        }
    }
    //セルを生成して返却するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{//TableViewCellSettings {
        var cell = UITableViewCell()//TableViewCellSettings()
        switch indexPath.section {
        case 0:
            //① UI部品を指定　TableViewCell
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_companyName", for: indexPath) //as! TableViewCell
                cell.textLabel?.text = "事業者名" // 注意：UITableViewCell内のViewに表示している。AttributesInspectorでHiddenをONにすると見えなくなる。
            return cell
        default:
            return cell
        }
    }

}
