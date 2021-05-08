//
//  SettingsOperatingJournalEntryViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/04/30.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class SettingsOperatingJournalEntryViewController: UIViewController, UIGestureRecognizerDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 更新機能　編集機能
        // UILongPressGestureRecognizer宣言
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))// 正解: Selector("somefunctionWithSender:forEvent:") → うまくできなかった。2020/07/26
        // `UIGestureRecognizerDelegate`を設定するのをお忘れなく
        longPressRecognizer.delegate = self
        // tableViewにrecognizerを設定
        listCollectionView.addGestureRecognizer(longPressRecognizer)

    }
    override func viewWillAppear(_ animated: Bool) {
        createList() // リストを作成
        listCollectionView.reloadData()
        // ナビゲーションを透明にする処理
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
    }
   
    // MARK: - Create View

    // リスト作成
    @IBOutlet var listCollectionView: UICollectionView!
    func createList() {
        //xib読み込み
        let nib = UINib(nibName: "ListCollectionViewCell", bundle: .main)
        listCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
    }
    // 編集機能　長押しした際に呼ばれるメソッド
    @objc func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        // 押された位置でcellのPathを取得
        let point = recognizer.location(in: listCollectionView)
        let indexPath = listCollectionView.indexPathForItem(at: point)
        
        if indexPath?.section == 1 {
            print("空白行を長押し")
        }else {
            if indexPath == nil {
                
            } else if recognizer.state == UIGestureRecognizer.State.began  {
                // 長押しされた場合の処理
                print("長押しされたcellのindexPath:\(String(describing: indexPath?.row))")
                // ロングタップされたセルの位置をフィールドで保持する
                self.tappedIndexPath = indexPath
                // 別の画面に遷移 仕訳画面
                let controller = UIStoryboard(name: "JournalEntryViewController", bundle: nil).instantiateViewController(withIdentifier: "JournalEntryViewController") as! JournalEntryViewController
                if tappedIndexPath != nil { // nil:ロングタップではない
                    controller.journalEntryType = "SettingsJournalEntriesFixing" // セルに表示した仕訳タイプを取得
                    controller.tappedIndexPath = self.tappedIndexPath!//アンラップ // ロングタップされたセルの位置をフィールドで保持したものを使用
                    self.tappedIndexPath = nil // 一度、画面遷移を行なったらセル位置の情報が残るのでリセットする
                }
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if identifier == "longTapped" { // segueがタップ
            if self.tappedIndexPath != nil { // ロングタップの場合はセルの位置情報を代入しているのでnilではない
                if let _:IndexPath = self.tappedIndexPath { //代入に成功したら、ロングタップだと判断できる
                    return true //true: 画面遷移させる
                }
            }
        }else if identifier == "buttonTapped" {
            return true
        }
        return false //false:画面遷移させない
    }
    // 追加機能　画面遷移の準備　仕訳画面
    var tappedIndexPath: IndexPath?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue.destinationの型はUIViewController
        let controller = segue.destination as! JournalEntryViewController
        // 遷移先のコントローラに値を渡す
        if segue.identifier == "buttonTapped" {
            controller.journalEntryType = "SettingsJournalEntries" // セルに表示した仕訳タイプを取得
        }
    }
    
}
// プロトコル定義
extension SettingsOperatingJournalEntryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // ヘッダーセル
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionReusableView", for: indexPath) as? CollectionReusableView else {
            fatalError("Could not find proper header")
        }
        if kind == UICollectionView.elementKindSectionHeader {
            if indexPath.section == 0 {
                header.sectionLabel.text = "仕訳テンプレート"//"section \(indexPath.section)"
            }
            return header
        }
        return UICollectionReusableView()
    }
    //collectionViewの要素の数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // データベース　仕訳テンプレートを追加
        let dataBaseManager = DataBaseManagerSettingsOperatingJournalEntry()
        let objects = dataBaseManager.getJournalEntry()
        return objects.count
    }
    //collectionViewのセルを返す（セルの内容を決める）
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ListCollectionViewCell
        // データベース　仕訳テンプレートを追加
        let dataBaseManager = DataBaseManagerSettingsOperatingJournalEntry()
        let objects = dataBaseManager.getJournalEntry()
        cell.nicknameLabel.text = objects[indexPath.row].nickname
        cell.debitLabel.text = objects[indexPath.row].debit_category
        cell.debitamauntLabel.text = String(objects[indexPath.row].debit_amount)
        cell.creditLabel.text = objects[indexPath.row].credit_category
        cell.creditamauntLabel.text = String(objects[indexPath.row].credit_amount)
        return cell
    }
//    //セル間の間隔を指定
//    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimunLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 20
//    }
    //セルのサイズ(CGSize)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(collectionView.frame)
        print(view.frame)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: collectionView.frame.width / 3 - 6, height: 100)
        }else {
            return CGSize(width: collectionView.frame.width - 6, height: 100)
        }
    }
    //余白の調整（UIImageを拡大、縮小している）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //top:ナビゲーションバーの高さ分上に移動
        return UIEdgeInsets(top: 3,left: 3,bottom: 3,right: 3)
    }
    ///セルの選択時に背景色を変化させる
    ///今度はセルが選択状態になった時に背景色が青に変化するようにしてみます。
    ///以下の3つのメソッドはデフォルトでtrueなので、このケースでは実装しなくても良いです。
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("Highlighted: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        print("Unhighlighted: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true  // 変更
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
