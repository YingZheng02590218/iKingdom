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
//        // アップグレード機能　まずinAppPurchaseを判断する　receiptチェックする
//        let upgradeManager = UpgradeManager()
//        upgradeManager.verifyPurchase(PRODUCT_ID:"com.ikingdom.Accountant.autoRenewableSubscriptions.advertisingOff") // 定数定義する
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return products.count // 注意：ベタ書きで1と書くと、cellForRowAtでproductsが空の状態となる。
        case 1: // リストア
            return 1
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
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
        case 1:
            return "Restore"
        case 2:
            return ""
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
            var localizedPrice = "1200円"
            var localizedSubscriptionPeriod = "1年間"
            if self.products.count > 0 {
                localizedPrice = products[0].localizedPrice!
                localizedSubscriptionPeriod = products[0].localizedSubscriptionPeriod
            }
            print(Locale.preferredLanguages) // ["ja-JP", "en-JP"]
            let language = Locale.preferredLanguages.first!
            print(language) // ja-JP
            if language == "ja-JP" {
                return "無料版ではほぼすべての画面上に広告が表示されます。まずは無料版でお使いいただいた上で、有料版をご検討ください。\n\n●有料版：スタンダードプラン\n年間払い \(localizedPrice) / \(localizedSubscriptionPeriod)\nスタンダードプランは、アプリ内の全ての広告が表示されなくなり、ユーザービリティを高めることができます。\n\n●自動継続課金について\n期間終了日の24時間以上前に自動更新の解除をされない場合、契約期間が自動更新されます。自動更新の課金は、契約期間の終了後24時間以内に行われます。\n\n●注意点\n・アプリ内で課金された方は上記以外の方法での解約できません\n・当月分のキャンセルについては受け付けておりません。\n・iTunesアカウントを経由して課金されます。"
            }else {
                return "The free version will display ads on almost every screen. First of all, please use the free version and then consider the paid version.\n\n● Paid version: Standard plan\nAnnual payment \(localizedPrice) / \(localizedSubscriptionPeriod) With the standard plan, all advertisements in the app will not be displayed, and usability can be improved.\n\n● About automatic renewal billing \nIf you do not cancel the automatic renewal more than 24 hours before the end date of the period, the contract period will be automatically renewed. You will be charged for automatic renewal within 24 hours of the end of the contract period.\n\n● Notes\n・ Those who have been charged within the app cannot cancel the contract by any method other than the above.\n・ We do not accept cancellations for the current month.\n・ You will be charged via your iTunes account."
            }
        case 1:
            print(Locale.preferredLanguages) // ["ja-JP", "en-JP"]
            let language = Locale.preferredLanguages.first!
            print(language) // ja-JP
            if language == "ja-JP" {
                return "●機種変更時の復元\n機種変更時には、以前購入した有料版を無料で復元できます。購入時と同じAppleIDでiPhone・iPad端末のiTunesにログインしてください。"
            }else {
                return "● Restoration when changing models\nWhen changing models, you can restore the previously purchased paid version for free. Please log in to iTunes on your iPhone / iPad device with the same Apple ID as when you purchased it."
            }
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
        case 1:
            print(Locale.preferredLanguages) // ["ja-JP", "en-JP"]
            let language = Locale.preferredLanguages.first!
            print(language) // ja-JP
            if language == "ja-JP" {
                cell.textLabel?.text = "購入の復元"
            }else {
                cell.textLabel?.text = "Restore Purchases"
            }
            cell.label.text = ""
            if inAppPurchaseFlag {
                cell.accessoryType = .checkmark
            }else {
                cell.accessoryType = .disclosureIndicator
            }
            return cell
        case 2:
            print(Locale.preferredLanguages) // ["ja-JP", "en-JP"]
            let language = Locale.preferredLanguages.first!
            print(language) // ja-JP
            if language == "ja-JP" {
                cell.textLabel?.text = "解約方法"
            }else {
                cell.textLabel?.text = "How to cancel"
            }
            cell.accessoryType = .disclosureIndicator
            cell.label.text = ""
            return cell
        case 3:
            print(Locale.preferredLanguages) // ["ja-JP", "en-JP"]
            let language = Locale.preferredLanguages.first!
            print(language) // ja-JP
            if language == "ja-JP" {
                cell.textLabel?.text = "プライバシーポリシー / 利用規約"
            }else {
                cell.textLabel?.text = "Privacy Policy / Terms of Use"
            }
            cell.accessoryType = .disclosureIndicator
            cell.label.text = ""
            return cell
        default:
            return cell
        }
    }
    // セルが選択された時に呼び出される　// すべての影響範囲に修正が必要
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // アップグレード機能　まずinAppPurchaseを判断する　receiptチェックする
        let upgradeManager = UpgradeManager()
        if UserDefaults.standard.object(forKey: "buy") != nil {
            let count = UserDefaults.standard.object(forKey: "buy") as! Int
            if count == 1 {
                inAppPurchaseFlag = true
            }
        } else {
            inAppPurchaseFlag = false
        }
        switch indexPath.section {
        case 0: // 購入
            guard inAppPurchaseFlag  else {
                upgradeManager.purchase(PRODUCT_ID: "com.ikingdom.Accountant.autoRenewableSubscriptions.advertisingOff")
                return
            }
            break
        case 1: // リストア
            upgradeManager.verifyPurchase(PRODUCT_ID: "com.ikingdom.Accountant.autoRenewableSubscriptions.advertisingOff") // 定数定義する
            print("InAppPurchaseがあります。inAppPurchaseFlagは\(inAppPurchaseFlag)です。")
            self.tableView.reloadData()
            break
        case 2: // 解約
            if Locale.current.regionCode == "JP" {
                if let url = URL(string: "https://support.apple.com/ja-jp/HT202039#:~:text=%E3%80%8C%E3%83%A6%E3%83%BC%E3%82%B6%E3%81%8A%E3%82%88%E3%81%B3%E3%82%A2%E3%82%AB%E3%82%A6%E3%83%B3%E3%83%88%E3%80%8D%E3%82%92%E9%81%B8%E6%8A%9E,%E3%81%95%E3%82%8C%E3%82%8B%E3%81%93%E3%81%A8%E3%82%82%E3%81%82%E3%82%8A%E3%81%BE%E3%81%9B%E3%82%93)%E3%80%82") {
                    UIApplication.shared.open(url)
                }
            }else {
                if let url = URL(string: "https://support.apple.com/en-us/HT202039") {
                    UIApplication.shared.open(url)
                }
            }
            break
        case 3: // プライバシーポリシー　利用規約
            if let url = URL(string: "https://www.facebook.com/The-Reckoning-103608024863220") {
                UIApplication.shared.open(url)
            }
            break
        default:
            break
        }
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
