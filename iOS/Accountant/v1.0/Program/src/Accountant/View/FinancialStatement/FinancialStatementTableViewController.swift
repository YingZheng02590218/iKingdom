//
//  FinancialStatementTableViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import GoogleMobileAds // マネタイズ対応
import UIKit

// 決算書クラス
class FinancialStatementTableViewController: UITableViewController {
    
    // フィードバック
    let feedbackGeneratorLight: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: CarouselTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: CarouselTableViewCell.self))
        tableView.separatorColor = .accentColor
        
        self.navigationItem.title = "決算書"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 要素数が少ないUITableViewで残りの部分や余白を消す
        let tableFooterView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = tableFooterView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            // 決算報告手続き
            // case 0: return    "財務諸表"
            // case 1: return    "月次推移表"
            // 決算本手続き 帳簿の締切
        case 2: return    "決算振替仕訳"
        case 3: return    "決算整理仕訳"
            // 決算予備手続き
        case 4: return    "試算表"
            // TODO: 開始手続き
            // case 4: return    "再振替仕訳"
            // case 5: return    "開始仕訳"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // 財務諸表
            return 1
        case 1:
            // 月次推移表
            return 1
        case 2:
            // 損益勘定
            return 1
        case 3:
            // 精算書
            return 1
        case 4:
            // 試算表　繰越試算表
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            // 財務諸表
            return 270
        case 1:
            // 月次推移表
            return 240
        default:
            return 43
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CarouselTableViewCell.self), for: indexPath) as? CarouselTableViewCell else {
                    return UITableViewCell()
                }
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.createImages()
                cell.backgroundColor = .clear
                cell.configure(gropName: "財務諸表")
                cell.betaLabel.isHidden = true
                cell.collectionView.tag = 0
                return cell
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
                cell.textLabel?.text = ""
                cell.textLabel?.textColor = .textColor
                cell.textLabel?.textAlignment = NSTextAlignment.center
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CarouselTableViewCell.self), for: indexPath) as? CarouselTableViewCell else {
                    return UITableViewCell()
                }
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.createImages()
                cell.backgroundColor = .mainColor2
                cell.configure(gropName: "月次推移表")
                cell.betaLabel.isHidden = false
                cell.collectionView.tag = 1
                return cell
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
                cell.textLabel?.text = ""
                cell.textLabel?.textColor = .textColor
                cell.textLabel?.textAlignment = NSTextAlignment.center
            }
        } else if indexPath.section == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "PLAccount", for: indexPath)
            cell.textLabel?.text = "損益"
            cell.textLabel?.textColor = .textColor
            cell.textLabel?.textAlignment = NSTextAlignment.center
        } else if indexPath.section == 3 {
            cell = tableView.dequeueReusableCell(withIdentifier: "WS", for: indexPath)
            cell.textLabel?.text = "精算表"
            cell.textLabel?.textColor = .textColor
            cell.textLabel?.textAlignment = NSTextAlignment.center
        } else {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "TB", for: indexPath)
                cell.textLabel?.text = "試算表"
                cell.textLabel?.textColor = .textColor
                cell.textLabel?.textAlignment = NSTextAlignment.center
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "AfterClosingTrialBalance", for: indexPath)
                cell.textLabel?.text = "繰越試算表"
                cell.textLabel?.textColor = .textColor
                cell.textLabel?.textAlignment = NSTextAlignment.center
            }
        }
        
        // Accessory Color
        let disclosureImage = UIImage(named: "navigate_next")?.withRenderingMode(.alwaysTemplate)
        let disclosureView = UIImageView(image: disclosureImage)
        disclosureView.tintColor = UIColor.accentColor
        cell.accessoryView = disclosureView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            return
        } else if indexPath.section == 1 {
            return
        } else if indexPath.section == 3 {
            if let cell = tableView.cellForRow(at: indexPath) {
                // インジケーター
                cell.accessoryView = {() -> UIActivityIndicatorView in
                    let indicatorView = UIActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
                    indicatorView.startAnimating()
                    return indicatorView
                }()
                DispatchQueue.main.async {
                    if let viewController = UIStoryboard(
                        name: String(describing: WSViewController.self),
                        bundle: nil
                    ).instantiateInitialViewController() as? WSViewController {
                        if let navigator = self.navigationController {
                            // Accessory Color
                            let disclosureImage = UIImage(named: "navigate_next")?.withRenderingMode(.alwaysTemplate)
                            let disclosureView = UIImageView(image: disclosureImage)
                            disclosureView.tintColor = UIColor.accentColor
                            cell.accessoryView = disclosureView
                            
                            navigator.pushViewController(viewController, animated: true)
                        } else {
                            let navigation = UINavigationController(rootViewController: viewController)
                            self.present(navigation, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // 画面のことをScene（シーン）と呼ぶ。 セグエとは、シーンとシーンを接続し画面遷移を行うための部品である。
        //        if IndexPath(row: 2, section: 0) == self.tableView.indexPathForSelectedRow! { //キャッシュ・フロー計算書　未対応
        //            return false //false:画面遷移させない
        //        }
        return true
    }
    // 画面遷移の準備　貸借対照表画面 損益計算書画面 キャッシュフロー計算書
    var tappedIndexPath: IndexPath?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 選択されたセルを取得
        guard let indexPath = self.tableView.indexPathForSelectedRow else { return } // ※ didSelectRowAtの代わりにこれを使う方がいい　タップされたセルの位置を取得
        
        switch segue.identifier {
            // 損益勘定
        case "segue_PLAccount": // “セグウェイにつけた名称”:
            // ③遷移先ViewCntrollerの取得
            if let navigationController = segue.destination as? UINavigationController,
               let _ = navigationController.topViewController as? GeneralLedgerPLAccountViewController {
                // 遷移先のコントローラに値を渡す
                // 遷移先のコントローラー.条件用の属性 = “条件”
            }
        default:
            break
        }
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension FinancialStatementTableViewController: UICollectionViewDelegateFlowLayout {
    // セルのサイズ(CGSize)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 横画面で、collectionViewの高さから計算した高さがマイナスになる場合の対策
        let height = (collectionView.bounds.size.height) - 10
        let width = (collectionView.bounds.size.width / 2) - 10
        return CGSize(width: width + 0.0, height: height < 0 ? 0 : height)
    }
    // 余白の調整（UIImageを拡大、縮小している）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // top:ナビゲーションバーの高さ分上に移動
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
}

extension FinancialStatementTableViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    // collectionViewの要素の数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        2
    }
    // collectionViewのセルを返す（セルの内容を決める）
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        switch collectionView.tag {
        case 0:
            switch indexPath.row {
            case 0:
                cell.label.text = "貸借対照表"
                cell.label.textColor = .accentColor
                if let image = UIImage(named: "Yearly")?.withRenderingMode(.alwaysOriginal) {
                    cell.imageView.image = image
                    // cell.imageView.backgroundColor = .yellow
                    // cell.backgroundColor = .systemPink
                    let constraint = NSLayoutConstraint(
                        item: cell.imageView,
                        attribute: NSLayoutConstraint.Attribute.height,
                        relatedBy: NSLayoutConstraint.Relation.equal,
                        toItem: cell.imageView,
                        attribute: NSLayoutConstraint.Attribute.width,
                        multiplier: image.size.height / image.size.width,
                        constant: 0.0
                    )
                    NSLayoutConstraint.activate([constraint])
                }
            case 1:
                cell.label.text = "損益計算書"
                cell.label.textColor = .accentColor
                if let image = UIImage(named: "Yearly")?.withRenderingMode(.alwaysOriginal) {
                    cell.imageView.image = image
                    // cell.imageView.backgroundColor = .yellow
                    // cell.backgroundColor = .systemPink
                    let constraint = NSLayoutConstraint(
                        item: cell.imageView,
                        attribute: NSLayoutConstraint.Attribute.height,
                        relatedBy: NSLayoutConstraint.Relation.equal,
                        toItem: cell.imageView,
                        attribute: NSLayoutConstraint.Attribute.width,
                        multiplier: image.size.height / image.size.width,
                        constant: 0.0
                    )
                    NSLayoutConstraint.activate([constraint])
                }
                
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.label.text = "月次貸借推移表"
                cell.label.textColor = .black
                if let image = UIImage(named: "Monthly")?.withRenderingMode(.alwaysOriginal) {
                    cell.imageView.image = image
                    // cell.imageView.backgroundColor = .yellow
                    // cell.backgroundColor = .systemPink
                    let constraint = NSLayoutConstraint(
                        item: cell.imageView,
                        attribute: NSLayoutConstraint.Attribute.height,
                        relatedBy: NSLayoutConstraint.Relation.equal,
                        toItem: cell.imageView,
                        attribute: NSLayoutConstraint.Attribute.width,
                        multiplier: image.size.height / image.size.width,
                        constant: 0.0
                    )
                    NSLayoutConstraint.activate([constraint])
                }
                cell.spinner.color = .gray
            case 1:
                cell.label.text = "月次損益推移表"
                cell.label.textColor = .black
                if let image = UIImage(named: "Monthly")?.withRenderingMode(.alwaysOriginal) {
                    cell.imageView.image = image
                    // cell.imageView.backgroundColor = .yellow
                    // cell.backgroundColor = .systemPink
                    let constraint = NSLayoutConstraint(
                        item: cell.imageView,
                        attribute: NSLayoutConstraint.Attribute.height,
                        relatedBy: NSLayoutConstraint.Relation.equal,
                        toItem: cell.imageView,
                        attribute: NSLayoutConstraint.Attribute.width,
                        multiplier: image.size.height / image.size.width,
                        constant: 0.0
                    )
                    NSLayoutConstraint.activate([constraint])
                }
                cell.spinner.color = .gray
            default:
                break
            }
        default:
            break
        }
        return cell
    }
}

extension FinancialStatementTableViewController: UICollectionViewDelegate {
    
    /// セルの選択時に背景色を変化させる
    /// 今度はセルが選択状態になった時に背景色が青に変化するようにしてみます。
    /// 以下の3つのメソッドはデフォルトでtrueなので、このケースでは実装しなくても良いです。
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("Highlighted: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        print("Unhighlighted: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        true  // 変更
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: \(indexPath)")
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorLight as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        switch collectionView.tag {
        case 0:
            switch indexPath.row {
            case 0:
                if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
                    // マイクロインタラクション
                    cell.animateViewSmaller()
                    // インジケーター
                    cell.spinner.startAnimating()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let viewController = UIStoryboard(
                            name: "BalanceSheetViewController",
                            bundle: nil
                        ).instantiateInitialViewController() as? BalanceSheetViewController {
                            if let navigator = self.navigationController {
                                // インジケーター
                                cell.spinner.stopAnimating()
                                
                                navigator.pushViewController(viewController, animated: true)
                            } else {
                                let navigation = UINavigationController(rootViewController: viewController)
                                self.present(navigation, animated: true, completion: nil)
                            }
                        }
                    }
                }
            case 1:
                if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
                    // マイクロインタラクション
                    cell.animateViewSmaller()
                    // インジケーター
                    cell.spinner.startAnimating()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let viewController = UIStoryboard(
                            name: "ProfitAndLossStatementViewController",
                            bundle: nil
                        ).instantiateInitialViewController() as? ProfitAndLossStatementViewController {
                            if let navigator = self.navigationController {
                                // インジケーター
                                cell.spinner.stopAnimating()
                                
                                navigator.pushViewController(viewController, animated: true)
                            } else {
                                let navigation = UINavigationController(rootViewController: viewController)
                                self.present(navigation, animated: true, completion: nil)
                            }
                        }
                    }
                }
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
                    // マイクロインタラクション
                    cell.animateViewSmaller()
                    // インジケーター
                    cell.spinner.startAnimating()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let viewController = UIStoryboard(
                            name: "MonthlyTrendsBalanceSheetViewController",
                            bundle: nil
                        ).instantiateInitialViewController() as? MonthlyTrendsBalanceSheetViewController {
                            if let navigator = self.navigationController {
                                // インジケーター
                                cell.spinner.stopAnimating()
                                
                                navigator.pushViewController(viewController, animated: true)
                            } else {
                                let navigation = UINavigationController(rootViewController: viewController)
                                self.present(navigation, animated: true, completion: nil)
                            }
                        }
                    }
                }
            case 1:
                if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
                    // マイクロインタラクション
                    cell.animateViewSmaller()
                    // インジケーター
                    cell.spinner.startAnimating()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let viewController = UIStoryboard(
                            name: "MonthlyProfitAndLossStatementViewController",
                            bundle: nil
                        ).instantiateInitialViewController() as? MonthlyProfitAndLossStatementViewController {
                            if let navigator = self.navigationController {
                                // インジケーター
                                cell.spinner.stopAnimating()
                                
                                navigator.pushViewController(viewController, animated: true)
                            } else {
                                let navigation = UINavigationController(rootViewController: viewController)
                                self.present(navigation, animated: true, completion: nil)
                            }
                        }
                    }
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Deselected: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        true  // 変更
    }
    
}
