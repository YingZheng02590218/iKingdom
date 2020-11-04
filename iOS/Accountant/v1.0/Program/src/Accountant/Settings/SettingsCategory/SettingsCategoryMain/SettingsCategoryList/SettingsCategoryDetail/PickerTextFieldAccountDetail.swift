//
//  PickerTextFieldAccountDetail.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/10/18.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// ドラムロール　勘定科目区分選択　勘定科目詳細画面　新規追加
class PickerTextFieldAccountDetail: UITextField, UIPickerViewDelegate, UIPickerViewDataSource {

    // 選択された項目
    var selectedRank0 = 0
    var selectedRank1 = 0
    var AccountDetail_big = ""
    var AccountDetail = ""
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
            self.tag = 0
        }else if identifier == "identifier_category" {
            self.tag = 1
//            self.component0 = component0
        }
//        print(self.identifier , identifier)
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
            big_6 = ["-"]
            break
        case 7:
            big_7 = ["売上原価","製造原価"]
            break
        case 8:
            big_8 = ["-"]
            break
        case 9:
            big_9 = ["営業外収益","営業外費用"]
            break
        case 10:
            big_10 = ["特別利益","特別損失"]
            break
        case 11:
            big_11 = ["-"]
            break
        default:
            //big_0 = array
            break
        }
    }
//UIPickerView
    //UIPickerViewの列の数 コンポーネントの数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    //UIPickerViewの行数、リストの数 コンポーネントの内のデータ
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //Segueを場合分け　初期値
//        if identifier == "identifier_category_big" {
        if component == 0 {
            return Rank0.count
        }else {//if identifier == "identifier_category" {
            switch pickerView.selectedRow(inComponent: 0){//component0 {
            case 0:
                return big_0.count
            case 1:
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
                return 1
            }
        }
//        return 1
    }
    //UIPickerViewの最初の表示 ホイールに表示する選択肢のタイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //Segueを場合分け　初期値
        if component == 0 {
            if identifier == "identifier_category_big" {
                self.text = Rank0[row] as String // TextFieldに表示
            }
            AccountDetail_big = Rank0[row] as String
            return Rank0[row] as String
        }else {//if identifier == "identifier_category" {
            switch pickerView.selectedRow(inComponent: 0){//component0 {
            case 0:
                // ドラムロールを2列同時に回転させた場合の対策
                if big_0.count <= row {
                    self.text = big_0[0] as String
                    return big_0[0] as String
                }else {
                    if identifier == "identifier_category" {
                        self.text = big_0[row] as String // TextFieldに表示
                    }
                    AccountDetail = big_0[row] as String
                    return big_0[row] as String      // PickerViewに表示
                }
            case 1:
                if big_1.count <= row {
                    self.text = big_1[0] as String
                    return big_1[0] as String
                }else {
                    if identifier == "identifier_category" {
                        self.text = big_1[row] as String
                    }
                    AccountDetail = big_1[row] as String
                    return big_1[row] as String
                }
            case 2:
                if big_2.count <= row {
                    self.text = big_2[0] as String
                    return big_2[0] as String
                }else {
                    if identifier == "identifier_category" {
                        self.text = big_2[row] as String
                    }
                    AccountDetail = big_2[row] as String
                    return big_2[row] as String
                }
            case 3:
                if big_3.count <= row {
                    self.text = big_3[0] as String
                    return big_3[0] as String
                }else {
                    if identifier == "identifier_category" {
                        self.text = big_3[row] as String
                    }
                    AccountDetail = big_3[row] as String
                    return big_3[row] as String  //ドラムロールを早く回すと、ここでエラーが発生する　2020/07/24
                }
            case 4:
                if big_4.count <= row {
                    self.text = big_4[0] as String
                    return big_4[0] as String
                }else {
                    if identifier == "identifier_category" {
                        self.text = big_4[row] as String //エラー　2020/08/04
                    }
                    AccountDetail = big_4[row] as String
                    return big_4[row] as String
                }
            case 5:
                if big_5.count <= row {
                    self.text = big_5[0] as String
                    return big_5[0] as String
                }else {
                    if identifier == "identifier_category" {
                        self.text = big_5[row] as String
                    }
                    AccountDetail = big_5[row] as String
                    return big_5[row] as String
                }
            case 6:
                if big_6.count <= row {
                    self.text = big_6[0] as String
                    return big_6[0] as String
                }else {
                    if big_6[row] as String == "-" {
                        if identifier == "identifier_category" {
                            self.text = "選択してください"
                        }
                        AccountDetail = "選択してください"
                    }else {
                        if identifier == "identifier_category" {
                            self.text = big_6[row] as String
                        }
                        AccountDetail = big_6[row] as String
                    }
                    return big_6[row] as String
                }
            case 7:
                if big_7.count <= row {
                    self.text = big_7[0] as String
                    return big_7[0] as String
                }else {
                    if identifier == "identifier_category" {
                        self.text = big_7[row] as String
                    }
                    AccountDetail = big_7[row] as String
                    return big_7[row] as String
                }
            case 8:
                if big_8.count <= row {
                    self.text = big_8[0] as String
                    return big_8[0] as String
                }else {
                    if big_8[row] as String == "-" {
                        if identifier == "identifier_category" {
                            self.text = "選択してください"
                        }
                        AccountDetail = "選択してください"
                    }else {
                        if identifier == "identifier_category" {
                            self.text = big_8[row] as String
                        }
                        AccountDetail = big_8[row] as String
                    }
                    return big_8[row] as String
                }
            case 9:
                if big_9.count <= row {
                    self.text = big_9[0] as String
                    return big_9[0] as String
                }else {
                    if identifier == "identifier_category" {
                        self.text = big_9[row] as String
                    }
                    return big_9[row] as String
                }
            case 10:
                if big_10.count <= row {
                    self.text = big_10[0] as String
                    return big_10[0] as String
                }else {
                    if identifier == "identifier_category" {
                        self.text = big_10[row] as String
                    }
                    AccountDetail = big_10[row] as String
                    return big_10[row] as String
                }
            case 11:
                if big_11.count <= row {
                    self.text = big_11[0] as String
                    return big_11[0] as String
                }else {
                    if big_11[row] as String == "-" {
                        if identifier == "identifier_category" {
                            self.text = "選択してください"
                        }
                        AccountDetail = "選択してください"
                    }else {
                        if identifier == "identifier_category" {
                            self.text = big_11[row] as String
                        }
                        AccountDetail = big_11[row] as String
                    }
                    return big_11[row] as String // エラー　2020/10/15
                }
            default:
                self.text = "選択してください" // 中区分
                return "-"
            }
        }
