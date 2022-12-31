//
//  SettingsPeriodYearViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/05.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 年度選択クラス
class SettingsPeriodYearViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet private var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = .accentColor

        // UIPickerView
        // Delegate設定
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    // ビューが表示された後に呼ばれる
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ドラムロールの初期位置 データベースに保存された年度の翌年
        pickerView.selectRow(DataBaseManagerSettingsPeriod.shared.getMainBooksAllCount() + 1, inComponent: 0, animated: true) // 翌年の分
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // UIPickerView
    // UIPickerViewの列の数 コンポーネントの数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2 // ドラムロールは二列
    }
    // UIPickerViewの行数、リストの数 コンポーネントの内のデータ
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return DataBaseManagerSettingsPeriod.shared.getMainBooksAllCount() + 2 // 前年、翌年の分
        default:
            return 1
        }
    }
    // UIPickerViewの最初の表示 ホイールに表示する選択肢のタイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return getPeriodFromDB(row: row)
        default:
            return "年度"
        }
    }
    // 年度の選択肢
    func getPeriodFromDB(row: Int) -> String {
        let objects = DataBaseManagerSettingsPeriod.shared.getMainBooksAll()
        if row == 0 {
            var firstfisvalYear = objects[row].fiscalYear
            firstfisvalYear -= 1
            return firstfisvalYear.description // 前年の分
        } else if row >= 1 && DataBaseManagerSettingsPeriod.shared.getMainBooksAllCount() + 1 > row {
            var lastRow = row
            lastRow -= 1
            return objects[lastRow].fiscalYear.description
        } else {
            var lastRow = row
            lastRow -= 2
            var lastfisvalYear = objects[lastRow].fiscalYear
            lastfisvalYear += 1
            return lastfisvalYear.description // 翌年の分
        }
    }
    
    @IBAction func save(_ sender: Any) {
        // オフラインの場合広告が表示できないので、ネットワーク接続を確認する
        if Network.shared.isOnline() ||
            // アップグレード機能　スタンダードプラン サブスクリプション購読済み
            UpgradeManager.shared.inAppPurchaseFlag {
            
            // 選択した年度の会計帳簿を作成する
            let row = pickerView.selectedRow(inComponent: 0)
            let fiscalYear = getPeriodFromDB(row: row)
            createNewPeriod(fiscalYear: Int(fiscalYear)!)

            if let tabBarController = self.presentingViewController as? UITabBarController, // 基底となっているコントローラ
               let splitViewController = tabBarController.selectedViewController as? UISplitViewController, // 基底のコントローラから、選択されているを取得する
               let navigationController = splitViewController.viewControllers[0] as? UINavigationController { // スプリットコントローラから、現在選択されているコントローラを取得する
                let navigationController2: UINavigationController
                // iPadとiPhoneで動きが変わるので分岐する
                if UIDevice.current.userInterfaceIdiom == .pad { // iPad
                    //        if UIDevice.current.orientation == .portrait { // ポートレート 上下逆さまだとポートレートとはならない
                    print(splitViewController.viewControllers.count)
                    if let navigationController0 = splitViewController.viewControllers[0] as? UINavigationController, // ナビゲーションバーコントローラの配下にあるビューコントローラーを取得
                       let navigationController1 = navigationController0.viewControllers[1] as? UINavigationController {
                        navigationController2 = navigationController1
                        print(navigationController0.viewControllers.count)
                        print(navigationController0.viewControllers[1])
                        print(navigationController2.viewControllers.count)
                        print(navigationController2.viewControllers[0])
                        print("iPad ビューコントローラーの階層")
                        //            print("splitViewController[0]      : ", splitViewController.viewControllers[0])     // UINavigationController
                        //            print("splitViewController[1]      : ", splitViewController.viewControllers[1] )    // UINavigationController
                        //            print("  navigationController[0]   : ", navigationController.viewControllers[0])    // SettingsTableViewController
                        //            print("    navigationController2[0]: ", navigationController2.viewControllers[0])   // SettingsPeriodTableViewController
                        if let presentingViewController = navigationController2.viewControllers[0] as? SettingsPeriodTableViewController { // 呼び出し元のビューコントローラーを取得
                            // viewWillAppearを呼び出す　更新のため
                            self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                                // ViewController(年度選択画面)を閉じた時に、遷移元であるViewController(会計期間画面)で行いたい処理
                                presentingViewController.showAd()// TableViewをリロードする処理がある
                            })
                        }
                    }
                } else { // iPhone
                    print(splitViewController.viewControllers.count)
                    if let navigationController1 = navigationController.viewControllers[1] as? UINavigationController {
                        navigationController2 = navigationController1
                        //             navigationController2 = navigationController.viewControllers[0] as! UINavigationController // ナビゲーションバーコントローラの配下にあるビューコントローラーを取得
                        print("iPhone ビューコントローラーの階層")
                        print("splitViewController[0]      : ", splitViewController.viewControllers[0])     // UINavigationController
                        print("  navigationController[0]   : ", navigationController.viewControllers[0])    // SettingsTableViewController
                        print("  navigationController[1]   : ", navigationController.viewControllers[1])    // UINavigationController
                        print("    navigationController2[0]: ", navigationController2.viewControllers[0])   // SettingsPeriodTableViewController
                        if let presentingViewController = navigationController2.viewControllers[0] as? SettingsPeriodTableViewController { // 呼び出し元のビューコントローラーを取得
                            // viewWillAppearを呼び出す　更新のため
                            self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                                // ViewController(年度選択画面)を閉じた時に、遷移元であるViewController(会計期間画面)で行いたい処理
                                presentingViewController.showAd()// TableViewをリロードする処理がある
                            })
                        }
                    }
                }
            }
        } else {
            // ネットワークなし
            let alertController = UIAlertController(title: "インターネット未接続", message: "オフラインでは利用できません。\n\nスタンダードプランに\nアップグレードしていただくと、\nオフラインでも利用可能となります。", preferredStyle: .alert)
            
            // 選択肢の作成と追加
            // titleに選択肢のテキストを、styleに.defaultを
            // handlerにボタンが押された時の処理をクロージャで実装する
            alertController.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: { (action: UIAlertAction!) -> Void in
                        // オフラインの場合広告が表示できないので、ネットワーク接続を確認する
                        if Network.shared.isOnline() {
                            // アップグレード画面を表示
                            if let viewController = UIStoryboard(
                                name: "SettingsUpgradeTableViewController",
                                bundle: nil
                            ).instantiateViewController(withIdentifier: "SettingsUpgradeTableViewController") as? SettingsUpgradeTableViewController {
                                self.present(viewController, animated: true, completion: nil)
                            }
                        } else {

                        }
                    }
                )
            )
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func createNewPeriod(fiscalYear: Int) {
        // データベースに会計帳簿があるかをチェック
        if !DataBaseManagerAccountingBooks.shared.checkInitialising(dataBase: DataBaseAccountingBooks(), fiscalYear: fiscalYear) { // データベースに同じ年度のモデルオブフェクトが存在しない場合
            let number = DataBaseManagerAccountingBooks.shared.addAccountingBooks(fiscalYear: fiscalYear)
            // 仕訳帳画面　　初期化
            // データベースに仕訳帳画面の仕訳帳があるかをチェック
            if !DataBaseManagerJournals.shared.checkInitialising(dataBase: DataBaseJournals(), fiscalYear: fiscalYear) { // データベースにモデルオブフェクトが存在しない場合
                DataBaseManagerJournals.shared.addJournals(number: number)
            }
            // 総勘定元帳画面　初期化
            let dataBaseManagerGeneralLedger = DataBaseManagerGeneralLedger()
            // データベースに勘定画面の勘定があるかをチェック
            if !dataBaseManagerGeneralLedger.checkInitialising(dataBase: DataBaseGeneralLedger(), fiscalYear: fiscalYear) { // データベースにモデルオブフェクトが存在しない場合
                dataBaseManagerGeneralLedger.addGeneralLedger(number: number)
            }
            // 決算書画面　初期化
            let dataBaseManagerFinancialStatements = DataBaseManagerFinancialStatements()
            // データベースに勘定画面の勘定があるかをチェック
            if !dataBaseManagerFinancialStatements.checkInitialising(dataBase: DataBaseFinancialStatements(), fiscalYear: fiscalYear) { // データベースにモデルオブフェクトが存在しない場合
                dataBaseManagerFinancialStatements.addFinancialStatements(number: number)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
