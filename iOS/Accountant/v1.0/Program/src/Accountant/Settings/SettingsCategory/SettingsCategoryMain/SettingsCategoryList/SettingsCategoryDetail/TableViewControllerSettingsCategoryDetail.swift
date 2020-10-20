//
//  TableViewControllerSettingsCategoryDetail.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/09/21.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 勘定科目　詳細画面
class TableViewControllerSettingsCategoryDetail: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 表示科目を変更後に勘定科目詳細画面を更新する
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // 大区分
            // 中区分
            // 小区分
            // 勘定科目名
            return 4
        }else {
            // 表示科目
            return 1
        }
    }

    var numberOfAccount :Int = 0 // 勘定科目番号
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCellSettingCategoryDetail
        // 勘定科目の連番から勘定科目を取得　紐づけた表示科目の連番を知るため
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        let object = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccount(number: numberOfAccount) // 勘定科目
        cell.label.text = "-"
        // セルの選択不可にする
        cell.selectionStyle = .none
        if indexPath.section == 0 { // タクソノミ
            switch indexPath.row {
            case 0:
                // 勘定科目の名称をセルに表示する
                cell.textLabel?.text = "大区分"
                cell.textLabel?.textColor = .darkGray
                cell.textLabel?.textAlignment = NSTextAlignment.left
                switch object?.Rank0 {
                case "0": cell.label.text =   "流動資産"
                    break
                case "1": cell.label.text =   "固定資産"
                    break
                case "2": cell.label.text =   "繰延資産"
                    break
                case "3": cell.label.text =   "流動負債"
                    break
                case "4": cell.label.text =   "固定負債"
                    break
                case "5": cell.label.text =   "資本"
                    break
                case "6": cell.label.text =   "売上"
                    break
                case "7": cell.label.text =   "売上原価"
                    break
                case "8": cell.label.text =   "販売費及び一般管理費"
                    break
                case "9": cell.label.text =   "営業外損益"
                    break
                case "10": cell.label.text =   "特別損益"
                    break
                case "11": cell.label.text =   "税金"
                    break
                default:
                    cell.label.text = "-"
                    break
                }
    //            if object!.category0 != "" {
    //            cell.label.text = dataBaseManagerSettingsCategoryBSAndPL.getMiddleCategory(category0: objectt!.category0,category1: objectt!.category1,category2: objectt!.category2,category3:"")[0].category
    //            }
                cell.label.textAlignment = NSTextAlignment.center
                break
            case 1:
                cell.textLabel?.text = "中区分"
                cell.textLabel?.textColor = .darkGray
                cell.textLabel?.textAlignment = NSTextAlignment.left
                switch object?.Rank1 {
                case "0": cell.label.text =   "当座資産"
                    break
                case "1": cell.label.text =   "棚卸資産"
                    break
                case "2": cell.label.text =   "その他の流動資産"
                    break
                case "3": cell.label.text =   "有形固定資産"
                    break
                case "4": cell.label.text =   "無形固定資産"
                    break
                case "5": cell.label.text =   "投資その他の資産"
                    break
                case "6": cell.label.text =   "繰延資産"
                    break
                case "7": cell.label.text =   "仕入債務"
                    break
                case "8": cell.label.text =   "その他の流動負債"
                    break
                case "9": cell.label.text =   "長期債務"
                    break
                case "10": cell.label.text =   "株主資本"
                    break
                case "11": cell.label.text =   "評価・換算差額等"
                    break
                case "12": cell.label.text =   "新株予約権"
                    break
                case "13": cell.label.text =   "売上原価"
                    break
                case "14": cell.label.text =   "製造原価"
                    break
                case "15": cell.label.text =   "営業外収益"
                    break
                case "16": cell.label.text =   "営業外費用"
                    break
                case "17": cell.label.text =   "特別利益"
                    break
                case "18": cell.label.text =   "特別損失"
                    break
                default:
                    cell.label.text = "-"
                    break
                }
    //            if object!.category0 != "" {
    //            cell.label.text = dataBaseManagerSettingsCategoryBSAndPL.getSmallCategory(category0: objectt!.category0,category1: objectt!.category1,category2: objectt!.category2,category3:objectt!.category3,category4: "")[0].category
    //            }
                cell.label.textAlignment = NSTextAlignment.center
                break
            case 2:
                cell.textLabel?.text = "小区分"
                cell.textLabel?.textColor = .darkGray
                cell.textLabel?.textAlignment = NSTextAlignment.left
    //            if object!.category0 != "" {
    //            cell.label.text = dataBaseManagerSettingsCategoryBSAndPL.getSmallCategory(category0: objectt!.category0,category1: objectt!.category1,category2: objectt!.category2,category3:objectt!.category3,category4:objectt!.category4)[0].category
    //            }
                cell.label.textAlignment = NSTextAlignment.center
                break
            case 3: // 勘定科目
                cell.textLabel?.text = "勘定科目名"
                cell.textLabel?.textColor = .darkGray
                cell.textLabel?.textAlignment = NSTextAlignment.left
                cell.label.text = object!.category
                //勘定科目
                cell.label.textAlignment = NSTextAlignment.center
                break
            default:
                //
                break
            }
        }else {
            cell.textLabel?.text = "表示科目名"
            cell.textLabel?.textColor = .darkGray
            cell.textLabel?.textAlignment = NSTextAlignment.left
            // セルの選択を許可
            cell.selectionStyle = .default
            if object!.Rank0 != "" {
                // 表示科目の連番から表示科目を取得　勘定科目の詳細情報を得るため
                let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
                if "" != object?.numberOfTaxonomy {
                    let objectt = dataBaseManagerSettingsTaxonomy.getSettingsTaxonomy(numberOfTaxonomy: Int(object!.numberOfTaxonomy)!) // 表示科目
                    cell.label.text = objectt!.category
                    cell.label.textColor = .black
                }else {
                    cell.label.text = "表示科目を選択してください"
                    cell.label.textColor = .lightGray
                }
            }
            cell.label.textAlignment = NSTextAlignment.center
        }
        return cell
    }
    // セルが選択された時に呼び出される　// すべての影響範囲に修正が必要
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at:indexPath) as! TableViewCellSettingCategoryDetail
        // 勘定科目名　変更
