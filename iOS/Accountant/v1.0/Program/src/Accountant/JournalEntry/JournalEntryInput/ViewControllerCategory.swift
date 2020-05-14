//
//  ViewControllerCategory.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/29.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class ViewControllerCategory: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var PickerView_category: UIPickerView!
    @IBOutlet weak var Button_Done: UIButton!
    @IBOutlet weak var Button_Cancel: UIButton!
    
    var categories :[String] = Array<String>()
    var subCategories_assets :[String] = Array<String>()
    var subCategories_liabilities :[String] = Array<String>()
    var subCategories_netAsset :[String] = Array<String>()
    var subCategories_expends :[String] = Array<String>()
    var subCategories_revenue :[String] = Array<String>()

    var identifier :String = "identifier_debit"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //UIPickerView
        // Delegate設定
        PickerView_category.delegate = self
        PickerView_category.dataSource = self
        //借方、貸方 大項目
        categories = [
            "資産","負債","純資産","費用","収益"]
        //勘定科目  小項目
        subCategories_assets = [
            "現金","定期預金","普通預金","原材料","立替金","備品"]
        subCategories_liabilities = [
            "未払金","長期借入金"]
        subCategories_netAsset = [
            "資本金"]
        subCategories_expends = [
            "仕入","地代家賃","水道光熱費","通信費","車両運搬費",
            "減価償却費","消耗品費","美容費","支払給与","教育費",
            "養育費","医療費","遊興費","交際費","支払保険料",
            "支払保険料","支払利息","特別費","租税公課"]
        subCategories_revenue = [
            "売上","受取利息","有価証券利息","雑益","固定資産売却益"]

    //Segueを場合分け　初期値
        if identifier == "identifier_debit" {       //借方　費用　仕入
            PickerView_category.selectRow(3, inComponent: 0, animated: false)
            PickerView_category.selectRow(0, inComponent: 1, animated: false)
        }else if identifier == "identifier_credit" {//貸方　資産　現金
            PickerView_category.selectRow(0, inComponent: 0, animated: false)
            PickerView_category.selectRow(0, inComponent: 1, animated: false)
        }
        //借方勘定科目を選択した後に、貸方勘定科目を選択する際に初期値が前回のものが表示されるので、リロードする
        self.PickerView_category.reloadAllComponents()
    }
