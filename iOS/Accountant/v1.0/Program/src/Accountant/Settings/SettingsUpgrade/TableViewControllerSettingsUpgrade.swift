//
//  TableViewControllerSettingsUpgrade.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/01/08.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit
import SwiftyStoreKit // アップグレード機能
import StoreKit // アップグレード機能

// アップグレード
class TableViewControllerSettingsUpgrade: UITableViewController {

//    private var stateInAppPurchaseFlag = false
    private var products: [SKProduct] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // 価格を取得
        purchaseGetInfo(PRODUCT_ID: ["com.ikingdom.Accountant.autoRenewableSubscriptions.advertisingOff"]) // 定数定義する
        // アップグレード機能　まずinAppPurchaseを判断する　receiptチェックする
        let upgradeManager = UpgradeManager()
        upgradeManager.verifyPurchase(PRODUCT_ID:"com.ikingdom.Accountant.autoRenewableSubscriptions.advertisingOff") // 定数定義する
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return products.count // 注意：ベタ書きで1と書くと、cellForRowAtでproductsが空の状態となる。
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
            return "無料版ではほぼすべての画面上に広告が表示されます。まずは無料版でお使いいただいた上で、有料版をご検討ください。\n\n●有料版：スタンダードプラン\n年間払い 1,200円 / 年\nスタンダードプランは、アプリ内の全ての広告が表示されなくなり、ユーザービリティを高めることができます。\n\n●機種変更時の復元\n機種変更時には、以前購入した有料版を無料で復元できます。購入時と同じAppleIDでiPhone・iPad端末のiTunesにログインしてください。\n\n●確認と解約\nAppStoreアプリの最下部にある「おすすめ」を選択　> Apple IDを選択　>「Apple IDを表示」を選択　> 購読の中にある「管理」からこのアプリを選択。この画面から次回の自動更新タイミングの確認や、自動更新の解除/設定ができます。\n\n●自動継続課金について\n期間終了日の24時間以上前に自動更新の解除をされない場合、契約期間が自動更新されます。自動更新の課金は、契約期間の終了後24時間以内に行われます。\n\n●注意点\n・アプリ内で課金された方は上記以外の方法での解約できません\n・当月分のキャンセルについては受け付けておりません。\n・iTunesアカウントを経由して課金されます。\n\n●利用規約\nhttps://www.facebook.com/The-Reckoning-103608024863220\n\n"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? TableViewCellSettingUpgrade else {
            return UITableViewCell()
        }
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
            let product = self.products[indexPath.row]
            cell.textLabel?.text = product.localizedTitle
            cell.label.text = "\(products[indexPath.row].localizedPrice!) / \(products[indexPath.row].localizedSubscriptionPeriod)　" // 円マークも付く
            cell.label.textColor = .darkGray
            cell.label.textAlignment = .right
            if inAppPurchaseFlag {
                // チェックマークを入れる
                cell.accessoryType = .checkmark
            }else {
                // チェックマークを外す
                cell.accessoryType = .none
            }
            return cell
        default:
            return cell
        }
    }
    // セルが選択された時に呼び出される　// すべての影響範囲に修正が必要
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // アップグレード機能　まずinAppPurchaseを判断する　receiptチェックする
        let upgradeManager = UpgradeManager()
        upgradeManager.verifyPurchase(PRODUCT_ID: "com.ikingdom.Accountant.autoRenewableSubscriptions.advertisingOff") // 定数定義する
        if UserDefaults.standard.object(forKey: "buy") != nil {
            let count = UserDefaults.standard.object(forKey: "buy") as! Int
            if count == 1 {
                inAppPurchaseFlag = true
            }
        } else {
            inAppPurchaseFlag = false
        }
        guard inAppPurchaseFlag  else {
            upgradeManager.purchase(PRODUCT_ID: "com.ikingdom.Accountant.autoRenewableSubscriptions.advertisingOff")
            return
        }
        print("InAppPurchaseがあります。inAppPurchaseFlagは\(inAppPurchaseFlag)です。")
    }

    // 価格の取得
    private func purchaseGetInfo(PRODUCT_ID: Set<String>) { // Set<>は、重複を許さない配列のようなもの
        SwiftyStoreKit.retrieveProductsInfo(PRODUCT_ID) { [weak self] result in // [weak self] を追加
            print(result)
            if let error = result.error {
                //購入済みの場合
                print("Error: \(result.error)")
//                self.showErrorAlert("情報取得に失敗　\(error.localizedDescription)")
                return // リターン
            }
            print("valid",result.retrievedProducts)
            print("invalid",result.invalidProductIDs)
            let products = Array(result.retrievedProducts) //
//            products.sort(by: { (lh, rh) -> Bool in
//                return lh.localizedPrice! < rh.localizedPrice!
//            })

            DispatchQueue.main.async {
                self?.products = products
                self?.tableView.reloadData()
            }
            if let product = result.retrievedProducts.first { // プロダクトは一種類なので、firstでよい
                //未購入の場合
                let priceString = product.localizedPrice! // 地域別の価格
                print("localizedTitle       : \(product.localizedTitle)")
                print("price                : \(priceString)")
                print("priceLocale          : \(product.priceLocale)")
                print("Product              : \(product.localizedDescription)")
                print("subscriptionPeriod   : \(product.subscriptionPeriod!.unit)")
                print("productIdentifier    : \(product.productIdentifier)")
                    
                return // リターンしてよい
            }
//            else if let invalidProductId = result.invalidProductIDs.first { // 不要？
//                print("Invalid product identifier: \(invalidProductId)")
//            }
        }
    }
}
