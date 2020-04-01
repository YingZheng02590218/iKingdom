//
//  ViewControllerJournalEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/23.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import RealmSwift

class ViewControllerJournalEntry: UIViewController {

    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var Button_Left: UIButton!
    @IBOutlet weak var TextField_category_debit: UITextField!
    @IBOutlet weak var TextField_category_credit: UITextField!
    @IBOutlet weak var TextField_amount_debit: UITextField!
    @IBOutlet weak var TextField_amount_credit: UITextField!
    
    @IBAction func TextField_category_debit(_ sender: UITextField) {}
    @IBAction func TextField_category_credit(_ sender: UITextField) {}
    @IBAction func TextField_amount_debit(_ sender: UITextField) {}
    @IBAction func TextField_amount_credit(_ sender: UITextField) {}
    
    @IBAction func Button_Input(_ sender: Any) {
        print(TextField_category_debit.text)
        print(TextField_category_credit.text)
        print(TextField_amount_debit.text)
        print(TextField_amount_credit.text)
    }
    
    var categories :[String] = Array<String>()
    var subCategories_assets :[String] = Array<String>()
    var subCategories_liabilities :[String] = Array<String>()
    var subCategories_netAsset :[String] = Array<String>()
    var subCategories_expends :[String] = Array<String>()
    var subCategories_revenue :[String] = Array<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createTextFieldForCategory()
        createTextFieldForAmount()
    }
//TextField
    func createTextFieldForCategory() {
        //TextFieldのキーボードを表示させないように、ダミーのViewを表示
        TextField_category_debit.inputView = UIView()
        TextField_category_credit.inputView = UIView()
        //TextFieldのキーボードを出したくない
        TextField_category_debit.isUserInteractionEnabled = true
        TextField_category_credit.isUserInteractionEnabled = true
        //仕訳画面を開いたら借方勘定科目TextFieldのキーボードを自動的に表示する
        self.TextField_category_debit.becomeFirstResponder()
//        self.TextField_category_debit.resignFirstResponder()
//        self.TextField_category_credit.becomeFirstResponder()
    }
    
    func createTextFieldForAmount(){
    // toolbar
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonTapped(_:)))
        doneButtonItem.tag = 5
        toolbar.setItems([doneButtonItem], animated: true)
        TextField_amount_debit.inputAccessoryView = toolbar
    // toolbar22
        let toolbar2 = UIToolbar()
        toolbar2.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem2 = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonTapped(_:)))
        doneButtonItem2.tag = 6
        toolbar2.setItems([doneButtonItem2], animated: true)
        TextField_amount_credit.inputAccessoryView = toolbar2
    }
    @objc func barButtonTapped(_ sender: UIBarButtonItem) {
      // do something here
        // キーボードを閉じる処理
           self.view.endEditing(true)
        if sender.tag == 5 {
            //TextFieldのキーボードを自動的に表示する
            // 今フォーカスが当たっているテキストボックスからフォーカスを外す
            TextField_amount_credit.becomeFirstResponder()
        }
    }
//    キーボード起動時
//    textFieldShouldBeginEditing
//    textFieldDidBeginEditing
//    リターン押下時
//    textFieldShouldReturn before responder
//    textFieldShouldEndEditing
//    textFieldDidEndEditing
//    textFieldShouldReturn
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
      return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      print("変更中")
      return true
    }
    // テキストフィールがタップされ、入力可能になる直前
    //    テキストフィールがタップされ、入力可能になったあと
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(#function)
        print("テキストフィールがタップされ、入力可能になったあと")
        //TextFieldのキーボードを自動的に閉じる
        // 今フォーカスが当たっているテキストボックスからフォーカスを外す
//        textField.resignFirstResponder()
        self.view.endEditing(true)
        if textField.tag == 111 {
            //TextFieldのキーボードを自動的に表示する
            // 今フォーカスが当たっているテキストボックスからフォーカスを外す
            TextField_category_credit.becomeFirstResponder()
        }else if textField.tag == 333{
            TextField_amount_credit.becomeFirstResponder()
        }
    }
//    キーボードを閉じる前
    func textFieldShouldEndEditing(_ textField:UITextField) -> Bool {
      print("キーボードを閉じる前")
      return true
    }
//    キーボードを閉じたあと
    func textFieldDidEndEditing(_ textField:UITextField){
      print("キーボードを閉じたあと")
    }
    //リターンキーが押されたとき
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //resignFirstResponder()メソッドを利用します。
        textField.resignFirstResponder()
        print("キーボードを閉じる前")
        // キーボードを閉じる処理
        self.view.endEditing(true)
        print("キーボードを閉じたあと")
        return true
    }
    //TextField キーボード以外の部分をタッチ
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touchesBeganメソッドをオーバーライドします。
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // segue.destinationの型はUIViewController
        let viewControllerCategory = segue.destination as! ViewControllerCategory
        switch segue.identifier {
         case "identifier_debit":
           viewControllerCategory.identifier = "identifier_debit"
            break
        case "identifier_credit":
            viewControllerCategory.identifier = "identifier_credit"
            break
         default:
//            viewControllerCategory.identifier = "identifier_debit"
           break
         }
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
