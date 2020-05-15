//
//  ViewControllerJournalEntry.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/23.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

class ViewControllerJournalEntry: UIViewController, UITextFieldDelegate {
    
    var categories :[String] = Array<String>()
    var subCategories_assets :[String] = Array<String>()
    var subCategories_liabilities :[String] = Array<String>()
    var subCategories_netAsset :[String] = Array<String>()
    var subCategories_expends :[String] = Array<String>()
    var subCategories_revenue :[String] = Array<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createDatePicker()
        createTextFieldForCategory()
        createTextFieldForAmount()
        createTextFieldForSmallwritting()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewControllerJournalEntry.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        //ここでUIKeyboardWillShowという名前の通知のイベントをオブザーバー登録をしている
        NotificationCenter.default.addObserver(self, selector: #selector(ViewControllerJournalEntry.keyboardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        //ここでUIKeyboardWillHideという名前の通知のイベントをオブザーバー登録をしている
    }
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func DatePicker(_ sender: UIDatePicker) {}
    let now :Date = Date()

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

//        var now :Date = Date()
//        let now1 = fffff.string(from: Calendar.current.date(byAdding: .month, value: -3, to: now)!)
//        now = fffff.date(from: now1)!
//        print(f.string(from: now))//年
//        print(ff.string(from: now))//月
//        print(fff.string(from: now))//月日
//        print(ffff.string(from: now))//年月日
//        print(now)

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
                datePicker.minimumDate = ffff2.date(from: (nowStringPreviousYear + "-04-01"))
                datePicker.maximumDate = ffff2.date(from: (nowStringYear + "-03-31"))
                //四月以降か
            }else if Interval2! >= 0 { //第一四半期　以降
                if Interval3! <= 0 { //第三四半期　以内
                    datePicker.minimumDate = ffff2.date(from: nowStringYear + "-04-01")!    //04-02にすると04-01となる
                    datePicker.maximumDate = ffff2.date(from: nowStringNextYear + "-03-31")!//04-01にすると03-31となる
                }
            }
        }
//        print("\(String(describing: datePicker.minimumDate))")
//        print("\(String(describing: datePicker.maximumDate))")
//
        datePicker.date = now
//        print("\(String(describing: datePicker.date))")

//        print(fff.string(from: dayOfStartInPeriod))
//        print(fff.string(from: dayOfEndInYear))
//        print(fff.string(from: dayOfStartInYear))
//        print(fff.string(from: dayOfEndInPeriod))
        
//        print(nowStringYear)
//        print(nowStringNextYear)
//        Label_date.text = ffff.string(from: DatePicker.date)
    }
    var diff :Int = 0
    @IBOutlet weak var Button_Left: UIButton!
    @IBAction func Button_Left(_ sender: UIButton) {
        //todo
        let min = datePicker.minimumDate!
        if datePicker.date > min {
            diff -= 1
        }
        let modifiedDate = Calendar.current.date(byAdding: .day, value: diff, to: now)!
        datePicker.date = modifiedDate
//        print("\(String(describing: datePicker.date))")
    }
    @IBOutlet weak var Button_Right: UIButton!
    @IBAction func Button_Right(_ sender: UIButton) {
        //todo
        let max = datePicker.maximumDate!
        if datePicker.date < max {
            diff += 1
        }
        let modifiedDate = Calendar.current.date(byAdding: .day, value: diff, to: now)!
        datePicker.date = modifiedDate
//        print("\(String(describing: datePicker.date))")
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
    // 画面遷移の準備　勘定科目画面
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
    
    @IBOutlet weak var TextField_amount_debit: UITextField!
    @IBOutlet weak var TextField_amount_credit: UITextField!
    @IBAction func TextField_amount_debit(_ sender: UITextField) {}
    @IBAction func TextField_amount_credit(_ sender: UITextField) {}
    // TextField 金額
    func createTextFieldForAmount() {
        TextField_amount_debit.delegate = self
        TextField_amount_credit.delegate = self
    // toolbar 借方 Done:Tag5 Cancel:Tag55
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        toolbar.backgroundColor = UIColor.clear// 名前で指定する
        toolbar.barTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)// RGBで指定する    alpha 0透明　1不透明
        toolbar.isTranslucent = true
        toolbar.barStyle = .default
        let doneButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonTapped(_:)))
        doneButtonItem.tag = 5
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(barButtonTapped(_:)))
        cancelItem.tag = 55
        toolbar.setItems([cancelItem, flexSpaceItem, doneButtonItem], animated: true)
