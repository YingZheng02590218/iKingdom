//
//  PickerTextField.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/07/30.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit

// 勘定科目選択ピッカー　仕訳画面　
class PickerTextField: UITextField {
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

    // 勘定科目選択ピッカーに表示する勘定科目の文言
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

    let fontSize: UIFont = .systemFont(ofSize: 25)
    var selectedValue: String?
    var isSettingHeight = false
    var currentRowHeight: CGFloat = 0
    // private var selectedRow: Int?
    
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
    
    // MARK: ピッカー

    func setup() {
        // 文字サイズを指定
        self.adjustsFontSizeToFitWidth = true // TextField 文字のサイズを合わせる
        self.minimumFontSize = 11
        
        pickerView.delegate = self
        pickerView.dataSource = self
        // pickerView.showsSelectionIndicator = true
        // PickerView のサイズと位置 金額のTextfieldのキーボードの高さに合わせる
        let bounds = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds
        pickerView.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds?.width ?? 320,
            height: (bounds?.height ?? 320) / 3
        )
        //        picker.transform = CGAffineTransform(scaleX: 0.5, y: 0.5);
        
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
        self.inputAssistantItem.trailingBarButtonGroups.removeAll()

        self.inputView = pickerView
        self.inputAccessoryView = toolbar
        
        // 借方勘定科目を選択した後に、貸方勘定科目を選択する際に初期値が前回のものが表示されるので、リロードする
        // pickerView.reloadAllComponents()
    }
    
    func updateUI() {
        // 勘定科目選択ピッカー　項目を初期化
        getSettingsCategoryFromDB()
    }
    
    func reloadComponent() {
        // 借方勘定科目TextFieldと貸方勘定科目TextFieldを行き来すると、
        // 　row の行数が変わるため。二つの目のcompornent表示を切り替える
        pickerView.reloadComponent(0)
        pickerView.reloadComponent(2)
    }

    func calculateRowHeight(pickerView: UIPickerView) {
        var rowHeight: CGFloat = currentRowHeight
        for value in Rank0.allCases {
            // let text = title(value)
            let text = value.rawValue
            let tempHeight = text.height(withConstrainedWidth: pickerView.frame.width, font: fontSize)
            if tempHeight > rowHeight {
                rowHeight = tempHeight
            }
        }
        // print(rowHeight)
        // print(currentRowHeight)
        currentRowHeight = rowHeight
        isSettingHeight = true
    }

    // MARK: データベース

    // 設定画面の勘定科目設定で有効を選択した勘定を、勘定科目選択ピッカーに表示するために、DBから文言を読み込む
    func getSettingsCategoryFromDB() {
        // データベース
        for i in 0..<Rank0.allCases.count {
            // 取得 大区分、中区分、小区分 スイッチONの勘定科目 個人事業主　（仕訳、総勘定元帳、貸借対照表、損益計算書、精算表、試算表 で使用している）
            let objects = DatabaseManagerSettingsTaxonomyAccount.shared.getDataBaseSettingsTaxonomyAccountInRankValid(rank0: i, rank1: nil)
            // どのセクションに表示するセルかを判別するため引数で渡す
            //　let items = transferItems(objects: objects) // 区分ごとの勘定科目が入ったArrayリストが返る
            var items: [String] = []
            for y in 0..<objects.count {    // 勘定
                items.append(objects[y].category) // 配列 Array<Element>型　に要素を追加していく
            }
            transferItems(bigCategory: i, array: items)    // 勘定科目区分ごとに文言を用意する
        }
    }
    // データベースにある設定データを変数に入れ替える
    func transferItems(bigCategory: Int, array: [String]) {
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

    // MARK: キーボード

    // Buttonを押下　選択した値を仕訳画面のTextFieldに表示する
    @objc
    func done() {
        print("done", self.text ?? "", selectedValue ?? "")
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        self.text = selectedValue
        self.endEditing(true)
    }
    
    @objc
    func cancel() {
        print("cancel", self.text ?? "", selectedValue ?? "")
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        self.text = ""
        self.endEditing(true)
    }
}

