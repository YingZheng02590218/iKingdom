//
//  TableViewControllerSettingsCategory.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/08/07.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 勘定科目　画面
class TableViewControllerSettingsCategory: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 設定表示科目　初期化　表示科目のスイッチを設定する　勘定科目のスイッチONが、ひとつもなければOFFにする
        let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
        dataBaseManagerSettingsTaxonomy.initializeSettingsTaxonomy()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 //4
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
            cell.textLabel?.text = "勘定科目一覧"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesBSandPL", for: indexPath)
            cell.textLabel?.text = "表示科目別勘定科目一覧"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BSandPL", for: indexPath)
            cell.textLabel?.text = "表示科目一覧"
            return cell
//        case 3:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "groups", for: indexPath)
//            cell.textLabel?.text =  "種類別勘定科目一覧"
//            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
            cell.textLabel?.text =   ""
            return cell
        }
    }
}
