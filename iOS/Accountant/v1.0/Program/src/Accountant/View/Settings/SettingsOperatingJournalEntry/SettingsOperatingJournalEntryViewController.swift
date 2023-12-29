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
    
    // まとめて編集機能
    @IBOutlet private var editWithSlectionButton: UIButton! // 選択した項目を編集ボタン
    
    @IBOutlet private var tableView: UITableView!
    // 仕訳画面表示ボタン
    @IBOutlet private var addButton: UIButton!

    // 仕訳編集　編集の対象となる仕訳の連番
    var primaryKey: Int?
    // まとめて編集機能　選択したよく使う仕訳の連番
    var selectedItemNumners: [Int] = []
    
    var viewReload = false // リロードするかどうか
    // グループ
    var groupObjects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
    // フィードバック
    let feedbackGeneratorMedium: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title設定
        navigationItem.title = "よく使う仕訳"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
        
        // まとめて編集機能 setEditingメソッドを使用するため、Storyboard上の編集ボタンを上書きしてボタンを生成する
        editButtonItem.tintColor = .accentColor
        if var rightBarButtonItems = navigationItem.rightBarButtonItems {
            rightBarButtonItems.append(editButtonItem)
            navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: false)
        }
        
        editWithSlectionButton.isHidden = true
        editWithSlectionButton.tintColor = tableView.isEditing ? .accentBlue : UIColor.clear// 色
        
        initTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // よく使う仕訳を追加や削除して、よく使う仕訳画面に戻ってきてもリロードされない。reloadData()は、よく使う仕訳画面に戻ってきた時のみ実行するように修正
        if viewReload {
            DispatchQueue.main.async {
                self.tableView.reloadData() // CollectionView を更新していたが、画面構成を変更したので、TableViewを更新する
                self.viewReload = false
                JournalEntryViewController.viewReload = true
            }
        } else {
            // グループ一覧から遷移してきた場合
            if self.isEditing { // 編集モードの場合
                // 選択中のセルがリセットされるので、リロードしない
            } else {
                // グループ
                groupObjects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        // 仕訳画面表示ボタン
        addButton.isEnabled = !isEditing
        
        if let addButton = addButton {
            // ボタンを丸くする処理。ボタンが正方形の時、一辺を2で割った数値を入れる。(今回の場合、 ボタンのサイズは70×70であるので、35。)
            addButton.layer.cornerRadius = addButton.frame.width / 2 - 1
            // 影の色を指定。(UIColorをCGColorに変換している)
            addButton.layer.shadowColor = UIColor.black.cgColor
            // 影の縁のぼかしの強さを指定
            addButton.layer.shadowRadius = 3
            // 影の位置を指定
            addButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
            // 影の不透明度(濃さ)を指定
            addButton.layer.shadowOpacity = 1.0
        }
    }
    // 編集モード切り替え
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        editWithSlectionButton.isHidden = !editing
        editWithSlectionButton.isEnabled = false // まとめて編集ボタン
        editWithSlectionButton.tintColor = editing ? .accentBlue : UIColor.clear // 色
        // 仕訳画面表示ボタン
        addButton.isEnabled = !editing
        if var rightBarButtonItems = navigationItem.rightBarButtonItems {
            for button in rightBarButtonItems where button != editButtonItem {
                button.isEnabled = !editing // ＋ボタン、グループ一覧ボタン
            }
        }
        // 編集中の場合
        if editing {
            self.selectedItemNumners = [] // 初期化
        }
        // 編集モードに入る前、編集後に選択していたセルをリセットする
        self.tableView.reloadData()
        navigationItem.title = "よく使う仕訳"
    }
    
    func presentToDetail() {
        // 別の画面に遷移 仕訳画面
        performSegue(withIdentifier: "longTapped", sender: nil)
    }
    
    // 仕訳画面表示ボタン
    @IBAction func addButtonTapped(_ sender: UIButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        sender.animateView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 別の画面に遷移 仕訳画面
            self.performSegue(withIdentifier: "buttonTapped2", sender: nil)
        }
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
            if segue.identifier == "buttonTapped" || segue.identifier == "buttonTapped2" {
                controller.journalEntryType = .SettingsJournalEntries // セルに表示した仕訳タイプを取得
            } else if segue.identifier == "longTapped" {
                if let primaryKey = primaryKey { // nil:ロングタップではない
                    controller.journalEntryType = .SettingsJournalEntriesFixing // セルに表示した仕訳タイプを取得
                    controller.primaryKey = primaryKey
                }
            }
        }
    }
    
    // MARK: - Action
    
    // まとめて編集機能 グループ選択画面を表示させる
    @IBAction func editBarButtonItemTapped(_ sender: Any) {
        
        if let viewController = UIStoryboard(name: "GroupChoiceViewController", bundle: nil).instantiateInitialViewController() as? GroupChoiceViewController {
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func updateGroup(groupNumber: Int) {
        
        updateGroup(selectedItemNumners: selectedItemNumners, groupNumber: groupNumber)
    }
    // グループを変更する
    func updateGroup(selectedItemNumners: [Int], groupNumber: Int) {
        // 一括変更の処理
        self.updateJournalEntry(selectedItemNumners: selectedItemNumners, groupNumber: groupNumber, completion: {
            // リロード
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                JournalEntryViewController.viewReload = true
            }
        })
    }
    
    func updateJournalEntry(selectedItemNumners: [Int], groupNumber: Int, completion: () -> Void) {
        for selectedItemNumner in selectedItemNumners {
            // 仕訳データを更新
            // 仕訳データを更新
            DataBaseManagerSettingsOperatingJournalEntry.shared.updateJournalEntry(
                primaryKey: selectedItemNumner,
                groupNumber: groupNumber
            )
        }
        completion() //　ここでコールバックする（呼び出し元に処理を戻す）
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
            // グループ　その他
            cell.collectionView.tag = 0 // グループの連番
            cell.configure(gropName: "その他")
        } else {
            cell.collectionView.tag = groupObjects[indexPath.row].number // グループの連番
            cell.configure(gropName: groupObjects[indexPath.row].groupName)
        }
        cell.delegate = self // CustomCollectionViewCellDelegate
        
        return cell
    }
    // cellの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == groupObjects.count {
            // グループ　その他
            let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(group: 0)
            if objects.isEmpty {
                return 30
            } else {
                return 250
            }
        } else {
            // データベース　よく使う仕訳
            let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(group: groupObjects[indexPath.row].number)
            if objects.isEmpty {
                return 30
            } else {
                return 250
            }
        }
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
        // データベース　よく使う仕訳
        let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(
            group: collectionView.tag // グループ　その他 collectionView.tag == 0
        )
        return objects.count
    }
    // collectionViewのセルを返す（セルの内容を決める）
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ListCollectionViewCell else { return UICollectionViewCell() }
        // データベース　よく使う仕訳
        let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(
            group: collectionView.tag // グループ　その他 collectionView.tag == 0
        )
        cell.number = objects[indexPath.row].number
        cell.nicknameLabel.text = objects[indexPath.row].nickname
        cell.debitLabel.text = objects[indexPath.row].debit_category
        cell.debitamauntLabel.text = String(objects[indexPath.row].debit_amount)
        cell.creditLabel.text = objects[indexPath.row].credit_category
        cell.creditamauntLabel.text = String(objects[indexPath.row].credit_amount)
        // 選択したよく使う仕訳の連番 に含まれている場合は、選択状態とする
        cell.isSelected = !selectedItemNumners.filter({ $0 == objects[indexPath.row].number }).isEmpty
        // と指定してしまうと その後、当該セルをタップしても反応しなくなるという問題が出てきます。
        // その場合は、以下のようにするとセルが反応してくれます。
        if cell.isSelected {
            // 画面を回転させるとセルの選択状態がリセットされる対策
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        }
        // コールバックに選択状態を切り替え時の処理を登録
        cell.switchValueChangedCompletion = { [weak self] (isSelected: Bool, number: Int) in
            guard let self = self else { return }
            print("cellForItemAt", isSelected, number)
            print("cellForItemAt selectedItemNumners", self.selectedItemNumners)
        }
        if objects.isEmpty {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
        }
        // 編集モードの場合
        // CollectionViewで複数選択できるように設定する
        collectionView.allowsMultipleSelection = self.isEditing
        
        return cell
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
        // タップしたセルを中央へスクロールさせる
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        // 編集中の場合
        if self.isEditing {
            // collectionViewCoellのindexPathを特定する
            guard let cell = collectionView.cellForItem(at: indexPath) as? ListCollectionViewCell,
                  let number = cell.number else {
                return
            }
            // DataSourceを更新
            if selectedItemNumners.filter({ $0 == number }).isEmpty {
                self.selectedItemNumners.append(number)
                self.selectedItemNumners.sort() // 配列の要素を並べ替える
            } else {
                // 画面を回転させるとセルの選択状態がリセットされる
                print("重複している", number)
            }
                
            print("didSelectItemAt selectedItemNumners", self.selectedItemNumners)
            
            editWithSlectionButton.isEnabled = !selectedItemNumners.isEmpty ? true : false // まとめて編集ボタン
            // title設定
            navigationItem.title = !selectedItemNumners.isEmpty ? "\(selectedItemNumners.count)件選択" : "よく使う仕訳"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Deselected: \(indexPath)")
        // 編集中の場合
        if self.isEditing {
            // collectionViewCoellのindexPathを特定する
            guard let cell = collectionView.cellForItem(at: indexPath) as? ListCollectionViewCell,
                  let number = cell.number else {
                return
            }
            // DataSourceを更新
            // 選択を解除されたよく使う仕訳の連番を除去する
            self.selectedItemNumners.removeAll(where: { $0 == number })
            print("didDeselectItemAt selectedItemNumners", self.selectedItemNumners)
            
            editWithSlectionButton.isEnabled = !selectedItemNumners.isEmpty ? true : false // まとめて編集ボタン
            // title設定
            navigationItem.title = !selectedItemNumners.isEmpty ? "\(selectedItemNumners.count)件選択" : "よく使う仕訳"
        } else {
            editWithSlectionButton.isEnabled = false
            navigationItem.title = "よく使う仕訳"
        }
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