//        doneButtonItem.isEnabled = false
        TextField_amount_debit.inputAccessoryView = toolbar
    // toolbar2 貸方 Done:Tag6 Cancel:Tag66
        let toolbar2 = UIToolbar()
        toolbar2.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        toolbar2.backgroundColor = UIColor.clear
        toolbar2.barTintColor = UIColor.clear
        toolbar2.isTranslucent = true
        toolbar2.barStyle = .default
        let doneButtonItem2 = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonTapped(_:)))
        doneButtonItem2.tag = 6
        let flexSpaceItem2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelItem2 = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(barButtonTapped(_:)))
        cancelItem2.tag = 66
        toolbar2.setItems([cancelItem2,flexSpaceItem2, doneButtonItem2], animated: true)
//        doneButtonItem2.isEnabled = false
        TextField_amount_credit.inputAccessoryView = toolbar2
        
        // TextFieldに入力された値に反応
        TextField_amount_debit.addTarget(self, action: #selector(textFieldDidChange),for: UIControl.Event.editingChanged)
        TextField_amount_credit.addTarget(self, action: #selector(textFieldDidChange),for: UIControl.Event.editingChanged)
    }
    // TextFieldに入力され値が変化した時の処理の関数
    @objc func textFieldDidChange(_ sender: UITextField) {
//    func textFieldEditingChanged(_ sender: UITextField){
        if sender.text != "" {
            print("\(String(describing: sender.text))")
        }
    }
    
    @IBOutlet weak var TextField_SmallWritting: UITextField!
    @IBAction func TextField_SmallWritting(_ sender: UITextField) {}
    // TextField 小書き
    func createTextFieldForSmallwritting() {
        TextField_SmallWritting.delegate = self
// toolbar 小書き Done:Tag Cancel:Tag
       let toolbar = UIToolbar()
       toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
//       toolbar.backgroundColor = UIColor.clear// 名前で指定する
//       toolbar.barTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)// RGBで指定する    alpha 0透明　1不透明
       toolbar.isTranslucent = true
//       toolbar.barStyle = .default
       let doneButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonTapped(_:)))
       doneButtonItem.tag = 7
       let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
       let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(barButtonTapped(_:)))
       cancelItem.tag = 77
       toolbar.setItems([cancelItem, flexSpaceItem, doneButtonItem], animated: true)
       TextField_SmallWritting.inputAccessoryView = toolbar
    }
    
    let SCREEN_SIZE = UIScreen.main.bounds.size
    // UIKeyboardWillShow通知を受けて、実行される関数
    @objc func keyboardWillShow(_ notification: NSNotification){
//        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.height
//        print("スクリーン高さ          " + "\(SCREEN_SIZE.height)")
//        print("キーボードまでの高さ     " + "\(SCREEN_SIZE.height - keyboardHeight)")
//        print("キーボード高さ          " + "\(keyboardHeight)")
//        TextField_SmallWritting.frame.origin.y = SCREEN_SIZE.height - keyboardHeight - TextField_SmallWritting.frame.height
    }
    // UIKeyboardWillShow通知を受けて、実行される関数
    @objc func keyboardWillHide(_ notification: NSNotification){
//        TextField_SmallWritting.frame.origin.y = SCREEN_SIZE.height - TextField_SmallWritting.frame.height
    }
    // TextFieldのキーボードについているBarButtonが押下された時
    @objc func barButtonTapped(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 5://借方金額の場合 Done
            if TextField_amount_debit.text == "0"{
                TextField_amount_debit.text = ""
                Label_Popup.text = "金額が0となっています"
            }else if TextField_amount_debit.text == ""{
                Label_Popup.text = "金額が空白となっています"
            }else{
                // キーボードを閉じる
                self.view.endEditing(true)
                if TextField_category_credit.text == "勘定科目" {
                    //TextFieldのキーボードを自動的に表示する　借方金額　→ 貸方勘定科目
                    TextField_category_credit.becomeFirstResponder()
                }
                Label_Popup.text = ""
            }
            break
        case 6://貸方金額の場合 Done
            if TextField_amount_credit.text == "0"{
                TextField_amount_credit.text = ""
                Label_Popup.text = "金額が0となっています"
            }else if TextField_amount_credit.text == ""{
                Label_Popup.text = "金額が空白となっています"
            }else{
                self.view.endEditing(true)
                if TextField_SmallWritting.text == "取引内容" {
                    // カーソルを小書きへ移す
                    self.TextField_SmallWritting.becomeFirstResponder()
                }
                Label_Popup.text = ""
            }
            break
        case 7://小書きの場合 Done
            self.view.endEditing(true)
            if TextField_SmallWritting.text == "" {
                TextField_SmallWritting.text = "取引内容"
            }
            break
        case 55://借方金額の場合 Cancel
            self.view.endEditing(true)
                TextField_amount_debit.text = "金額"
            break
        case 66://貸方金額の場合 Cancel
            self.view.endEditing(true)
                TextField_amount_credit.text = "金額"
            break
        case 77://小書きの場合 Cancel
            self.view.endEditing(true)
                TextField_SmallWritting.text = "取引内容"
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
    // テキストフィールがタップされ、入力可能になったあと
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //todo
//        print(#function)
//        print("テキストフィールがタップされ、入力可能になったあと")
        //TextFieldのキーボードを自動的に閉じる
//        self.view.endEditing(true)
    }
    // 文字クリア
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //todo
        if textField.text == "勘定科目" {
            return true
        }else if textField.text == "金額" {
            return true
        }else if textField.text == "取引内容" {
            return true
        }else{
            return false
        }
    }
    // 入力チェック(半角数字、文字数制限)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //todo