//        var alertTextField: UITextField?
//        let alert = UIAlertController(
//            title: "Edit Name",
//            message: "Enter new name",
//            preferredStyle: UIAlertController.Style.alert)
//        alert.addTextField(
//            configurationHandler: {(textField: UITextField!) in
//                alertTextField = textField
//                textField.text = cell.label.text
//                // textField.placeholder = "Mike"
//                // textField.isSecureTextEntry = true
//        })
//        alert.addAction(
//            UIAlertAction(
//                title: "Cancel",
//                style: UIAlertAction.Style.cancel,
//                handler: nil))
//        alert.addAction(
//            UIAlertAction(
//                title: "OK",
//                style: UIAlertAction.Style.default) { _ in
//                if let text = alertTextField?.text {
//                    cell.label.text = text
//                    // 勘定科目の連番から、勘定科目名を更新する
//                    let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
//                    databaseManagerSettingsTaxonomyAccount.updateAccountNameOfSettingsTaxonomyAccount(number: self.numberOfAccount, accountName: text) // 勘定科目
//                }
//            }
//        )
//        self.present(alert, animated: true, completion: nil)
    }
    // 追加・編集機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        if IndexPath(row: 0, section: 1) != self.tableView.indexPathForSelectedRow! { // 表示科目名以外は遷移しない
            return false //false:画面遷移させない
        }
        return true
    }
    // 画面遷移の準備　表示科目一覧画面へ
    var tappedIndexPath: IndexPath?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 勘定科目の連番から勘定科目を取得　紐づけた表示科目の連番を知るため
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        let object = databaseManagerSettingsTaxonomyAccount.getSettingsTaxonomyAccount(number: numberOfAccount) // 勘定科目

        // 選択されたセルを取得
        let indexPath: IndexPath = self.tableView.indexPathForSelectedRow! // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
        switch segue.identifier {
        // 損益勘定
        case "segue_TaxonomyList": //“セグウェイにつけた名称”:
            // segue.destinationの型はUIViewController
            let viewControllerGenearlLedgerAccount = segue.destination as! TableViewControllerSettingsTaxonomyList
            // 遷移先のコントローラに値を渡す
            viewControllerGenearlLedgerAccount.numberOfTaxonomyAccount = numberOfAccount // 設定勘定科目連番　を渡す
            switch object?.Rank0 {
            case "0","1","2","3","4","5":
                viewControllerGenearlLedgerAccount.segmentedControl_switch.selectedSegmentIndex = 0 // セグメントスイッチにBSを設定
                // 遷移先のコントローラー.条件用の属性 = “条件”
                break
            case "6","7","8","9","10","11":
                viewControllerGenearlLedgerAccount.segmentedControl_switch.selectedSegmentIndex = 1 // セグメントスイッチにPLを設定
                break
            default:
                //
                break
            }
            viewControllerGenearlLedgerAccount.howToUse = true // 勘定科目　詳細　設定画面からの遷移の場合はtrue
        default:
            //
            break
        }
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // 勘定科目に紐づけられた表示科目を変更する　設定勘定科目連番、表示科目連番
    func changeTaxonomyOfTaxonomyAccount(number: Int, numberOfTaxonomy: Int) {
        // データベース　仕訳データを追加
        let databaseManagerSettingsTaxonomyAccount = DatabaseManagerSettingsTaxonomyAccount()
        databaseManagerSettingsTaxonomyAccount.updateTaxonomyOfSettingsTaxonomyAccount(number: number, numberOfTaxonomy: String(numberOfTaxonomy))
    }

}
