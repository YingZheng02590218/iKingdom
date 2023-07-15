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
    
    @IBOutlet private var tableView: UITableView!
    
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
    
    // 削除機能 アラートのポップアップを表示
    private func showPopover(indexPath: IndexPath) {
        let alert = UIAlertController(title: "削除", message: "グループ名を削除しますか？", preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .destructive,
                handler: { _ in
                    print("OK アクションをタップした時の処理")
                    // グループ名を削除
                    //                        let result = self.presenter.deleteJournalEntry(number: self.presenter.objects(forRow: indexPath.row).number)
                    let objects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
                    let result = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.deleteJournalEntryGroup(number: objects[indexPath.row].number)
                    if result == true {
                        self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                    }
                }
            )
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
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
        cell.textLabel?.minimumScaleFactor = 0.05
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        let objects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
        
        cell.textLabel?.text = objects[indexPath.row].groupName
        return cell
    }
    // 削除機能 セルを左へスワイプ
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0:
            // グループ名
            let action = UIContextualAction(style: .destructive, title: "削除") { (action, view, completionHandler) in
                // 確認のポップアップを表示したい
                self.showPopover(indexPath: indexPath)
                completionHandler(true) // 処理成功時はtrue/失敗時はfalseを設定する
            }
            action.image = UIImage(systemName: "trash.fill") // 画像設定（タイトルは非表示になる）
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
        default:
            // 空白行
            let configuration = UISwipeActionsConfiguration(actions: [])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
    }
}