//        print("テキストフィールド入力中")
        
        var resultForCharacter = false
        var resultForLength = false
        // 入力チェック　数字のみに制限
        if textField == TextField_amount_debit || textField == TextField_amount_credit { // 借方金額仮　貸方金額
            let allowedCharacters = CharacterSet(charactersIn:"0123456789")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            // 指定したスーパーセットの文字セットでないならfalseを返す
            resultForCharacter = allowedCharacters.isSuperset(of: characterSet)
        }else{  // 小書き
            resultForCharacter = true
        }
        // 入力チェック　文字数最大数を設定
        var maxLength: Int = 0 // 文字数最大値を定義
        switch textField.tag {
        case 333,444: // 金額の文字数
            maxLength = 7
        case 555: // 小書きの文字数
            maxLength = 25
        default:
            break
        }
        // textField内の文字数
        let textFieldNumber = textField.text?.count ?? 0    //todo
        // 入力された文字数
        let stringNumber = string.count
        // 最大文字数以上ならfalseを返す
        resultForLength = textFieldNumber + stringNumber <= maxLength
        // 判定
        if !resultForCharacter { // 指定したスーパーセットの文字セットでないならfalseを返す
            return false
        }else if !resultForLength { // 最大文字数以上ならfalseを返す
            return false
        }else {
            return true
        }
    }

    //リターンキーが押されたとき
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        print("キーボードを閉じる前")
        // キーボードを閉じる処理
