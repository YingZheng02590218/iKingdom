//
//  TableViewControllerPL.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 損益計算書クラス
class TableViewControllerPL: UITableViewController, UIPrintInteractionControllerDelegate {

    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 損益計算書　計算
        dataBaseManagerPL.initializeBenefits()
        
        let databaseManager = DataBaseManagerTB() //データベースマネジャー
        databaseManager.calculateAmountOfAllAccount()
        //精算表　借方合計と貸方合計の計算 (修正記入、損益計算書、貸借対照表)
        let databaseManagerWS = DataBaseManagerWS()
        databaseManagerWS.calculateAmountOfAllAccount()
        databaseManagerWS.calculateAmountOfAllAccountForBS()
        databaseManagerWS.calculateAmountOfAllAccountForPL()
        // 月末、年度末などの決算日をラベルに表示する
        let dataBaseManagerAccountingBooksShelf = DataBaseManagerAccountingBooksShelf() //データベースマネジャー
        let company = dataBaseManagerAccountingBooksShelf.getCompanyName()
        label_company_name.text = company // 社名
        let dataBaseManagerPeriod = DataBaseManagerPeriod() //データベースマネジャー
        let fiscalYear = dataBaseManagerPeriod.getSettingsPeriodYear()
        label_closingDate.text = String(fiscalYear+1) + "年3月31日" // 決算日を表示する
        label_title.text = "損益計算書"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("refreshTable")), for: UIControl.Event.valueChanged)
        self.refreshControl = refreshControl
    }
    // ビューが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool){
        // 仕訳帳画面を表示する際に、インセットを設定する。top: ステータスバーとナビゲーションバーの高さより下からテーブルを描画するため
        tableView.contentInset = UIEdgeInsets(top: +(view_top.bounds.height+UIApplication.shared.statusBarFrame.height+self.navigationController!.navigationBar.bounds.height), left: 0, bottom: 0, right: 0)
    }
    // ビューが表示された後に呼ばれる
    override func viewDidAppear(_ animated: Bool){
//        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
    }
    
    @objc func refreshTable() {
        // 全勘定の合計と残高を計算する
        let databaseManager = DataBaseManagerTB() //データベースマネジャー
        databaseManager.setAllAccountTotal()
        databaseManager.calculateAmountOfAllAccount() // 合計額を計算
        //精算表　借方合計と貸方合計の計算 (修正記入、損益計算書、貸借対照表)
        let databaseManagerWS = DataBaseManagerWS()
        databaseManagerWS.calculateAmountOfAllAccount()
        databaseManagerWS.calculateAmountOfAllAccountForBS()
        databaseManagerWS.calculateAmountOfAllAccountForPL()
        // 更新処理
        self.tableView.reloadData()
        // クルクルを止める
        refreshControl?.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース
//        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        let dataBaseManagerSettingsCategoryBSAndPL = DataBaseManagerSettingsCategoryBSAndPL() //データベースマネジャー
        let mid_category10 = dataBaseManagerSettingsCategoryBSAndPL.getMiddleCategory(mid_category: 10)//営業外収益10
        let mid_category6 = dataBaseManagerSettingsCategoryBSAndPL.getMiddleCategory(mid_category: 6)//営業外費用6
        let mid_category11 = dataBaseManagerSettingsCategoryBSAndPL.getMiddleCategory(mid_category: 11)//特別利益11
        let mid_category7 = dataBaseManagerSettingsCategoryBSAndPL.getMiddleCategory(mid_category: 7)//特別損失7
        let objects9 = dataBaseManagerSettingsCategoryBSAndPL.getSmallCategory(section: 3, small_category: 9)//販売費及び一般管理費9

        
//        let objects = dataBaseManagerSettingsCategoryBSAndPL.getBigCategory(section: 3)
//        let objectss = dataBaseManagerSettingsCategoryBSAndPL.getBigCategory(section: 4)
//        let mid_category9 = dataBaseManagerSettingsCategoryBSAndPL.getMiddleCategory(mid_category: 9)//営業収益9 小分類単位で利用するのでコメントアウト
//        let mid_category5 = dataBaseManagerSettingsCategoryBSAndPL.getMiddleCategory(mid_category: 5)//営業費用5 小分類単位で利用するのでコメントアウト
        
//        print(objects.count, objectss.count)
//        print(mid_category10.count, mid_category6.count, mid_category11.count, mid_category7.count)
        return 7 + 8 + 5 + mid_category10.count + objects9.count + mid_category6.count + mid_category11.count + mid_category7.count    // 7:5大利益　8:小分類のタイトル　5:小分類の合計
    }

    let dataBaseManagerPL = DataBaseManagerPL()
    let dataBaseManagerBSAndPL = DataBaseManagerBSAndPL() // Use of undeclared type ''が発生した。2020/07/24
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース
        let dataBaseManagerSettingsCategoryBSAndPL = DataBaseManagerSettingsCategoryBSAndPL() //データベースマネジャー
        // 中分類　中分類ごとの数を取得
        let mid_category10 = dataBaseManagerSettingsCategoryBSAndPL.getMiddleCategory(mid_category: 10)//営業外収益10
        let mid_category6 = dataBaseManagerSettingsCategoryBSAndPL.getMiddleCategory(mid_category: 6)//営業外費用6
        let mid_category11 = dataBaseManagerSettingsCategoryBSAndPL.getMiddleCategory(mid_category: 11)//特別利益11
        let mid_category7 = dataBaseManagerSettingsCategoryBSAndPL.getMiddleCategory(mid_category: 7)//特別損失7
        // 小分類
        let objects9 = dataBaseManagerSettingsCategoryBSAndPL.getSmallCategory(section: indexPath.section, small_category: 9)//販売費及び一般管理費9
        
        let han =           3 + objects9.count + 1 //販売費及び一般管理費合計
        let ei =            3 + objects9.count + 2 //営業利益
        let eigai =         3 + objects9.count + 3 //営業外収益10
        let eigaiTotal =    3 + objects9.count + mid_category10.count + 4 //営業外収益合計
        let eigaih =        3 + objects9.count + mid_category10.count + 5 //営業外費用6
        let eigaihTotal =   3 + objects9.count + mid_category10.count + mid_category6.count + 6 //営業外費用合計
        let kei =           3 + objects9.count + mid_category10.count + mid_category6.count + 7 //経常利益
        let toku =          3 + objects9.count + mid_category10.count + mid_category6.count + 8 //特別利益11
        let tokuTotal =     3 + objects9.count + mid_category10.count + mid_category6.count + mid_category11.count + 9 //特別利益合計
        let tokus =         3 + objects9.count + mid_category10.count + mid_category6.count + mid_category11.count + 10 //特別損失7
        let tokusTotal =    3 + objects9.count + mid_category10.count + mid_category6.count + mid_category11.count + mid_category7.count + 11 //特別損失合計
        let zei =           3 + objects9.count + mid_category10.count + mid_category6.count + mid_category11.count + mid_category7.count + 12 //税金等調整前当期純利益
        let zeikin =        3 + objects9.count + mid_category10.count + mid_category6.count + mid_category11.count + mid_category7.count + 13 //法人税等8
        let touki =         3 + objects9.count + mid_category10.count + mid_category6.count + mid_category11.count + mid_category7.count + 14 //当期純利益
        let htouki =        3 + objects9.count + mid_category10.count + mid_category6.count + mid_category11.count + mid_category7.count + 15 //非支配株主に帰属する当期純利益
        let otouki =        3 + objects9.count + mid_category10.count + mid_category6.count + mid_category11.count + mid_category7.count + 16 //親会社株主に帰属する当期純利益

        switch indexPath.row {
        case 0: //売上高10
            let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "売上高"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する 
            cell.label_amount.text = dataBaseManagerPL.getSmallCategoryTotal(big_category: 4, small_category: 10)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case 1: //売上原価8
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "売上原価"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getSmallCategoryTotal(big_category: 3, small_category: 8)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case 2: //売上総利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "売上総利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getBenefitTotal(benefit: 0)
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        case 3: //販売費及び一般管理費9
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "販売費及び一般管理費"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.label_amount.text = ""
            return cell
        case han: //販売費及び一般管理費合計
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "販売費及び一般管理費合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getSmallCategoryTotal(big_category: 3, small_category: 9)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case ei: //営業利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "営業利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getBenefitTotal(benefit: 1)
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        case eigai: //営業外収益10
            let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "営業外収益"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.label_amount.text = ""
            return cell
        case eigaiTotal: //営業外収益合計
            let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "営業外収益合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getMiddleCategoryTotal(big_category: 4, mid_category: 10)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case eigaih: //営業外費用6
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "営業外費用"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.label_amount.text = ""
            return cell
        case eigaihTotal: //営業外費用合計
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "営業外費用合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getMiddleCategoryTotal(big_category: 3, mid_category: 6)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case kei: //経常利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "経常利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getBenefitTotal(benefit: 2)
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        case toku: //特別利益11
            let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "特別利益"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.label_amount.text = ""
            return cell
        case tokuTotal: //特別利益合計
            let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "特別利益合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getMiddleCategoryTotal(big_category: 4, mid_category: 11)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case tokus: //特別損失7
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "特別損失"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            // 金額は表示しない
            cell.label_amount.text = ""
            return cell
        case tokusTotal: //特別損失合計
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "特別損失合計"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getMiddleCategoryTotal(big_category: 3, mid_category: 7)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case zei: //税金等調整前当期純利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "税金等調整前当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getBenefitTotal(benefit: 3)
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        case zeikin: //税等8
            let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "法人税等"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getMiddleCategoryTotal(big_category: 3, mid_category: 8)
            cell.label_amount.font = UIFont.systemFont(ofSize: 15)
            return cell
        case touki: //当期純利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = dataBaseManagerPL.getBenefitTotal(benefit: 4)
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        case htouki: //非支配株主に帰属する当期純利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "非支配株主に帰属する当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = "0"//dataBaseManagerPL.getBenefitTotal(benefit: 4) //todo
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        case otouki: //親会社株主に帰属する当期純利益
            let cell = tableView.dequeueReusableCell(withIdentifier: "equal", for: indexPath) as! TableViewCellAmount
            cell.textLabel?.text = "親会社株主に帰属する当期純利益"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //ラベルを置いて金額を表示する
            cell.label_amount.text = "0"//dataBaseManagerPL.getBenefitTotal(benefit: 4) //todo
            cell.label_amount.font = UIFont.boldSystemFont(ofSize: 15)
            return cell
        default:
            // 勘定科目
            if       indexPath.row > 3 &&                // 販売費及び一般管理費9
                     indexPath.row < han {                // 販売費及び一般管理費合計　タイトルより下の行から、合計の行より上
                let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
                cell.textLabel?.text = "    "+objects9[indexPath.row - (3+1)].category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.label_amount.text = dataBaseManagerBSAndPL.getAccountTotal(big_category: 3, bSAndPL_category: objects9[indexPath.row - (3+1)].BSAndPL_category)
                cell.label_amount.font = UIFont.systemFont(ofSize: 15)
                return cell
            }else if indexPath.row > eigai &&             // 営業外収益10
                      indexPath.row < eigaiTotal {          // 営業外収益合計
                let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
                cell.textLabel?.text = "    "+mid_category10[indexPath.row - (eigai + 1)].category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.label_amount.text = dataBaseManagerBSAndPL.getAccountTotal(big_category: 4, bSAndPL_category: mid_category10[indexPath.row - (eigai + 1)].BSAndPL_category) //収益:4
                cell.label_amount.font = UIFont.systemFont(ofSize: 15)
                return cell
            }else if indexPath.row > eigaih &&          // 営業外費用
                      indexPath.row < eigaihTotal {      // 営業外費用合計
                let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
                cell.textLabel?.text = "    "+mid_category6[indexPath.row - (eigaih + 1)].category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.label_amount.text = dataBaseManagerBSAndPL.getAccountTotal(big_category: 3, bSAndPL_category: mid_category6[indexPath.row - (eigaih + 1)].BSAndPL_category)
                cell.label_amount.font = UIFont.systemFont(ofSize: 15)
                return cell
            }else if indexPath.row > toku &&                       // 特別利益
                      indexPath.row < tokuTotal {                   // 特別利益合計
                let cell = tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
                cell.textLabel?.text = "    "+mid_category11[indexPath.row - (toku + 1)].category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.label_amount.text = dataBaseManagerBSAndPL.getAccountTotal(big_category: 4, bSAndPL_category: mid_category11[indexPath.row - (toku+1)].BSAndPL_category) //収益:4
                cell.label_amount.font = UIFont.systemFont(ofSize: 15)
                return cell
            }else if indexPath.row > tokus &&                   // 特別損失
                      indexPath.row < tokusTotal {               // 特別損失合計
                let cell = tableView.dequeueReusableCell(withIdentifier: "minus", for: indexPath) as! TableViewCellAmount
                cell.textLabel?.text = "    "+mid_category7[indexPath.row - (tokus + 1)].category
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                //ラベルを置いて金額を表示する
                cell.label_amount.text = dataBaseManagerBSAndPL.getAccountTotal(big_category: 3, bSAndPL_category: mid_category7[indexPath.row - (tokus+1)].BSAndPL_category)
                cell.label_amount.font = UIFont.systemFont(ofSize: 15)
                return cell
    // 税金　勘定科目を表示する必要はない
                // 法人税、住民税及び事業税
                // 法人税等調整額
            }else{
                    return tableView.dequeueReusableCell(withIdentifier: "plus", for: indexPath) as! TableViewCellAmount
            }
        }
    }
    @IBOutlet weak var view_top: UIView!
    var printing: Bool = false // プリント機能を使用中のみたてるフラグ　true:セクションをテーブルの先頭行に固定させない。描画時にセクションが重複してしまうため。
        // disable sticky section header
        override func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if printing {
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                // スクロールのオフセットがヘッダー部分のビューとステータスバーの高さ以上　かつ　0以上
                if scrollView.contentOffset.y >= view_top.bounds.height+UIApplication.shared.statusBarFrame.height+self.navigationController!.navigationBar.bounds.height && scrollView.contentOffset.y >= 0 {
                    // セクションヘッダーの高さをインセットに設定する　セクションヘッダーがテーブル上にとどまらないようにするため
                    scrollView.contentInset = UIEdgeInsets(top: -(view_top.bounds.height+UIApplication.shared.statusBarFrame.height+self.navigationController!.navigationBar.bounds.height), left: 0, bottom: 0, right: 0)
                }
            }else{
                if self.navigationController?.navigationBar.bounds.height != nil { //ナビゲーションバーが見えない状態で画面遷移をするとnilとなる　2020/07/12 22:45
                    // インセットを設定する　ステータスバーとナビゲーションバーより下からテーブルビューを配置するため
                    scrollView.contentInset = UIEdgeInsets(top: +self.navigationController!.navigationBar.bounds.height+UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
                }
                //            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
//                if scrollView.contentOffset.y <= tableView.sectionHeaderHeight && scrollView.contentOffset.y >= 0 { // スクロールがセクション高さ以上かつ0以上
//                    scrollView.contentInset = UIEdgeInsets(top: scrollView.contentOffset.y * -1, left: 0, bottom: 0, right: 0)
//                }else if scrollView.contentOffset.y > tableView.sectionHeaderHeight && scrollView.contentOffset.y >= 0 { // セクションの重複を防ぐ
//                    scrollView.contentInset = UIEdgeInsets(top: (tableView.sectionHeaderHeight+scrollView.contentOffset.y) * -1, left: 0, bottom: 0, right: 0)
//                }else if scrollView.contentOffset.y >= tableView.sectionHeaderHeight {
//        //            scrollView.contentInset = UIEdgeInsets(top: (tableView.sectionHeaderHeight+scrollView.contentOffset.y) * -1, left: 0, bottom: 0, right: 0)
//                    scrollView.contentInset = UIEdgeInsets(top: scrollView.contentOffset.y * -1, left: 0, bottom: 0, right: 0)
//                }
//            }else{
//                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            }
        }
    
        var pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)
        @IBOutlet weak var button_print: UIButton!
        /**
         * 印刷ボタン押下時メソッド
         */
        @IBAction func button_print(_ sender: UIButton) {
//            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
            printing = true
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
            // 第三の方法
            //余計なUIをキャプチャしないように隠す
            tableView.showsVerticalScrollIndicator = false
            if let tappedIndexPath: IndexPath = self.tableView.indexPathForSelectedRow { // タップされたセルの位置を取得
                tableView.deselectRow(at: tappedIndexPath, animated: true)// セルの選択を解除
            }
//            pageSize = CGSize(width: 210 / 25.4 * 72, height: 297 / 25.4 * 72)//実際印刷用紙サイズ937x1452ピクセル
            pageSize = CGSize(width: tableView.contentSize.width / 25.4 * 72, height: tableView.contentSize.height / 25.4 * 72)
            //viewと同じサイズのコンテキスト（オフスクリーンバッファ）を作成
    //        var rect = self.view.bounds
            //p-41 「ビットマップグラフィックスコンテキストを使って新しい画像を生成」
            //1. UIGraphicsBeginImageContextWithOptions関数でビットマップコンテキストを生成し、グラフィックススタックにプッシュします。
            UIGraphicsBeginImageContextWithOptions(pageSize, true, 0.0)
                //2. UIKitまたはCore Graphicsのルーチンを使って、新たに生成したグラフィックスコンテキストに画像を描画します。
    //        imageRect.draw(in: CGRect(origin: .zero, size: pageSize))
                //3. UIGraphicsGetImageFromCurrentImageContext関数を呼び出すと、描画した画像に基づく UIImageオブジェクトが生成され、返されます。必要ならば、さらに描画した上で再びこのメソッ ドを呼び出し、別の画像を生成することも可能です。
            //p-43 リスト 3-1 縮小画像をビットマップコンテキストに描画し、その結果の画像を取得する
    //        let newImage = UIGraphicsGetImageFromCurrentImageContext()
            let newImage = self.tableView.captureImagee()
            //4. UIGraphicsEndImageContextを呼び出してグラフィックススタックからコンテキストをポップします。
            UIGraphicsEndImageContext()
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
            //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
            printing = false
            /*
            ビットマップグラフィックスコンテキストでの描画全体にCore Graphicsを使用する場合は、
             CGBitmapContextCreate関数を使用して、コンテキストを作成し、
             それに画像コンテンツを描画します。
             描画が完了したら、CGBitmapContextCreateImage関数を使用し、そのビットマップコンテキストからCGImageRefを作成します。
             Core Graphicsの画像を直接描画したり、この画像を使用して UIImageオブジェクトを初期化することができます。
             完了したら、グラフィックスコンテキストに対 してCGContextRelease関数を呼び出します。
            */
            let myImageView = UIImageView(image: newImage)
            myImageView.layer.position = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
            
    //PDF
            //p-49 リスト 4-2 ページ単位のコンテンツの描画
                let framePath = NSMutableData()
            //p-45 「PDFコンテキストの作成と設定」
                // PDFグラフィックスコンテキストは、UIGraphicsBeginPDFContextToData関数、
                //  または UIGraphicsBeginPDFContextToFile関数のいずれかを使用して作成します。
                //  UIGraphicsBeginPDFContextToData関数の場合、
                //  保存先はこの関数に渡される NSMutableDataオブジェクトです。
                UIGraphicsBeginPDFContextToData(framePath, myImageView.bounds, nil)
            print(" myImageView.bounds : \(myImageView.bounds)")
            //p-46 「UIGraphicsBeginPDFPage関数は、デフォルトのサイズを使用してページを作成します。」
//                UIGraphicsBeginPDFPage()
//            UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:0, width:myImageView.bounds.width, height:myImageView.bounds.width*1.414516129), nil) //高さはA4コピー用紙と同じ比率にするために、幅×1.414516129とする

             /* PDFページの描画
               UIGraphicsBeginPDFPageは、デフォルトのサイズを使用して新しいページを作成します。一方、
               UIGraphicsBeginPDFPageWithInfo関数を利用す ると、ページサイズや、PDFページのその他の属性をカスタマイズできます。
            */
            //p-49 「リスト 4-2 ページ単位のコンテンツの描画」
                // グラフィックスコンテキストを取得する
//                guard let currentContext = UIGraphicsGetCurrentContext() else { return }
//                myImageView.layer.render(in: currentContext)
//
//            if myImageView.bounds.height > myImageView.bounds.width*1.414516129 {
//    //2ページ目
//           UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:-myImageView.bounds.width*1.414516129, width:myImageView.bounds.width, height:myImageView.bounds.width*1.414516129), nil) //高さはA4コピー用紙と同じ比率にするために、幅×1.414516129とする
//            // グラフィックスコンテキストを取得する
//            guard let currentContext2 = UIGraphicsGetCurrentContext() else { return }
//            myImageView.layer.render(in: currentContext2)
//            }
//            if myImageView.bounds.height > (myImageView.bounds.width*1.414516129)*2 {
//    //3ページ目
//            UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:-(myImageView.bounds.width*1.414516129)*2, width:myImageView.bounds.width, height:myImageView.bounds.width*1.414516129), nil) //高さはA4コピー用紙と同じ比率にするために、幅×1.414516129とする
//             // グラフィックスコンテキストを取得する
//             guard let currentContext3 = UIGraphicsGetCurrentContext() else { return }
//             myImageView.layer.render(in: currentContext3)
//            }
            // ビューイメージを全て印刷できるページ数を用意する
            var pageCounts: CGFloat = 0
            while myImageView.bounds.height > (myImageView.bounds.width*1.414516129) * pageCounts {
                //            if myImageView.bounds.height > (myImageView.bounds.width*1.414516129)*2 {
                UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:-(myImageView.bounds.width*1.414516129)*pageCounts, width:myImageView.bounds.width, height:myImageView.bounds.width*1.414516129), nil) //高さはA4コピー用紙と同じ比率にするために、幅×1.414516129とする
                // グラフィックスコンテキストを取得する
                guard let currentContext = UIGraphicsGetCurrentContext() else { return }
                myImageView.layer.render(in: currentContext)
                // ページを増加
                pageCounts += 1
            }
            //描画が終了したら、UIGraphicsEndPDFContextを呼び出して、PDFグラフィックスコンテキストを閉じます。
                UIGraphicsEndPDFContext()
                
    //ここからプリントです
            //p-63 リスト 5-1 ページ範囲の選択が可能な単一のPDFドキュメント
            let pic = UIPrintInteractionController.shared
            if UIPrintInteractionController.canPrint(framePath as Data) {
                //pic.delegate = self;
                pic.delegate = self
                
                let printInfo = UIPrintInfo.printInfo()
                printInfo.outputType = .general
                printInfo.jobName = "Profit And Loss Statement"
                printInfo.duplex = .none
                pic.printInfo = printInfo
                //'showsPageRange' was deprecated in iOS 10.0: Pages can be removed from the print preview, so page range is always shown.
                pic.printingItem = framePath
        
                let completionHandler: (UIPrintInteractionController, Bool, NSError) -> Void = { (pic: UIPrintInteractionController, completed: Bool, error: Error?) in
                    
                    if !completed && (error != nil) {
                        print("FAILED! due to error in domain %@ with error code %u \(String(describing: error))")
                    }
                }
                //p-79 印刷インタラクションコントローラを使って印刷オプションを提示
                //UIPrintInteractionControllerには、ユーザに印刷オプションを表示するために次の3つのメソッ ドが宣言されており、それぞれアニメーションが付属しています。
                if UIDevice.current.userInterfaceIdiom == .pad {
                    //これらのうちの2つは、iPadデバイス上で呼び出されることを想定しています。
                    //・presentFromBarButtonItem:animated:completionHandler:は、ナビゲーションバーまたは ツールバーのボタン(通常は印刷ボタン)からアニメーションでPopover Viewを表示します。
    //                print("通過・printButton.frame -> \(button_print.frame)")
    //                print("通過・printButton.bounds -> \(button_print.bounds)")
                    //UIBarButtonItemの場合
                    //pic.present(from: printUIButton, animated: true, completionHandler: nil)
                    //・presentFromRect:inView:animated:completionHandler:は、アプリケーションのビューの任意の矩形からアニメーションでPopover Viewを表示します。
                    pic.present(from: CGRect(x: 0, y: 0, width: 0, height: 0), in: self.view, animated: true, completionHandler: nil)
                    print("iPadです")
                } else {
                    //モーダル表示
                    //・presentAnimated:completionHandler:は、画面の下端からスライドアップするページをアニ メーション化します。これはiPhoneおよびiPod touchデバイス上で呼び出されることを想定しています。
                    pic.present(animated: true, completionHandler: completionHandler as? UIPrintInteractionController.CompletionHandler)
                    print("iPhoneです")
                }
            }
            //余計なUIをキャプチャしないように隠したのを戻す
            tableView.showsVerticalScrollIndicator = true
            // インセットを設定する　ステータスバーとナビゲーションバーより下からテーブルビューを配置するため
            tableView.contentInset = UIEdgeInsets(top: +self.navigationController!.navigationBar.bounds.height+UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) //ビットマップコンテキストに描画後、画面上のTableViewを先頭にスクロールする
        }
        
        // MARK: - UIImageWriteToSavedPhotosAlbum
        
        @objc func didFinishWriteImage(_ image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer) {
            if let error = error {
            print("Image write error: \(error)")
            }
        }

        func printInteractionController ( _ printInteractionController: UIPrintInteractionController, choosePaper paperList: [UIPrintPaper]) -> UIPrintPaper {
            print("printInteractionController")
            for i in 0..<paperList.count {
                let paper: UIPrintPaper = paperList[i]
            print(" paperListのビクセル is \(paper.paperSize.width) \(paper.paperSize.height)")
            }
            //ピクセル
            print(" pageSizeピクセル    -> \(pageSize)")
            let bestPaper = UIPrintPaper.bestPaper(forPageSize: pageSize, withPapersFrom: paperList)
            //mmで用紙サイズと印刷可能範囲を表示
            print(" paperSizeミリ      -> \(bestPaper.paperSize.width / 72.0 * 25.4), \(bestPaper.paperSize.height / 72.0 * 25.4)")
            print(" bestPaper         -> \(bestPaper.printableRect.origin.x / 72.0 * 25.4), \(bestPaper.printableRect.origin.y / 72.0 * 25.4), \(bestPaper.printableRect.size.width / 72.0 * 25.4), \(bestPaper.printableRect.size.height / 72.0 * 25.4)\n")
            return bestPaper
        }
    
}