extension PickerTextField: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if !isSettingHeight {
            calculateRowHeight(pickerView: pickerView)
        }
        // print(currentRowHeight)
        return currentRowHeight
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return pickerView.bounds.width * 0.45 - 20
        case 1:
            return 60 // iPad Landscapeの場合　上下のrowの文言が重なってしまう対策（60以上）
        default:
            return pickerView.bounds.width * 0.45 - 20
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        //        let label = (view as? UILabel) ?? UILabel(
        //            frame: .init(
        //                origin: .zero,
        //                size: .init(width: pickerView.bounds.width * 0.5 - 10, height: 0)
        //            )
        //        )

        if component == 0 {
            let label = UILabel(
                frame: .init(
                    origin: .zero,
                    size: .init(width: pickerView.bounds.width * 0.45 - 20, height: 0)
                )
            )
            label.font = fontSize
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 1 // 0だと、文字サイズが縮小されない。2行の場合は0とする。
            label.textAlignment = .right
            label.text = Rank0.allCases[row].rawValue
            // label.sizeToFit() // 文言が入り切らない場合に、2行にするために使用。alignmentが効かなくなるため削除。
            label.adjustsFontSizeToFitWidth = true // UIPickerView 文字のサイズを合わせる
            label.minimumScaleFactor = 0.4 // デフォルトは0となる。0だと、文字サイズが縮小されない
            // print("1列目", label.frame.origin, label.frame.width)
            // print("1列目", label.text, selectedValue)
            return label
        } else if component == 1 {
            // 隙間
            let label = UILabel(
                frame: .init(
                    origin: .zero,
                    size: .init(width: 0, height: 0)
                )
            )
            label.text = ""
            return label
        } else {
            let label = UILabel(
                frame: .init(
                    origin: .zero,
                    size: .init(width: pickerView.bounds.width * 0.45 - 20, height: 0)
                )
            )
            label.font = fontSize
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 1 // 0だと、文字サイズが縮小されない。2行の場合は0とする。
            label.textAlignment = .left
            switch pickerView.selectedRow(inComponent: 0) {
            case 0:
                // 大区分に勘定科目がない場合
                if big0.isEmpty {
                    label.text = ""
                    break
                }
                // 勘定科目選択ピッカーを2列同時に回転させた場合の対策
                if big0.count <= row {
                    label.text = ""
                    break
                }
                // 通常
                label.text = big0[row]
                self.selectedValue = big0[row]
            case 1:
                if big1.isEmpty {
                    label.text = ""
                    break
                }
                if big1.count <= row {
                    label.text = ""
                    break
                }
                label.text = big1[row]
                self.selectedValue = big1[row]
            case 2:
                if big2.isEmpty {
                    label.text = ""
                    break
                }
                if big2.count <= row {
                    label.text = ""
                    break
                }
                label.text = big2[row]
                self.selectedValue = big2[row]
            case 3:
                if big3.isEmpty {
                    label.text = ""
                    break
                }
                if big3.count <= row {
                    label.text = ""
                    break
                }
                label.text = big3[row]
                self.selectedValue = big3[row]
            case 4:
                if big4.isEmpty {
                    label.text = ""
                    break
                }
                if big4.count <= row {
                    label.text = ""
                    break
                }
                label.text = big4[row]
                self.selectedValue = big4[row]
            case 5:
                if big5.isEmpty {
                    label.text = ""
                    break
                }
                if big5.count <= row {
                    label.text = ""
                    break
                }
                label.text = big5[row]
                self.selectedValue = big5[row]
            case 6:
                if big6.isEmpty {
                    label.text = ""
                    break
                }
                if big6.count <= row {
                    label.text = ""
                    break
                }
                label.text = big6[row]
                self.selectedValue = big6[row]
            case 7:
                if big7.isEmpty {
                    label.text = ""
                    break
                }
                if big7.count <= row {
                    label.text = ""
                    break
                }
                label.text = big7[row]
                self.selectedValue = big7[row]
            case 8:
                if big8.isEmpty {
                    label.text = ""
                    break
                }
                if big8.count <= row {
                    label.text = ""
                    break
                }
                label.text = big8[row]
                self.selectedValue = big8[row]
            case 9:
                if big9.isEmpty {
                    label.text = ""
                    break
                }
                if big9.count <= row {
                    label.text = ""
                    break
                }
                label.text = big9[row]
                self.selectedValue = big9[row]
            case 10:
                if big10.isEmpty {
                    label.text = ""
                    break
                }
                if big10.count <= row {
                    label.text = ""
                    break
                }
                label.text = big10[row]
                self.selectedValue = big10[row]
            case 11:
                if big11.isEmpty {
                    label.text = ""
                    break
                }
                if big11.count <= row {
                    label.text = ""
                    break
                }
                label.text = big11[row]
                self.selectedValue = big11[row]
            default:
                label.text = ""
            }
            // label.sizeToFit() // 文言が入り切らない場合に、2行にするために使用。alignmentが効かなくなるため削除。
            label.adjustsFontSizeToFitWidth = true // UIPickerView 文字のサイズを合わせる
            label.minimumScaleFactor = 0.3 // デフォルトは0となる。0だと、文字サイズが縮小されない
            // print("2列目", label.frame.origin, label.frame.width)
            // print("2列目", label.text, selectedValue)
            return label
        }
    }
}

