//
//  BackupViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/26.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import UIKit

class BackupViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet var button: EMTNeumorphicButton!
    @IBOutlet var label: UILabel!
    // コンテナ　ファイル
    private let containerManager = ContainerManager()

    // iCloudが有効かどうかの判定
    private var isiCloudEnabled: Bool {
        (FileManager.default.ubiquityIdentityToken != nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 削除機能 setEditingメソッドを使用するため、Storyboard上の編集ボタンを上書きしてボタンを生成する
        editButtonItem.tintColor = .accentColor
        navigationItem.rightBarButtonItem = editButtonItem

        // title設定
        navigationItem.title = "バックアップ・復元"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor

        // UI
        setTableView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // ニューモフィズム　ボタンとビューのデザインを指定する
        createEMTNeumorphicView()
    }

    // MARK: - Setting

    private func setTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        // XIBを登録　xibカスタムセル設定によりsegueが無効になっているためsegueを発生させる
        tableView.register(UINib(nibName: "WithIconTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.separatorColor = .accentColor
    }

    // MARK: EMTNeumorphicView
    // ニューモフィズム　ボタンとビューのデザインを指定する
    private func createEMTNeumorphicView() {
        //        inputButton.setTitle("入力", for: .normal)
        button.neumorphicLayer?.cornerRadius = 15
        button.setTitleColor(.accentColor, for: .selected)
        button.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button.neumorphicLayer?.edged = Constant.edged
        button.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        // iCloudが無効の場合、不活性化
        if isiCloudEnabled {
            button.setTitleColor(.accentColor, for: .normal)
            // アイコン画像の色を指定する
            button.tintColor = .accentColor
            let backImage = UIImage(named: "baseline_cloud_upload_black_36pt")?.withRenderingMode(.alwaysTemplate)
            button.setImage(backImage, for: UIControl.State.normal)
            label.isHidden = true
        } else {
            button.setTitleColor(.mainColor, for: .normal)
            // アイコン画像の色を指定する
            button.tintColor = .mainColor
            let backImage = UIImage(named: "baseline_cloud_off_black_36pt")?.withRenderingMode(.alwaysTemplate)
            button.setImage(backImage, for: UIControl.State.normal)
            label.isHidden = false
        }
        button.isEnabled = isiCloudEnabled
    }
    // 編集モード切り替え
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.setEditing(editing, animated: animated)
    }
    // バックアップ作成ボタン
    @IBAction func buttonTapped(_ sender: EMTNeumorphicButton) {
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sender.isSelected = !sender.isSelected
        }
        // iCloud Documents にバックアップを作成する
        BackupManager.shared.backup()
    }

}

extension BackupViewController: UITableViewDelegate, UITableViewDataSource {
    // セクションの数を設定する
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    // セクションヘッダーのテキスト決める
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "バックアップ時刻"
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "復元する場合は、上記からバックアップファイルを選択してください。"
    }
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    // セルを生成して返却するメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WithIconTableViewCell else { return UITableViewCell() }
        // TODO: バックアップデータ一覧　時刻　バージョン　ファイルサイズMB
        cell.centerLabel.text = "バックアップデータ \(1)"
        cell.leftImageView.image = UIImage(named: "database-database_symbol")?.withRenderingMode(.alwaysTemplate)
        cell.shouldIndentWhileEditing = true
        cell.accessoryView = nil

        return cell
    }
    // 編集機能
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    // 削除機能 セルを左へスワイプ
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "削除") { (action, view, completionHandler) in
            // 削除機能 アラートのポップアップを表示
            self.showPopover(indexPath: indexPath)
            completionHandler(true) // 処理成功時はtrue/失敗時はfalseを設定する
        }
        action.image = UIImage(systemName: "trash.fill") // 画像設定（タイトルは非表示になる）
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    // 削除機能 アラートのポップアップを表示
    private func showPopover(indexPath: IndexPath) {
        let alert = UIAlertController(title: "削除", message: "バックアップファイルを削除しますか？", preferredStyle: .alert)

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .destructive,
                handler: { _ in
                    print("OK アクションをタップした時の処理")
                    // TODO: バックアップファイルを削除
                    self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                    //                            // イベントログ
                    //                            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    //                                AnalyticsParameterContentType: Constant.JOURNALS,
                    //                                AnalyticsParameterItemID: Constant.DELETEJOURNALENTRY
                    //                            ])
                    //                        }
                }
            )
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 復元機能 アラートのポップアップを表示
        self.showPopoverRestore(indexPath: indexPath)
    }
    // 復元機能 アラートのポップアップを表示
    private func showPopoverRestore(indexPath: IndexPath) {
        let alert = UIAlertController(title: "復元", message: "バックアップファイルからデータベースを復元しますか？\n現在のデータベースは上書きされます。\n復元には時間がかかることがあります。\n復元中は操作を行なわずにお待ちください。", preferredStyle: .alert)

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .destructive,
                handler: { _ in
                    print("OK アクションをタップした時の処理")
                    // TODO: データベースを復元
                    self.tableView.reloadData() // データベースの削除処理が成功した場合、テーブルをリロードする
                    //                            // イベントログ
                    //                            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    //                                AnalyticsParameterContentType: Constant.JOURNALS,
                    //                                AnalyticsParameterItemID: Constant.DELETEJOURNALENTRY
                    //                            ])
                    //                        }
                }
            )
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

}
