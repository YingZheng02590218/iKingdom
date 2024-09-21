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
                    let groups = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
                    self.updateJournalEntry(groupNumber: groups[indexPath.row].number, completion: {
                        let result = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.deleteJournalEntryGroup(number: groups[indexPath.row].number)
                        if result == true {
                            self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                        }
                    })
                }
            )
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateJournalEntry(groupNumber: Int, completion: () -> Void) {
        // データベース　よく使う仕訳
        let settingsOperatingJournalEntries = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(group: groupNumber)
        for settingsOperatingJournalEntry in settingsOperatingJournalEntries {
            // 仕訳データを更新
            let primaryKey = DataBaseManagerSettingsOperatingJournalEntry.shared.updateJournalEntry(
                primaryKey: settingsOperatingJournalEntry.number,
                groupNumber: 0 // その他
            )
        }
        completion() //　ここでコールバックする（呼び出し元に処理を戻す）
    }
        
    @IBAction func addBarButtonItemTapped(_ sender: Any) {
        DispatchQueue.main.async {
            if let viewController = UIStoryboard(
                name: String(describing: SettingsOperatingJournalEntryGroupDetailViewController.self),
                bundle: nil
            ).instantiateInitialViewController() as? SettingsOperatingJournalEntryGroupDetailViewController {
                // delegateを委任
                viewController.presentationController?.delegate = self
                // ナビゲーションバーを表示させる
                let navigation = UINavigationController(rootViewController: viewController)
                self.present(navigation, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Navigation
    
    func setupCellLongPressed(indexPath: IndexPath) {
        // 別の画面に遷移
        performSegue(withIdentifier: "longTapped", sender: nil)
    }
    
    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // 画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if let _ = self.tappedIndexPath { // 代入に成功したら、ロングタップだと判断できる
            return true // true: 画面遷移させる
        }
        return false // false:画面遷移させない
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SettingsOperatingJournalEntryGroupDetailViewController {
            // 遷移先のコントローラに値を渡す
            if let tappedIndexPath = tappedIndexPath { // nil:ロングタップではない
                controller.tappedIndexPath = tappedIndexPath // アンラップ // ロングタップされたセルの位置をフィールドで保持したものを使用
                self.tappedIndexPath = nil // 一度、画面遷移を行なったらセル位置の情報が残るのでリセットする
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
        
        // Accessory Color
        let disclosureImage = UIImage(named: "navigate_next")?.withRenderingMode(.alwaysTemplate)
        let disclosureView = UIImageView(image: disclosureImage)
        disclosureView.tintColor = UIColor.accentColor
        cell.accessoryView = disclosureView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // タップされたセルの位置をフィールドで保持する
            self.tappedIndexPath = indexPath
            tableView.deselectRow(at: indexPath, animated: true)
            setupCellLongPressed(indexPath: indexPath)
        default:
            break
        }
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

extension SettingsOperatingJournalEntryGroupViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        tableView.reloadData()
    }
}
