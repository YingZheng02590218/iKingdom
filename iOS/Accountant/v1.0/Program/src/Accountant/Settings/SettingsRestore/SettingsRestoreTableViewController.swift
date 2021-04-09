//
//  SettingsRestoreTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/01/13.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit

class SettingsRestoreTableViewController: UITableViewController {

    //    private var stateInAppPurchaseFlag = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        //State変数に代入して画面を変更する
//        self.stateInAppPurchaseFlag = inAppPurchaseFlag
        // セルを選択不可とする
//        self.tableView.allowsSelection = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
//            return "Premium Plan"
//        case 1:
//            return "Optional Plan"
//        case 2:
            return "Standard Plan"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
//            return "プレミアムプランは、クラウド機能が解放されます。アプリ内に保存された大切な仕訳データをiCloud上にバックアップを取ることで、iPhone本体が破損した場合などの、万が一に備えてデータの復元が可能な状態を保ちます。他には、iPadなどのタブレット端末など、同じAppleアカウントでログインしているデバイスと、データを同期させることができるので、複数のデバイスから仕訳入力ができます。\n(スタンダードプランとオプショナルプランの機能を含みます)"
//        case 1:
//            return "オプショナルプランは、さらにユーザービリティを高めるための、細かな操作設定が可能となります。\n(スタンダードプランの機能を含みます)"
//        case 2:
            return "スタンダードプランを復元します。"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! SettingUpgradeTableViewCell
        switch indexPath.section {
        case 0:
//            //① UI部品を指定　TableViewCell
//            cell.textLabel?.text = "プレミアムプラン" // 注意：UITableViewCell内のViewに表示している。AttributesInspectorでHiddenをONにすると見えなくなる。
//            cell.label.text = "￥ 6,000 / 年"
//            cell.label.textColor = .darkGray
//            return cell
//        case 1:
//            cell.textLabel?.text = "オプショナルプラン"
//            cell.label.text = "￥ 3,600 / 年"
//            cell.label.textColor = .darkGray
//            return cell
//        case 2:
//            let upgradeManager = UpgradeManager()
//            upgradeManager.purchaseGetInfo(PRODUCT_ID: ["com.ikingdom.Accountant.autoRenewableSubscriptions.advertisingOff"])
            cell.textLabel?.text = "スタンダードプラン"
            cell.label.textColor = .darkGray
            cell.label.textAlignment = .right
            if inAppPurchaseFlag {
                cell.label.text = "復元済み　"
            }else {
                cell.label.text = "購入を復元　"
            }
            return cell
        default:
            return cell
        }
    }
    // セルが選択された時に呼び出される　// すべての影響範囲に修正が必要
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        if inAppPurchaseFlag {
//
//        }else {
            // アップグレード機能　まずinAppPurchaseを判断する　receiptチェックする
            let upgradeManager = UpgradeManager()
            upgradeManager.verifyPurchase(PRODUCT_ID:"com.ikingdom.Accountant.autoRenewableSubscriptions.advertisingOff")
            print(UserDefaults.standard.object(forKey: "buy"))
            if UserDefaults.standard.object(forKey: "buy") != nil {
                let count = UserDefaults.standard.object(forKey: "buy") as! Int
                if count == 1 {
                    inAppPurchaseFlag = true
                }
            } else {
                inAppPurchaseFlag = false
            }
//            guard inAppPurchaseFlag  else {
//                upgradeManager.purchase(PRODUCT_ID: "com.ikingdom.Accountant.autoRenewableSubscriptions.advertisingOff")
//                return
//            }
            print("InAppPurchaseがあります。inAppPurchaseFlagは\(inAppPurchaseFlag)です。")
        }
//    }
}
