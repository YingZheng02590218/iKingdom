//
//  PickerTextField.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/30.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// ドラムロール　仕訳画面　勘定科目選択
class PickerTextField: UITextField, UIPickerViewDelegate, UIPickerViewDataSource {

    // ドラムロールに表示する勘定科目の文言
    var categories: [String] = Array<String>()
    var big0: [String] = Array<String>()
    var big1: [String] = Array<String>()
    var big2: [String] = Array<String>()
    var big3: [String] = Array<String>()
    var big4: [String] = Array<String>()
    var big5: [String] = Array<String>()
    var big6: [String] = Array<String>()
    var big7: [String] = Array<String>()
    var big8: [String] = Array<String>()
    var big9: [String] = Array<String>()
    var big10: [String] = Array<String>()
    var big11: [String] = Array<String>()

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
    
    func setup(identifier: String) {
        // ピッカー　ドラムロールの項目を初期化
        getSettingsCategoryFromDB()
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        // PickerView のサイズと位置 金額のTextfieldのキーボードの高さに合わせる
        picker.frame = CGRect(
            x: 0,
            y: 0,
            width: (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)!,
            height: (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.height)! / 3
        )
        //        picker.transform = CGAffineTransform(scaleX: 0.5, y: 0.5);
        
        let toolbar = UIToolbar(
            frame: CGRect(
                x: 0,
                y: 0,
                width: (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)!,
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

        self.inputView = picker
        self.inputAccessoryView = toolbar
        
        // 借方勘定科目を選択した後に、貸方勘定科目を選択する際に初期値が前回のものが表示されるので、リロードする
        picker.reloadAllComponents()
    }
    // 設定画面の勘定科目設定で有効を選択した勘定を、勘定科目画面のドラムロールに表示するために、DBから文言を読み込む
    func getSettingsCategoryFromDB() {
        // 勘定科目区分　大区分
        categories = ["流動資産", "固定資産", "繰延資産", "流動負債", "固定負債", "資本", "売上", "売上原価", "販売費及び一般管理費", "営業外損益", "特別損益", "税金"]
        // データベース
        let databaseManager = CategoryListModel()
        for i in 0..<categories.count {
            let objects = databaseManager.getSettingsSwitchingOn(rank0: i) // どのセクションに表示するセルかを判別するため引数で渡す
            //            let items = transferItems(objects: objects) // 区分ごとの勘定科目が入ったArrayリストが返る
            var items: [String] = Array<String>()
            for y in 0..<objects.count {    // 勘定
                items.append(objects[y].category as String) // 配列 Array<Element>型　に要素を追加していく
            }
            transferItems(bigCategory: i, array: items)    // 勘定科目区分ごとに文言を用意する
        }
    }
    // データベースにある設定データを変数に入れ替える
    func transferItems(bigCategory: Int, array: Array<String>) {
        switch bigCategory {
        case 0:
            big0 = array
        case 1:
            big1 = array
        case 2:
            big2 = array
        case 3:
            big3 = array
        case 4:
            big4 = array
        case 5:
            big5 = array
        case 6:
            big6 = array
        case 7:
            big7 = array
        case 8:
            big8 = array
        case 9:
            big9 = array
        case 10:
            big10 = array
        case 11:
            big11 = array
        default:
            // big0 = array
            break
        }
    }
    // UIPickerView
    // UIPickerViewの列の数 コンポーネントの数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    // UIPickerViewの行数、リストの数 コンポーネントの内のデータ
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return categories.count
        } else {
            switch pickerView.selectedRow(inComponent: 0) {
            case 0: // "資産":
                return big0.count
            case 1: // "負債":
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
        if component == 0 {
            return categories[row] as String
        } else {
            switch pickerView.selectedRow(inComponent: 0) {
            case 0:
                // ドラムロールを2列同時に回転させた場合の対策
                if big0.count <= row {
                    self.text = big0[0] as String
                    return big0[0] as String
                } else {
                    print(big0.count)
                    self.text = big0[row] as String // TextFieldに表示
                    return big0[row] as String      // PickerViewに表示
                }
            case 1:
                if big1.count <= row {
                    self.text = big1[0] as String
                    return big1[0] as String
                } else {
                    print(big1.count)
                    self.text = big1[row] as String
                    return big1[row] as String
                }
            case 2:
                if big2.count <= row {
                    self.text = big2[0] as String
                    return big2[0] as String
                } else {
                    print(big2.count)
                    self.text = big2[row] as String
                    return big2[row] as String
                }
            case 3:
                if big3.count <= row {
                    self.text = big3[0] as String
                    return big3[0] as String
                } else {
                    print(big3.count)
                    self.text = big3[row] as String
                    return big3[row] as String  // ドラムロールを早く回すと、ここでエラーが発生する　2020/07/24
                }
            case 4:
                if big4.count <= row {
                    self.text = big4[0] as String
                    return big4[0] as String
                } else {
                    print(big4.count)
                    self.text = big4[row] as String // エラー　2020/08/04
                    return big4[row] as String
                }
            case 5:
                if big5.count <= row {
                    self.text = big5[0] as String
                    return big5[0] as String
                } else {
                    print(big5.count)
                    self.text = big5[row] as String
                    return big5[row] as String
                }
            case 6:
                if big6.count <= row {
                    self.text = big6[0] as String
                    return big6[0] as String
                } else {
                    print(big6.count)
                    self.text = big6[row] as String // エラー　2020/10/30 一度選択して、もう一度選択し直そうとした場合エラー
                    return big6[row] as String
                }
            case 7:
                if big7.count <= row {
                    self.text = big7[0] as String
                    return big7[0] as String
                } else {
                    print(big7.count)
                    self.text = big7[row] as String
                    return big7[row] as String
                }
            case 8:
                if big8.count <= row {
                    self.text = big8[0] as String
                    return big8[0] as String
                } else {
                    print(big8.count)
                    self.text = big8[row] as String
                    return big8[row] as String
                }
            case 9:
                if big9.count <= row {
                    self.text = big9[0] as String
                    return big9[0] as String
                } else {
                    self.text = big9[row] as String
                    return big9[row] as String
                }
            case 10:
                if big10.count <= row {
                    self.text = big10[0] as String
                    return big10[0] as String
                } else {
                    self.text = big10[row] as String
                    return big10[row] as String
                }
            case 11:
                if big11.count <= row {
                    self.text = big11[0] as String
                    return big11[0] as String
                } else {
                    self.text = big11[row] as String // エラー　2020/10/31
                    return big11[row] as String // エラー　2020/10/15
                }
            default:
                return ""
            }
        }
    }
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 文字色
        if component == 0 {
            self.text = categories[row] as String
        } else if component == 1 { // ドラムロールの2列目か？
            switch pickerView.selectedRow(inComponent: 0) {
            case 0:
                // ドラムロールを2列同時に回転させた場合の対策
                if big0.count <= row {
                    self.text = big0[0] as String
                    break
                }
                self.text = big0[row] as String
            case 1:
                if big1.count <= row {
                    self.text = big1[0] as String
                    break
                }
                self.text = big1[row] as String
            case 2:
                if big2.count <= row {
                    self.text = big2[0] as String
                    break
                }
                self.text = big2[row] as String
            case 3:
                if big3.count <= row {
                    self.text = big3[0] as String
                    break
                }
                self.text = big3[row] as String
            case 4:
                if big4.count <= row {
                    self.text = big4[0] as String
                    break
                }
                self.text = big4[row] as String
            case 5:
                if big5.count <= row {
                    self.text = big5[0] as String
                    break
                }
                self.text = big5[row] as String
            case 6:
                if big6.count <= row {
                    self.text = big6[0] as String
                    break
                }
                self.text = big6[row] as String
            case 7:
                if big7.count <= row {
                    self.text = big7[0] as String
                    break
                }
                self.text = big7[row] as String
            case 8:
                if big8.count <= row {
                    self.text = big8[0] as String
                    break
                }
                self.text = big8[row] as String
            case 9:
                if big9.count <= row {
                    self.text = big9[0] as String
                    break
                }
                self.text = big9[row] as String
            case 10:
                if big10.count <= row {
                    self.text = big10[0] as String
                    break
                }
                self.text = big10[row] as String
            case 11:
                if big11.count <= row {
                    self.text = big11[0] as String
                    break
                }
                self.text = big11[row] as String
            default:
                self.text = ""
            }
        }
        // 一つ目のcompornentの選択内容に応じて、二つの目のcompornent表示を切り替える
        pickerView.reloadAllComponents()
    }
    // Buttonを押下　選択した値を仕訳画面のTextFieldに表示する
    @objc func done() {
        self.endEditing(true)
    }
    
    @objc func cancel() {
        self.text = ""
        self.endEditing(true)
    }
}
