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
    // 編集機能
    var tappedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title設定
        navigationItem.title = "グループ一覧"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor

        setTableView()
        setLongPressRecognizer()
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
    
    private func setLongPressRecognizer() {
        // 更新機能　編集機能
        // UILongPressGestureRecognizer宣言
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))// 正解: Selector("somefunctionWithSender:forEvent: ") → うまくできなかった。2020/07/26
        // `UIGestureRecognizerDelegate`を設定するのをお忘れなく
        longPressRecognizer.delegate = self
        // tableViewにrecognizerを設定
        tableView.addGestureRecognizer(longPressRecognizer)
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
    
    // MARK: - Navigation
    
    func setupCellLongPressed(indexPath: IndexPath) {
        // 別の画面に遷移
        performSegue(withIdentifier: "longTapped", sender: nil)
    }

    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // 画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if identifier == "longTapped" { // segueがタップ
            // 編集中ではない場合
            if !tableView.isEditing { // ロングタップの場合はセルの位置情報を代入しているのでnilではない
                if let _ = self.tappedIndexPath { // 代入に成功したら、ロングタップだと判断できる
                    return true // true: 画面遷移させる
                }
            }
        } else if identifier == "buttonTapped" { // segueがタップ
            return true // true: 画面遷移させる
        }
        return false // false:画面遷移させない
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue.destinationの型はUIViewController
        print(segue.destination)
        if let navigationController = segue.destination as? UINavigationController,
           let controller = navigationController.topViewController as? SettingsOperatingJournalEntryGroupDetailViewController {
            // 遷移先のコントローラに値を渡す
            if segue.identifier == "longTapped" {
                // 編集中ではない場合
                if !tableView.isEditing {
                    if let tappedIndexPath = tappedIndexPath { // nil:ロングタップではない
                        controller.tappedIndexPath = tappedIndexPath // アンラップ // ロングタップされたセルの位置をフィールドで保持したものを使用
                        self.tappedIndexPath = nil // 一度、画面遷移を行なったらセル位置の情報が残るのでリセットする
                    }
                }
            }
        }
    }

}

extension SettingsOperatingJournalEntryGroupViewController: UIGestureRecognizerDelegate {
    // 編集機能　長押しした際に呼ばれるメソッド
    @objc
    private func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        // 編集中ではない場合
        if !tableView.isEditing {
            if recognizer.state == UIGestureRecognizer.State.began {
                // 押された位置でcellのPathを取得
                let point = recognizer.location(in: tableView)
                let indexPath = tableView.indexPathForRow(at: point)
                
                if let indexPath = indexPath {
                    switch indexPath.section {
                    case 0:
                        // 長押しされた場合の処理
                        print("長押しされたcellのindexPath:\(String(describing: indexPath.row))")
                        // ロングタップされたセルの位置をフィールドで保持する
                        self.tappedIndexPath = indexPath
                        tableView.deselectRow(at: indexPath, animated: true)
                        setupCellLongPressed(indexPath: indexPath)
                    default:
                        break
                    }
                }
            }
        }
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
