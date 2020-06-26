//
//  TableViewControllerBS.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 貸借対照表クラス
class TableViewControllerBS: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // 資産の部、負債の部、純資産の部
        return 3
    }
    // セクションヘッダーの高さを決める
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 //セクションヘッダーの高さを設定　セルの高さより高くしてメリハリをつける セル(Row Hight 30)
    }
    // セクションヘッダーの色とか調整する
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.gray
        header.textLabel?.textAlignment = .left
        // システムフォントのサイズを設定
        header.textLabel?.font = UIFont.systemFont(ofSize: 20)
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "資産の部"
        case 1:
            return "負債の部"
        case 2:
            return "純資産の部"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = databaseManagerSettings.getSettings(section: section) // どのセクションに表示するセルかを判別するため引数で渡す
//        return objects.count + 5 // 分類名(流動資産,固定資産など)と合計の行
        switch section {
        case 0://資産の部
            return 5+6+objects.count // 中分類、小分類、勘定科目　の数
        case 1://負債の部
            return 5+2+objects.count
        case 2://純資産の部
            return 5+0+objects.count
        default:
            return 0
        }
    }

    let dataBaseManagerBS = DataBaseManagerBS()
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー

        switch indexPath.section {
        case 0: // 資産の部
            // 中分類　中分類ごとの数を取得
            let objectsCounts0 = databaseManagerSettings.getMiddleCategory(section: indexPath.section,mid_category: 0)
            let objectsCounts1 = databaseManagerSettings.getMiddleCategory(section: indexPath.section,mid_category: 1)
            // 小分類
            let objects0 = databaseManagerSettings.getSmallCategory(section: indexPath.section, small_category: 0)
            let objects1 = databaseManagerSettings.getSmallCategory(section: indexPath.section, small_category: 1)
            let objects2 = databaseManagerSettings.getSmallCategory(section: indexPath.section, small_category: 2)
            let objects3 = databaseManagerSettings.getSmallCategory(section: indexPath.section, small_category: 3)
            let objects4 = databaseManagerSettings.getSmallCategory(section: indexPath.section, small_category: 4)
            let objects5 = databaseManagerSettings.getSmallCategory(section: indexPath.section, small_category: 5)

            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "流動資産" // 注意：UITableViewCell内のViewに表示している。AttributesInspectorでHiddenをONにすると見えなくなる。
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                return cell
            case 1 + objectsCounts0.count + 3: // 中分類名の分を1行追加
                let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath) as! TableViewCellTotal
                cell.textLabel?.text = "流動資産合計"
                let text:String = dataBaseManagerBS.getMiddleCategoryTotal(big_category: indexPath.section, mid_category: 0)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_total.attributedText = attributeText
                return cell
            case 1 + objectsCounts0.count + 3 + 1: // 中分類名の分を1行追加 合計の行を追加
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "固定資産"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                return cell
            case 1 + objectsCounts0.count + 3 + 1 + objectsCounts1.count + 3 + 1: //最後の行の前
                let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath) as! TableViewCellTotal
                cell.textLabel?.text = "固定資産合計"
                let text:String = dataBaseManagerBS.getMiddleCategoryTotal(big_category: indexPath.section, mid_category: 1)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_total.attributedText = attributeText
                return cell
            case 1 + objectsCounts0.count + 3 + 1 + objectsCounts1.count + 3 + 1 + 1: //最後の行
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                cell.textLabel?.text = "資産合計"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                let text:String = dataBaseManagerBS.getBigCategoryTotal(big_category: 0)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfMiddleCategory.attributedText = attributeText
                cell.label_totalOfMiddleCategory.font = UIFont.boldSystemFont(ofSize: 20)
                return cell
            default:
                // 小分類
                switch indexPath.row {
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    cell.textLabel?.text = translateSmallCategory(small_category: 0)
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    return cell
                case 1 + objects0.count + 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    cell.textLabel?.text = translateSmallCategory(small_category: 1)
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    return cell
                case 1 + objects0.count + 1 + objects1.count + 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    cell.textLabel?.text = translateSmallCategory(small_category: 2)
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    return cell
                case 1 + objectsCounts0.count + 3 + 1 + 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    cell.textLabel?.text = translateSmallCategory(small_category: 3)
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    return cell
                case 1 + objectsCounts0.count + 3 + 1 + objects3.count + 1 + 1: // 無形固定資産
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    cell.textLabel?.text = translateSmallCategory(small_category: 4)
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    return cell
                case 1 + objectsCounts0.count + 3 + 1 + objects3.count + 1 + objects4.count + 1 + 1: // 投資その他資産
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    cell.textLabel?.text = translateSmallCategory(small_category: 5)
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    return cell
                default:
                    // 勘定科目
                    let cell = tableView.dequeueReusableCell(withIdentifier: "account", for: indexPath) as! TableViewCellAccount
                    if       indexPath.row >= 2 &&                  // 中分類、小分類　計二行
                             indexPath.row <  2+objects0.count+1 {  // 小分類のタイトルより下の行から、小分類合計の行より上
                        cell.textLabel?.text = objects0[indexPath.row-(1+1)].category
                        // 勘定別の合計　計算
                        cell.label_account.text = dataBaseManagerBS.getAccountTotal(big_category: indexPath.section, account: objects0[indexPath.row-(1+1)].category)    // 合計
                        cell.label_account.textAlignment = .right
                    }else if indexPath.row >= 2+objects0.count &&
                             indexPath.row <  2+objects0.count+1+objects1.count+1 { //小分類
                        cell.textLabel?.text = objects1[indexPath.row-(2+objects0.count+1)].category
                        cell.label_account.text = dataBaseManagerBS.getAccountTotal(big_category: indexPath.section, account: objects1[indexPath.row-(2+objects0.count+1)].category)
                        cell.label_account.textAlignment = .right
                    }else if indexPath.row >= 2+objects0.count+1+objects1.count &&
                             indexPath.row <  2+objects0.count+1+objects1.count+1+objects2.count+1 { //小分類
                        cell.textLabel?.text = objects2[indexPath.row-(2+objects0.count+1+objects1.count+1)].category
                        cell.label_account.text = dataBaseManagerBS.getAccountTotal(big_category: indexPath.section, account: objects2[indexPath.row-(2+objects0.count+1+objects1.count+1)].category)
                        cell.label_account.textAlignment = .right
                    }else if indexPath.row >= 2+objects0.count+1+objects1.count+1+objects2.count &&
                             indexPath.row <  4+objects0.count+1+objects1.count+1+objects2.count+1+objects3.count+1 { //小分類
                        cell.textLabel?.text = objects3[indexPath.row-(4+objects0.count+1+objects1.count+1+objects2.count+1)].category
                        cell.label_account.text = dataBaseManagerBS.getAccountTotal(big_category: indexPath.section, account: objects3[indexPath.row-(4+objects0.count+1+objects1.count+1+objects2.count+1)].category)
                        cell.label_account.textAlignment = .right
                    }else if indexPath.row >= 4+objects0.count+1+objects1.count+1+objects2.count+1+objects3.count &&
                             indexPath.row <  4+objects0.count+1+objects1.count+1+objects2.count+1+objects3.count+1+objects4.count+1 { // 無形固定資産
                        cell.textLabel?.text = objects4[indexPath.row-(4+objects0.count+1+objects1.count+1+objects2.count+1+objects3.count+1)].category
                        cell.label_account.text = dataBaseManagerBS.getAccountTotal(big_category: indexPath.section, account: objects4[indexPath.row-(4+objects0.count+1+objects1.count+1+objects2.count+1+objects3.count+1)].category)
                        cell.label_account.textAlignment = .right
                    }else if indexPath.row >= 4+objects0.count+1+objects1.count+1+objects2.count+1+objects3.count+1+objects4.count &&
                             indexPath.row <  6+objects0.count+1+objects1.count+1+objects2.count+1+objects3.count+1+objects4.count+1+objects5.count+1 { // 無形固定資産
                        cell.textLabel?.text = objects5[indexPath.row-(4+objects0.count+1+objects1.count+1+objects2.count+1+objects3.count+1+objects4.count+1)].category
                        cell.label_account.text = dataBaseManagerBS.getAccountTotal(big_category: indexPath.section, account: objects5[indexPath.row-(4+objects0.count+1+objects1.count+1+objects2.count+1+objects3.count+1+objects4.count+1)].category)
                        cell.label_account.textAlignment = .right
                    }
                    return cell
                }
            }
        case 1: // 負債の部
            // 中分類　中分類ごとの数を取得
            let objectsCounts2 = databaseManagerSettings.getMiddleCategory(section: indexPath.section,mid_category: 2)
            let objectsCounts3 = databaseManagerSettings.getMiddleCategory(section: indexPath.section,mid_category: 3)
            // 小分類
            let objects6 = databaseManagerSettings.getSmallCategory(section: indexPath.section, small_category: 6)
            let objects7 = databaseManagerSettings.getSmallCategory(section: indexPath.section, small_category: 7)
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "流動負債"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                return cell
            case 2 + objectsCounts2.count + 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath) as! TableViewCellTotal
                cell.textLabel?.text = "流動負債合計"
                let text:String = dataBaseManagerBS.getMiddleCategoryTotal(big_category: indexPath.section, mid_category: 2)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_total.attributedText = attributeText
                return cell
            case 2 + objectsCounts2.count + 2: // 中分類名の分を1行追加 合計の行を追加
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "固定負債"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                return cell
            case 2 + objectsCounts2.count + 2 + 1 + objectsCounts3.count: //最後の行の前
                let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath) as! TableViewCellTotal
                cell.textLabel?.text = "固定負債合計"
                let text:String = dataBaseManagerBS.getMiddleCategoryTotal(big_category: indexPath.section, mid_category: 3)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_total.attributedText = attributeText
                return cell
            case 2 + objectsCounts2.count + 2 + 1 + objectsCounts3.count + 1: //最後の行
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                cell.textLabel?.text = "負債合計"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                let text:String = dataBaseManagerBS.getBigCategoryTotal(big_category: 1)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfMiddleCategory.attributedText = attributeText
                cell.label_totalOfMiddleCategory.font = UIFont.boldSystemFont(ofSize: 20)
                return cell
            default:
                // 小分類
                switch indexPath.row {
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    cell.textLabel?.text = translateSmallCategory(small_category: 6)
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    return cell
                case 1 + objects6.count + 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    cell.textLabel?.text = translateSmallCategory(small_category: 7)
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    return cell
                default:
                    // 勘定科目
                    let cell = tableView.dequeueReusableCell(withIdentifier: "account", for: indexPath) as! TableViewCellAccount
                    if       indexPath.row >= 2 &&                  // 中分類、小分類　計二行
                             indexPath.row <  2+objects6.count+1 {  // 小分類のタイトルより下の行から、小分類合計の行より上
                        cell.textLabel?.text = objects6[indexPath.row-(1+1)].category
                        cell.label_account.text = dataBaseManagerBS.getAccountTotal(big_category: indexPath.section, account: objects6[indexPath.row-(1+1)].category)
                        cell.label_account.textAlignment = .right
                    }else if indexPath.row >= 2+objects6.count &&
                             indexPath.row <  2+objects6.count+1+objects7.count+1 { //小分類
                        cell.textLabel?.text = objects7[indexPath.row-(2+objects6.count+1)].category
                        cell.label_account.text = dataBaseManagerBS.getAccountTotal(big_category: indexPath.section, account: objects7[indexPath.row-(2+objects6.count+1)].category)
                        cell.label_account.textAlignment = .right
                    }else if indexPath.row >= 2+objects6.count+1+objects7.count &&
                             indexPath.row <  2+objects6.count+1+objects7.count+1+0+1 { //小分類
                        cell.textLabel?.text = objectsCounts3[indexPath.row-(2+objects6.count+1+objects7.count+1)].category //"小分類なし" //Todo
                        cell.label_account.text = dataBaseManagerBS.getAccountTotal(big_category: indexPath.section, account: objectsCounts3[indexPath.row-(2+objects6.count+1+objects7.count+1)].category)
                        cell.label_account.textAlignment = .right
                    }
                    return cell
                }
            }
        case 2: // 純資産の部
            // 中分類　中分類ごとの数を取得
            let objectsCounts4 = databaseManagerSettings.getMiddleCategory(section: indexPath.section,mid_category: 4)
            
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "株主資本"
                //                cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                return cell
            case objectsCounts4.count + 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath) as! TableViewCellTotal
                cell.textLabel?.text = "株主資本合計"
                let text:String = dataBaseManagerBS.getMiddleCategoryTotal(big_category: indexPath.section, mid_category: 4)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_total.attributedText = attributeText
                return cell
            case objectsCounts4.count + 2: // 中分類名の分を1行追加 合計の行を追加
                let cell = tableView.dequeueReusableCell(withIdentifier: "middleCategory", for: indexPath)
                cell.textLabel?.text = "その他の包括利益累計額"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                return cell
            case objectsCounts4.count + 3 + 0: //最後の行 Todo
                let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath) as! TableViewCellTotal
                cell.textLabel?.text = "その他の包括利益累計額合計"
                let text:String = "0"//dataBaseManagerBS.calculateMiddleTotal(big_category: indexPath.section, mid_category: 4)//Todo
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_total.attributedText = attributeText
                return cell
            case objectsCounts4.count + 3 + 0 + 1: //最後の行
                let cell = tableView.dequeueReusableCell(withIdentifier: "totalOfMiddleCategory", for: indexPath) as! TableViewCellTotalOfMiddleCategory
                cell.textLabel?.text = "純資産合計"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                let text:String = dataBaseManagerBS.getBigCategoryTotal(big_category: 2)
                // テキストをカスタマイズするために、NSMutableAttributedStringにする
                let attributeText = NSMutableAttributedString(string: text)
                // styleをunderLineに。valueをrawValueに。該当箇所を0-text.count文字目まで
                attributeText.addAttribute(
                  NSAttributedString.Key.underlineStyle,
                  value: NSUnderlineStyle.single.rawValue,
                  range: NSMakeRange(0, text.count)
                )
                cell.label_totalOfMiddleCategory.attributedText = attributeText
                cell.label_totalOfMiddleCategory.font = UIFont.boldSystemFont(ofSize: 20)
                return cell
            default:
                // 勘定科目
                let cell = tableView.dequeueReusableCell(withIdentifier: "account", for: indexPath) as! TableViewCellAccount
                if       indexPath.row >= 1 &&                        // 中分類、小分類　計二行
                         indexPath.row <  1+objectsCounts4.count+1 {  // 小分類のタイトルより下の行から、小分類合計の行より上
                    cell.textLabel?.text = objectsCounts4[indexPath.row-1].category
                    cell.label_account.text = dataBaseManagerBS.getAccountTotal(big_category: indexPath.section, account: objectsCounts4[indexPath.row-1].category)
                    cell.label_account.textAlignment = .right
                }
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }

    func translateSmallCategory(small_category: Int) -> String {
        var small_category_name: String
        switch small_category {
        case 0:
            small_category_name = " 現金・預金"
            break
        case 1:
            small_category_name = " 棚卸資産"
            break
        case 2:
            small_category_name = " その他流動資産"
            break
        case 3:
            small_category_name = " 有形固定資産"
            break
        case 4:
            small_category_name = " 無形固定資産"
            break
        case 5:
            small_category_name = " 投資その他資産"
            break
        case 6:
            small_category_name = " 仕入負債"
            break
        case 7:
            small_category_name = " その他流動負債"
            break
        case 8:
            small_category_name = " 売上原価"
            break
        case 9:
            small_category_name = " 販売費及び一般管理費"
            break
        case 10:
            small_category_name = " 売上高"
            break
        default:
            small_category_name = " 小分類なし"
            break
        }
        return small_category_name
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
