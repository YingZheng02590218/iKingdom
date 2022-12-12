//
//  SettingsCategoryTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/08/07.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 勘定科目クラス
class SettingsCategoryTableViewController: UITableViewController {


    @IBOutlet var gADBannerView: GADBannerView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 年度を追加後に会計期間画面を更新する
        tableView.reloadData()
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
    //        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
            // GADBannerView を作成する
            gADBannerView = GADBannerView(adSize:kGADAdSizeMediumRectangle)
            // GADBannerView プロパティを設定する
            gADBannerView.adUnitID = Constant.ADMOB_ID
            
            gADBannerView.rootViewController = self
            // 広告を読み込む
            gADBannerView.load(GADRequest())
            print(tableView.visibleCells[tableView.visibleCells.count-1].frame.height)
            // GADBannerView を作成する
            addBannerViewToView(gADBannerView, constant: self.tableView.visibleCells[self.tableView.visibleCells.count-1].frame.height * -1)
        }
        else {
            if let gADBannerView = gADBannerView {
                gADBannerView.isHidden = true
            }
        }

    }
    
    // ビューが表示された後に呼ばれる
    override func viewDidAppear(_ animated: Bool){
        // チュートリアル対応 コーチマーク型　初回起動時　7行を追加
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch_SettingsCategory"
        if ud.bool(forKey: firstLunchKey) {
            ud.set(false, forKey: firstLunchKey)
            ud.synchronize()
            // チュートリアル対応 コーチマーク型
            presentAnnotation()
        }
        else {
            // チュートリアル対応 コーチマーク型
            finishAnnotation()
        }
    }
    // チュートリアル対応 コーチマーク型
    func presentAnnotation() {
        //タブの無効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
            }
        }
        let viewController = UIStoryboard(name: "SettingsCategoryTableViewController", bundle: nil).instantiateViewController(withIdentifier: "Annotation_SettingsCategory") as! AnnotationViewControllerSettingsCategory
        viewController.alpha = 0.7
        present(viewController, animated: true, completion: nil)
    }
    
    func finishAnnotation() {
        //タブの有効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = true
                }
            }
        }
        // チュートリアル対応 赤ポチ型
        // 赤ポチを終了
        self.tabBarController?.viewControllers?[4].tabBarItem.badgeValue = nil
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
    }
    // セクションヘッダーのテキスト決める
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "勘定科目"
        case 1:
            return "表示科目"
//        case 2:
//            return "情報"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "使用する勘定科目を設定することができます。"
        case 1:
            return "決算書上に表示される表示科目を参照することができます。"
//        case 2:
//            return "帳簿情報を設定することができます。"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = UITableViewCell()

        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                //① UI部品を指定
                cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
                cell.textLabel?.text = "勘定科目一覧"
                cell.textLabel?.textColor = .textColor
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "categoriesBSandPL", for: indexPath)
                cell.textLabel?.text = "表示科目別勘定科目一覧"
                cell.textLabel?.textColor = .textColor
//        case 3:
//            cell = tableView.dequeueReusableCell(withIdentifier: "groups", for: indexPath)
//            cell.textLabel?.text =  "種類別勘定科目一覧"
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
                cell.textLabel?.text =   ""
                cell.textLabel?.textColor = .textColor
            }
        }else {
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "BSandPL", for: indexPath)
                cell.textLabel?.text = "表示科目一覧"
                cell.textLabel?.textColor = .textColor
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
                cell.textLabel?.textColor = .textColor
                cell.textLabel?.text =   ""
            }
        }
        // Accessory Color
        let disclosureImage = UIImage(named: "navigate_next")!.withRenderingMode(.alwaysTemplate)
        let disclosureView = UIImageView(image: disclosureImage)
        disclosureView.tintColor = UIColor.accentColor
        cell.accessoryView = disclosureView

        return cell
    }
}
