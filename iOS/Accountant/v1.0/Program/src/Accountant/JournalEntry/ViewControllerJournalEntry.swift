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
    @IBOutlet weak var Label_category_debit: UILabel!
    @IBOutlet weak var TextField_category_credit: UITextField!
    
    @IBOutlet weak var TextField_amount_debit: UITextField!
    @IBOutlet weak var TextField_amount_credit: UITextField!
    
    @IBAction func DatePicker(_ sender: UIDatePicker) {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "YYYY/MM/dd"
//        Label_date.text = "\(formatter.string(from: DatePicker.date))"
    }
    @IBAction func TextField_category_debit(_ sender: UITextField) {
         self.view.endEditing(true)
    }
    @IBAction func TextField_category_credit(_ sender: UITextField) {
        self.view.endEditing(true)
    }
    @IBAction func TextField_amount_debit(_ sender: UITextField) {}
    @IBAction func TextField_amount_credit(_ sender: UITextField) {}
    
    @IBAction func Button_Input(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd"
        print("\(formatter.string(from: DatePicker.date))")
        print(DatePicker.date)
        print(TextField_category_debit.text)
        print(TextField_category_credit.text)
        print(TextField_amount_debit.text)
        print(TextField_amount_credit.text)
    }
    @IBOutlet weak var Label_date: UILabel!
    
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
        createDatePicker()
//        performSegue(withIdentifier: "identifier_debit", sender: nil)
    }
    
    func createDatePicker() {
        let f     = DateFormatter()//年
        let ff    = DateFormatter()//月
        let fff   = DateFormatter()//月日
        let ffff  = DateFormatter()//年月日
        let ffff2 = DateFormatter()//年月日
        let fffff = DateFormatter()

        f.dateFormat    = DateFormatter.dateFormat(fromTemplate: "YYYY", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        ff.dateFormat   = DateFormatter.dateFormat(fromTemplate: "MM", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        fff.dateFormat  = DateFormatter.dateFormat(fromTemplate: "MM/dd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        ffff.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        fffff.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ", options: 0, locale: Locale(identifier: "en_US_POSIX"))
//        var dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "YYYY-MM-DD"
        ffff2.dateFormat = "yyyy-MM-dd"

        let now :Date = Date()
//        var now :Date = Date()
//        let now1 = fffff.string(from: Calendar.current.date(byAdding: .month, value: -3, to: now)!)
//        now = fffff.date(from: now1)!
//        print(f.string(from: now))//年
//        print(ff.string(from: now))//月
//        print(fff.string(from: now))//月日
//        print(ffff.string(from: now))//年月日
        print(now)

        let nowStringYear = f.string(from: now)//年
        
//        let modifiedDate = Calendar.current.date(byAdding: .year, value: -1, to: now)!
        let nowStringPreviousYear = f.string(from: Calendar.current.date(byAdding: .year, value: -1, to: now)!)//年
//        let modifiedDate2 = Calendar.current.date(byAdding: .year, value: 1, to: now)!
        let nowStringNextYear = f.string(from: Calendar.current.date(byAdding: .year, value: 1, to: now)!)//年
        
//        let nowStringMonth = ff.string(from: now)//月
        let nowStringMonthDay = fff.string(from: now)//月日
        
        let dayOfStartInYear :Date   = fff.date(from: "01/01")!
        let dayOfEndInPeriod :Date   = fff.date(from: "03/31")!
        let dayOfStartInPeriod :Date = fff.date(from: "04/01")!
        let dayOfEndInYear :Date     = fff.date(from: "12/31")!
//        let dayOfStartInPeriod :Date = ff.date(from: "04")!
//        let dayOfEndInYear :Date     = ff.date(from: "12")!
//        let dayOfStartInYewr :Date   = ff.date(from: "01")!
//        let dayOfEndInPeriod :Date   = ff.date(from: "03")!

        //一月以降か
        let dayInterval = (Calendar.current.dateComponents([.month], from: dayOfStartInYear, to: fff.date(from: nowStringMonthDay)! )).month
        //三月三十一日未満か
        let dayInterval1 = (Calendar.current.dateComponents([.month], from: dayOfEndInPeriod, to: fff.date(from: nowStringMonthDay)! )).month
        //四月以降か
        let dayInterval2 = (Calendar.current.dateComponents([.month], from: dayOfStartInPeriod, to: fff.date(from: nowStringMonthDay)! )).month
        //十二月と同じ、もしくはそれ以前か
        let dayInterval3 = (Calendar.current.dateComponents([.month], from: dayOfEndInYear, to: fff.date(from: nowStringMonthDay)! )).month
        //一月以降か
        if  dayInterval! >= 0  {
            //三月三十一日未満か
            if  dayInterval1! <= 0  {
                DatePicker.minimumDate = ffff2.date(from: (nowStringPreviousYear + "-04-01"))
                DatePicker.maximumDate = ffff2.date(from: (nowStringYear + "-03-31"))
                //四月以降か
                if dayInterval2! >= 0 {
                    //十二月と同じ、もしくはそれ以前か
                    if dayInterval3! <= 0 {
                        //04-02にすると04-01となる
                        DatePicker.minimumDate = ffff2.date(from: nowStringYear + "-04-01")!
                        //04-01にすると03-31となる
                        DatePicker.maximumDate = ffff2.date(from: nowStringNextYear + "-03-31")!
                    }
                }
            }
        }
        print(DatePicker.minimumDate)
        print(DatePicker.maximumDate)
 
//        print(fff.string(from: dayOfStartInPeriod))
//        print(fff.string(from: dayOfEndInYear))
//        print(fff.string(from: dayOfStartInYear))
//        print(fff.string(from: dayOfEndInPeriod))
        
//        print(nowStringYear)
//        print(nowStringNextYear)
        Label_date.text = ffff.string(from: DatePicker.date)
    }

//TextField
    func createTextFieldForCategory() {
        //TextFieldのキーボードを表示させないように、ダミーのViewを表示
//        TextField_category_debit.inputView = UIView()
//        TextField_category_credit.inputView = UIView()
        //TextFieldのキーボードを出したくない
        TextField_category_debit.isUserInteractionEnabled = true
        TextField_category_credit.isUserInteractionEnabled = true
        //仕訳画面を開いたら借方勘定科目TextFieldのキーボードを自動的に表示する
        self.TextField_category_debit.becomeFirstResponder()
//        self.TextField_category_debit.resignFirstResponder()
//        self.TextField_category_credit.becomeFirstResponder()
    }
    
    func createTextFieldForAmount(){
    // toolbar 借方 Tag5
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonTapped(_:)))
        doneButtonItem.tag = 5
        toolbar.setItems([doneButtonItem], animated: true)
        TextField_amount_debit.inputAccessoryView = toolbar
    // toolbar2 貸方 Tag6
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
            TextField_category_credit.becomeFirstResponder()
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
    // テキストフィールがタップされ、入力可能になったあと
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
