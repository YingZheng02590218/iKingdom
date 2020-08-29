//
//  TableViewControllerSettingsGroups.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/08/07.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewControllerSettingsGroups: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // 勘定科目を種類別に表示する
        return 7
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_category", for: indexPath)
        // 勘定科目を種類別に表示する
        return cell
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "評価勘定"
        case 1:
            return "対照勘定"
        case 2:
            return "備忘勘定"
        case 3:
            return "混合勘定"
        case 4:
            return "仮勘定"
        case 5:
            return "未決算勘定"
        case 6:
            return "決算勘定"
        default:
            return ""
        }
    }
}