//UIPickerView
    //UIPickerViewの列の数 コンポーネントの数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    //UIPickerViewの行数、リストの数 コンポーネントの内のデータ
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return categories.count
        }else{
            switch PickerView_category.selectedRow(inComponent: 0) {
              case 0://"資産":
                return subCategories_assets.count
              case 1://"負債":
                  return subCategories_liabilities.count
              case 2://"純資産":
                  return subCategories_netAsset.count
              case 3://"費用":
                  return subCategories_expends.count
              case 4://"収益":
                  return subCategories_revenue.count
              default:
                  return subCategories_expends.count
            }
        }
    }
    //UIPickerViewの最初の表示 ホイールに表示する選択肢のタイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         if component == 0 {
             return categories[row] as String
         }else{
            switch PickerView_category.selectedRow(inComponent: 0) {
            case 0://"資産":
                return subCategories_assets[row] as String
            case 1://"負債":
                return subCategories_liabilities[row] as String
            case 2://"純資産":
                return subCategories_netAsset[row] as String
            case 3://"費用":
                return subCategories_expends[row] as String
            case 4://"収益":
                return subCategories_revenue[row] as String
            default:
                return subCategories_expends[row] as String
            }
        }
     }
     // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //todo
        let viewControllerJournalEntry = self.presentingViewController as! ViewControllerJournalEntry
        var result :String
        var count :Int
        // ドラムロールの2列目か？
        if component == 1 {
            switch PickerView_category.selectedRow(inComponent: 0) {
            case 0://"資産":
                result = subCategories_assets[PickerView_category.selectedRow(inComponent: 1)] as String
                count = subCategories_assets.count
                break
            case 1://"負債":
                result = subCategories_liabilities[PickerView_category.selectedRow(inComponent: 1)] as String
                count = subCategories_liabilities.count
                break
            case 2://"純資産":
                result = subCategories_netAsset[PickerView_category.selectedRow(inComponent: 1)] as String
                count = subCategories_netAsset.count
                break
            case 3://"費用":
                result = subCategories_expends[PickerView_category.selectedRow(inComponent: 1)] as String
                count = subCategories_expends.count
                break
            case 4://"収益":
                result = subCategories_revenue[PickerView_category.selectedRow(inComponent: 1)] as String
                count = subCategories_revenue.count
                break
            default:
                result = subCategories_expends[PickerView_category.selectedRow(inComponent: 1)] as String
                count = subCategories_expends.count
                break
            }
            //借方勘定科目と貸方勘定科目は同じか？
            if viewControllerJournalEntry.TextField_category_debit.text  == result ||
                viewControllerJournalEntry.TextField_category_credit.text  == result {
                // ドラムロールの最大値か？
                count -= 1
                if count == row {
                    PickerView_category.selectRow(row - 1, inComponent: 1, animated: true)
                }else{
                    PickerView_category.selectRow(row + 1, inComponent: 1, animated: true)
    //            PickerView_category.selectRow(0, inComponent: 1, animated: false)
                }
            }
        }
        //一つ目のcompornentの選択内容に応じて、二つの目のcompornent表示を切り替える
        self.PickerView_category.reloadAllComponents()
    }
    //PickerView以外の部分をタッチ
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    //Buttonを押下　選択した値を仕訳画面のTextFieldに表示する
    @IBAction func Button_Done(_ sender: UIButton) {
        let viewControllerJournalEntry = self.presentingViewController as! ViewControllerJournalEntry
        var result :String
        var count :Int
        switch PickerView_category.selectedRow(inComponent: 0) {
        case 0://"資産":
            result = subCategories_assets[PickerView_category.selectedRow(inComponent: 1)] as String
            count = subCategories_assets.count
            break
        case 1://"負債":
            result = subCategories_liabilities[PickerView_category.selectedRow(inComponent: 1)] as String
            count = subCategories_liabilities.count
            break
        case 2://"純資産":
            result = subCategories_netAsset[PickerView_category.selectedRow(inComponent: 1)] as String
            count = subCategories_netAsset.count
            break
        case 3://"費用":
            result = subCategories_expends[PickerView_category.selectedRow(inComponent: 1)] as String
            count = subCategories_expends.count
            break
        case 4://"収益":
            result = subCategories_revenue[PickerView_category.selectedRow(inComponent: 1)] as String
            count = subCategories_revenue.count
            break
        default:
            result = subCategories_expends[PickerView_category.selectedRow(inComponent: 1)] as String
            count = subCategories_expends.count
            break
        }
        //借方勘定科目と貸方勘定科目は同じか？
        if viewControllerJournalEntry.TextField_category_debit.text  == result ||
            viewControllerJournalEntry.TextField_category_credit.text  == result {
            // ドラムロールの最大値か？
            count -= 1
            if count == PickerView_category.selectedRow(inComponent: 1) {
                PickerView_category.selectRow(PickerView_category.selectedRow(inComponent: 1) - 1, inComponent: 1, animated: true)
            }else{
                PickerView_category.selectRow(PickerView_category.selectedRow(inComponent: 1) + 1, inComponent: 1, animated: true)
//            PickerView_category.selectRow(0, inComponent: 1, animated: false)
            }
            //一つ目のcompornentの選択内容に応じて、二つの目のcompornent表示を切り替える
            self.PickerView_category.reloadAllComponents()
        }else {
        //Segueを場合分け
            if identifier == "identifier_debit" {
                viewControllerJournalEntry.TextField_category_debit.text = result  //ここで値渡し
                if viewControllerJournalEntry.TextField_amount_debit.text == "金額" {
                    viewControllerJournalEntry.TextField_amount_debit.becomeFirstResponder()
                }
                viewControllerJournalEntry.Label_Popup.text = ""//ポップアップの文字表示をクリア
            }else if identifier == "identifier_credit" {
                viewControllerJournalEntry.TextField_category_credit.text = result  //ここで値渡し
//                viewControllerJournalEntry.TextField_amount_credit.becomeFirstResponder() //貸方金額は不使用のため
                if viewControllerJournalEntry.TextField_SmallWritting.text == "取引内容" {
                    viewControllerJournalEntry.TextField_SmallWritting.becomeFirstResponder()// カーソルを小書きへ移す
                }
                viewControllerJournalEntry.Label_Popup.text = ""//ポップアップの文字表示をクリア
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func Button_Cancel(_ sender: UIButton) {
        let viewControllerJournalEntry = self.presentingViewController as! ViewControllerJournalEntry
        //Segueを場合分け
        if identifier == "identifier_debit" {
            viewControllerJournalEntry.TextField_category_debit.text = "勘定科目"  //ここで値渡し
//            viewControllerJournalEntry.TextField_amount_debit.becomeFirstResponder()
        }else if identifier == "identifier_credit" {
            viewControllerJournalEntry.TextField_category_credit.text = "勘定科目"  //ここで値渡し
//            viewControllerJournalEntry.TextField_amount_credit.becomeFirstResponder()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
