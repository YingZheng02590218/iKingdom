//
//  SettingsOperatingJournalEntryViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/04/30.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 設定仕訳画面
class SettingsOperatingJournalEntryViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    // 仕訳編集　編集の対象となる仕訳の連番
    var primaryKey: Int?
    
    var viewReload = false // リロードするかどうか
    // グループ
    var groupObjects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title設定
        navigationItem.title = "設定 よく使う仕訳"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
        
        initTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        groupObjects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()

        // よく使う仕訳を追加や削除して、よく使う仕訳画面に戻ってきてもリロードされない。reloadData()は、よく使う仕訳画面に戻ってきた時のみ実行するように修正
        if viewReload {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.viewReload = false
                JournalEntryViewController.viewReload = true
            }
        }
    }
    
    func presentToDetail() {
        // 別の画面に遷移 仕訳画面
        performSegue(withIdentifier: "longTapped", sender: nil)
    }
    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // 画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if identifier == "longTapped" { // segueがタップ
            if let primaryKey = primaryKey { // ロングタップの場合はセルの位置情報を代入しているのでnilではない
                return true // true: 画面遷移させる
            }
        } else if identifier == "buttonTapped" {
            // 追加ボタン
            return true
        } else if identifier == "groupButtonTapped" {
            // グループ一覧ボタン
            return true
        }
        return false // false:画面遷移させない
    }
    // 追加機能　画面遷移の準備　仕訳画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue.destinationの型はUIViewController
        if let controller = segue.destination as? JournalEntryTemplateViewController {
            // 遷移先のコントローラに値を渡す
            if segue.identifier == "buttonTapped" {
                controller.journalEntryType = .SettingsJournalEntries // セルに表示した仕訳タイプを取得
            } else if segue.identifier == "longTapped" {
                if let primaryKey = primaryKey { // nil:ロングタップではない
                    controller.journalEntryType = .SettingsJournalEntriesFixing // セルに表示した仕訳タイプを取得
                    controller.primaryKey = primaryKey
                }
            }
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension SettingsOperatingJournalEntryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func initTable() {
        tableView.delegate = self
        tableView.dataSource = self
        let customTableViewCellName = "CustomTableViewCell"
        tableView.register(UINib(nibName: customTableViewCellName, bundle: nil), forCellReuseIdentifier: customTableViewCellName)
        tableView.separatorColor = .accentColor
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groupObjects.count + 1 // グループ　その他
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath as IndexPath) as! CustomTableViewCell
        cell.collectionView.delegate = self
        cell.collectionView.dataSource = self
        if indexPath.row == groupObjects.count {
            cell.collectionView.tag = 111
            cell.configure(gropName: "その他")
        } else {
            cell.collectionView.tag = 0
            cell.configure(gropName: groupObjects[indexPath.row].groupName)
        }
        cell.delegate = self // CustomCollectionViewCellDelegate
        
        return cell
    }
    // cellの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        250
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        250
    }
}

// プロトコル定義
extension SettingsOperatingJournalEntryViewController: UICollectionViewDelegateFlowLayout {
    //    //セル間の間隔を指定
    //    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimunLineSpacingForSectionAt section: Int) -> CGFloat {
    //        return 20
    //    }
    // セルのサイズ(CGSize)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(collectionView.frame)
        print(tableView.frame)
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                return CGSize(width: (collectionView.frame.width / 4) - 20, height: (collectionView.frame.height / 2) - 20)
            } else {
                return CGSize(width: (collectionView.frame.width / 3) - 40, height: (collectionView.frame.height / 2) - 20)
            }
        } else {
            // TableViewCell の高さからCollectionViewCell の高さを割り出す
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                return CGSize(width: (collectionView.frame.width / 3) - 20, height: (collectionView.frame.height / 2) - 20)
            } else {
                return CGSize(width: collectionView.frame.width - 40, height: (collectionView.frame.height / 2) - 20)
            }
        }
    }
    // 余白の調整（UIImageを拡大、縮小している）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // top:ナビゲーションバーの高さ分上に移動
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}

extension SettingsOperatingJournalEntryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    // collectionViewの要素の数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // グループ　その他
        if collectionView.tag == 111 {
            let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(group: 0)
            return objects.count
        } else {
            // データベース　よく使う仕訳
            let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(group: groupObjects[section].number)
            return objects.count
        }
    }
    // collectionViewのセルを返す（セルの内容を決める）
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ListCollectionViewCell else { return UICollectionViewCell() }
        // グループ　その他
        if collectionView.tag == 111 {
            let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(group: 0)
            cell.number = objects[indexPath.row].number
            cell.nicknameLabel.text = objects[indexPath.row].nickname
            cell.debitLabel.text = objects[indexPath.row].debit_category
            cell.debitamauntLabel.text = String(objects[indexPath.row].debit_amount)
            cell.creditLabel.text = objects[indexPath.row].credit_category
            cell.creditamauntLabel.text = String(objects[indexPath.row].credit_amount)
            
            return cell
        } else {
            // データベース　よく使う仕訳
            let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(group: groupObjects[indexPath.row].number)
            cell.number = objects[indexPath.row].number
            cell.nicknameLabel.text = objects[indexPath.row].nickname
            cell.debitLabel.text = objects[indexPath.row].debit_category
            cell.debitamauntLabel.text = String(objects[indexPath.row].debit_amount)
            cell.creditLabel.text = objects[indexPath.row].credit_category
            cell.creditamauntLabel.text = String(objects[indexPath.row].credit_amount)
            
            return cell
        }
    }
}

extension SettingsOperatingJournalEntryViewController: UICollectionViewDelegate {
    /// セルの選択時に背景色を変化させる
    /// 今度はセルが選択状態になった時に背景色が青に変化するようにしてみます。
    /// 以下の3つのメソッドはデフォルトでtrueなので、このケースでは実装しなくても良いです。
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("Highlighted: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        print("Unhighlighted: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        true  // 変更
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: \(indexPath)")
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Deselected: \(indexPath)")
    }
    
    //    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    //        return true  // 変更
    //    }
}

extension SettingsOperatingJournalEntryViewController: CustomCollectionViewCellDelegate {
    func showDetail(cell: ListCollectionViewCell) {
        if let number = cell.number {
            // セルに表示させているよく使う仕訳の連番を保持する
            primaryKey = number
            // 画面遷移
            presentToDetail()
        }
    }
}
