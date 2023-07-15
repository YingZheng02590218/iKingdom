//
//  SettingsOperatingJournalEntryGroupViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/07/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import UIKit

// グループ一覧
class SettingsOperatingJournalEntryGroupViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Setting
    
    private func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.separatorColor = .accentColor
    }
}

extension SettingsOperatingJournalEntryGroupViewController: UITableViewDelegate {
}

extension SettingsOperatingJournalEntryGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let objects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UITableViewCell else { return UITableViewCell() }
        // タイトル
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
//        cell.textLabel?.minimumScaleFactor = 0.05
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        let objects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()

        cell.textLabel?.text = objects[indexPath.row].groupName
        return cell
    }
}
