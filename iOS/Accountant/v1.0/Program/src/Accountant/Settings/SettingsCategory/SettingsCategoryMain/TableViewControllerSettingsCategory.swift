//
//  TableViewControllerSettingsCategory.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/08/07.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import GoogleMobileAds // マネタイズ対応

// 勘定科目　画面
class TableViewControllerSettingsCategory: UITableViewController {

    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/8565070944"
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"
    // true:テスト
    let AdMobTest:Bool = false
    @IBOutlet var gADBannerView: GADBannerView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        // 設定表示科目　初期化　表示科目のスイッチを設定する　勘定科目のスイッチONが、ひとつもなければOFFにする
//        let dataBaseManagerSettingsTaxonomy = DataBaseManagerSettingsTaxonomy()
//        dataBaseManagerSettingsTaxonomy.initializeSettingsTaxonomy()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 年度を追加後に会計期間画面を更新する
        tableView.reloadData()
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView

        // マネタイズ対応　完了　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        // GADBannerView を作成する
        gADBannerView = GADBannerView(adSize:kGADAdSizeLargeBanner)
        // iPhone X のポートレート決め打ちです　→ 仕訳帳のタブバーの上にバナー広告が表示されるように調整した。
//        print(self.view.frame.size.height)
//        print(gADBannerView.frame.height)
//        gADBannerView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - gADBannerView.frame.height + tableView.contentOffset.y) // スクロール時の、広告の位置を固定する
//        gADBannerView.frame.size = CGSize(width: self.view.frame.width, height: gADBannerView.frame.height)
        // GADBannerView プロパティを設定する
        if AdMobTest {
            gADBannerView.adUnitID = TEST_ID
        }
        else{
            gADBannerView.adUnitID = AdMobID
        }
        gADBannerView.rootViewController = self
        // 広告を読み込む
        gADBannerView.load(GADRequest())
        print(tableView.visibleCells[tableView.visibleCells.count-1].frame.height)
        // GADBannerView を作成する
//        addBannerViewToView(gADBannerView, constant: 0)
        addBannerViewToView(gADBannerView, constant: self.tableView.visibleCells[self.tableView.visibleCells.count-1].frame.height * -1)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView, constant: CGFloat) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(bannerView)
      view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bottomLayoutGuide,
                            attribute: .top,
                            multiplier: 1,
                            constant: constant),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
        ])
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
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                //① UI部品を指定
                let cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
                cell.textLabel?.text = "勘定科目一覧"
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesBSandPL", for: indexPath)
                cell.textLabel?.text = "表示科目別勘定科目一覧"
                return cell
//        case 3:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "groups", for: indexPath)
//            cell.textLabel?.text =  "種類別勘定科目一覧"
//            return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
                cell.textLabel?.text =   ""
                return cell
            }
        }else {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BSandPL", for: indexPath)
                cell.textLabel?.text = "表示科目一覧"
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath)
                cell.textLabel?.text =   ""
                return cell
            }
        }
    }
}
