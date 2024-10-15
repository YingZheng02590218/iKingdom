//
//  AccountDetailPickerTextField.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/10/18.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// ドラムロール　勘定科目区分選択　勘定科目詳細画面　新規追加
class AccountDetailPickerTextField: UITextField, UIPickerViewDelegate, UIPickerViewDataSource {
    // フィードバック
    private let feedbackGeneratorMedium: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()

    let pickerView = UIPickerView()

    // 選択された項目
    var selectedRank0 = "" // 大区分　row
    var selectedRank1 = "" // 中区分　row
    var accountDetailBig = "" // 大区分　名称
    var accountDetail = "" // 中区分　名称
    // ドラムロールに表示する勘定科目の文言
    var big0: [String] = []
    var big1: [String] = []
    var big2: [String] = []
    var big3: [String] = []
    var big4: [String] = []
    var big5: [String] = []
    var big6: [String] = []
    var big7: [String] = []
    var big8: [String] = []
    var big9: [String] = []
    var big10: [String] = []
    var big11: [String] = []

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // 入力カーソル非表示
    override func caretRect(for position: UITextPosition) -> CGRect {
        CGRect.zero
    }
    // 範囲選択カーソル非表示
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }
    // コピー・ペースト・選択等のメニュー非表示
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }
    
    var identifier = ""
    var component0 = 0

    func setup(identifier: String) {
        // アイディを記憶
        self.identifier = identifier
        // Segueを場合分け　初期値
        if identifier == "identifier_category_big" {
            self.tag = 0
        } else if identifier == "identifier_category" {
            self.tag = 1
        }
        // ピッカー　ドラムロールの項目を初期化
        setSettingsCategory()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        // PickerView のサイズと位置 金額のTextfieldのキーボードの高さに合わせる
        let bounds = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds
        pickerView.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds?.width ?? 320,
            height: (bounds?.height ?? 320) / 3
        )
        
        let toolbar = UIToolbar(
            frame: CGRect(
                x: 0,
                y: 0,
                width: bounds?.width ?? 320,
                height: 44
            )
        )
        toolbar.isTranslucent = true
        toolbar.barStyle = .default
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        toolbar.setItems([cancelItem, flexSpaceItem, doneItem], animated: true)
        // previous, next, paste ボタンを消す
        self.inputAssistantItem.leadingBarButtonGroups.removeAll()

        self.inputView = pickerView
        self.inputAccessoryView = toolbar
        
        // 借方勘定科目を選択した後に、貸方勘定科目を選択する際に初期値が前回のものが表示されるので、リロードする
        pickerView.reloadAllComponents()
    }
    // 設定画面の勘定科目設定で有効を選択した勘定を、勘定科目画面のドラムロールに表示するために、DBから文言を読み込む
    func setSettingsCategory() {
        // 勘定科目区分　大区分
        for i in 0..<Rank0.allCases.count {
            transferItems(rank1: i)    // 勘定科目区分ごとに文言を用意する
        }
    }
    // 設定データを変数に入れ替える 中区分
    func transferItems(rank1: Int) {
        switch rank1 {
        case 0:
            big0 = ["当座資産", "棚卸資産", "その他の流動資産"]
        case 1:
            big1 = ["有形固定資産", "無形固定資産", "投資その他の資産"]
        case 2:
            big2 = ["繰延資産"]
        case 3:
            big3 = ["仕入債務", "その他の流動負債"]
        case 4:
            big4 = ["長期債務"]
        case 5:
            big5 = ["株主資本", "評価・換算差額等", "新株予約権", "非支配株主持分"]
        case 6:
            big6 = ["-"]
        case 7:
            big7 = ["売上原価", "製造原価"]
        case 8:
            big8 = ["-"]
        case 9:
            big9 = ["営業外収益", "営業外費用"]
        case 10:
            big10 = ["特別利益", "特別損失"]
        case 11:
            big11 = ["-"]
        default:
            // big0 = array
            break
        }
    }
