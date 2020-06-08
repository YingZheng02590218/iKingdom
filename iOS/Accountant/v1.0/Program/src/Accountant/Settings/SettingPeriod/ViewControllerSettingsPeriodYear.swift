//
//  ViewControllerSettingsPeriodYear.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/06/05.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class ViewControllerSettingsPeriodYear: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UIPickerView
        // Delegate設定
        pickerView.delegate = self
        pickerView.dataSource = self
        // ドラムロールの初期位置 データベースに保存された年度の翌年
        pickerView.selectRow(1, inComponent: 0, animated: false)
    }

//UIPickerView
    //UIPickerViewの列の数 コンポーネントの数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // ドラムロールは二列
    }
    //UIPickerViewの行数、リストの数 コンポーネントの内のデータ
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            let dataBaseManagerPeriod = DataBaseManagerPeriod()
            return dataBaseManagerPeriod.getMainBooksAllCount() + 1 //翌年の分
        default:
            return 1
        }
    }
    //UIPickerViewの最初の表示 ホイールに表示する選択肢のタイトル
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
        let dataBaseManagerPeriod = DataBaseManagerPeriod()
        
        let objects = dataBaseManagerPeriod.getMainBooksAll()
        if dataBaseManagerPeriod.getMainBooksAllCount() <= row {
            var lastRow = row
            lastRow -= 1
            var lastfisvalYear = objects[lastRow].fiscalYear
            lastfisvalYear += 1
            return lastfisvalYear.description // 翌年の分
        }else {
            return objects[row].fiscalYear.description
        }
    }
    
    @IBAction func save(_ sender: Any) {
        // 選択した年度の会計帳簿を作成する
        let row = pickerView.selectedRow(inComponent: 0)
        let fiscalYear = getPeriodFromDB(row: row)
        createNewPeriod(fiscalYear: Int(fiscalYear)!)
//        self.dismiss(animated: true, completion: nil)
        // viewWillAppearを呼び出す　更新のため
        self.dismiss(animated: true, completion: {
            [presentingViewController] () -> Void in
            // ViewController(年度選択画面)を閉じた時に、遷移元であるViewController(会計期間画面)で行いたい処理
            presentingViewController?.viewWillAppear(true)// TableViewをリロードする処理がある
        })
    }
    
    func createNewPeriod(fiscalYear: Int){
        // オブジェクト作成
        let dataBaseManager = DataBaseManagerAccountingBooks()
        // データベースに会計帳簿があるかをチェック
        if !dataBaseManager.checkInitialising(fiscalYear: fiscalYear) { // データベースに同じ年度のモデルオブフェクトが存在しない場合
            let number = dataBaseManager.addAccountingBooks(fiscalYear: fiscalYear)
        // 仕訳帳画面　　初期化
            // データベース
            let dataBaseManagerJournalEntryBook = DataBaseManagerJournalEntryBook() //データベースマネジャー
            // データベースに仕訳帳画面の仕訳帳があるかをチェック
            if !dataBaseManagerJournalEntryBook.checkInitialising(fiscalYear: fiscalYear) { // データベースにモデルオブフェクトが存在しない場合
                dataBaseManagerJournalEntryBook.addJournalEntryBook(number: number)
            }
        // 総勘定元帳画面　初期化
            // データベース
            let dataBaseManagerGeneralLedger = DataBaseManagerGeneralLedger() //データベースマネジャー
            // データベースに勘定画面の勘定があるかをチェック
            if !dataBaseManagerGeneralLedger.checkInitialising(fiscalYear: fiscalYear) { // データベースにモデルオブフェクトが存在しない場合
                dataBaseManagerGeneralLedger.addGeneralLedger(number: number)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
