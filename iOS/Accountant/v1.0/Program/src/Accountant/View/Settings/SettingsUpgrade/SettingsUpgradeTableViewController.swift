//
//  SettingsUpgradeTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/01/08.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit
import SwiftyStoreKit // アップグレード機能
import StoreKit // アップグレード機能
import SafariServices // アプリ内でブラウザ表示

// アップグレード画面
class SettingsUpgradeTableViewController: UITableViewController {

    
    private var products: [SKProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 価格を取得
        UpgradeManager.shared.purchaseGetInfo(PRODUCT_ID: [UpgradeManager.PRODUCT_ID_STANDARD_PLAN],
                                              completion: { products in
            self.products = products
            self.tableView.reloadData()
        })
        // XIBを登録　xibカスタムセル設定によりsegueが無効になっているためsegueを発生させる
        tableView.register(UINib(nibName: "WithIconTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {

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
            let language = Locale.preferredLanguages.first!
            print(language) // ja-JP
            var localizedPrice = language == "ja-JP" ? "----円" : "¥----"
            var localizedSubscriptionPeriod = language == "ja-JP" ? "-年間" : "-yr"
            if self.products.count > 0 {
                localizedPrice = products[section].localizedPrice!
                localizedSubscriptionPeriod = products[section].localizedSubscriptionPeriod
            }
            if language == "ja-JP" {
                return "● 有料版：スタンダードプラン\n年間払い \(localizedPrice) / \(localizedSubscriptionPeriod)\nスタンダードプランは、アプリ内の全ての広告が表示されなくなり、ユーザービリティを高めることができます。\n\n● 自動継続課金について\n期間終了日の24時間以上前に自動更新の解除をされない場合、契約期間が自動更新されます。自動更新の課金は、契約期間の終了後24時間以内に行われます。\n\n● 注意点\n・アプリ内で課金された方は上記以外の方法での解約できません\n・当月分のキャンセルについては受け付けておりません。\n・iTunesアカウントを経由して課金されます。"
            }
            else {
                return "● Paid version: Standard plan\nAnnual payment \(localizedPrice) / \(localizedSubscriptionPeriod) With the standard plan, all advertisements in the app will not be displayed, and usability can be improved.\n\n● About automatic renewal billing \nIf you do not cancel the automatic renewal more than 24 hours before the end date of the period, the contract period will be automatically renewed. You will be charged for automatic renewal within 24 hours of the end of the contract period.\n\n● Notes\n・ Those who have been charged within the app cannot cancel the contract by any method other than the above.\n・ We do not accept cancellations for the current month.\n・ You will be charged via your iTunes account."
            }
        case 1:
            let language = Locale.preferredLanguages.first!
            print(language) // ja-JP
            if language == "ja-JP" {
                return "● 機種変更時の復元\n機種変更時には、以前購入した有料版を復元することができます。購入時と同じAppleIDでiPhone・iPad端末のiTunesにログインしてください。"
            }
            else {
                return "● Restoration when changing models\nWhen changing models, you can restore the previously purchased paid version for free. Please log in to iTunes on your iPhone / iPad device with the same Apple ID as when you purchased it."
            }
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WithIconTableViewCell

        // Accessory Color
        let disclosureImage = UIImage(named: "navigate_next")!.withRenderingMode(.alwaysTemplate)
        let disclosureView = UIImageView(image: disclosureImage)
        disclosureView.tintColor = UIColor.AccentColor
        cell.accessoryView = disclosureView

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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? SettingUpgradeTableViewCell else {
                return UITableViewCell()
            }
            let product = self.products[indexPath.row]
            cell.textLabel?.text = product.localizedTitle
            cell.label.text = "\(product.localizedPrice!) / \(product.localizedSubscriptionPeriod)　" // 円マークも付く
            cell.label.textColor = .darkGray
            cell.label.textAlignment = .right
            if UpgradeManager.shared.inAppPurchaseFlag {
                // チェックマークを入れる
                cell.accessoryView = UIImageView(image: UIImage(systemName: "checkmark.seal.fill")?.withRenderingMode(.alwaysTemplate))
                cell.accessoryView?.tintColor = .green
            }
            else {
                // チェックマークを外す
                cell.accessoryView = UIImageView(image: UIImage(systemName: "checkmark.seal")?.withRenderingMode(.alwaysTemplate))
                cell.accessoryView?.tintColor = .gray
            }
            return cell
        case 1:
            let language = Locale.preferredLanguages.first!
            print(language) // ja-JP
            if language == "ja-JP" {
                cell.centerLabel.text = "購入の復元をする"
            }
            else {
                cell.centerLabel.text = "Restore Purchases"
            }
            if UpgradeManager.shared.inAppPurchaseFlag {
                cell.accessoryType = .none
            }
            else {
                cell.accessoryType = .none
            }
            cell.accessoryView = nil
            cell.leftImageView.image = UIImage(named: "settings_backup_restore_symbol")?.withRenderingMode(.alwaysTemplate)
        case 2:
            let language = Locale.preferredLanguages.first!
            print(language) // ja-JP
            if language == "ja-JP" {
                cell.centerLabel.text = "解約方法"
            }else {
                cell.centerLabel.text = "How to cancel"
            }
            cell.leftImageView.image = UIImage(named: "cancel-cancel_symbol")?.withRenderingMode(.alwaysTemplate)
        case 3:
            let language = Locale.preferredLanguages.first!
            print(language) // ja-JP
            if language == "ja-JP" {
                cell.centerLabel.text = "プライバシーポリシー / 利用規約"
            }else {
                cell.centerLabel.text = "Privacy Policy / Terms of Use"
            }
            cell.leftImageView.image = UIImage(named: "gavel-gavel_grad200_symbol")?.withRenderingMode(.alwaysTemplate)
        default:
            break
        }

        return cell
    }
    // セルが選択された時に呼び出される　// すべての影響範囲に修正が必要
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0: // 購入
            UpgradeManager.shared.purchase(PRODUCT_ID: UpgradeManager.PRODUCT_ID_STANDARD_PLAN, completion: { isSuccess in
                // 購入済みを表すアイコンの色を緑色へ切り替えるためにリロードする
                self.tableView.reloadData()
            })
            break
        case 1: // リストア
            UpgradeManager.shared.verifyPurchase(PRODUCT_ID: UpgradeManager.PRODUCT_ID_STANDARD_PLAN, completion: { isSuccess in
                let alert = UIAlertController(title: "復元", message: "\(isSuccess ? "成功しました" : "失敗しました")", preferredStyle: .alert)
                self.present(alert, animated: true) { () -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                self.tableView.reloadData()
            })
            break
        case 2: // 解約
            // アプリ内でブラウザを開く
            if Locale.current.regionCode == "JP" {
                let url = URL(string:"https://support.apple.com/ja-jp/HT202039#:~:text=%E3%80%8C%E3%83%A6%E3%83%BC%E3%82%B6%E3%81%8A%E3%82%88%E3%81%B3%E3%82%A2%E3%82%AB%E3%82%A6%E3%83%B3%E3%83%88%E3%80%8D%E3%82%92%E9%81%B8%E6%8A%9E,%E3%81%95%E3%82%8C%E3%82%8B%E3%81%93%E3%81%A8%E3%82%82%E3%81%82%E3%82%8A%E3%81%BE%E3%81%9B%E3%82%93)%E3%80%82")
                if let url = url{
                    let vc = SFSafariViewController(url: url)
                    present(vc, animated: true, completion: nil)
                }
            }
            else {
                // アプリ内でブラウザを開く
                let url = URL(string:"https://support.apple.com/en-us/HT202039")
                if let url = url{
                    let vc = SFSafariViewController(url: url)
                    present(vc, animated: true, completion: nil)
                }
            }
            break
        case 3: // プライバシーポリシー　利用規約
            /// TODO: -  アプリ名変更
            // アプリ内でブラウザを開く
            let url = URL(string:"https://www.facebook.com/The-Reckoning-103608024863220")
            if let url = url{
                let vc = SFSafariViewController(url: url)
                present(vc, animated: true, completion: nil)
            }
            break
        default:
            break
        }
    }

}