//        self.view.endEditing(true)
//        print("キーボードを閉じた後")
        //todo
        switch textField.text {
        case "勘定科目":
            Label_Popup.text = "勘定科目を入力してください"
            return false
        case "":// ありえない　リターンキーを押せないため
            Label_Popup.text = "空白となっています"
            return false
        case "金額":
            Label_Popup.text = "金額を入力してください"
            return false
        case "0":
            textField.text = ""
            Label_Popup.text = "金額が0となっています"
            return false
        default:
            Label_Popup.text = ""//ポップアップの文字表示をクリア
            //resignFirstResponder()メソッドを利用します。
            textField.resignFirstResponder()
            return true
        }
    }
    //TextField キーボード以外の部分をタッチ
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touchesBeganメソッドをオーバーライドします。
        self.view.endEditing(true)
    }
    //キーボードを閉じる前
    func textFieldShouldEndEditing(_ textField:UITextField) -> Bool {
        //todo
//        print(#function)
//        print("キーボードを閉じる前")
        return true
    }
    //キーボードを閉じたあと
    func textFieldDidEndEditing(_ textField:UITextField){
        //todo
//        print(#function)
//        print("キーボードを閉じた後")
        // TextField 貸方金額　入力後
        if textField.tag == 333 {
            if TextField_amount_debit.text != "" {
                TextField_amount_credit.text = TextField_amount_debit.text // 借方金額を貸方金額に表示
            }
            if TextField_category_credit.text == "勘定科目" {//貸方勘定科目が未入力の場合
                //次のTextFieldのキーボードを自動的に表示する 借方金額　→ 貸方勘定科目
                TextField_category_credit.becomeFirstResponder()
            }
        }else if textField.tag == 444 {
            if TextField_amount_credit.text != "" {
                TextField_amount_debit.text = TextField_amount_credit.text // 貸方金額を借方金額に表示
            }
        }
    }
    
    // 入力ボタン
    @IBOutlet weak var Label_Popup: UILabel!
    @IBAction func Button_Input(_ sender: Any) {
        // シスログ出力
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd"
        // printによる出力はUTCになってしまうので、9時間ずれる
//        print("\(datePicker.date)")
//        print("日付　　　　 " + "\(formatter.string(from: datePicker.date))")
//        print("借方勘定科目 " + "\(String(describing: TextField_category_debit.text))")
//        print("貸方勘定科目 " + "\(String(describing: TextField_category_credit.text))")
//        print("借方金額　　 " + "\(String(describing: TextField_amount_debit.text))")
//        print("貸方金額　　 " + "\(String(describing: TextField_amount_credit.text))")
//        print("小書き　　　 " + "\(String(describing: TextField_SmallWritting.text))")
        // 入力チェック
        if TextField_category_debit.text != "勘定科目" && TextField_category_debit.text != "" {
            if TextField_category_credit.text != "勘定科目" && TextField_category_credit.text != "" {
                if TextField_amount_debit.text != "金額" && TextField_amount_debit.text != "" && TextField_amount_debit.text != "0" {
                    if TextField_amount_credit.text != "金額" && TextField_amount_credit.text != "" && TextField_amount_credit.text != "0" {
                        if TextField_SmallWritting.text == "取引内容" {
                            TextField_SmallWritting.text = ""
                        }

                        // データベース　仕訳データを追加
                        let dataBaseManager = DataBaseManager() //データベースマネジャー
                        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
                        dataBaseManager.addJournalEntry(
                            date: formatter.string(from: datePicker.date),
                            debit_category: TextField_category_debit.text!,
                            debit_amount: Int(TextField_amount_debit.text!)!,
                            credit_category: TextField_category_credit.text!,
                            credit_amount: Int(TextField_amount_credit.text!)!,
                            smallWritting: TextField_SmallWritting.text!
                        )
                        // 
//                        self.dismiss(animated: true, completion: nil)
//                        print("入力ボタン \(presentingViewController)")
                        let tabBarController = self.presentingViewController as! UITabBarController // 一番基底となっているコントローラ
                        let presentingViewController = tabBarController.selectedViewController as! TableViewControllerJournalEntry // 基底のコントローラから、現在選択されているコントローラを取得する
                        // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
                        self.dismiss(animated: true, completion: {
                                [presentingViewController] () -> Void in
                                    // ViewController(仕訳画面)を閉じた時に遷移元のTableViewController(仕訳帳画面)で行いたい処理
                                    presentingViewController.viewWillAppear(true)
                        })
                    }else{
                        Label_Popup.text = "金額を入力してください"
                        //未入力のTextFieldのキーボードを自動的に表示する
                        TextField_amount_credit.becomeFirstResponder()
                    }
                }else{
                    Label_Popup.text = "金額を入力してください"
                    //未入力のTextFieldのキーボードを自動的に表示する
                    TextField_amount_debit.becomeFirstResponder()
                }
            }else{
                Label_Popup.text = "貸方勘定科目を入力してください"
                //未入力のTextFieldのキーボードを自動的に表示する
                TextField_category_credit.becomeFirstResponder()
            }
        }else{
            Label_Popup.text = "借方勘定科目を入力してください"
            //未入力のTextFieldのキーボードを自動的に表示する
            TextField_category_debit.becomeFirstResponder()
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