// UIPickerView
    // UIPickerViewの列の数 コンポーネントの数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        print("AccountDetailPickerTextField numberOfComponents")
        return 2
    }
    // UIPickerViewの行数、リストの数 コンポーネントの内のデータ
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("AccountDetailPickerTextField numberOfRowsInComponent", component)
        if component == 0 {
            return Rank0.allCases.count
        } else {
            switch pickerView.selectedRow(inComponent: 0) {
            case 0:
                return big0.count
            case 1:
                return big1.count
            case 2:
                return big2.count
            case 3:
                return big3.count
            case 4:
                return big4.count
            case 5:
                return big5.count
            case 6:
                return big6.count
            case 7:
                return big7.count
            case 8:
                return big8.count
            case 9:
                return big9.count
            case 10:
                return big10.count
            case 11:
                return big11.count
            default:
                return 0
            }
        }
    }
    // UIPickerViewの最初の表示 ホイールに表示する選択肢のタイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("AccountDetailPickerTextField titleForRow", component, row)
// 1列目　初期値
        if component == 0 {
            if identifier == "identifier_category_big" {
                self.text = Rank0.allCases[row].rawValue as String // TextFieldに表示
            }
            self.accountDetailBig = Rank0.allCases[row].rawValue as String
            self.selectedRank0 = String(row)
            return Rank0.allCases[row].rawValue as String
// 2列目　初期値
        } else {
            switch pickerView.selectedRow(inComponent: 0) {
            case 0:
                // ドラムロールを2列同時に回転させた場合の対策
                if big0.count <= row {
                    if identifier == "identifier_category" {
                        self.text = big0[big0.count - 1] as String
                    }
                    self.selectedRank1 = "2"
                    return ""
                } else {
                    if identifier == "identifier_category" {
                        self.text = big0[row] as String // TextFieldに表示
                    }
                    self.selectedRank1 = String(row)
                    self.accountDetail = big0[row] as String
                    return big0[row] as String      // PickerViewに表示
                }
            case 1:
                if big1.count <= row {
                    if identifier == "identifier_category" {
                        self.text = big1[big1.count - 1] as String
                    }
                    self.selectedRank1 = "5"
                    return ""
                } else {
                    if identifier == "identifier_category" {
                        self.text = big1[row] as String
                    }
                    self.selectedRank1 = String(row + 3)
                    self.accountDetail = big1[row] as String
                    return big1[row] as String
                }
            case 2:
                if big2.count <= row {
                    if identifier == "identifier_category" {
                        self.text = big2[big2.count - 1] as String
                    }
                    self.selectedRank1 = "6"
                    return ""
                } else {
                    if identifier == "identifier_category" {
                        self.text = big2[row] as String
                    }
                    self.selectedRank1 = String(row + 6)
                    self.accountDetail = big2[row] as String
                    return big2[row] as String
                }
            case 3:
                if big3.count <= row {
                    if identifier == "identifier_category" {
                        self.text = big3[big3.count - 1] as String
                    }

                    self.selectedRank1 = "8"
                    return ""
                } else {
                    if identifier == "identifier_category" {
                        self.text = big3[row] as String
                    }
                    self.accountDetail = big3[row] as String
                    self.selectedRank1 = String(row + 7)
                    return big3[row] as String  // ドラムロールを早く回すと、ここでエラーが発生する　2020/07/24
                }
            case 4:
                if big4.count <= row {
                    if identifier == "identifier_category" {
                        self.text = big4[big4.count - 1] as String
                    }
                    self.selectedRank1 = "9"
                    return ""
                } else {
                    if identifier == "identifier_category" {
                        self.text = big4[row] as String // エラー　2020/08/04
                    }
                    self.accountDetail = big4[row] as String
                    self.selectedRank1 = String(row + 9)
                    return big4[row] as String
                }
            case 5:
                if big5.count <= row {
                    if identifier == "identifier_category" {
                        self.text = big5[big5.count - 1] as String
                    }
                    self.selectedRank1 = "19"
                    return ""
                } else {
                    if identifier == "identifier_category" {
                        self.text = big5[row] as String
                    }
                    self.accountDetail = big5[row] as String
                    if row == 3 { // 被支配株主持分の場合 「19」なので対応が必要
                        self.selectedRank1 = "19"
                    } else {
                        self.selectedRank1 = String(row + 10)
                    }
                    return big5[row] as String
                }
            case 6:
                if big6.count <= row {
                    if identifier == "identifier_category" {
                        self.text = big6[big6.count - 1] as String
                    }
                    self.selectedRank1 = ""
                    return ""
                } else {
                    if big6[row] as String == "-" {
                        if identifier == "identifier_category" {
                            self.text = "-"
                        }
                        self.accountDetail = "-"
                    } else {
                        if identifier == "identifier_category" {
                            self.text = big6[row] as String
                        }
                        self.accountDetail = big6[row] as String
                    }
                    self.selectedRank1 = ""
                    return big6[row] as String
                }
            case 7:// 2列目　初期値
                if big7.count <= row {
                    if identifier == "identifier_category" {
                        self.text = big7[big7.count - 1] as String
                    }
                    self.selectedRank1 = "14"
                    return ""
                } else {
                    if identifier == "identifier_category" {
                        self.text = big7[row] as String
                    }
                    self.accountDetail = big7[row] as String
                    self.selectedRank1 = String(row + 13)
                    return big7[row] as String
                }
            case 8:
                if big8.count <= row {
                    if identifier == "identifier_category" {
                        self.text = big8[big8.count - 1] as String
                    }
                    self.selectedRank1 = ""
                    return ""
                } else {
                    if big8[row] as String == "-" {
                        if identifier == "identifier_category" {
                            self.text = "-"
                        }
                        self.accountDetail = "-"
                    } else {
                        if identifier == "identifier_category" {
                            self.text = big8[row] as String
                        }
                        self.accountDetail = big8[row] as String
                    }
                    self.selectedRank1 = ""
                    return big8[row] as String
                }
            case 9:
                if big9.count <= row {
                    if identifier == "identifier_category" {
                        self.text = big9[big9.count - 1] as String
                    }
                    self.selectedRank1 = "16"
                    return ""
                } else {
                    if identifier == "identifier_category" {
                        self.text = big9[row] as String
                    }
                    self.accountDetail = big9[row] as String
                    self.selectedRank1 = String(row + 15)
                    return big9[row] as String
                }
            case 10:
                if big10.count <= row {
                    if identifier == "identifier_category" {
                        self.text = big10[big10.count - 1] as String
                    }
                    self.selectedRank1 = "18"
                    return ""
                } else {
                    if identifier == "identifier_category" {
                        self.text = big10[row] as String
                    }
                    self.accountDetail = big10[row] as String
                    self.selectedRank1 = String(row + 17)
                    return big10[row] as String
                }
            case 11:
                if big11.count <= row {
                    if identifier == "identifier_category" {
                        self.text = big11[big11.count - 1] as String
                    }
                    self.selectedRank1 = ""
                    return ""
                } else {
                    if big11[row] as String == "-" {
                        if identifier == "identifier_category" {
                            self.text = "-"
                        }
                        self.accountDetail = "-"
                    } else {
                        if identifier == "identifier_category" {
                            self.text = big11[row] as String
                        }
                        self.accountDetail = big11[row] as String
                    }
                    self.selectedRank1 = ""
                    return big11[row] as String // エラー　2020/10/15
                }
            default:
                self.text = "" // 中区分
                return "-"
            }
        }
    }
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("AccountDetailPickerTextField didSelectRow", component, row)
        // 一つ目のcompornentの選択内容に応じて、二つの目のcompornent表示を切り替える
        pickerView.reloadAllComponents()
//        pickerView.reloadComponent(1)
    }
    // Buttonを押下　選択した値を仕訳画面のTextFieldに表示する
    @objc 
    func done() {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        self.endEditing(true)
    }
    
    @objc 
    func cancel() {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        accountDetailBig = ""
        accountDetail = ""
        self.selectedRank0 = ""
        self.selectedRank1 = ""
        self.endEditing(true)
    }
}
