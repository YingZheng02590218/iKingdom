//
//  TableViewControllerSettingsCategory.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/08/07.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class TableViewControllerSettingsCategory: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "groups", for: indexPath)
            cell.textLabel?.text =  "種類別勘定科目"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
            cell.textLabel?.text =   ""
            return cell
        }
    }
}
