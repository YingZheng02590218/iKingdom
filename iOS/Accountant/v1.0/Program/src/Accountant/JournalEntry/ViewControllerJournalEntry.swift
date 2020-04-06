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

    @IBOutlet weak var Button_Left: UIButton!
    @IBAction func Button_Input(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd"
        print("\(DatePicker.date)")
        print("日付　　　　 " + "\(formatter.string(from: DatePicker.date))")
        print("借方勘定科目 " + "\(String(describing: TextField_category_debit.text))")
        print("貸方勘定科目 " + "\(String(describing: TextField_category_credit.text))")
        print("借方金額　　 " + "\(String(describing: TextField_amount_debit.text))")
        print("貸方金額　　 " + "\(String(describing: TextField_amount_credit.text))")
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
        createDatePicker()
//        performSegue(withIdentifier: "identifier_debit", sender: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewControllerJournalEntry.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        //ここでUIKeyboardWillShowという名前の通知のイベントをオブザーバー登録をしている
        NotificationCenter.default.addObserver(self, selector: #selector(ViewControllerJournalEntry.keyboardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        //ここでUIKeyboardWillHideという名前の通知のイベントをオブザーバー登録をしている
    }
    
    
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBAction func DatePicker(_ sender: UIDatePicker) {}

    func createDatePicker() {
        let f     = DateFormatter() //年
        let ff    = DateFormatter() //月
        let fff   = DateFormatter() //月日
        let ffff  = DateFormatter() //年月日
        let ffff2 = DateFormatter() //年月日
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
        let nowStringPreviousYear = f.string(from: Calendar.current.date(byAdding: .year, value: -1, to: now)!)//年
        let nowStringNextYear = f.string(from: Calendar.current.date(byAdding: .year, value: 1, to: now)!)//年
//        let nowStringMonth = ff.string(from: now)//月
        let nowStringMonthDay = fff.string(from: now)//月日
        
        let dayOfStartInYear :Date   = fff.date(from: "01/01")!
        let dayOfEndInPeriod :Date   = fff.date(from: "03/31")!
        let dayOfStartInPeriod :Date = fff.date(from: "04/01")!
        let dayOfEndInYear :Date     = fff.date(from: "12/31")!

        //一月以降か
        let Interval = (Calendar.current.dateComponents([.month], from: dayOfStartInYear, to: fff.date(from: nowStringMonthDay)! )).month
        //三月三十一日未満か
        let Interval1 = (Calendar.current.dateComponents([.month], from: dayOfEndInPeriod, to: fff.date(from: nowStringMonthDay)! )).month
        //四月以降か
        let Interval2 = (Calendar.current.dateComponents([.month], from: dayOfStartInPeriod, to: fff.date(from: nowStringMonthDay)! )).month
        //十二月と同じ、もしくはそれ以前か
        let Interval3 = (Calendar.current.dateComponents([.month], from: dayOfEndInYear, to: fff.date(from: nowStringMonthDay)! )).month
        
        if  Interval! >= 0  {
            if  Interval1! <= 0  { //第四四半期の場合
                DatePicker.minimumDate = ffff2.date(from: (nowStringPreviousYear + "-04-01"))
                DatePicker.maximumDate = ffff2.date(from: (nowStringYear + "-03-31"))
                //四月以降か
                if Interval2! >= 0 { //第一四半期　以降
                    if Interval3! <= 0 { //第三四半期　以内
                        DatePicker.minimumDate = ffff2.date(from: nowStringYear + "-04-01")!    //04-02にすると04-01となる
                        DatePicker.maximumDate = ffff2.date(from: nowStringNextYear + "-03-31")!//04-01にすると03-31となる
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
//        Label_date.text = ffff.string(from: DatePicker.date)
    }
    
//TextField
    @IBOutlet weak var TextField_category_debit: UITextField!
    @IBOutlet weak var TextField_category_credit: UITextField!
    @IBAction func TextField_category_debit(_ sender: UITextField) {
        //カーソルが当たったらすぐに終了させる　勘定科目画面に遷移させるため
         self.view.endEditing(true)
    }
    @IBAction func TextField_category_credit(_ sender: UITextField) {
        //カーソルが当たったらすぐに終了させる　勘定科目画面に遷移させるため
        self.view.endEditing(true)
    }
    func createTextFieldForCategory() {
        //TextFieldのキーボードを表示させないように、ダミーのViewを表示 TextField
//        TextField_category_debit.inputView = UIView()
//        TextField_category_credit.inputView = UIView()
        //TextFieldのキーボードを出したくない 場合はfalse カーソルすら当たらなくなる
//        TextField_category_debit.isUserInteractionEnabled = true
//        TextField_category_credit.isUserInteractionEnabled = true
        //仕訳画面を開いたら借方勘定科目TextFieldのキーボードを自動的に表示する
        self.TextField_category_debit.becomeFirstResponder()
    }
    
    @IBOutlet weak var TextField_amount_debit: UITextField!
    @IBOutlet weak var TextField_amount_credit: UITextField!
    @IBAction func TextField_amount_debit(_ sender: UITextField) {}
    @IBAction func TextField_amount_credit(_ sender: UITextField) {
        TextField_amount_credit.text = TextField_amount_debit.text
    }
    func createTextFieldForAmount(){
    // toolbar 借方 Done:Tag5 Cancel:Tag55
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonTapped(_:)))
        doneButtonItem.tag = 5
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(barButtonTapped(_:)))
        cancelItem.tag = 55
        toolbar.setItems([cancelItem, flexSpaceItem, doneButtonItem], animated: true)
//        toolbar.backgroundColor = UIColor.clear
        //UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        //UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.5)
        //UIColor.clear
        //(Red: 0, green: 0, blue: 0, alpha: 0)
        // alpha 0 で色を設定
//        toolbar.barTintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        //UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        toolbar.isTranslucent = true
        TextField_amount_debit.inputAccessoryView = toolbar
    // toolbar2 貸方 Done:Tag6 Cancel:Tag66
        let toolbar2 = UIToolbar()
        toolbar2.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem2 = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonTapped(_:)))
        doneButtonItem2.tag = 6
        let flexSpaceItem2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelItem2 = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(barButtonTapped(_:)))
        cancelItem2.tag = 66
        toolbar2.setItems([cancelItem2,flexSpaceItem2, doneButtonItem2], animated: true)
