//
//  ViewControllerJournalEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/23.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class ViewControllerJournalEntry: UIViewController/*,UIPickerViewDataSource,UIPickerViewDelegate*/ {

    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var Button_Left: UIButton!
    @IBOutlet weak var TextField_category_debit: UITextField!
    @IBOutlet weak var TextField_category_credit: UITextField!
    
    @IBAction func TextField_category_debit(_ sender: UITextField) {}
    @IBAction func TextField_category_credit(_ sender: UITextField) {}
    @IBAction func TextField_amount_debit(_ sender: UITextField) {}
    @IBAction func TextField_amount_credit(_ sender: UITextField) {}
    @IBOutlet weak var PickerView_category: UIPickerView!
    
    var categories :[String] = Array<String>()
    var subCategories_assets :[String] = Array<String>()
    var subCategories_liabilities :[String] = Array<String>()
    var subCategories_netAsset :[String] = Array<String>()
    var subCategories_expends :[String] = Array<String>()
    var subCategories_revenue :[String] = Array<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //仕訳画面を開いたら自動的にキーボードを表示する　借方勘定科目 TextField
        self.TextField_category_debit.becomeFirstResponder()
       // TextField_category_debit
    }
    
//TextField
// キーボードを閉じる
    func textFieldDidBeginEditing(_ textField: UITextField) {

        textField.resignFirstResponder()
//        textField.inputView = nil
//        textField.becomeFirstResponder()
    }
    //「return」キーを押す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //resignFirstResponder()メソッドを利用します。
        textField.resignFirstResponder()
        return true
    }
    //TextField以外の部分をタッチ
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touchesBeganメソッドをオーバーライドします。
        self.view.endEditing(true)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         let viewControllerCategory = segue.destination as! ViewControllerCategory
//        viewControllerCategory.delegate = self // delegateを登録
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
