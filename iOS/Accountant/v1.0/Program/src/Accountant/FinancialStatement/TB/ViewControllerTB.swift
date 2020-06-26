//
//  ViewControllerTB.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/19.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 試算表クラス
class ViewControllerTB: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableView_TB: UITableView!
    @IBOutlet weak var label_company_name: UILabel!
    @IBOutlet weak var label_closingDate: UILabel!
    @IBOutlet weak var segmentedControl_switch: UISegmentedControl!
    @IBAction func segmentedControl(_ sender: Any) {
        TableView_TB.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TableView_TB.delegate = self
        TableView_TB.dataSource = self
        
        let databaseManager = DataBaseManagerTB() //データベースマネジャー
        databaseManager.culculatAmountOfAllAccount()
        // 月末、年度末などの決算日をラベルに表示する
//        label_closingDate.text = "令和xx年3月31日"
        label_company_name.text = "会社の名前" // Todo
        let dataBaseManagerPeriod = DataBaseManagerPeriod() //データベースマネジャー
        let fiscalYear = dataBaseManagerPeriod.getSettingsPeriodYear()
        // ToDo どこで設定した年度のデータを参照するか考える
        label_closingDate.text = fiscalYear.description + "年3月31日" // 決算日を表示する

    }
    
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        // セクション毎に分けて表示する。indexPath が row と section を持っているので、sectionで切り分ける。ここがポイント
        let objects = databaseManagerSettings.getAllSettingsCategory()
        return objects.count + 1 //合計額の行の分
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // データベース
        let databaseManagerSettings = DatabaseManagerSettingsCategory() //データベースマネジャー
        let objects = databaseManagerSettings.getAllSettingsCategory()
        let databaseManager = DataBaseManagerTB() //データベースマネジャー

        if indexPath.row < objects.count {
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_TB", for: indexPath) as! TableViewCellTB
            // 勘定科目をセルに表示する
            //        cell.textLabel?.text = "\(objects[indexPath.row].category as String)"
            cell.label_account.text = "\(objects[indexPath.row].category as String)"
            cell.label_account.textAlignment = NSTextAlignment.center
            switch segmentedControl_switch.selectedSegmentIndex {
            case 0: // 合計　借方
                cell.label_debit.text = databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 0).description
                    // 合計　貸方
                cell.label_credit.text = databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 1).description
                break
            case 1: // 残高　借方
                cell.label_debit.text = databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 2).description
                    // 残高　貸方
                cell.label_credit.text = databaseManager.getTotalAmount(account: "\(objects[indexPath.row].category as String)", leftOrRight: 3).description
                break
            default:
                print()
            }
            return cell
        }else {
            let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
            let object = dataBaseManagerFinancialStatements.getFinancialStatements()
            //① UI部品を指定
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_last_TB", for: indexPath) as! TableViewCellTB
//            let r = 0
//            switch r {
            switch segmentedControl_switch.selectedSegmentIndex {
            case 0: // 合計　借方
                cell.label_debit.text = object.compoundTrialBalance?.debit_total_total.description
                    // 合計　貸方
                cell.label_credit.text = object.compoundTrialBalance?.credit_total_total.description
                break
            case 1: // 残高　借方
                cell.label_debit.text = object.compoundTrialBalance?.debit_balance_total.description
                    // 残高　貸方
                cell.label_credit.text = object.compoundTrialBalance?.credit_balance_total.description
                break
            default:
                print()
            }
            return cell
        }
    }
}
