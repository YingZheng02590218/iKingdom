//
//  PickerTextFieldAccountDetail.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/10/18.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// ドラムロール　勘定科目詳細画面　新規追加
class PickerTextFieldAccountDetail: UITextField, UIPickerViewDelegate, UIPickerViewDataSource {

    // ドラムロールに表示する勘定科目の文言
    var Rank0 :[String] = Array<String>()
    var big_0 :[String] = Array<String>()
    var big_1 :[String] = Array<String>()
    var big_2 :[String] = Array<String>()
    var big_3 :[String] = Array<String>()
    var big_4 :[String] = Array<String>()
    var big_5 :[String] = Array<String>()
    var big_6 :[String] = Array<String>()
    var big_7 :[String] = Array<String>()
    var big_8 :[String] = Array<String>()
    var big_9 :[String] = Array<String>()
    var big_10 :[String] = Array<String>()
    var big_11 :[String] = Array<String>()

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width:0, height: 0))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var identifier = ""
    var component0 = 0
    func setup(identifier: String, component0: Int) {
        // アイディを記憶
        self.identifier = identifier
        //Segueを場合分け　初期値
        if identifier == "identifier_category_big" {

        }else if identifier == "identifier_category" {
            self.component0 = component0
        }
        // ピッカー　ドラムロールの項目を初期化
        setSettingsCategory()
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        // PickerView のサイズと位置 金額のTextfieldのキーボードの高さに合わせる
        picker.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 350)
//        picker.transform = CGAffineTransform(scaleX: 0.5, y: 0.5);
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width:0, height: 44))
        toolbar.barTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)// RGBで指定する alpha 0透明　1不透明
        toolbar.isTranslucent = true
        toolbar.barStyle = .default
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        toolbar.setItems([cancelItem, flexSpaceItem, doneItem], animated: true)
        // previous, next, paste ボタンを消す
        self.inputAssistantItem.leadingBarButtonGroups.removeAll()

        self.inputView = picker
        self.inputAccessoryView = toolbar
        
        //借方勘定科目を選択した後に、貸方勘定科目を選択する際に初期値が前回のものが表示されるので、リロードする
        picker.reloadAllComponents()
    }
    // 設定画面の勘定科目設定で有効を選択した勘定を、勘定科目画面のドラムロールに表示するために、DBから文言を読み込む
    func setSettingsCategory(){
        // 勘定科目区分　大区分
        Rank0 = ["流動資産","固定資産","繰延資産","流動負債","固定負債","資本","売上","売上原価","販売費及び一般管理費","営業外損益","特別損益","税金"]
        for i in 0..<Rank0.count {
            transferItems(Rank1: i)    // 勘定科目区分ごとに文言を用意する
        }
    }
    // 設定データを変数に入れ替える 中区分
    func transferItems(Rank1: Int) {
        switch Rank1 {
        case 0:
            big_0 = ["当座資産","棚卸資産","その他の流動資産"]
            break
        case 1:
            big_1 = ["有形固定資産","無形固定資産","投資その他の資産"]
            break
        case 2:
            big_2 = ["繰延資産"]
            break
        case 3:
            big_3 = ["仕入債務","その他の流動負債"]
            break
        case 4:
            big_4 = ["長期債務"]
            break
        case 5:
            big_5 = ["株主資本","評価・換算差額等","新株予約権","非支配株主持分"]
            break
        case 6:
            big_6 = [""]
            break
        case 7:
            big_7 = ["売上原価","製造原価"]
            break
        case 8:
            big_8 = [""]
            break
        case 9:
            big_9 = ["営業外収益","営業外費用"]
            break
        case 10:
            big_10 = ["特別利益","特別損失"]
            break
        case 11:
            big_11 = [""]
            break
        default:
            //big_0 = array
            break
        }
    }