extension PickerTextField: UIPickerViewDataSource {
    // UIPickerViewの列の数 コンポーネントの数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // 1列目、2列目、3列目
        3
    }
    // UIPickerViewの行数、リストの数 コンポーネントの内のデータ
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return Rank0.allCases.count
        } else if component == 1 {
            // 隙間
            return 1
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
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            // 一つ目のcompornentの選択内容に応じて、二つの目のcompornent表示を切り替える
            pickerView.reloadComponent(2)
        } else if component == 2 {
            switch pickerView.selectedRow(inComponent: 0) {
            case 0:
                // 大区分に勘定科目がない場合
                if big0.isEmpty {
                    self.selectedValue = ""
                    break
                }
                // 勘定科目選択ピッカーを2列同時に回転させた場合の対策
                if big0.count <= row {
                    self.selectedValue = big0[0]
                    break
                }
                self.selectedValue = big0[row]
            case 1:
                if big1.isEmpty {
                    self.selectedValue = ""
                    break
                }
                if big1.count <= row {
                    self.selectedValue = big1[0]
                    break
                }
                self.selectedValue = big1[row]
            case 2:
                if big2.isEmpty {
                    self.selectedValue = ""
                    break
                }
                if big2.count <= row {
                    self.selectedValue = big2[0]
                    break
                }
                self.selectedValue = big2[row]
            case 3:
                if big3.isEmpty {
                    self.selectedValue = ""
                    break
                }
                if big3.count <= row {
                    self.selectedValue = big3[0]
                    break
                }
                self.selectedValue = big3[row]
            case 4:
                if big4.isEmpty {
                    self.selectedValue = ""
                    break
                }
                if big4.count <= row {
                    self.selectedValue = big4[0]
                    break
                }
                self.selectedValue = big4[row]
            case 5:
                if big5.isEmpty {
                    self.selectedValue = ""
                    break
                }
                if big5.count <= row {
                    self.selectedValue = big5[0]
                    break
                }
                self.selectedValue = big5[row]
            case 6:
                if big6.isEmpty {
                    self.selectedValue = ""
                    break
                }
                if big6.count <= row {
                    self.selectedValue = big6[0]
                    break
                }
                self.selectedValue = big6[row]
            case 7:
                if big7.isEmpty {
                    self.selectedValue = ""
                    break
                }
                if big7.count <= row {
                    self.selectedValue = big7[0]
                    break
                }
                self.selectedValue = big7[row]
            case 8:
                if big8.isEmpty {
                    self.selectedValue = ""
                    break
                }
                if big8.count <= row {
                    self.selectedValue = big8[0]
                    break
                }
                self.selectedValue = big8[row]
            case 9:
                if big9.isEmpty {
                    self.selectedValue = ""
                    break
                }
                if big9.count <= row {
                    self.selectedValue = big9[0]
                    break
                }
                self.selectedValue = big9[row]
            case 10:
                if big10.isEmpty {
                    self.selectedValue = ""
                    break
                }
                if big10.count <= row {
                    self.selectedValue = big10[0]
                    break
                }
                self.selectedValue = big10[row]
            case 11:
                if big11.isEmpty {
                    self.selectedValue = ""
                    break
                }
                if big11.count <= row {
                    self.selectedValue = big11[0]
                    break
                }
                self.selectedValue = big11[row]
            default:
                self.selectedValue = ""
            }
            // 借方勘定科目TextFieldと貸方勘定科目TextFieldを行き来すると、
            // 　row の行数が変わるため。二つの目のcompornent表示を切り替える
            pickerView.reloadComponent(2)
        }
    }
}
