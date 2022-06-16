//
//  CategoryListTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/05/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import AudioToolbox // 効果音

// 勘定科目一覧　画面
class CategoryListTableViewController: UITableViewController {
    
    // MARK: - Variable/Let

    var index: Int = 0 // カルーセルのタブの識別
    
    /// GUIアーキテクチャ　MVP
    private var presenter: CategoryListPresenterInput!
    func inject(presenter: CategoryListPresenterInput) {
        self.presenter = presenter
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = CategoryListPresenter.init(view: self, model: CategoryListModel(), index: index)
        inject(presenter: presenter)
        
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {

        presenter.viewWillAppear()
    }
    
    // MARK: - Setting
    
    private func setTableView() {
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // 複数選択を可能にする
        // falseの場合は単一選択になる
        tableView.allowsMultipleSelectionDuringEditing = false
        // 編集ボタンの設定
        navigationItem.rightBarButtonItem = editButtonItem
    }

    // MARK: - Action
    
    // 勘定科目の有効無効　変更時のアクション TableViewの中のどのTableViewCellに配置されたトグルスイッチかを探す
    @objc func hundleSwitch(sender: UISwitch) {
        // UISwitchが配置されたセルを探す
        var hoge = sender.superview // 親ビュー
        while(hoge!.isKind(of: TableViewCellCategoryList.self) == false) {
            hoge = hoge!.superview
        }
        let cell = hoge as! TableViewCellCategoryList

        // 大区分の内でonとなっているスイッチが残りひとつの場合は、offにさせない
        if presenter.dataBaseSettingsTaxonomyAccount.count <= 1 {
            if !sender.isOn { // ON から　OFF に切り替えようとした時は効果音を鳴らす
                // バイブレーション　ブーッブーという強いバイブレーションが2回続く
                AudioServicesPlaySystemSound( 1011 )
                // 効果音
                //　let soundIdRing: SystemSoundID = 1073
                //　AudioServicesPlaySystemSound(soundIdRing)
            }
            // ONに強制的に戻す
            sender.isOn = true
            changeSwitch(tag: cell.tag, isOn: sender.isOn) // 引数：連番、トグルスイッチ.有効無効
            // UIButtonを無効化　はしないで、強制的にONに戻す
            // sender.isEnabled = false
            sender.isEnabled = true
        }
        else {
            // ここからデータベースを更新する
            changeSwitch(tag: cell.tag, isOn: sender.isOn) // 引数：連番、トグルスイッチ.有効無効
            //UIButtonを有効化
            sender.isEnabled = true
        }
        // tableView.reloadData() // 不要　注意：ここでリロードすると、トグルスイッチが深緑色となり元の緑色に戻らなくなる
    }
    // トグルスイッチの切り替え 引数：連番、トグルスイッチ.有効無効
    func changeSwitch(tag: Int, isOn: Bool) {
        // 勘定科目のスイッチを設定する
        presenter.changeSwitch(tag: tag, isOn: isOn)
    }
    // 削除機能 アラートのポップアップを表示
    private func showPopover(indexPath: IndexPath) {
        // 勘定クラス
        let dataBaseManagerAccount = GenearlLedgerAccountModel()
        let objectss = dataBaseManagerAccount.getAllJournalEntryInAccountAll(account: presenter.objects(forRow: indexPath.row, section: indexPath.section).category) // 全年度の仕訳データを確認する
        let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccountAll(account: presenter.objects(forRow: indexPath.row, section: indexPath.section).category) // 全年度の仕訳データを確認する
        let alert = UIAlertController(title: "削除", message: "「\(presenter.objects(forRow: indexPath.row, section: indexPath.section).category)」を削除しますか？\n仕訳データが \(objectss.count) 件\n決算整理仕訳データが \(objectsss.count) 件あります", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {
            (action: UIAlertAction!) in
            print("OK アクションをタップした時の処理")
            // 設定勘定科目、勘定、仕訳、決算整理仕訳、損益勘定、損益振替仕訳　データを削除
            self.presenter.deleteSettingsTaxonomyAccount(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    // 編集モード切り替え
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.setEditing(editing, animated: animated)
    }
    
    // MARK: - Navigation

    // 画面遷移の準備　勘定科目画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // セグエで場合分け
        // 既存の設定勘定科目を選択された場合
        // 選択されたセルを取得
        let indexPath: IndexPath = self.tableView.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
        // segue.destinationの型はUIViewController
        let tableViewControllerSettingsCategoryDetail = segue.destination as! SettingsCategoryDetailTableViewController
        // 遷移先のコントローラに値を渡す
        tableViewControllerSettingsCategoryDetail.numberOfAccount = presenter.objects(forRow: indexPath.row, section: indexPath.section).number // セルに表示した勘定科目の連番を取得
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return presenter.numberOfsections()
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return presenter.titleForHeaderInSection(section: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return presenter.numberOfobjects(section: section)
    }
    //セルを生成して返却するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCellCategoryList {
        //① UI部品を指定　TableViewCellCategory
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_list_category", for: indexPath) as! TableViewCellCategoryList
        // 勘定科目の名称をセルに表示する 丁数(元丁) 勘定名
        cell.textLabel?.text = " \(presenter.objects(forRow: indexPath.row, section: indexPath.section).number). \(presenter.objects(forRow: indexPath.row, section: indexPath.section).category as String)"
        cell.textLabel?.textColor = .TextColor
//        cell.label_category.text = " \(presenter.objects(forRow: indexPath.row, section: indexPath.section).category as String)"
        // 勘定科目の連番
        cell.tag = presenter.objects(forRow: indexPath.row, section: indexPath.section).number
        // 勘定科目の有効無効
        cell.ToggleButton.isOn = presenter.objects(forRow: indexPath.row, section: indexPath.section).switching
        // 勘定科目の有効無効　変更時のアクションを指定
        cell.ToggleButton.addTarget(self, action: #selector(hundleSwitch), for: UIControl.Event.valueChanged)
        // モデルオブフェクトの取得 勘定別に取得
        let dataBaseManagerAccount = GenearlLedgerAccountModel()
        let objectss = dataBaseManagerAccount.getAllJournalEntryInAccountAll(account: presenter.objects(forRow: indexPath.row, section: indexPath.section).category as String) // 通常仕訳　勘定別 全年度にしてはいけない
        let objectsss = dataBaseManagerAccount.getAllAdjustingEntryInAccountAll(account: presenter.objects(forRow: indexPath.row, section: indexPath.section).category as String) // 決算整理仕訳　勘定別　損益勘定以外 全年度にしてはいけない
        // タクソノミに紐付けされていない勘定科目はスイッチをONにできないように無効化する
        if "" == presenter.objects(forRow: indexPath.row, section: indexPath.section).numberOfTaxonomy {
            //UIButtonを無効化
            cell.ToggleButton.isEnabled = false
        }
        else {
            // 仕訳データが存在する場合、トグルスイッチはOFFにできないように、無効化する
            if objectss.count <= 0 && objectsss.count <= 0 {
                //UIButtonを有効化
                cell.ToggleButton.isEnabled = true
            }
            else {
                //UIButtonを無効化
                cell.ToggleButton.isEnabled = false
            }
        }
        return cell
    }

//    // セル選択不可
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        // 編集モードの場合　は押下できないのでこの処理は通らない
//        if tableView.isEditing {
//            return indexPath
//        }else {
//            // 選択不可にしたい場合は"nil"を返す
//            return nil
//        }
//    }
    // 削除機能 セルを左へスワイプ
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 編集モードの場合
        if tableView.isEditing {
            // スタイルには、normal と　destructive がある
            let action = UIContextualAction(style: .destructive, title: "削除") { (action, view, completionHandler) in
                // なんか処理
                // 確認のポップアップを表示したい
                self.showPopover(indexPath: indexPath)
                completionHandler(true) // 処理成功時はtrue/失敗時はfalseを設定する
            }
            action.image = UIImage(systemName: "trash.fill") // 画像設定（タイトルは非表示になる）
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
        }
        else {
            // 編集モードではない状態でセルをスワイプした場合
            let configuration = UISwipeActionsConfiguration(actions: [])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
    }
    // セルの右側から出てくるdeleteボタンを押下した時
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {
        // ユーザーが新規追加した勘定科目のみを削除可能とする。
        if editingStyle == .delete {
            // 確認のポップアップを表示したい
            self.showPopover(indexPath: indexPath)
        }
        if editingStyle == .insert {
        // 対象セルの下に追加（先にリストに追加する）
//        tableDataList.insert(0, at: indexPath.row + 1)
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: 0)], with: .automatic)
            tableView.endUpdates()
        }
    }
    // 編集機能
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // デフォルトの勘定科目数（230）以上ある場合は、削除可能とし、それ以下の場合は削除不可とする。
        if 230 > presenter.objects(forRow: indexPath.row, section: indexPath.section).number {
            return .none // 削除不可
        }
        return .delete
    }
}

extension CategoryListTableViewController: CategoryListPresenterOutput {
    
    func reloadData() {
        // データベースの削除処理が成功した場合、テーブルをリロードする
        tableView.reloadData()
    }
    
    func setupViewForViewDidLoad() {
        // UI
        setTableView()
    }
    
    func setupViewForViewWillAppear() {
        // 勘定科目画面から、仕訳帳画面へ遷移して仕訳を追加した後に、戻ってきた場合はリロードする
        tableView.reloadData()
    }
}