//        self.text = "選択してください" // 小区分
//        return "-"
    }
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Segueを場合分け　初期値
        if component == 0 {
            if identifier == "identifier_category_big" {
                self.text = Rank0[row] as String
            }
            self.selectedRank0 = row
        }else {//if identifier == "identifier_category" {
//        // ドラムロールの2列目か？
//        if component == 1 {
            switch pickerView.selectedRow(inComponent: 0){//component0 {
            case 0:
                // ドラムロールを2列同時に回転させた場合の対策
                if big_0.count <= row {
                    self.text = big_0[0] as String
                    self.selectedRank1 = 0
                    break
                }
                if identifier == "identifier_category" {
                    self.text = big_0[row] as String
                }
                self.selectedRank1 = row
                break
            case 1:
                if big_1.count <= row {
                    self.text = big_1[0] as String
                    self.selectedRank1 = 0
                    break
                }
                if identifier == "identifier_category" {
                    self.text = big_1[row] as String
                }
                self.selectedRank1 = row
                break
            case 2:
                if big_2.count <= row {
                    self.text = big_2[0] as String
                    self.selectedRank1 = 0
                    break
                }
                if identifier == "identifier_category" {
                    self.text = big_2[row] as String
                }
                self.selectedRank1 = row
                break
            case 3:
                if big_3.count <= row {
                    self.text = big_3[0] as String
                    self.selectedRank1 = 0
                    break
                }
                if identifier == "identifier_category" {
                    self.text = big_3[row] as String
                }
                self.selectedRank1 = row
                break
            case 4:
                if big_4.count <= row {
                    self.text = big_4[0] as String
                    self.selectedRank1 = 0
                    break
                }
                if identifier == "identifier_category" {
                    self.text = big_4[row] as String
                }
                self.selectedRank1 = row
                break
            case 5:
                if big_5.count <= row {
                    self.text = big_5[0] as String
                    self.selectedRank1 = 0
                    break
                }
                if identifier == "identifier_category" {
                    self.text = big_5[row] as String
                }
                self.selectedRank1 = row
                break
            case 6:
                if big_6.count <= row {
                    self.text = big_6[0] as String
                    self.selectedRank1 = 0
                    break
                }
                if identifier == "identifier_category" {
                    self.text = big_6[row] as String
                }
                self.selectedRank1 = row
                break
            case 7:
                if big_7.count <= row {
                    self.text = big_7[0] as String
                    self.selectedRank1 = 0
                    break
                }
                if identifier == "identifier_category" {
                    self.text = big_7[row] as String
                }
                self.selectedRank1 = row
                break
            case 8:
                if big_8.count <= row {
                    self.text = big_8[0] as String
                    self.selectedRank1 = 0
                    break
                }
                if identifier == "identifier_category" {
                    self.text = big_8[row] as String
                }
                self.selectedRank1 = row
                break
            case 9:
                if big_9.count <= row {
                    self.text = big_9[0] as String
                    self.selectedRank1 = 0
                    break
                }
                if identifier == "identifier_category" {
                    self.text = big_9[row] as String
                }
                self.selectedRank1 = row
                break
            case 10:
                if big_10.count <= row {
                    self.text = big_10[0] as String
                    self.selectedRank1 = 0
                    break
                }
                if identifier == "identifier_category" {
                    self.text = big_10[row] as String
                }
                self.selectedRank1 = row
                break
            case 11:
                if big_11.count <= row {
                    self.text = big_11[0] as String
                    self.selectedRank1 = 0
                    break
                }
                if identifier == "identifier_category" {
                    self.text = big_11[row] as String
                }
                self.selectedRank1 = row
                break
            default:
                self.text = "-"
                break
            }
//        }else {
//            self.text = "-"
        }
        //一つ目のcompornentの選択内容に応じて、二つの目のcompornent表示を切り替える
//        pickerView.reloadAllComponents()
        pickerView.reloadComponent(1)
    }
    //Buttonを押下　選択した値を仕訳画面のTextFieldに表示する
    @objc func done() {
        self.endEditing(true)
    }
    
    @objc func cancel() {
        AccountDetail_big = "選択してください"
        AccountDetail = "選択してください"
//        self.textColor = .lightGray
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