//UIPickerView
    //UIPickerViewの列の数 コンポーネントの数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1//2
    }
    //UIPickerViewの行数、リストの数 コンポーネントの内のデータ
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //Segueを場合分け　初期値
        if identifier == "identifier_category_big" {
//        if component == 0 {
            return Rank0.count
        }else if identifier == "identifier_category" {
            switch component0 {//pickerView.selectedRow(inComponent: 0) {
            case 0://"資産":
                return big_0.count
            case 1://"負債":
                return big_1.count
            case 2:
                return big_2.count
            case 3:
                return big_3.count
            case 4:
                return big_4.count
            case 5:
                return big_5.count
            case 6:
                return big_6.count
            case 7:
                return big_7.count
            case 8:
                return big_8.count
            case 9:
                return big_9.count
            case 10:
                return big_10.count
            case 11:
                return big_11.count
            default:
                return 0
            }
        }
        return 1
    }
    //UIPickerViewの最初の表示 ホイールに表示する選択肢のタイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //Segueを場合分け　初期値
        if identifier == "identifier_category_big" {
//        if component == 0 {
            self.text = Rank0[row] as String // TextFieldに表示
            return Rank0[row] as String
        }else if identifier == "identifier_category" {
            switch component0 {//pickerView.selectedRow(inComponent: 0) {
            case 0:
                self.text = big_0[row] as String // TextFieldに表示
                return big_0[row] as String      // PickerViewに表示
            case 1:
                self.text = big_1[row] as String
                return big_1[row] as String
            case 2:
                self.text = big_2[row] as String
                return big_2[row] as String
            case 3:
                self.text = big_3[row] as String
                return big_3[row] as String  //ドラムロールを早く回すと、ここでエラーが発生する　2020/07/24
            case 4:
                self.text = big_4[row] as String //エラー　2020/08/04
                return big_4[row] as String
            case 5:
                self.text = big_5[row] as String
                return big_5[row] as String
            case 6:
                self.text = big_6[row] as String
                return big_6[row] as String
            case 7:
                self.text = big_7[row] as String
                return big_7[row] as String
            case 8:
                self.text = big_8[row] as String
                return big_8[row] as String
            case 9:
                self.text = big_9[row] as String
                return big_9[row] as String
            case 10:
                self.text = big_10[row] as String
                return big_10[row] as String
            case 11:
                self.text = big_11[row] as String
                return big_11[row] as String // エラー　2020/10/15
            default:
                return ""
            }
        }
        self.text = "-"
        return "-"
    }
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 文字色
//        self.textColor = UIColor.black
//        var result :String = ""
//        var count :Int = 0
        //Segueを場合分け　初期値
        if identifier == "identifier_category_big" {
            self.text = Rank0[row] as String
        }else if identifier == "identifier_category" {
//        // ドラムロールの2列目か？
//        if component == 1 {
            switch component0 {//pickerView.selectedRow(inComponent: 0) {
            case 0://"資産":
//                result = big_0[row] as String
                self.text = big_0[row] as String
//                count = big_0.count
                break
            case 1://"負債":
//                result = big_1[row] as String
                self.text = big_1[row] as String
//                count = subCategories_liabilities.count
                break
            case 2://"純資産":
                self.text = big_2[row] as String
//                count = subCategories_netAsset.count
                break
            case 3://"費用":
                self.text = big_3[row] as String
//                count = subCategories_expends.count
                break
            case 4://"収益":
                self.text = big_4[row] as String
//                count = subCategories_revenue.count
                break
            case 5:
                self.text = big_5[row] as String
                break
            case 6:
                self.text = big_6[row] as String
                break
            case 7:
                self.text = big_7[row] as String
                break
            case 8:
                self.text = big_8[row] as String
                break
            case 9:
                self.text = big_9[row] as String
                break
            case 10:
                self.text = big_10[row] as String
                break
            case 11:
                self.text = big_11[row] as String
                break
            default:
                self.text = ""//subCategories_expends[row] as String
                break
            }
//            // UIPickerTextField 隣のテキストフィールドを探す
//            var hoge = pickerView.superview // 親ビュー
//            while(hoge!.isKind(of: ViewControllerJournalEntry.self) == false) {
//                hoge = hoge!.superview
//            }
//            let viewControllerJournalEntry = hoge as! ViewControllerJournalEntry
            
//            let tabBarController = self.presentingViewController as! UITabBarController // 一番基底となっているコントローラ
//            let navigationController = tabBarController.selectedViewController as! UINavigationController // 基底のコントローラから、現在選択されているコントローラを取得する
//            let presentingViewController = navigationController.viewControllers[0] as! TableViewControllerJournals // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
//            //借方勘定科目と貸方勘定科目は同じか？
//            if viewControllerJournalEntry.TextField_category_debit.text  == result ||
//                viewControllerJournalEntry.TextField_category_credit.text  == result {
//                if count > 2 { // ドラムロールのコンポーネントは2行以上あるか？
//                    // ドラムロールの最大値か？
//                    count -= 1
//                    if count == row {
//                        pickerView.selectRow(row - 1, inComponent: 1, animated: true)
//                    }else{
//                        pickerView.selectRow(row + 1, inComponent: 1, animated: true)
//                        //            PickerView_category.selectRow(0, inComponent: 1, animated: false)
//                    }
//                }
//            }
        }else {
            self.text = ""
        }
        //一つ目のcompornentの選択内容に応じて、二つの目のcompornent表示を切り替える
        pickerView.reloadAllComponents()
    }
    //Buttonを押下　選択した値を仕訳画面のTextFieldに表示する
    @objc func done() {
        self.endEditing(true)
    }
    
    @objc func cancel() {
        self.text = "選択してください"
        self.endEditing(true)
    }
//    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return dataList.count
//    }
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return dataList[row]
//    }
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        self.text = dataList[row]
//    }
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//         return 1
//    }
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return dataList.count
//    }
}