//        toolbar2.backgroundColor = UIColor.clear//(Red: 0, green: 0, blue: 0, alpha: 0) // alpha 0透明　1不透明
//        toolbar2.barTintColor = UIColor.clear//UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        toolbar2.isTranslucent = true
        TextField_amount_credit.inputAccessoryView = toolbar2
    }

    let SCREEN_SIZE = UIScreen.main.bounds.size
    //UIKeyboardWillShow通知を受けて、実行される関数
    @objc func keyboardWillShow(_ notification: NSNotification){
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.height
//         textField.frame.origin.y = SCREEN_SIZE.height - keyboardHeight - textField.frame.height
        print("キーボード高さ" + "\(keyboardHeight)")
        print("スクリーン高さ-キーボード高さ" + "\(SCREEN_SIZE.height - keyboardHeight)")
        print("スクリーン高さ" + "\(SCREEN_SIZE.height)")
    }
    //UIKeyboardWillShow通知を受けて、実行される関数
    @objc func keyboardWillHide(_ notification: NSNotification){
//        textField.frame.origin.y = SCREEN_SIZE.height - textField.frame.height
    }
    //TextFieldのキーボードについているBarButtonが押下された時
    @objc func barButtonTapped(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 5://借方金額の場合 Done
            // キーボードを閉じる
            self.view.endEditing(true)
            //TextFieldのキーボードを自動的に表示する　借方金額　→ 貸方勘定科目
            TextField_category_credit.becomeFirstResponder()
            break
        case 6://貸方金額の場合 Done
            self.view.endEditing(true)
            break
        case 55://借方金額の場合 Cancel
            self.view.endEditing(true)
            TextField_amount_debit.text = ""
            break
        case 66://貸方金額の場合 Cancel
            self.view.endEditing(true)
            TextField_amount_credit.text = ""
            break
        default:
            self.view.endEditing(true)
            break
        }
    }
// キーボード起動時
//    textFieldShouldBeginEditing
//    textFieldDidBeginEditing
// リターン押下時
//    textFieldShouldReturn before responder
//    textFieldShouldEndEditing
//    textFieldDidEndEditing
//    textFieldShouldReturn
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //todo
        if textField.text == "勘定科目"{
            return true
        }else{
            return false
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //todo
        print("変更中")
      return true
    }
    // テキストフィールがタップされ、入力可能になる直前
    // テキストフィールがタップされ、入力可能になったあと
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //todo
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
      //todo
      print("キーボードを閉じる前")
      return true
    }
//    キーボードを閉じたあと
    func textFieldDidEndEditing(_ textField:UITextField){
      //todo
      print("キーボードを閉じたあと")
    }
    //リターンキーが押されたとき
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //todo
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
        //todo
//        TextField_amount_debit.resignFirstResponder()
//        TextField_amount_credit.resignFirstResponder()
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
