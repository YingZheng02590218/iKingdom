//
//  JournalEntryViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/23.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応
import UIKit

// 仕訳クラス
class JournalEntryViewController: UIViewController {
    
    // MARK: - var let
    
    private var rewardedAd: GADRewardedAd?
    /// Text that indicates current coin count.
    @IBOutlet var coinCountLabel: UILabel!
    
    @IBOutlet var backgroundView: UIView!
    // タイトルラベル
    @IBOutlet var labelTitle: UILabel!
    // 仕訳/決算整理仕訳　切り替え
    @IBOutlet var segmentedControl: UISegmentedControl!
    // 単一仕訳/複合仕訳　切り替え
    @IBOutlet var compoundJournalEntrySegmentedControl: UISegmentedControl!
    
    // MARK: よく使う仕訳
    // よく使う仕訳　エリア
    @IBOutlet var journalEntryTemplateView: UIView!
    // よく使う仕訳　カルーセル
    @IBOutlet private var tableView: UITableView! {
        didSet {
            // 仕訳テンプレート画面では使用しない
            if let tableView = tableView {
                tableView.delegate = self
                tableView.dataSource = self
                tableView.register(UINib(nibName: String(describing: CarouselTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: CarouselTableViewCell.self))
                tableView.separatorColor = .accentColor
            }
        }
    }
    
    // MARK: デイトピッカー
    // デイトピッカー　日付
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet private var datePickerView: EMTNeumorphicView!
    @IBOutlet private var maskDatePickerButton: UIButton!
    // デイトピッカーのマスク
    var isMaskedDatePicker = false // マスクフラグ
    
    // MARK: ボタン
    // ボタン　アウトレットコレクション
    @IBOutlet var arrayHugo: [EMTNeumorphicButton]!
    @IBOutlet var buttonRight: EMTNeumorphicButton!
    @IBOutlet private var buttonLeft: EMTNeumorphicButton!
    @IBOutlet var inputButton: EMTNeumorphicButton!
    @IBOutlet private var cancelButton: EMTNeumorphicButton!
    // 仕訳画面表示ボタン
    @IBOutlet private var addButton: UIButton!
    
    // MARK: テキストフィールド
    @IBOutlet var textFieldView: EMTNeumorphicView!
    // 勘定科目エリア　余白
    @IBOutlet var spaceView: UIView!
    // テキストフィールド　勘定科目、金額　単一仕訳
    @IBOutlet var textFieldCategoryDebit: PickerTextField! {
        didSet {
            textFieldCategoryDebit.delegate = self
            textFieldCategoryDebit.textAlignment = .left
            textFieldCategoryDebit.layer.borderWidth = 0.5
            textFieldCategoryDebit.setup()
            textFieldCategoryDebit.updateUI()
        }
    }
    @IBOutlet var textFieldAmountDebit: UITextField! {
        didSet {
            textFieldAmountDebit.delegate = self
            textFieldAmountDebit.textAlignment = .left
            textFieldAmountDebit.layer.borderWidth = 0.5
        }
    }
    @IBOutlet var textFieldCategoryCredit: PickerTextField! {
        didSet {
            textFieldCategoryCredit.delegate = self
            textFieldCategoryCredit.textAlignment = .right
            textFieldCategoryCredit.layer.borderWidth = 0.5
            textFieldCategoryCredit.setup()
            textFieldCategoryCredit.updateUI()
        }
    }
    @IBOutlet var textFieldAmountCredit: UITextField! {
        didSet {
            textFieldAmountCredit.delegate = self
            textFieldAmountCredit.textAlignment = .right
            textFieldAmountCredit.layer.borderWidth = 0.5
        }
    }
    // テキストフィールド　勘定科目、金額　複合仕訳
    @IBOutlet var viewDebit1: UIView!
    @IBOutlet var textFieldCategoryDebit1: PickerTextField! {
        didSet {
            textFieldCategoryDebit1.delegate = self
            textFieldCategoryDebit1.textAlignment = .left
            textFieldCategoryDebit1.layer.borderWidth = 0.5
            textFieldCategoryDebit1.setup()
            textFieldCategoryDebit1.updateUI()
        }
    }
    @IBOutlet var textFieldAmountDebit1: UITextField! {
        didSet {
            textFieldAmountDebit1.delegate = self
            textFieldAmountDebit1.textAlignment = .left
            textFieldAmountDebit1.layer.borderWidth = 0.5
        }
    }
    @IBOutlet var viewCredit1: UIView!
    @IBOutlet var textFieldCategoryCredit1: PickerTextField! {
        didSet {
            textFieldCategoryCredit1.delegate = self
            textFieldCategoryCredit1.textAlignment = .right
            textFieldCategoryCredit1.layer.borderWidth = 0.5
            textFieldCategoryCredit1.setup()
            textFieldCategoryCredit1.updateUI()
        }
    }
    @IBOutlet var textFieldAmountCredit1: UITextField! {
        didSet {
            textFieldAmountCredit1.delegate = self
            textFieldAmountCredit1.textAlignment = .right
            textFieldAmountCredit1.layer.borderWidth = 0.5
        }
    }
    
    @IBOutlet var viewDebit2: UIView!
    @IBOutlet var textFieldCategoryDebit2: PickerTextField! {
        didSet {
            textFieldCategoryDebit2.delegate = self
            textFieldCategoryDebit2.textAlignment = .left
            textFieldCategoryDebit2.layer.borderWidth = 0.5
            textFieldCategoryDebit2.setup()
            textFieldCategoryDebit2.updateUI()
        }
    }
    @IBOutlet var textFieldAmountDebit2: UITextField! {
        didSet {
            textFieldAmountDebit2.delegate = self
            textFieldAmountDebit2.textAlignment = .left
            textFieldAmountDebit2.layer.borderWidth = 0.5
        }
    }
    @IBOutlet var viewCredit2: UIView!
    @IBOutlet var textFieldCategoryCredit2: PickerTextField! {
        didSet {
            textFieldCategoryCredit2.delegate = self
            textFieldCategoryCredit2.textAlignment = .right
            textFieldCategoryCredit2.layer.borderWidth = 0.5
            textFieldCategoryCredit2.setup()
            textFieldCategoryCredit2.updateUI()
        }
    }
    @IBOutlet var textFieldAmountCredit2: UITextField! {
        didSet {
            textFieldAmountCredit2.delegate = self
            textFieldAmountCredit2.textAlignment = .right
            textFieldAmountCredit2.layer.borderWidth = 0.5
        }
    }
    
    @IBOutlet var viewDebit3: UIView!
    @IBOutlet var textFieldCategoryDebit3: PickerTextField! {
        didSet {
            textFieldCategoryDebit3.delegate = self
            textFieldCategoryDebit3.textAlignment = .left
            textFieldCategoryDebit3.layer.borderWidth = 0.5
            textFieldCategoryDebit3.setup()
            textFieldCategoryDebit3.updateUI()
        }
    }
    @IBOutlet var textFieldAmountDebit3: UITextField! {
        didSet {
            textFieldAmountDebit3.delegate = self
            textFieldAmountDebit3.textAlignment = .left
            textFieldAmountDebit3.layer.borderWidth = 0.5
        }
    }
    @IBOutlet var viewCredit3: UIView!
    @IBOutlet var textFieldCategoryCredit3: PickerTextField! {
        didSet {
            textFieldCategoryCredit3.delegate = self
            textFieldCategoryCredit3.textAlignment = .right
            textFieldCategoryCredit3.layer.borderWidth = 0.5
            textFieldCategoryCredit3.setup()
            textFieldCategoryCredit3.updateUI()
        }
    }
    @IBOutlet var textFieldAmountCredit3: UITextField! {
        didSet {
            textFieldAmountCredit3.delegate = self
            textFieldAmountCredit3.textAlignment = .right
            textFieldAmountCredit3.layer.borderWidth = 0.5
        }
    }
    
    @IBOutlet var viewDebit4: UIView!
    @IBOutlet var textFieldCategoryDebit4: PickerTextField! {
        didSet {
            textFieldCategoryDebit4.delegate = self
            textFieldCategoryDebit4.textAlignment = .left
            textFieldCategoryDebit4.layer.borderWidth = 0.5
            textFieldCategoryDebit4.setup()
            textFieldCategoryDebit4.updateUI()
        }
    }
    @IBOutlet var textFieldAmountDebit4: UITextField! {
        didSet {
            textFieldAmountDebit4.delegate = self
            textFieldAmountDebit4.textAlignment = .left
            textFieldAmountDebit4.layer.borderWidth = 0.5
        }
    }
    @IBOutlet var viewCredit4: UIView!
    @IBOutlet var textFieldCategoryCredit4: PickerTextField! {
        didSet {
            textFieldCategoryCredit4.delegate = self
            textFieldCategoryCredit4.textAlignment = .right
            textFieldCategoryCredit4.layer.borderWidth = 0.5
            textFieldCategoryCredit4.setup()
            textFieldCategoryCredit4.updateUI()
        }
    }
    @IBOutlet var textFieldAmountCredit4: UITextField! {
        didSet {
            textFieldAmountCredit4.delegate = self
            textFieldAmountCredit4.textAlignment = .right
            textFieldAmountCredit4.layer.borderWidth = 0.5
        }
    }
    // テキストフィールド　小書き
    @IBOutlet var textFieldSmallWritting: UITextField!
    @IBOutlet var smallWrittingTextFieldView: EMTNeumorphicView!
    // 小書き　カウンタ
    @IBOutlet var smallWritingCounterLabel: UILabel!
    
    // MARK: - 複合仕訳
    
    // MARK: 金額
    // 借方
    var debitAmountTotal: Int {
        var total = 0
        if let debitAmount = debit.amount {
            total += debitAmount
        }
        for i in debitElements {
            total += i.amount ?? 0
        }
        return total
    }
    // 貸方
    var creditAmountTotal: Int {
        var total = 0
        if let creditAmount = credit.amount {
            total += creditAmount
        }
        for i in creditElements {
            total += i.amount ?? 0
        }
        return total
    }
    
    // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
    func compareDebitAndCredit() {
        // 借方
        guard let debitAmount = debit.amount, debitAmount != 0 else {
            return
        }
        // 貸方
        guard let creditAmount = credit.amount, creditAmount != 0 else {
            return
        }
        // 増設する勘定科目へ
        if debitAmountTotal > creditAmountTotal {
            // 相手勘定科目が1件の場合
            if debitElements.isEmpty {
                // 貸方
                let creditElements = self.creditElements
                if creditElements.filter({ $0.amount == nil || $0.amount == 0 }).isEmpty {
                    DispatchQueue.main.async {
                        // 貸方科目へ
                        if self.creditElements.count < 4 {
                            self.creditElements.append(AccountTitleAmount())
                        }
                    }
                }
            } else {
                // 借方0と貸方0の金額の大きさが逆転した場合、取引要素1〜4をリセットする
                if debitAmount > creditAmount {
                    debitElements = []
                    DispatchQueue.main.async {
                        // 貸方科目へ
                        if self.creditElements.count < 4 {
                            self.creditElements.append(AccountTitleAmount())
                        }
                    }
                }
            }
        } else if debitAmountTotal < creditAmountTotal {
            // 相手勘定科目が1件の場合
            if creditElements.isEmpty {
                // 借方
                let debitElements = self.debitElements
                if debitElements.filter({ $0.amount == nil || $0.amount == 0 }).isEmpty {
                    DispatchQueue.main.async {
                        // 借方科目へ
                        if self.debitElements.count < 4 {
                            self.debitElements.append(AccountTitleAmount())
                        }
                    }
                }
            } else {
                // 借方0と貸方0の金額の大きさが逆転した場合、取引要素1〜4をリセットする
                if debitAmount < creditAmount {
                    creditElements = []
                    DispatchQueue.main.async {
                        // 借方科目へ
                        if self.debitElements.count < 4 {
                            self.debitElements.append(AccountTitleAmount())
                        }
                    }
                }
            }
        } else {
            // 貸借一致
            // 相手勘定科目が1件の場合
            if creditElements.isEmpty {
                DispatchQueue.main.async {
                    // 借方
                    var debitElements = self.debitElements
                    debitElements.removeAll(where: { $0.amount == nil || $0.amount == 0 })
                    self.debitElements = debitElements
                }
            }
            // 相手勘定科目が1件の場合
            if debitElements.isEmpty {
                DispatchQueue.main.async {
                    // 貸方
                    var creditElements = self.creditElements
                    creditElements.removeAll(where: { $0.amount == nil || $0.amount == 0 })
                    self.creditElements = creditElements
                }
            }
            
            if smallWritting == nil {
                // 小書きへ
                textFieldSmallWritting.becomeFirstResponder()
            }
        }
    }
    
    // 借方0〜4、貸方0〜4、貸借の科目を比較する　同じ勘定科目の場合は赤い枠線を表示させる　未入力は表示させない
    func compareCategoryDebitAndCredit() {
        // 存在確認　同じ勘定科目名が存在するかどうかを確認する
        let allDebitElements: [AccountTitleAmount] = [debit] + debitElements
        print("借方", allDebitElements)
        // 存在確認　同じ勘定科目名が存在するかどうかを確認する
        let allCreditElements: [AccountTitleAmount] = [credit] + creditElements
        print("貸方", allCreditElements)
        
        if allDebitElements.filter({ $0.title == debit.title }).count > 1 ||
            !allCreditElements.filter({ $0.title == debit.title }).isEmpty {
            // テキストフィールドの枠線を赤色とする。
            textFieldCategoryDebit.layer.borderColor = UIColor.red.cgColor
            textFieldCategoryDebit.layer.borderWidth = 1.0
            textFieldCategoryDebit.layer.cornerRadius = 5
        } else {
            // テキストフィールドの枠線を非表示とする。
            textFieldCategoryDebit.layer.borderColor = UIColor.lightGray.cgColor
            textFieldCategoryDebit.layer.borderWidth = 0.0
        }
        if let textFieldCategoryDebit1 = textFieldCategoryDebit1 {
            if allDebitElements.filter({ $0.title == debitElements[safe: 0]?.title }).count > 1 ||
                !allCreditElements.filter({ $0.title == debitElements[safe: 0]?.title }).isEmpty {
                // テキストフィールドの枠線を赤色とする。
                textFieldCategoryDebit1.layer.borderColor = UIColor.red.cgColor
                textFieldCategoryDebit1.layer.borderWidth = 1.0
                textFieldCategoryDebit1.layer.cornerRadius = 5
            } else {
                // テキストフィールドの枠線を非表示とする。
                textFieldCategoryDebit1.layer.borderColor = UIColor.lightGray.cgColor
                textFieldCategoryDebit1.layer.borderWidth = 0.0
            }
        }
        if let textFieldCategoryDebit2 = textFieldCategoryDebit2 {
            if allDebitElements.filter({ $0.title == debitElements[safe: 1]?.title }).count > 1 ||
                !allCreditElements.filter({ $0.title == debitElements[safe: 1]?.title }).isEmpty {
                // テキストフィールドの枠線を赤色とする。
                textFieldCategoryDebit2.layer.borderColor = UIColor.red.cgColor
                textFieldCategoryDebit2.layer.borderWidth = 1.0
                textFieldCategoryDebit2.layer.cornerRadius = 5
            } else {
                // テキストフィールドの枠線を非表示とする。
                textFieldCategoryDebit2.layer.borderColor = UIColor.lightGray.cgColor
                textFieldCategoryDebit2.layer.borderWidth = 0.0
            }
        }
        if let textFieldCategoryDebit3 = textFieldCategoryDebit3 {
            if allDebitElements.filter({ $0.title == debitElements[safe: 2]?.title }).count > 1 ||
                !allCreditElements.filter({ $0.title == debitElements[safe: 2]?.title }).isEmpty {
                // テキストフィールドの枠線を赤色とする。
                textFieldCategoryDebit3.layer.borderColor = UIColor.red.cgColor
                textFieldCategoryDebit3.layer.borderWidth = 1.0
                textFieldCategoryDebit3.layer.cornerRadius = 5
            } else {
                // テキストフィールドの枠線を非表示とする。
                textFieldCategoryDebit3.layer.borderColor = UIColor.lightGray.cgColor
                textFieldCategoryDebit3.layer.borderWidth = 0.0
            }
        }
        if let textFieldCategoryDebit4 = textFieldCategoryDebit4 {
            if allDebitElements.filter({ $0.title == debitElements[safe: 3]?.title }).count > 1 ||
                !allCreditElements.filter({ $0.title == debitElements[safe: 3]?.title }).isEmpty {
                // テキストフィールドの枠線を赤色とする。
                textFieldCategoryDebit4.layer.borderColor = UIColor.red.cgColor
                textFieldCategoryDebit4.layer.borderWidth = 1.0
                textFieldCategoryDebit4.layer.cornerRadius = 5
            } else {
                // テキストフィールドの枠線を非表示とする。
                textFieldCategoryDebit4.layer.borderColor = UIColor.lightGray.cgColor
                textFieldCategoryDebit4.layer.borderWidth = 0.0
            }
        }
        
        
        if allCreditElements.filter({ $0.title == credit.title }).count > 1 ||
            !allDebitElements.filter({ $0.title == credit.title }).isEmpty {
            // テキストフィールドの枠線を赤色とする。
            textFieldCategoryCredit.layer.borderColor = UIColor.red.cgColor
            textFieldCategoryCredit.layer.borderWidth = 1.0
            textFieldCategoryCredit.layer.cornerRadius = 5
        } else {
            // テキストフィールドの枠線を非表示とする。
            textFieldCategoryCredit.layer.borderColor = UIColor.lightGray.cgColor
            textFieldCategoryCredit.layer.borderWidth = 0.0
        }
        if let textFieldCategoryCredit1 = textFieldCategoryCredit1 {
            if allCreditElements.filter({ $0.title == creditElements[safe: 0]?.title }).count > 1 ||
                !allDebitElements.filter({ $0.title == creditElements[safe: 0]?.title }).isEmpty {
                // テキストフィールドの枠線を赤色とする。
                textFieldCategoryCredit1.layer.borderColor = UIColor.red.cgColor
                textFieldCategoryCredit1.layer.borderWidth = 1.0
                textFieldCategoryCredit1.layer.cornerRadius = 5
            } else {
                // テキストフィールドの枠線を非表示とする。
                textFieldCategoryCredit1.layer.borderColor = UIColor.lightGray.cgColor
                textFieldCategoryCredit1.layer.borderWidth = 0.0
            }
        }
        if let textFieldCategoryCredit2 = textFieldCategoryCredit2 {
            if allCreditElements.filter({ $0.title == creditElements[safe: 1]?.title }).count > 1 ||
                !allDebitElements.filter({ $0.title == creditElements[safe: 1]?.title }).isEmpty  {
                // テキストフィールドの枠線を赤色とする。
                textFieldCategoryCredit2.layer.borderColor = UIColor.red.cgColor
                textFieldCategoryCredit2.layer.borderWidth = 1.0
                textFieldCategoryCredit2.layer.cornerRadius = 5
            } else {
                // テキストフィールドの枠線を非表示とする。
                textFieldCategoryCredit2.layer.borderColor = UIColor.lightGray.cgColor
                textFieldCategoryCredit2.layer.borderWidth = 0.0
            }
        }
        if let textFieldCategoryCredit3 = textFieldCategoryCredit3 {
            if allCreditElements.filter({ $0.title == creditElements[safe: 2]?.title }).count > 1 ||
                !allDebitElements.filter({ $0.title == creditElements[safe: 2]?.title }).isEmpty  {
                // テキストフィールドの枠線を赤色とする。
                textFieldCategoryCredit3.layer.borderColor = UIColor.red.cgColor
                textFieldCategoryCredit3.layer.borderWidth = 1.0
                textFieldCategoryCredit3.layer.cornerRadius = 5
            } else {
                // テキストフィールドの枠線を非表示とする。
                textFieldCategoryCredit3.layer.borderColor = UIColor.lightGray.cgColor
                textFieldCategoryCredit3.layer.borderWidth = 0.0
            }
        }
        if let textFieldCategoryCredit4 = textFieldCategoryCredit4 {
            if allCreditElements.filter({ $0.title == creditElements[safe: 3]?.title }).count > 1 ||
                !allDebitElements.filter({ $0.title == creditElements[safe: 3]?.title }).isEmpty  {
                // テキストフィールドの枠線を赤色とする。
                textFieldCategoryCredit4.layer.borderColor = UIColor.red.cgColor
                textFieldCategoryCredit4.layer.borderWidth = 1.0
                textFieldCategoryCredit4.layer.cornerRadius = 5
            } else {
                // テキストフィールドの枠線を非表示とする。
                textFieldCategoryCredit4.layer.borderColor = UIColor.lightGray.cgColor
                textFieldCategoryCredit4.layer.borderWidth = 0.0
            }
        }
        // 貸借の金額を比較する　不一致の場合は赤い枠線を表示させる
        compareAmountDebitAndCredit()
    }
    
    // 貸借の金額を比較する　不一致の場合は赤い枠線を表示させる
    func compareAmountDebitAndCredit() {
        var debitAmountTotal = 0
        var creditAmountTotal = 0
        // 借方
        guard let debitAmount = debit.amount else {
            return
        }
        debitAmountTotal += debitAmount
        for i in debitElements {
            debitAmountTotal += i.amount ?? 0
        }
        // 貸方
        guard let creditAmount = credit.amount else {
            return
        }
        creditAmountTotal += creditAmount
        for i in creditElements {
            creditAmountTotal += i.amount ?? 0
        }
        // 増設する勘定科目へ
        print(debitAmountTotal, creditAmountTotal)
        if debitAmountTotal == creditAmountTotal {
            // 貸借一致
            // テキストフィールドの枠線を非表示とする。
            textFieldAmountCredit.layer.borderColor = UIColor.lightGray.cgColor
            textFieldAmountCredit.layer.borderWidth = 0.0
            // テキストフィールドの枠線を非表示とする。
            textFieldAmountDebit.layer.borderColor = UIColor.lightGray.cgColor
            textFieldAmountDebit.layer.borderWidth = 0.0
        } else {
            // 相手勘定科目が1件の場合
            if debitElements.isEmpty {
                // 借方科目へ
                // テキストフィールドの枠線を赤色とする。
                textFieldAmountDebit.layer.borderColor = UIColor.red.cgColor
                textFieldAmountDebit.layer.borderWidth = 1.0
                textFieldAmountDebit.layer.cornerRadius = 5
            } else {
                // テキストフィールドの枠線を非表示とする。
                textFieldAmountDebit.layer.borderColor = UIColor.lightGray.cgColor
                textFieldAmountDebit.layer.borderWidth = 0.0
            }
            if creditElements.isEmpty {
                // 貸方科目へ
                // テキストフィールドの枠線を赤色とする。
                textFieldAmountCredit.layer.borderColor = UIColor.red.cgColor
                textFieldAmountCredit.layer.borderWidth = 1.0
                textFieldAmountCredit.layer.cornerRadius = 5
            } else {
                // テキストフィールドの枠線を非表示とする。
                textFieldAmountCredit.layer.borderColor = UIColor.lightGray.cgColor
                textFieldAmountCredit.layer.borderWidth = 0.0
            }
        }
    }
    
    // MARK: 取引要素（勘定科目、金額）借方0〜4、貸方0〜4、小書き
    
    // 借方 取引要素
    var debit = AccountTitleAmount() {
        willSet(value) {
            if value.title == nil && value.amount == nil {
                // 借方
                textFieldCategoryDebit.text = nil
                textFieldAmountDebit.text = nil
            } else {
                // 借方
                textFieldCategoryDebit.text = value.title
                textFieldAmountDebit.text = StringUtility.shared.addComma(string: value.amount?.description ?? "")
                if value.amount != debit.amount {
                    if journalEntryType != .CompoundJournalEntry {
                        DispatchQueue.main.async {
                            // 相手勘定の金額へ同じ金額を設定する
                            self.credit.amount = value.amount
                        }
                    }
                }
                // 仕訳、決算整理仕訳 編集とよう使う仕訳以外
                guard journalEntryType == .CompoundJournalEntry ||
                        journalEntryType == .JournalEntry ||
                        journalEntryType == .AdjustingAndClosingEntry ||
                        journalEntryType == .JournalEntries ||
                        journalEntryType == .AdjustingAndClosingEntries else {
                    return
                }
                // 借方科目　未入力の場合
                guard value.title != nil else {
                    DispatchQueue.main.async {
                        if !(self.textFieldCategoryDebit.isEditing || self.textFieldCategoryCredit.isEditing) {
                            // 借方科目へ
                            self.textFieldCategoryDebit.becomeFirstResponder()
                        }
                    }
                    return
                }
                // 借方科目 入力済みの場合
                guard !(value.amount == nil && value.title != "") else {
                    DispatchQueue.main.async {
                        if !(self.textFieldCategoryDebit.isEditing || self.textFieldCategoryCredit.isEditing) {
                            // 借方金額へ
                            self.textFieldAmountDebit.becomeFirstResponder()
                        }
                    }
                    return
                }
                // 金額が入力された場合
                guard value.amount == debit.amount else {
                    // 貸方へ
                    if credit.title == nil || credit.title == "" {
                        DispatchQueue.main.async {
                            if !(self.textFieldCategoryDebit.isEditing || self.textFieldCategoryCredit.isEditing) {
                                // 貸方科目へ
                                self.textFieldCategoryCredit.becomeFirstResponder()
                            }
                        }
                    } else {
                        // 貸方科目 入力済みの場合
                        if credit.amount == nil && credit.title != "" {
                            DispatchQueue.main.async {
                                if !(self.textFieldCategoryDebit.isEditing || self.textFieldCategoryCredit.isEditing) {
                                    // 貸方金額へ
                                    self.textFieldAmountCredit.becomeFirstResponder()
                                }
                            }
                        } else {
                            // 仕訳タイプ判定
                            if journalEntryType == .CompoundJournalEntry { // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
                                DispatchQueue.main.async {
                                    // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
                                    self.compareDebitAndCredit()
                                }
                            } else if journalEntryType == .JournalEntry ||
                                        journalEntryType == .AdjustingAndClosingEntry ||
                                        journalEntryType == .JournalEntries ||
                                        journalEntryType == .AdjustingAndClosingEntries {
                                if value.title != "" && smallWritting == nil { // 勘定科目ピッカーでキャンセルボタンを押下された場合は、カーソル移動させない
                                    DispatchQueue.main.async {
                                        // 小書きへ
                                        self.textFieldSmallWritting.becomeFirstResponder()
                                    }
                                }
                            }
                        }
                    }
                    return
                }
                // 仕訳タイプ判定
                if journalEntryType == .CompoundJournalEntry { // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
                    // 勘定科目ピッカーのキャンセルボタンをタップされた場合
                    DispatchQueue.main.async {
                        // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
                        self.compareDebitAndCredit()
                    }
                } else if journalEntryType == .JournalEntry ||
                            journalEntryType == .AdjustingAndClosingEntry ||
                            journalEntryType == .JournalEntries ||
                            journalEntryType == .AdjustingAndClosingEntries {
                    // 貸方へ
                    if credit.title == nil /*|| credit.title == ""*/ { // 一度、カーソルを当てた場合は、カーソル移動させない
                        // 勘定科目ピッカーのキャンセルボタンをタップされた場合
                        DispatchQueue.main.async {
                            if !(self.textFieldCategoryDebit.isEditing || self.textFieldCategoryCredit.isEditing) {
                                // 貸方科目へ
                                self.textFieldCategoryCredit.becomeFirstResponder()
                            }
                        }
                    } else {
                        // 勘定科目ピッカーのキャンセルボタンをタップされた場合
                        if credit.amount == nil && credit.title != "" {
                            DispatchQueue.main.async {
                                if !(self.textFieldCategoryDebit.isEditing || self.textFieldCategoryCredit.isEditing) {
                                    // 貸方金額へ
                                    self.textFieldAmountCredit.becomeFirstResponder()
                                }
                            }
                        } else {
                            if value.title != "" && smallWritting == nil { // 勘定科目ピッカーでキャンセルボタンを押下された場合は、カーソル移動させない
                                DispatchQueue.main.async {
                                    // 小書きへ
                                    self.textFieldSmallWritting.becomeFirstResponder()
                                }
                            }
                        }
                    }
                }
            }
        }
        didSet {
            // 仕訳タイプ判定
            if journalEntryType == .CompoundJournalEntry || // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
                journalEntryType == .JournalEntry ||
                journalEntryType == .AdjustingAndClosingEntry ||
                journalEntryType == .JournalEntries || // 仕訳 仕訳帳画面からの遷移の場合
                journalEntryType == .AdjustingAndClosingEntries || // 決算整理仕訳 精算表画面からの遷移の場合
                journalEntryType == .JournalEntriesFixing || // 仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
                journalEntryType == .AdjustingEntriesFixing || // 決算整理仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
                journalEntryType == .JournalEntriesPackageFixing || // 仕訳一括編集 仕訳帳画面からの遷移の場合
                journalEntryType == .SettingsJournalEntries || // よく使う仕訳 追加
                journalEntryType == .SettingsJournalEntriesFixing { // よく使う仕訳 更新
                DispatchQueue.main.async {
                    // 借方0〜4、貸方0〜4、貸借の科目を比較する　同じ勘定科目の場合は赤い枠線を表示させる　未入力は表示させない
                    self.compareCategoryDebitAndCredit()
                }
            }
        }
    }
    
    // 貸方 取引要素
    var credit = AccountTitleAmount() {
        willSet(value) {
            if value.title == nil && value.amount == nil {
                // 貸方
                textFieldCategoryCredit.text = nil
                textFieldAmountCredit.text = nil
            } else {
                // 貸方
                textFieldCategoryCredit.text = value.title
                textFieldAmountCredit.text = StringUtility.shared.addComma(string: value.amount?.description ?? "")
                if value.amount != credit.amount {
                    if journalEntryType != .CompoundJournalEntry {
                        DispatchQueue.main.async {
                            // 相手勘定の金額へ同じ金額を設定する
                            self.debit.amount = value.amount
                        }
                    }
                }
                // 仕訳、決算整理仕訳 編集とよう使う仕訳以外
                guard journalEntryType == .CompoundJournalEntry ||
                        journalEntryType == .JournalEntry ||
                        journalEntryType == .AdjustingAndClosingEntry ||
                        journalEntryType == .JournalEntries ||
                        journalEntryType == .AdjustingAndClosingEntries else {
                    return
                }
                // 貸方科目　未入力の場合
                guard value.title != nil else {
                    DispatchQueue.main.async {
                        if !(self.textFieldCategoryDebit.isEditing || self.textFieldCategoryCredit.isEditing) {
                            // 貸方科目へ
                            self.textFieldCategoryCredit.becomeFirstResponder()
                        }
                    }
                    return
                }
                // 貸方科目 入力済みの場合
                guard !(value.amount == nil && value.title != "") else {
                    DispatchQueue.main.async {
                        if !(self.textFieldCategoryDebit.isEditing || self.textFieldCategoryCredit.isEditing) {
                            // 貸方金額へ
                            self.textFieldAmountCredit.becomeFirstResponder()
                        }
                    }
                    return
                }
                // 金額が入力された場合
                guard value.amount == credit.amount else {
                    // 借方へ
                    if debit.title == nil || debit.title == "" {
                        DispatchQueue.main.async {
                            if !(self.textFieldCategoryDebit.isEditing || self.textFieldCategoryCredit.isEditing) {
                                // 借方科目へ
                                self.textFieldCategoryDebit.becomeFirstResponder()
                            }
                        }
                    } else {
                        // 借方科目 入力済みの場合
                        if debit.amount == nil && debit.title != "" {
                            DispatchQueue.main.async {
                                if !(self.textFieldCategoryDebit.isEditing || self.textFieldCategoryCredit.isEditing) {
                                    // 借方金額へ
                                    self.textFieldAmountDebit.becomeFirstResponder()
                                }
                            }
                        } else {
                            // 仕訳タイプ判定
                            if journalEntryType == .CompoundJournalEntry { // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
                                DispatchQueue.main.async {
                                    // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
                                    self.compareDebitAndCredit()
                                }
                            } else if journalEntryType == .JournalEntry ||
                                        journalEntryType == .AdjustingAndClosingEntry ||
                                        journalEntryType == .JournalEntries ||
                                        journalEntryType == .AdjustingAndClosingEntries {
                                if value.title != "" && smallWritting == nil { // 勘定科目ピッカーでキャンセルボタンを押下された場合は、カーソル移動させない
                                    DispatchQueue.main.async {
                                        // 小書きへ
                                        self.textFieldSmallWritting.becomeFirstResponder()
                                    }
                                }
                            }
                        }
                    }
                    return
                }
                // 仕訳タイプ判定
                if journalEntryType == .CompoundJournalEntry { // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
                    // 勘定科目ピッカーのキャンセルボタンをタップされた場合
                    DispatchQueue.main.async {
                        // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
                        self.compareDebitAndCredit()
                    }
                } else if journalEntryType == .JournalEntry ||
                            journalEntryType == .AdjustingAndClosingEntry ||
                            journalEntryType == .JournalEntries ||
                            journalEntryType == .AdjustingAndClosingEntries {
                    // 借方へ
                    if debit.title == nil /*|| debit.title == ""*/ { // 一度、カーソルを当てた場合は、カーソル移動させない
                        // 勘定科目ピッカーのキャンセルボタンをタップされた場合
                        DispatchQueue.main.async {
                            if !(self.textFieldCategoryDebit.isEditing || self.textFieldCategoryCredit.isEditing) {
                                // 借方科目へ
                                self.textFieldCategoryDebit.becomeFirstResponder()
                            }
                        }
                    } else {
                        // 勘定科目ピッカーのキャンセルボタンをタップされた場合
                        if debit.amount == nil && debit.title != "" {
                            DispatchQueue.main.async {
                                if !(self.textFieldCategoryDebit.isEditing || self.textFieldCategoryCredit.isEditing) {
                                    // 借方金額へ
                                    self.textFieldAmountDebit.becomeFirstResponder()
                                }
                            }
                        } else {
                            if value.title != "" && smallWritting == nil { // 勘定科目ピッカーでキャンセルボタンを押下された場合は、カーソル移動させない
                                DispatchQueue.main.async {
                                    // 小書きへ
                                    self.textFieldSmallWritting.becomeFirstResponder()
                                }
                            }
                        }
                    }
                }
            }
        }
        didSet {
            // 仕訳タイプ判定
            if journalEntryType == .CompoundJournalEntry || // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
                journalEntryType == .JournalEntry ||
                journalEntryType == .AdjustingAndClosingEntry ||
                journalEntryType == .JournalEntries || // 仕訳 仕訳帳画面からの遷移の場合
                journalEntryType == .AdjustingAndClosingEntries || // 決算整理仕訳 精算表画面からの遷移の場合
                journalEntryType == .JournalEntriesFixing || // 仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
                journalEntryType == .AdjustingEntriesFixing || // 決算整理仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
                journalEntryType == .JournalEntriesPackageFixing || // 仕訳一括編集 仕訳帳画面からの遷移の場合
                journalEntryType == .SettingsJournalEntries || // よく使う仕訳 追加
                journalEntryType == .SettingsJournalEntriesFixing { // よく使う仕訳 更新
                DispatchQueue.main.async {
                    // 借方0〜4、貸方0〜4、貸借の科目を比較する　同じ勘定科目の場合は赤い枠線を表示させる　未入力は表示させない
                    self.compareCategoryDebitAndCredit()
                }
            }
        }
    }
    
    // 借方 取引要素 複合仕訳
    var debitElements: [AccountTitleAmount] = [] {
        willSet(value) {
            if value.count >= 1 {
                // 借方科目
                textFieldCategoryDebit1.text = value[0].title
                textFieldAmountDebit1.text = StringUtility.shared.addComma(string: value[0].amount?.description ?? "")
                guard value[0].amount == debitElements[safe: 0]?.amount else {
                    DispatchQueue.main.async {
                        // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
                        self.compareDebitAndCredit()
                    }
                    return
                }
                guard value[0].title != nil else {
                    // 借方科目へ
                    textFieldCategoryDebit1.becomeFirstResponder()
                    return
                }
                // NOTE: 貸借一致したとき、非表示にした入力欄の金額へフォーカスが当たってしまうので、電卓が表示されてしまうため早期リターンする
                // 借方科目 入力済みの場合
                guard !(value[0].amount == nil && value[0].title != "") else {
                    // 借方金額へ
                    textFieldAmountDebit1.becomeFirstResponder()
                    return
                }
            } else {
                // 勘定科目
                textFieldCategoryDebit1.text = nil
                textFieldAmountDebit1.text = nil
            }
            if value.count >= 2 {
                // 借方科目
                textFieldCategoryDebit2.text = value[1].title
                textFieldAmountDebit2.text = StringUtility.shared.addComma(string: value[1].amount?.description ?? "")
                guard value[1].amount == debitElements[safe: 1]?.amount else {
                    DispatchQueue.main.async {
                        // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
                        self.compareDebitAndCredit()
                    }
                    return
                }
                guard value[1].title != nil else {
                    // 借方科目へ
                    textFieldCategoryDebit2.becomeFirstResponder()
                    return
                }
                // 借方科目 入力済みの場合
                guard !(value[1].amount == nil && value[1].title != "") else {
                    // 借方金額へ
                    textFieldAmountDebit2.becomeFirstResponder()
                    return
                }
            } else {
                // 勘定科目
                textFieldCategoryDebit2.text = nil
                textFieldAmountDebit2.text = nil
            }
            if value.count >= 3 {
                // 借方科目
                textFieldCategoryDebit3.text = value[2].title
                textFieldAmountDebit3.text = StringUtility.shared.addComma(string: value[2].amount?.description ?? "")
                guard value[2].amount == debitElements[safe: 2]?.amount else {
                    DispatchQueue.main.async {
                        // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
                        self.compareDebitAndCredit()
                    }
                    return
                }
                guard value[2].title != nil else {
                    // 借方科目へ
                    textFieldCategoryDebit3.becomeFirstResponder()
                    return
                }
                // 借方科目 入力済みの場合
                guard !(value[2].amount == nil && value[2].title != "") else {
                    // 借方金額へ
                    textFieldAmountDebit3.becomeFirstResponder()
                    return
                }
            } else {
                // 勘定科目
                textFieldCategoryDebit3.text = nil
                textFieldAmountDebit3.text = nil
            }
            if value.count >= 4 {
                // 借方科目
                textFieldCategoryDebit4.text = value[3].title
                textFieldAmountDebit4.text = StringUtility.shared.addComma(string: value[3].amount?.description ?? "")
                guard value[3].amount == debitElements[safe: 3]?.amount else {
                    DispatchQueue.main.async {
                        // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
                        self.compareDebitAndCredit()
                    }
                    return
                }
                guard value[3].title != nil else {
                    // 借方科目へ
                    textFieldCategoryDebit4.becomeFirstResponder()
                    return
                }
                // 借方科目 入力済みの場合
                guard !(value[3].amount == nil && value[3].title != "") else {
                    // 借方金額へ
                    textFieldAmountDebit4.becomeFirstResponder()
                    return
                }
            } else {
                // 勘定科目
                textFieldCategoryDebit4.text = nil
                textFieldAmountDebit4.text = nil
            }
        }
        didSet(value) {
            // UIを追加する
            switch debitElements.count {
            case 0:
                viewDebit1.isHidden = true
                viewDebit2.isHidden = true
                viewDebit3.isHidden = true
                viewDebit4.isHidden = true
            case 1:
                viewDebit1.isHidden = false
                viewCredit1.isHidden = true
                viewDebit2.isHidden = true
                viewCredit2.isHidden = true
                viewDebit3.isHidden = true
                viewCredit3.isHidden = true
                viewDebit4.isHidden = true
                viewCredit4.isHidden = true
            case 2:
                viewDebit2.isHidden = false
                viewCredit2.isHidden = true
                viewDebit3.isHidden = true
                viewCredit3.isHidden = true
                viewDebit4.isHidden = true
                viewCredit4.isHidden = true
            case 3:
                viewDebit3.isHidden = false
                viewCredit3.isHidden = true
                viewDebit4.isHidden = true
                viewCredit4.isHidden = true
            case 4:
                viewDebit4.isHidden = false
                viewCredit4.isHidden = true
            default:
                break
            }
            DispatchQueue.main.async {
                // 借方0〜4、貸方0〜4、貸借の科目を比較する　同じ勘定科目の場合は赤い枠線を表示させる　未入力は表示させない
                self.compareCategoryDebitAndCredit()
            }
        }
    }
    
    // 貸方　取引要素 複合仕訳
    var creditElements: [AccountTitleAmount] = [] {
        willSet(value) {
            if value.count >= 1 {
                // 貸方科目
                textFieldCategoryCredit1.text = value[0].title
                textFieldAmountCredit1.text = StringUtility.shared.addComma(string: value[0].amount?.description ?? "")
                guard value[0].amount == creditElements[safe: 0]?.amount else {
                    DispatchQueue.main.async {
                        // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
                        self.compareDebitAndCredit()
                    }
                    return
                }
                guard value[0].title != nil else {
                    // 貸方科目へ
                    textFieldCategoryCredit1.becomeFirstResponder()
                    return
                }
                // NOTE: 貸借一致したとき、非表示にした入力欄の金額へフォーカスが当たってしまうので、電卓が表示されてしまうため早期リターンする
                // 借方科目 入力済みの場合
                guard !(value[0].amount == nil && value[0].title != "") else {
                    // 貸方金額へ
                    textFieldAmountCredit1.becomeFirstResponder()
                    return
                }
            } else {
                // 勘定科目
                textFieldCategoryCredit1.text = nil
                textFieldAmountCredit1.text = nil
            }
            if value.count >= 2 {
                // 貸方科目
                textFieldCategoryCredit2.text = value[1].title
                textFieldAmountCredit2.text = StringUtility.shared.addComma(string: value[1].amount?.description ?? "")
                guard value[1].amount == creditElements[safe: 1]?.amount else {
                    DispatchQueue.main.async {
                        // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
                        self.compareDebitAndCredit()
                    }
                    return
                }
                guard value[1].title != nil else {
                    // 貸方科目へ
                    textFieldCategoryCredit2.becomeFirstResponder()
                    return
                }
                // 借方科目 入力済みの場合
                guard !(value[1].amount == nil && value[1].title != "") else {
                    // 貸方金額へ
                    textFieldAmountCredit2.becomeFirstResponder()
                    return
                }
            } else {
                // 勘定科目
                textFieldCategoryCredit2.text = nil
                textFieldAmountCredit2.text = nil
            }
            if value.count >= 3 {
                // 貸方科目
                textFieldCategoryCredit3.text = value[2].title
                textFieldAmountCredit3.text = StringUtility.shared.addComma(string: value[2].amount?.description ?? "")
                guard value[2].amount == creditElements[safe: 2]?.amount else {
                    DispatchQueue.main.async {
                        // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
                        self.compareDebitAndCredit()
                    }
                    return
                }
                guard value[2].title != nil else {
                    // 貸方科目へ
                    textFieldCategoryCredit3.becomeFirstResponder()
                    return
                }
                // 借方科目 入力済みの場合
                guard !(value[2].amount == nil && value[2].title != "") else {
                    // 貸方金額へ
                    textFieldAmountCredit3.becomeFirstResponder()
                    return
                }
            } else {
                // 勘定科目
                textFieldCategoryCredit3.text = nil
                textFieldAmountCredit3.text = nil
            }
            if value.count >= 4 {
                // 貸方科目
                textFieldCategoryCredit4.text = value[3].title
                textFieldAmountCredit4.text = StringUtility.shared.addComma(string: value[3].amount?.description ?? "")
                guard value[3].amount == creditElements[safe: 3]?.amount else {
                    DispatchQueue.main.async {
                        // 貸借の金額を比較する　金額が少ない方に取引要素を追加する
                        self.compareDebitAndCredit()
                    }
                    return
                }
                guard value[3].title != nil else {
                    // 貸方科目へ
                    textFieldCategoryCredit4.becomeFirstResponder()
                    return
                }
                // 借方科目 入力済みの場合
                guard !(value[3].amount == nil && value[3].title != "") else {
                    // 貸方金額へ
                    textFieldAmountCredit4.becomeFirstResponder()
                    return
                }
            } else {
                // 勘定科目
                textFieldCategoryCredit4.text = nil
                textFieldAmountCredit4.text = nil
            }
        }
        didSet(value) {
            // UIを追加する
            switch creditElements.count {
            case 0:
                viewCredit1.isHidden = true
                viewCredit2.isHidden = true
                viewCredit3.isHidden = true
                viewCredit4.isHidden = true
            case 1:
                viewDebit1.isHidden = true
                viewCredit1.isHidden = false
                viewDebit2.isHidden = true
                viewCredit2.isHidden = true
                viewDebit3.isHidden = true
                viewCredit3.isHidden = true
                viewDebit4.isHidden = true
                viewCredit4.isHidden = true
            case 2:
                viewDebit2.isHidden = true
                viewCredit2.isHidden = false
                viewDebit3.isHidden = true
                viewCredit3.isHidden = true
                viewDebit4.isHidden = true
                viewCredit4.isHidden = true
            case 3:
                viewDebit3.isHidden = true
                viewCredit3.isHidden = false
                viewDebit4.isHidden = true
                viewCredit4.isHidden = true
            case 4:
                viewDebit4.isHidden = true
                viewCredit4.isHidden = false
            default:
                break
            }
            DispatchQueue.main.async {
                // 借方0〜4、貸方0〜4、貸借の科目を比較する　同じ勘定科目の場合は赤い枠線を表示させる　未入力は表示させない
                self.compareCategoryDebitAndCredit()
            }
        }
    }
    // 小書き
    var smallWritting: String? {
        didSet {
            textFieldSmallWritting.text = smallWritting
            // 小書き　文字数カウンタ
            let maxLength = EditableType.smallWriting.maxLength
            smallWritingCounterLabel.font = .boldSystemFont(ofSize: 15)
            smallWritingCounterLabel.text = "\(maxLength - (smallWritting?.count ?? 0))/\(maxLength)  "
            if smallWritting?.count ?? 0 > maxLength {
                smallWritingCounterLabel.textColor = .systemPink
            } else {
                smallWritingCounterLabel.textColor = smallWritting?.count ?? 0 >= maxLength - 3 ? .systemYellow : .systemGreen
            }
            if smallWritting?.count ?? 0 == maxLength {
                // フィードバック
                if #available(iOS 10.0, *), let generator = feedbackGeneratorNotification as? UINotificationFeedbackGenerator {
                    generator.notificationOccurred(.error)
                }
            }
        }
    }
    // 小書き　エラーメッセージ
    var errorMessage: String?
    // テキストフィールド　勘定科目、小書きのキーボードが表示中フラグ
    var isShown = false
    // テキストフィールドのタグ
    var tag: Int = 0
    private var timer: Timer? // Timerを保持する変数
    // 仕訳タイプ(仕訳 or 決算整理仕訳 or 編集)
    var journalEntryType: JournalEntryType = .Undecided {
        didSet {
            DispatchQueue.main.async {
                if self.journalEntryType != .Undecided {
                    self.updateUI()
                } else {
                    // .Undecided
                }
            }
        }
    } // Journal Entries、Adjusting and Closing Entries, JournalEntriesPackageFixing
    // 仕訳編集　仕訳帳画面で選択されたセルの位置　仕訳か決算整理仕訳かの判定に使用する
    var tappedIndexPath = IndexPath(row: 0, section: 0)
    // 仕訳編集　編集の対象となる仕訳の連番
    var primaryKey: Int = 0
    // グループ
    var groupObjects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
    // 和暦対応　西暦に固定する
    let calendar = Calendar(identifier: .gregorian)
    
    /// モーダル上部に設置されるインジケータ
    private lazy var indicatorView: SemiModalIndicatorView = {
        let indicator = SemiModalIndicatorView()
        indicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(indicatorDidTap(_:))))
        return indicator
    }()
    // インジゲーター
    var activityIndicatorView = UIActivityIndicatorView()
    let backView = UIView()
    // フィードバック
    let feedbackGeneratorMedium: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    // フィードバック
    private let feedbackGeneratorHeavy: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    // フィードバック
    private let feedbackGeneratorNotification: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
    /// GUIアーキテクチャ　MVP
    private var presenter: JournalEntryPresenterInput!
    
    func inject(presenter: JournalEntryPresenterInput) {
        self.presenter = presenter
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = JournalEntryPresenter.init(view: self, model: JournalEntryModel())
        inject(presenter: presenter)
        
        presenter.viewDidLoad()
    }
    
    // ビューが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ここでUIKeyboardWillShowという名前の通知のイベントをオブザーバー登録をしている
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // テキストフィールド　勘定科目、小書きのキーボードが表示中 viewDidLoadなどで監視を設定
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidAppear), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidDisappear), name: UIResponder.keyboardDidHideNotification, object: nil)
        // TODO: 動作確認用
        //        // 名前を指定してStoryboardを取得する(Fourth.storyboard)
        //        let storyboard: UIStoryboard = UIStoryboard(name: "PDFMakerViewController", bundle: nil)
        //
        //        // StoryboardIDを指定してViewControllerを取得する(PDFMakerViewController)
        //        let fourthViewController = storyboard.instantiateViewController(withIdentifier: "PDFMakerViewController") as! PDFMakerViewController
        //
        //        self.present(fourthViewController, animated: true, completion: nil)
        
        presenter.viewDidAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        presenter.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // ここでUIKeyboardWillShowという名前の通知のイベントをオブザーバー解除をしている
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // テキストフィールド　勘定科目、小書きのキーボードが表示中 監視を解除
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    // MARK: - チュートリアル対応 コーチマーク型
    
    // チュートリアル対応 コーチマーク型
    // ウォークスルーが終了後に、呼び出される
    func showAnnotation() {
        presenter.showAnnotation()
    }
    // チュートリアル対応 コーチマーク型　コーチマークを終了 コーチマーク画面からコール
    func finishAnnotation() {
        // フラグを倒す
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunch_JournalEntry"
        userDefaults.set(false, forKey: firstLunchKey)
        userDefaults.synchronize()
        
        // タブの有効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = true
                }
            }
        }
        // チュートリアル対応 赤ポチ型　初回起動時　7行を追加
        let firstLunchKeySettingsCategory = "firstLunch_SettingsCategory"
        if userDefaults.bool(forKey: firstLunchKeySettingsCategory) { // 設定勘定科目のコーチマークが表示されていない場合
            DispatchQueue.main.async {
                // 赤ポチを開始
                self.tabBarController?.viewControllers?[4].tabBarItem.badgeValue = ""
            }
        }
    }
    
    // MARK: - Setting
    
    // 金額　電卓画面で入力した値を表示させる
    func setAmountValue(numbersOnDisplay: Int, tag: Int) {
        // 仕訳タイプ判定
        if journalEntryType == .CompoundJournalEntry { // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
            switch tag {
            case 333:
                debit.amount = numbersOnDisplay
            case 444:
                credit.amount = numbersOnDisplay
            case 777:
                debitElements[0].amount = numbersOnDisplay
            case 888:
                creditElements[0].amount = numbersOnDisplay
            case 111_111:
                debitElements[1].amount = numbersOnDisplay
            case 121_212:
                creditElements[1].amount = numbersOnDisplay
            case 151_515:
                debitElements[2].amount = numbersOnDisplay
            case 161_616:
                creditElements[2].amount = numbersOnDisplay
            case 191_919:
                debitElements[3].amount = numbersOnDisplay
            case 202_020:
                creditElements[3].amount = numbersOnDisplay
            default:
                break
            }
        } else {
            switch tag {
            case 333:
                debit.amount = numbersOnDisplay
            case 444:
                credit.amount = numbersOnDisplay
            default:
                break
            }
        }
    }
    
    // よく使う仕訳　エリア カルーセルをリロードする
    func reloadCarousel() {
        DispatchQueue.main.async { [self] in
            // データベース　よく使う仕訳
            if let text = debit.title {
                let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(
                    account: text
                )
                if objects.isEmpty {
                    // よく使う仕訳で選択した勘定科目が入っている可能性があるので、初期化
                    debit.title = nil
                }
            }
            if let text = credit.title {
                let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(
                    account: text
                )
                if objects.isEmpty {
                    // よく使う仕訳で選択した勘定科目が入っている可能性があるので、初期化
                    credit.title = nil
                }
            }
            if let tableView = tableView {
                // よく使う仕訳　エリア
                tableView.reloadData()
            }
        }
    }
    
    // MARK: UIDatePicker
    // デートピッカー作成
    func createDatePicker() {
        // 現在時刻を取得
        let now = Date() // UTC時間なので　9時間ずれる
        // 開いている会計帳簿の年度を取得
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        let nowStringYear = fiscalYear.description                            //　本年度
        let nowStringNextYear = (fiscalYear + 1).description                  //　次年度
        let nowStringMonthDay = DateManager.shared.dateFormatterMMdd.string(from: now) // 現在時刻の月日
        let nowStringYYYY = DateManager.shared.dateFormatterYYYY.string(from: now)
        // 設定決算日
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        guard let dayOfEndInPeriod: Date   = DateManager.shared.dateFormatterMMdd.date(from: theDayOfReckoning) else { return } // 決算日設定機能 注意：nowStringYearは、開始日の日付が存在するかどうかを確認するために記述した。閏年など
        guard let modifiedDate = calendar.date(byAdding: .day, value: 1, to: dayOfEndInPeriod) else { return } // 決算日設定機能　年度開始日は決算日の翌日に設定する
        guard let dayOfStartInPeriod: Date = DateManager.shared.dateFormatterMMdd.date(from: DateManager.shared.dateFormatterMMdd.string(from: modifiedDate)) else { return } // 決算日設定機能　年度開始日
        // 期間
        guard let dayOfStartInYear: Date       = DateManager.shared.dateFormatterMMdd.date(from: "01/01") else { return }
        guard let dayOfEndInYear: Date         = DateManager.shared.dateFormatterMMdd.date(from: "12/31") else { return }
        guard let nowStringMonthDayMMdd: Date  = DateManager.shared.dateFormatterMMdd.date(from: nowStringMonthDay) else { return }
        guard let yyyyMMddHHmmss: Date         = DateManager.shared.dateFormatteryyyyMMddHHmmss.date(from: theDayOfReckoning + "/" + nowStringYear) else { return }
        guard let yyyyMMddHHmmssNextYear: Date = DateManager.shared.dateFormatteryyyyMMddHHmmss.date(from: theDayOfReckoning + "/" + nowStringNextYear) else { return }
        // guard let yyyyMMddHHmmssNow: Date      = DateManager.shared.dateFormatteryyyyMMddHHmmss.date(from: nowStringMonthDay + "/" + nowStringYYYY + ", " + nowStringHHmmss) else { return }
        // リワード広告が表示されたあと、日付が現在日時にリセットされる
        // guard let yyyyMMddHHmmssNowCurrent = Date.convertDate(from: nowStringMonthDay + "/" + nowStringYYYY + ", " + nowStringHHmmss, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ") else { return }
        // print(yyyyMMddHHmmssNowCurrent.toString(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
        
        // デイトピッカーの最大値と最小値を設定
        if journalEntryType == .AdjustingAndClosingEntries || // 決算整理仕訳 精算表画面からの遷移の場合
            journalEntryType == .AdjustingAndClosingEntry {
            // 決算整理仕訳の場合は日付を決算日に固定
            if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                print("### 会計期間が年をまたがない場合")
                // 決算日設定機能　注意：カンマの後にスペースがないとnilになる 04-02にすると04-01となる
                datePicker.minimumDate = yyyyMMddHHmmss
                // 04-01にすると03-31となる
                datePicker.maximumDate = yyyyMMddHHmmss
            } else { // 会計期間が年をまたぐ場合
                print("### 会計期間が年をまたぐ場合")
                // 決算日設定機能　注意：カンマの後にスペースがないとnilになる 04-02にすると04-01となる
                datePicker.minimumDate = calendar.date(byAdding: .year, value: 1, to: yyyyMMddHHmmss)
                // 04-01にすると03-31となる
                datePicker.maximumDate = calendar.date(byAdding: .year, value: 1, to: yyyyMMddHHmmss)
            }
        } else if journalEntryType == .JournalEntriesFixing { // 仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
            // 決算日設定機能　何もしない
        } else if journalEntryType == .AdjustingEntriesFixing { // 決算整理仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
            // 決算日設定機能　何もしない
        } else if journalEntryType == .JournalEntriesPackageFixing { // 仕訳一括編集 仕訳帳画面からの遷移の場合
            
        } else {
            if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                print("### 会計期間が年をまたがない場合")
                // 決算日設定機能　注意：カンマの後にスペースがないとnilになる 04-02にすると04-01となる
                guard let modifiedDate = calendar.date(byAdding: .year, value: -1, to: yyyyMMddHHmmss),
                      let modifiedDate = calendar.date(byAdding: .day, value: 1, to: modifiedDate) else { return } // 決算日設定機能　年度開始日は決算日の翌日に設定する
                datePicker.minimumDate = modifiedDate
                // 04-01にすると03-31となる
                datePicker.maximumDate = yyyyMMddHHmmss
            } else { // 会計期間が年をまたぐ場合
                // 01/01 以降か
                guard let interval = (calendar.dateComponents([.month], from: dayOfStartInYear, to: nowStringMonthDayMMdd)).month else { return }
                // 設定決算日 未満か
                guard let interval1 = (calendar.dateComponents([.month], from: dayOfEndInPeriod, to: nowStringMonthDayMMdd)).month else { return }
                // 年度開始日 以降か
                guard let interval2 = (calendar.dateComponents([.month], from: dayOfStartInPeriod, to: nowStringMonthDayMMdd)).month else { return }
                // 12/31と同じ、もしくはそれ以前か
                guard let interval3 = (calendar.dateComponents([.month], from: dayOfEndInYear, to: nowStringMonthDayMMdd)).month else { return }
                
                if interval >= 0 {
                    print("### 会計期間　1/01 以降")
                    if interval1 <= 0 {
                        print("### 会計期間　設定決算日 未満")
                        // 決算日設定機能　注意：カンマの後にスペースがないとnilになる
                        datePicker.minimumDate = calendar.date(byAdding: .day, value: 1, to: yyyyMMddHHmmss)
                        // 四月以降か
                        datePicker.maximumDate = calendar.date(byAdding: .year, value: 1, to: yyyyMMddHHmmss)
                    } else if interval2 >= 0 {
                        print("### 会計期間　年度開始日 以降")
                        if interval3 <= 0 {
                            print("### 会計期間　12/31 以前")
                            // 決算日設定機能　注意：カンマの後にスペースがないとnilになる 04-02にすると04-01となる
                            datePicker.minimumDate = calendar.date(byAdding: .day, value: 1, to: yyyyMMddHHmmss)
                            // 04-01にすると03-31となる
                            datePicker.maximumDate = calendar.date(byAdding: .year, value: 1, to: yyyyMMddHHmmss)
                        }
                    }
                }
            }
        }
        // ピッカーの初期値
        if journalEntryType == .JournalEntriesFixing { // 仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
            // 決算日設定機能　何もしない viewDidLoad()で値を設定している
        } else if journalEntryType == .AdjustingEntriesFixing { // 決算整理仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
            // 決算日設定機能　何もしない viewDidLoad()で値を設定している
        } else if journalEntryType == .JournalEntriesPackageFixing { // 仕訳一括編集 仕訳帳画面からの遷移の場合
            // nothing
        } else if journalEntryType == .AdjustingAndClosingEntries || // 決算整理仕訳 精算表画面からの遷移の場合
                    journalEntryType == .AdjustingAndClosingEntry {
            if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                datePicker.date = yyyyMMddHHmmss // 注意：カンマの後にスペースがないとnilになる
            } else {
                datePicker.date = yyyyMMddHHmmssNextYear // 注意：カンマの後にスペースがないとnilになる
            }
        } else {
            // リワード広告が表示されたあと、日付が現在日時にリセットされる
            // datePicker.date = yyyyMMddHHmmssNowCurrent // 注意：カンマの後にスペースがないとnilになる
        }
        //        // 背景色
        //        datePicker.backgroundColor = .systemBackground
        //　iOS14対応　モード　ドラムロールはwheels
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        // 和暦対応　西暦に固定する
        datePicker.calendar = Calendar(identifier: .gregorian)
    }
    
    // MARK: EMTNeumorphicView
    // ニューモフィズム　ボタンとビューのデザインを指定する
    func createEMTNeumorphicView() {
        
        if let datePickerView = datePickerView {
            datePickerView.neumorphicLayer?.cornerRadius = 15
            datePickerView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            datePickerView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            datePickerView.neumorphicLayer?.edged = Constant.edged
            datePickerView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            datePickerView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        }
        if let buttonLeft = buttonLeft {
            buttonLeft.setTitleColor(.textColor, for: .normal)
            buttonLeft.neumorphicLayer?.cornerRadius = 10
            buttonLeft.setTitleColor(.textColor, for: .selected)
            buttonLeft.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            buttonLeft.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            buttonLeft.neumorphicLayer?.edged = Constant.edged
            buttonLeft.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            buttonLeft.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
            let backImage = UIImage(named: "arrow_back_ios-arrow_back_ios_symbol")?.withRenderingMode(.alwaysTemplate)
            buttonLeft.setImage(backImage, for: UIControl.State.normal)
            // アイコン画像の色を指定する
            buttonLeft.tintColor = .accentColor
        }
        if let buttonRight = buttonRight {
            buttonRight.setTitleColor(.textColor, for: .normal)
            buttonRight.neumorphicLayer?.cornerRadius = 10
            buttonRight.setTitleColor(.textColor, for: .selected)
            buttonRight.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            buttonRight.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            buttonRight.neumorphicLayer?.edged = Constant.edged
            buttonRight.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            buttonRight.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
            let backImage = UIImage(named: "arrow_forward_ios-arrow_forward_ios_symbol")?.withRenderingMode(.alwaysTemplate)
            buttonRight.setImage(backImage, for: UIControl.State.normal)
            // アイコン画像の色を指定する
            buttonRight.tintColor = .accentColor
        }
        if let textFieldView = textFieldView {
            textFieldView.neumorphicLayer?.cornerRadius = 15
            textFieldView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            textFieldView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            textFieldView.neumorphicLayer?.edged = Constant.edged
            textFieldView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            textFieldView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
            textFieldView.neumorphicLayer?.depthType = .concave
        }
        if let smallWrittingTextFieldView = smallWrittingTextFieldView {
            smallWrittingTextFieldView.neumorphicLayer?.cornerRadius = 15
            smallWrittingTextFieldView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            smallWrittingTextFieldView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            smallWrittingTextFieldView.neumorphicLayer?.edged = Constant.edged
            smallWrittingTextFieldView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            smallWrittingTextFieldView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
            smallWrittingTextFieldView.neumorphicLayer?.depthType = .concave
        }
        // inputButton.setTitle("入 力", for: .normal)
        inputButton.setTitleColor(.accentColor, for: .normal)
        inputButton.neumorphicLayer?.cornerRadius = 15
        inputButton.setTitleColor(.accentColor, for: .selected)
        inputButton.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        inputButton.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        inputButton.neumorphicLayer?.edged = Constant.edged
        inputButton.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        inputButton.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        
        cancelButton.setTitleColor(.textColor, for: .normal)
        cancelButton.neumorphicLayer?.cornerRadius = 15
        cancelButton.setTitleColor(.textColor, for: .selected)
        cancelButton.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        cancelButton.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        cancelButton.neumorphicLayer?.edged = Constant.edged
        cancelButton.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        cancelButton.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        // Optional. if it is nil (default), elementBackgroundColor will be used as element color.
        cancelButton.neumorphicLayer?.elementColor = UIColor.baseColor.cgColor
        let backImage = UIImage(named: "close-close_symbol")?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(backImage, for: UIControl.State.normal)
        // アイコン画像の色を指定する
        cancelButton.tintColor = .accentColor
        
        if let addButton = addButton {
            // ボタンの色
            addButton.backgroundColor = .accentLight
            // 仕訳画面表示ボタン
            addButton.isEnabled = !isEditing
            // ボタンを丸くする処理。ボタンが正方形の時、一辺を2で割った数値を入れる。(今回の場合、 ボタンのサイズは70×70であるので、35。)
            addButton.layer.cornerRadius = addButton.frame.width / 2 - 1
            // 影の色を指定。(UIColorをCGColorに変換している)
            addButton.layer.shadowColor = UIColor.black.cgColor
            // 影の縁のぼかしの強さを指定
            addButton.layer.shadowRadius = 3
            // 影の位置を指定
            addButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
            // 影の不透明度(濃さ)を指定
            addButton.layer.shadowOpacity = 1.0
        }
        
        // 仕訳 タブバーの仕訳タブからの遷移の場合
        if let backgroundView = backgroundView {
            // 中央上部に配置する
            indicatorView.frame = CGRect(x: 0, y: 0, width: 40, height: 5)
            backgroundView.addSubview(indicatorView)
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                indicatorView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
                indicatorView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 5),
                indicatorView.widthAnchor.constraint(equalToConstant: indicatorView.frame.width),
                indicatorView.heightAnchor.constraint(equalToConstant: indicatorView.frame.height)
            ])
        }
    }
    // 入力数カウンタラベル
    func updateCoinCountLabel() {
        if journalEntryType != .SettingsJournalEntries  && // よく使う仕訳 追加
            journalEntryType != .SettingsJournalEntriesFixing { // よく使う仕訳 更新
            // アップグレード機能　スタンダードプラン 未購入
            if !UpgradeManager.shared.inAppPurchaseFlag {
                // 仕訳が50件超の入力がある場合は、ダイアログを表示する　マネタイズ対応
                let results = DataBaseManagerJournalEntry.shared.getJournalEntryCount()
                if results.count > Constant.SHOW_REWARD_AD_COUNT {
                    // リワード広告　報酬
                    coinCountLabel.text = "残り \(UserData.rewardAdCoinCount) 回の入力ができます"
                    coinCountLabel.sizeToFit()
                    coinCountLabel.isHidden = false
                    // フェードイン・アウトメソッド
                    coinCountLabel.animateViewFadeOut()
                } else {
                    coinCountLabel.isHidden = true
                }
            } else {
                coinCountLabel.isHidden = true
            }
        }
    }
    
    // MARK: UITextField
    // TextField作成 小書き
    func createTextFieldForSmallwritting() {
        textFieldSmallWritting.delegate = self
        // テキストの入力位置を指すライン、これはカーソルではなくキャレット(caret)と呼ぶそうです。
        textFieldSmallWritting.tintColor = UIColor.accentColor
        // 文字サイズを指定
        textFieldSmallWritting.adjustsFontSizeToFitWidth = true // TextField 文字のサイズを合わせる
        textFieldSmallWritting.minimumFontSize = 17
        
        // toolbar 小書き Done:Tag Cancel:Tag
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(
            x: 0,
            y: 0,
            width: (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)!,
            height: 44
        )
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
        textFieldSmallWritting.inputAccessoryView = toolbar
        
        textFieldSmallWritting.layer.borderWidth = 0.5
        // 最大文字数
        textFieldSmallWritting.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // MARK: - Action
    
    // MARK: UISegmentedControl
    @IBAction func segmentedControl(_ sender: Any) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        if segmentedControl.selectedSegmentIndex == 0 {
            // 仕訳タイプ判定
            journalEntryType = .JournalEntry // 仕訳 タブバーの仕訳タブからの遷移の場合
        } else {
            journalEntryType = .AdjustingAndClosingEntry // 決算整理仕訳 タブバーの仕訳タブからの遷移の場合
        }
    }
    
    // 単一仕訳/複合仕訳　切り替え
    @IBAction func compoundJournalEntrySegmentedControl(_ sender: Any) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // 単一仕訳/複合仕訳　切り替え
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "compound_journal_entry"
        if compoundJournalEntrySegmentedControl.selectedSegmentIndex == 0 {
            userDefaults.set(false, forKey: firstLunchKey)
            userDefaults.synchronize()
        } else {
            userDefaults.set(true, forKey: firstLunchKey)
            userDefaults.synchronize()
        }
        // 単一仕訳/複合仕訳　切り替え
        if compoundJournalEntrySegmentedControl.selectedSegmentIndex == 0 {
            // 仕訳タイプ判定
            journalEntryType = .JournalEntry // 仕訳 タブバーの仕訳タブからの遷移の場合
            // NOTE: 入力を終了してから、取引要素をクリアしないと、入力値を代入しようとしてIndex out of rangeとなる。
            self.view.endEditing(true)
            // 取引要素　借方 貸方　クリア
            creditElements = []
            debitElements = []
        } else {
            // 仕訳タイプ判定
            journalEntryType = .CompoundJournalEntry // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
            self.view.endEditing(true)
        }
    }
    
    // MARK: UIButton
    // デイトピッカーのマスク
    @IBAction func maskDatePickerButtonTapped(_ sender: Any) {
        // マスクを取る
        maskDatePickerButton.isHidden = true
        // デイトピッカーのマスク
        isMaskedDatePicker = true
    }
    
    @IBAction func leftButtonTapped(_ sender: UIButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // 選択されていたボタンを選択解除する
        let newArray = arrayHugo.filter { $0.isSelected == true }
        for i in newArray {
            i.isSelected = false
        }
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.isSelected = !sender.isSelected
        }
        
        let min = datePicker.minimumDate!
        if datePicker.date > min {
            let modifiedDate = calendar.date(byAdding: .day, value: -1, to: datePicker.date)! // 1日前へ
            datePicker.date = modifiedDate
        }
    }
    
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // 選択されていたボタンを選択解除する
        let newArray = arrayHugo.filter { $0.isSelected == true }
        for i in newArray {
            i.isSelected = false
        }
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.isSelected = !sender.isSelected
        }
        
        let max = datePicker.maximumDate!
        if datePicker.date < max {
            let modifiedDate = calendar.date(byAdding: .day, value: 1, to: datePicker.date)! // 1日次へ
            datePicker.date = modifiedDate
        }
    }
    
    // MARK: キーボード
    // UIKeyboardWillShow通知を受けて、実行される関数
    @objc
    func keyboardWillShow(notification: NSNotification) {
        // 小書きを入力中は、画面を上げる
        if textFieldSmallWritting.isEditing {
            guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            // 入力ボタンの下辺
            let txtLimit = inputButton.frame.origin.y + inputButton.frame.height - 10.0
            
            animateWithKeyboard(notification: notification) { keyboardFrame in
                if self.view.frame.origin.y == 0 {
                    print(self.view.frame.origin.y)
                    print(keyboardSize.height - txtLimit)
                    print(keyboardSize.height)
                    print(txtLimit)
                    self.view.frame.origin.y -= keyboardSize.height - txtLimit
                }
            }
        }
    }
    // UIKeyboardWillShow通知を受けて、実行される関数
    @objc
    func keyboardWillHide(notification: NSNotification) {
        animateWithKeyboard(notification: notification) { _ in
            if self.view.frame.origin.y != 0 {
                print(self.view.frame.origin.y)
                self.view.frame.origin.y = 0
            }
        }
    }
    // キーボードのアニメーションに合わせてViewをアニメーションさせる
    func animateWithKeyboard(notification: NSNotification, animations: ((_ keyboardFrame: CGRect) -> Void)?) {
        // キーボードのdurationを抽出 *1
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        guard let duration = notification.userInfo?[durationKey] as? Double else { return }
        
        // キーボードのframeを抽出する *2
        let frameKey = UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardFrameValue = notification.userInfo?[frameKey] as? NSValue else { return }
        
        // アニメーション曲線を抽出する *3
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
        guard let curveValue = notification.userInfo?[curveKey] as? Int else { return }
        guard let curve = UIView.AnimationCurve(rawValue: curveValue) else { return }
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            // ここにアニメーション化したいレイアウト変更を記述する
            animations?(keyboardFrameValue.cgRectValue)
            self.view?.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    // TextFieldのキーボードについているBarButtonが押下された時
    @objc
    func barButtonTapped(_ sender: UIBarButtonItem) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        
        switch sender.tag {
        case 7: // 小書きの場合 Done
            self.view.endEditing(true)
        case 77: // 小書きの場合 Cancel
            self.view.endEditing(true)
        default:
            self.view.endEditing(true)
        }
    }
    // TextField キーボード以外の部分をタッチ　 TextFieldをタップしても呼ばれない
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {// この後に TapGestureRecognizer が呼ばれている
        // touchesBeganメソッドをオーバーライドします。
        self.view.endEditing(true)
    }
    // テキストフィールド　勘定科目、小書きのキーボードが表示中フラグを切り替える
    @objc
    func keyboardDidAppear() {
        isShown = true
    }
    
    @objc
    func keyboardDidDisappear() {
        isShown = false
    }
    
    // MARK: EMTNeumorphicButton
    // 入力ボタン
    @IBAction func inputButtonTapped(_ sender: EMTNeumorphicButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorHeavy as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // 選択されていたボタンを選択解除する
        let newArray = arrayHugo.filter { $0.isSelected == true }
        for i in newArray {
            i.isSelected = false
        }
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.isSelected = !sender.isSelected
        }
        // バリデーションチェック
        if journalEntryType == .JournalEntriesPackageFixing {
            // バリデーションチェック ひとつでも変更されているか、小書き
            guard textInputCheckForJournalEntriesPackageFixing() else {
                return
            }
        } else {
            // バリデーションチェック　全て入力されているか
            guard textInputCheck() else {
                return
            }
        }
        
        switch journalEntryType {
            
        case .JournalEntry, .AdjustingAndClosingEntry, .JournalEntries, .AdjustingAndClosingEntries:
            // ユーザーが入力した仕訳の内容を取得する
            if let journalEntryData = getInputJournalEntryData() {
                presenter.inputButtonTapped(isForced: false, journalEntryType: journalEntryType, journalEntryData: journalEntryData, journalEntryDatas: nil, primaryKey: nil)
            }
            return
        case .JournalEntriesFixing, .AdjustingEntriesFixing:
            // ユーザーが入力した仕訳の内容を取得する
            if let journalEntryData = getInputJournalEntryData() {
                presenter.inputButtonTapped(isForced: false, journalEntryType: journalEntryType, journalEntryData: journalEntryData, journalEntryDatas: nil, primaryKey: primaryKey)
            }
            return
        case .JournalEntriesPackageFixing:
            // 仕訳一括編集 仕訳帳画面からの遷移の場合
            let journalEntryData = buttonTappedForJournalEntriesPackageFixing()
            presenter.inputButtonTapped(isForced: false, journalEntryType: journalEntryType, journalEntryData: journalEntryData, journalEntryDatas: nil, primaryKey: nil)
            return
        case .SettingsJournalEntries, .SettingsJournalEntriesFixing:
            // 継承したクラスで処理を行う
            break
        case .CompoundJournalEntry: // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
            // ユーザーが入力した仕訳の内容を取得する 複合仕訳
            if let journalEntryDatas = getInputJournalEntryDatas() {
                presenter.inputButtonTapped(isForced: false, journalEntryType: journalEntryType, journalEntryData: nil, journalEntryDatas: journalEntryDatas, primaryKey: nil)
            }
            return
        case .Undecided:
            break
        }
    }
    
    // 仕訳一括編集　の処理
    func buttonTappedForJournalEntriesPackageFixing() -> JournalEntryData {
        // バリデーションチェック
        var datePicker: String?
        if isMaskedDatePicker {
            let date = "\(self.datePicker.date.year)/\(self.datePicker.date.month)/\(self.datePicker.date.day)"
            datePicker = date
        } else {
            datePicker = nil
        }
        var textFieldCategoryDebit: String?
        if let text = debit.title {
            if !text.isEmpty {
                textFieldCategoryDebit = text
            }
        } else {
            textFieldCategoryDebit = nil
        }
        var textFieldCategoryCredit: String?
        if let text = credit.title {
            if !text.isEmpty {
                textFieldCategoryCredit = text
            }
        } else {
            textFieldCategoryCredit = nil
        }
        var textFieldAmountDebit: Int64?
        if let text = debit.amount {
            textFieldAmountDebit = Int64(text)
        } else {
            textFieldAmountDebit = nil
        }
        var textFieldAmountCredit: Int64?
        if let text = credit.amount {
            textFieldAmountCredit = Int64(text)
        } else {
            textFieldAmountCredit = nil
        }
        var textFieldSmallWritting: String?
        if let text = smallWritting {
            if !text.isEmpty {
                textFieldSmallWritting = text
            }
        } else {
            textFieldSmallWritting = nil
        }
        
        let dBJournalEntry = JournalEntryData(
            date: datePicker,
            debit_category: textFieldCategoryDebit,
            debit_amount: textFieldAmountDebit,
            credit_category: textFieldCategoryCredit,
            credit_amount: textFieldAmountCredit,
            smallWritting: textFieldSmallWritting
        )
        
        return dBJournalEntry
    }
    
    // ユーザーが入力した仕訳の内容を取得する
    func getInputJournalEntryData() -> JournalEntryData? {
        // データベース　仕訳データを追加
        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
        if let textFieldCategoryDebit = debit.title,
           let textFieldAmountDebit = debit.amount,
           let textFieldCategoryCredit = credit.title,
           let textFieldAmountCredit = credit.amount {
            let textFieldSmallWritting = smallWritting
            // 先頭を0埋めする
            let date = "\(datePicker.date.year)" + "/" + "\(String(format: "%02d", datePicker.date.month))" + "/" + "\(String(format: "%02d", datePicker.date.day))"
            let textFieldAmountDebitInt64 = Int64(textFieldAmountDebit)
            let textFieldAmountCreditInt64 = Int64(textFieldAmountCredit)
            
            let dBJournalEntry = JournalEntryData(
                date: date,
                debit_category: textFieldCategoryDebit,
                debit_amount: textFieldAmountDebitInt64,
                credit_category: textFieldCategoryCredit,
                credit_amount: textFieldAmountCreditInt64,
                smallWritting: textFieldSmallWritting
            )
            
            return dBJournalEntry
        }
        
        return nil
    }
    
    // ユーザーが入力した仕訳の内容を取得する 複合仕訳
    func getInputJournalEntryDatas() -> [JournalEntryData]? {
        var datas: [JournalEntryData] = []
        // 借方
        guard let debitAmount = debit.amount else {
            return nil
        }
        // 貸方
        guard let creditAmount = credit.amount else {
            return nil
        }
        // 借方金額が大きい
        if debitAmount > creditAmount {
            if let textFieldCategoryDebit = debit.title,
               let textFieldAmountDebit = credit.amount, // 金額が小さい方に合わせる
               let textFieldCategoryCredit = credit.title,
               let textFieldAmountCredit = credit.amount {
                let textFieldSmallWritting = smallWritting
                // 先頭を0埋めする
                let date = "\(datePicker.date.year)" + "/" + "\(String(format: "%02d", datePicker.date.month))" + "/" + "\(String(format: "%02d", datePicker.date.day))"
                let textFieldAmountDebitInt64 = Int64(textFieldAmountDebit)
                let textFieldAmountCreditInt64 = Int64(textFieldAmountCredit)
                
                let dBJournalEntry = JournalEntryData(
                    date: date,
                    debit_category: textFieldCategoryDebit,
                    debit_amount: textFieldAmountDebitInt64,
                    credit_category: textFieldCategoryCredit,
                    credit_amount: textFieldAmountCreditInt64,
                    smallWritting: textFieldSmallWritting
                )
                
                datas.append(dBJournalEntry)
            }
            for i in creditElements {
                //                creditAmountTotal += i.amount ?? 0
                if let textFieldCategoryDebit = debit.title,
                   let textFieldAmountDebit = i.amount, // 金額が小さい方に合わせる
                   let textFieldCategoryCredit = i.title,
                   let textFieldAmountCredit = i.amount {
                    let textFieldSmallWritting = smallWritting
                    // 先頭を0埋めする
                    let date = "\(datePicker.date.year)" + "/" + "\(String(format: "%02d", datePicker.date.month))" + "/" + "\(String(format: "%02d", datePicker.date.day))"
                    let textFieldAmountDebitInt64 = Int64(textFieldAmountDebit)
                    let textFieldAmountCreditInt64 = Int64(textFieldAmountCredit)
                    
                    let dBJournalEntry = JournalEntryData(
                        date: date,
                        debit_category: textFieldCategoryDebit,
                        debit_amount: textFieldAmountDebitInt64,
                        credit_category: textFieldCategoryCredit,
                        credit_amount: textFieldAmountCreditInt64,
                        smallWritting: textFieldSmallWritting
                    )
                    
                    datas.append(dBJournalEntry)
                }
            }
        }
        // 貸方金額が大きい
        if debitAmount < creditAmount {
            if let textFieldCategoryDebit = debit.title,
               let textFieldAmountDebit = debit.amount,
               let textFieldCategoryCredit = credit.title,
               let textFieldAmountCredit = debit.amount { // 金額が小さい方に合わせる
                let textFieldSmallWritting = smallWritting
                // 先頭を0埋めする
                let date = "\(datePicker.date.year)" + "/" + "\(String(format: "%02d", datePicker.date.month))" + "/" + "\(String(format: "%02d", datePicker.date.day))"
                let textFieldAmountDebitInt64 = Int64(textFieldAmountDebit)
                let textFieldAmountCreditInt64 = Int64(textFieldAmountCredit)
                
                let dBJournalEntry = JournalEntryData(
                    date: date,
                    debit_category: textFieldCategoryDebit,
                    debit_amount: textFieldAmountDebitInt64,
                    credit_category: textFieldCategoryCredit,
                    credit_amount: textFieldAmountCreditInt64,
                    smallWritting: textFieldSmallWritting
                )
                
                datas.append(dBJournalEntry)
            }
            for i in debitElements {
                //                debitAmountTotal += i.amount ?? 0
                if let textFieldCategoryDebit = i.title,
                   let textFieldAmountDebit = i.amount,
                   let textFieldCategoryCredit = credit.title,
                   let textFieldAmountCredit = i.amount { // 金額が小さい方に合わせる
                    let textFieldSmallWritting = smallWritting
                    // 先頭を0埋めする
                    let date = "\(datePicker.date.year)" + "/" + "\(String(format: "%02d", datePicker.date.month))" + "/" + "\(String(format: "%02d", datePicker.date.day))"
                    let textFieldAmountDebitInt64 = Int64(textFieldAmountDebit)
                    let textFieldAmountCreditInt64 = Int64(textFieldAmountCredit)
                    
                    let dBJournalEntry = JournalEntryData(
                        date: date,
                        debit_category: textFieldCategoryDebit,
                        debit_amount: textFieldAmountDebitInt64,
                        credit_category: textFieldCategoryCredit,
                        credit_amount: textFieldAmountCreditInt64,
                        smallWritting: textFieldSmallWritting
                    )
                    
                    datas.append(dBJournalEntry)
                }
            }
        }
        // 貸借一致　単一仕訳
        if debitAmount == creditAmount {
            if let textFieldCategoryDebit = debit.title,
               let textFieldAmountDebit = debit.amount,
               let textFieldCategoryCredit = credit.title,
               let textFieldAmountCredit = credit.amount {
                let textFieldSmallWritting = smallWritting
                // 先頭を0埋めする
                let date = "\(datePicker.date.year)" + "/" + "\(String(format: "%02d", datePicker.date.month))" + "/" + "\(String(format: "%02d", datePicker.date.day))"
                let textFieldAmountDebitInt64 = Int64(textFieldAmountDebit)
                let textFieldAmountCreditInt64 = Int64(textFieldAmountCredit)
                
                let dBJournalEntry = JournalEntryData(
                    date: date,
                    debit_category: textFieldCategoryDebit,
                    debit_amount: textFieldAmountDebitInt64,
                    credit_category: textFieldCategoryCredit,
                    credit_amount: textFieldAmountCreditInt64,
                    smallWritting: textFieldSmallWritting
                )
                
                datas.append(dBJournalEntry)
            }
        }
        
        return datas
    }
    
    // MARK: バリデーション
    // 入力チェック 仕訳一括編集
    func textInputCheckForJournalEntriesPackageFixing() -> Bool {
        // 入力値を取得する
        let journalEntryData = buttonTappedForJournalEntriesPackageFixing()
        // バリデーション 何も入力されていない
        switch ErrorValidation().validateEmptyAll(journalEntryData: journalEntryData) {
        case .success, .unvalidated:
            errorMessage = nil
        case .failure(let message):
            errorMessage = message
            showErrorMessage(completion: {
                // なにか変更させる
            })
            return false // NG
        }
        
        // 小書き　バリデーションチェック
        switch ErrorValidation().validateSmallWriting(text: smallWritting ?? "") {
        case .success, .unvalidated:
            errorMessage = nil
        case .failure(let message):
            errorMessage = message
            showErrorMessage(completion: {
                // TextFieldのキーボードを自動的に表示する
                self.textFieldSmallWritting.becomeFirstResponder()
            })
            return false // NG
        }
        
        return true // OK
    }
    
    // 入力チェック
    func textInputCheck() -> Bool {
        // バリデーション 借方勘定科目 入力チェック
        guard textInputCheck(text: debit.title, editableType: .categoryDebit, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 未入力のTextFieldのキーボードを自動的に表示する
                self.textFieldCategoryDebit.becomeFirstResponder()
            }
        }) else {
            return false // NG
        }
        // バリデーション 貸方勘定科目 入力チェック
        guard textInputCheck(text: credit.title, editableType: .categoryCredit, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 未入力のTextFieldのキーボードを自動的に表示する
                self.textFieldCategoryCredit.becomeFirstResponder()
            }
        }) else {
            return false // NG
        }
        
        // バリデーション 金額 入力チェック
        guard textInputCheck(amount: debit.amount, editableType: .amount, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 未入力のTextFieldのキーボードを自動的に表示する
                self.textFieldAmountDebit.becomeFirstResponder()
            }
        }) else {
            return false // NG
        }
        // バリデーション 金額 入力チェック
        guard textInputCheck(amount: credit.amount, editableType: .amount, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 未入力のTextFieldのキーボードを自動的に表示する
                self.textFieldAmountCredit.becomeFirstResponder()
            }
        }) else {
            return false // NG
        }
        if journalEntryType == .CompoundJournalEntry { // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
            // バリデーション 勘定科目 入力チェック
            for i in 0..<debitElements.count {
                // バリデーション 借方勘定科目　1〜4 入力チェック
                guard textInputCheck(text: debitElements[i].title, editableType: .categoryDebit, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // 未入力のTextFieldのキーボードを自動的に表示する
                        switch i {
                        case 0:
                            self.textFieldCategoryDebit1.becomeFirstResponder()
                        case 1:
                            self.textFieldCategoryDebit2.becomeFirstResponder()
                        case 2:
                            self.textFieldCategoryDebit3.becomeFirstResponder()
                        case 3:
                            self.textFieldCategoryDebit4.becomeFirstResponder()
                        default:
                            break
                        }
                    }
                }) else {
                    return false // NG
                }
            }
            for i in 0..<creditElements.count {
                // バリデーション 貸方勘定科目　1〜4 入力チェック
                guard textInputCheck(text: creditElements[i].title, editableType: .categoryCredit, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // 未入力のTextFieldのキーボードを自動的に表示する
                        switch i {
                        case 0:
                            self.textFieldCategoryCredit1.becomeFirstResponder()
                        case 1:
                            self.textFieldCategoryCredit2.becomeFirstResponder()
                        case 2:
                            self.textFieldCategoryCredit3.becomeFirstResponder()
                        case 3:
                            self.textFieldCategoryCredit4.becomeFirstResponder()
                        default:
                            break
                        }
                    }
                }) else {
                    return false // NG
                }
            }
            // バリデーション 勘定科目　重複 複合仕訳
            guard textInputCheckDuplicated(debit: debit, debitElements: debitElements, credit: credit, creditElements: creditElements, completion: {
                
            }) else {
                return false // NG
            }
            // バリデーション 金額 貸借一致
            guard textInputCheck(creditAmount: creditAmountTotal, debitAmount: debitAmountTotal, completion: {
                
            }) else {
                return false // NG
            }
        } else {
            // バリデーション 勘定科目　重複　貸借 単一仕訳
            guard textInputCheck(creditText: credit.title, debitText: debit.title, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // 未入力のTextFieldのキーボードを自動的に表示する
                    self.textFieldCategoryCredit.becomeFirstResponder()
                }
            }) else {
                return false // NG
            }
            // バリデーション 金額 貸借一致
            guard textInputCheck(creditAmount: credit.amount, debitAmount: debit.amount, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // 未入力のTextFieldのキーボードを自動的に表示する
                    self.textFieldAmountCredit.becomeFirstResponder()
                }
            }) else {
                return false // NG
            }
        }
        
        // 小書き　バリデーションチェック
        switch ErrorValidation().validateSmallWriting(text: smallWritting ?? "") {
        case .success, .unvalidated:
            errorMessage = nil
        case .failure(let message):
            errorMessage = message
            showErrorMessage(completion: {
                // TextFieldのキーボードを自動的に表示する
                self.textFieldSmallWritting.becomeFirstResponder()
            })
            return false // NG
        }
        
        return true // OK
    }
    // バリデーション 勘定科目、金額 入力チェック
    func textInputCheck(text: String? = nil, amount: Int? = nil, editableType: EditableType, completion: @escaping () -> Void) -> Bool {
        // バリデーションチェック
        switch ErrorValidation().validateEmpty(text: text, amount: amount, editableType: editableType) {
        case .success, .unvalidated:
            errorMessage = nil
        case .failure(let message):
            errorMessage = message
            showErrorMessage(completion: {
                completion()
            })
            return false // NG
        }
        
        return true // OK
    }
    // バリデーション 勘定科目　重複　貸借 単一仕訳
    func textInputCheck(creditText: String?, debitText: String?, completion: @escaping () -> Void) -> Bool {
        // バリデーション 勘定科目
        switch ErrorValidation().validate(creditText: creditText, debitText: debitText) {
        case .success, .unvalidated:
            errorMessage = nil
        case .failure(let message):
            errorMessage = message
            showErrorMessage(completion: {
                completion()
            })
            return false // NG
        }
        
        return true // OK
    }
    // バリデーション 勘定科目　重複 複合仕訳
    func textInputCheckDuplicated(debit: AccountTitleAmount, debitElements: [AccountTitleAmount], credit: AccountTitleAmount, creditElements: [AccountTitleAmount], completion: @escaping () -> Void) -> Bool {
        // バリデーション 勘定科目 重複　複合仕訳
        switch ErrorValidation().validateDuplicated(debit: debit, debitElements: debitElements, credit: credit, creditElements: creditElements) {
        case .success, .unvalidated:
            errorMessage = nil
        case .failure(let message):
            errorMessage = message
            showErrorMessage(completion: {
                completion()
            })
            return false // NG
        }
        
        return true // OK
    }
    // バリデーション 金額　貸借一致
    func textInputCheck(creditAmount: Int?, debitAmount: Int?, completion: @escaping () -> Void) -> Bool {
        // バリデーションチェック
        switch ErrorValidation().validate(creditAmount: creditAmount, debitAmount: debitAmount) {
        case .success, .unvalidated:
            errorMessage = nil
        case .failure(let message):
            errorMessage = message
            showErrorMessage(completion: {
                completion()
            })
            return false // NG
        }
        
        return true // OK
    }
    // エラーダイアログ
    func showErrorMessage(completion: @escaping () -> Void) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorNotification as? UINotificationFeedbackGenerator {
            generator.notificationOccurred(.error)
        }
        let alert = UIAlertController(title: "エラー", message: errorMessage, preferredStyle: .alert)
        self.present(alert, animated: true) { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true, completion: nil)
                completion()
            }
        }
    }
    
    // リワード広告を表示　マネタイズ対応
    func showAd() async {
        guard let ad = rewardedAd else {
            Task {
                // セットアップ AdMob
                await setupAdMob()
            }
            return print("Ad wasn't ready.")
        }
        // The UIViewController parameter is an optional.
        ad.present(fromRootViewController: nil) {
            let reward = ad.adReward
            print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
            // リワード　報酬を獲得
            self.earnCoins(NSInteger(truncating: reward.amount))
        }
    }
    
    // MARK: GADRewardedAd
    // セットアップ AdMob　アップグレード機能　スタンダードプラン
    func setupAdMob() async {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            do {
                // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
                rewardedAd = try await GADRewardedAd.load(
                    withAdUnitID: Constant.ADMOB_ID_REWARD, request: GADRequest()
                )
                rewardedAd?.fullScreenContentDelegate = self
            } catch {
                print("Rewarded ad failed to load with error: \(error.localizedDescription)")
            }
        }
    }
    
    // リワード　報酬を獲得
    fileprivate func earnCoins(_ coins: NSInteger) {
        UserData.rewardAdCoinCount += coins
        // 入力数カウンタラベル
        updateCoinCountLabel()
    }
    
    // MARK: UIButton
    @IBAction func cancelButtonTapped(_ sender: EMTNeumorphicButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // 選択されていたボタンを選択解除する
        let newArray = arrayHugo.filter { $0.isSelected == true }
        for i in newArray {
            i.isSelected = false
        }
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.isSelected = !sender.isSelected
        }
        // 取引要素　借方 貸方　クリア
        debit = AccountTitleAmount()
        credit = AccountTitleAmount()
        // 仕訳タイプ判定
        if journalEntryType == .CompoundJournalEntry { // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
            creditElements = []
            debitElements = []
        }
        // 取引要素 小書き
        smallWritting = nil
        // 終了させる　仕訳帳画面か精算表画面へ戻る
        if journalEntryType != .CompoundJournalEntry && // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
            journalEntryType != .JournalEntry && // 仕訳 タブバーの仕訳タブからの遷移の場合
            journalEntryType != .AdjustingAndClosingEntry { // 決算整理仕訳 タブバーの仕訳タブからの遷移の場合
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // よく使う仕訳画面へ遷移ボタン
    @IBAction func addButtonTapped(_ sender: UIButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        sender.animateView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 別の画面に遷移 仕訳画面
            self.performSegue(withIdentifier: "buttonTapped2", sender: nil)
        }
    }
    // 追加機能　画面遷移の準備の前に入力検証
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "buttonTapped2" {
            return false // false:画面遷移させない
        }
        return true // true: 画面遷移させる
    }
    // 追加機能　画面遷移の準備　仕訳画面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue.destinationの型はUIViewController
        if let controller = segue.destination as? JournalEntryTemplateViewController {
            // 遷移先のコントローラに値を渡す
            if segue.identifier == "buttonTapped2" {
                controller.journalEntryType = .SettingsJournalEntries // セルに表示した仕訳タイプを取得
                // ユーザーが入力した仕訳の内容を取得する
                // 仕訳一括編集　の処理
                let journalEntryData = buttonTappedForJournalEntriesPackageFixing()
                // 仕訳画面で入力された仕訳の内容
                controller.journalEntryData = journalEntryData
            }
        }
        // テキストフィールドのタグ
        if let controller = segue.destination as? ClassicCalculatorViewController {
            
            controller.tag = tag
        }
    }
    
    // インジケータ タップ
    @objc
    private func indicatorDidTap(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - GADFullScreenContentDelegate

extension JournalEntryViewController: GADFullScreenContentDelegate {
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        Task {
            // セットアップ AdMob
            await setupAdMob()
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension JournalEntryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groupObjects.count + 1 // グループ　その他
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CarouselTableViewCell.self), for: indexPath) as? CarouselTableViewCell else { return UITableViewCell() }
        
        cell.collectionView.delegate = self
        cell.collectionView.dataSource = self
        if indexPath.row == groupObjects.count {
            // グループ　その他
            cell.collectionView.tag = 0 // グループの連番
            cell.configure(gropName: "その他")
        } else {
            cell.collectionView.tag = groupObjects[indexPath.row].number // グループの連番
            cell.configure(gropName: groupObjects[indexPath.row].groupName)
        }
        
        return cell
    }
    // cellの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == groupObjects.count {
            // グループ　その他
            let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(group: 0)
            if objects.isEmpty {
                return 30
            } else {
                return tableView.frame.height - 0
            }
        } else {
            // データベース　よく使う仕訳
            let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(group: groupObjects[indexPath.row].number)
            if objects.isEmpty {
                return 30
            } else {
                return tableView.frame.height - 0
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension JournalEntryViewController: UICollectionViewDelegateFlowLayout {
    // セルのサイズ(CGSize)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // データベース　よく使う仕訳
        let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(
            group: collectionView.tag // グループ　その他 collectionView.tag == 0
        )
        // Labelの文字数に合わせてセルの幅を決める
        let size: CGSize = objects[indexPath.row].nickname.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0)])
        // 横画面で、collectionViewの高さから計算した高さがマイナスになる場合の対策
        let height = (collectionView.bounds.size.height / 2) - 0
        return CGSize(width: size.width + 20.0, height: height < 0 ? 0 : height)
    }
    // 余白の調整（UIImageを拡大、縮小している）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // top:ナビゲーションバーの高さ分上に移動
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
}

extension JournalEntryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    // collectionViewの要素の数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // データベース　よく使う仕訳
        let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(
            group: collectionView.tag // グループ　その他 collectionView.tag == 0
        )
        return objects.count
    }
    // collectionViewのセルを返す（セルの内容を決める）
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CarouselCollectionViewCell else { return UICollectionViewCell() }
        // データベース　よく使う仕訳
        let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(
            group: collectionView.tag // グループ　その他 collectionView.tag == 0
        )
        cell.nicknameLabel.text = objects[indexPath.row].nickname
        
        return cell
    }
}

extension JournalEntryViewController: UICollectionViewDelegate {
    
    /// セルの選択時に背景色を変化させる
    /// 今度はセルが選択状態になった時に背景色が青に変化するようにしてみます。
    /// 以下の3つのメソッドはデフォルトでtrueなので、このケースでは実装しなくても良いです。
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("Highlighted: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        print("Unhighlighted: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        true  // 変更
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: \(indexPath)")
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        // データベース　よく使う仕訳
        let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(
            group: collectionView.tag // グループ　その他 collectionView.tag == 0
        )
        DispatchQueue.main.async {
            self.debit = AccountTitleAmount(title: objects[indexPath.row].debit_category, amount: Int(objects[indexPath.row].debit_amount)) // Down cast
            DispatchQueue.main.async {
                self.credit = AccountTitleAmount(title: objects[indexPath.row].credit_category, amount: Int(objects[indexPath.row].credit_amount)) // Down cast
                DispatchQueue.main.async {
                    self.view.endEditing(true)
                }
            }
        }
        smallWritting = objects[indexPath.row].smallWritting
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Deselected: \(indexPath)")
    }
    
    //    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    //        return true  // 変更
    //    }
    
}

// MARK: - UITextFieldDelegate

extension JournalEntryViewController: UITextFieldDelegate {
    
    // キーボード起動時
    //    textFieldShouldBeginEditing
    //    textFieldDidBeginEditing
    // リターン押下時
    //    textFieldShouldReturn before responder
    //    textFieldShouldEndEditing
    //    textFieldDidEndEditing
    //    textFieldShouldReturn
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // 借方金額　貸方金額、小書き
        if textField == textFieldAmountDebit || textField == textFieldAmountCredit ||
            textField == textFieldAmountDebit1 || textField == textFieldAmountCredit1 ||
            textField == textFieldAmountDebit2 || textField == textFieldAmountCredit2 ||
            textField == textFieldAmountDebit3 || textField == textFieldAmountCredit3 ||
            textField == textFieldAmountDebit4 || textField == textFieldAmountCredit4 {
            // 借方勘定科目、貸方勘定科目、小書きのキーボードが表示中に、電卓を表示させないようにする
            if isShown {
                // フォーカスを、貸方勘定科目から、金額へ移す際に、キーボードを閉じる
                // キーボードが表示されている時
                self.view.endEditing(true)
            } else {
                // 隠れている時
                return true
            }
        }
        return true
    }
    
    // 入力開始 テキストフィールがタップされ、入力可能になったあと
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // フォーカス　効果　ドロップシャドウをかける
        textField.layer.shadowOpacity = 1.0
        textField.layer.shadowRadius = 6
        textField.layer.shadowColor = UIColor.calculatorDisplay.cgColor
        textField.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        // 2列目のComponentをリロードする
        if textField == textFieldCategoryDebit {
            textFieldCategoryDebit.reloadComponent()
        } else if textField == textFieldCategoryCredit {
            textFieldCategoryCredit.reloadComponent()
        } else if textField == textFieldCategoryDebit1 {
            textFieldCategoryDebit1.reloadComponent()
        } else if textField == textFieldCategoryCredit1 {
            textFieldCategoryCredit1.reloadComponent()
        } else if textField == textFieldCategoryDebit2 {
            textFieldCategoryDebit2.reloadComponent()
        } else if textField == textFieldCategoryCredit2 {
            textFieldCategoryCredit2.reloadComponent()
        } else if textField == textFieldCategoryDebit3 {
            textFieldCategoryDebit3.reloadComponent()
        } else if textField == textFieldCategoryCredit3 {
            textFieldCategoryCredit3.reloadComponent()
        } else if textField == textFieldCategoryDebit4 {
            textFieldCategoryDebit4.reloadComponent()
        } else if textField == textFieldCategoryCredit4 {
            textFieldCategoryCredit4.reloadComponent()
        }
        
        // 借方金額　貸方金額
        if textField == textFieldAmountDebit || textField == textFieldAmountCredit ||
            textField == textFieldAmountDebit1 || textField == textFieldAmountCredit1 ||
            textField == textFieldAmountDebit2 || textField == textFieldAmountCredit2 ||
            textField == textFieldAmountDebit3 || textField == textFieldAmountCredit3 ||
            textField == textFieldAmountDebit4 || textField == textFieldAmountCredit4 {
            // テキストフィールドのタグ
            tag = textField.tag
            // 電卓画面へ遷移させるために要る
            self.view.endEditing(true)
        }
    }
    // 文字クリア
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            return true
        } else {
            return false
        }
    }
    // textFieldに文字が入力される際に呼ばれる　入力チェック(半角数字、文字数制限)
    // 戻り値にtrueを返すと入力した文字がTextFieldに反映され、falseを返すと入力した文字が反映されない。
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var resultForCharacter = false
        var resultForLength = false
        // 入力チェック　数字のみに制限
        if textField == textFieldAmountDebit || textField == textFieldAmountCredit ||
            textField == textFieldAmountDebit1 || textField == textFieldAmountCredit1 ||
            textField == textFieldAmountDebit2 || textField == textFieldAmountCredit2 ||
            textField == textFieldAmountDebit3 || textField == textFieldAmountCredit3 ||
            textField == textFieldAmountDebit4 || textField == textFieldAmountCredit4 { // 借方金額仮　貸方金額
            //            let allowedCharacters = CharacterSet(charactersIn: ",0123456789")// Here change this characters based on your requirement
            //            let characterSet = CharacterSet(charactersIn: string)
            //            // 指定したスーパーセットの文字セットでないならfalseを返す
            //            resultForCharacter = allowedCharacters.isSuperset(of: characterSet)
        } else {  // 小書き　ニックネーム
            let notAllowedCharacters = CharacterSet(charactersIn: ",") // 除外したい文字。絵文字はInterface BuilderのKeyboardTypeで除外してある。
            let characterSet = CharacterSet(charactersIn: string)
            // 指定したスーパーセットの文字セットならfalseを返す
            resultForCharacter = !(notAllowedCharacters.isSuperset(of: characterSet))
        }
        // 入力チェック　文字数最大数を設定
        var maxLength: Int = 0 // 文字数最大値を定義
        switch textField.tag {
            // 金額の文字数 + カンマの数 (100万円の位まで入力可能とする)
        case 333, 444, 777, 888, 111_111, 121_212, 151_515, 161_616, 191_919, 202_020:
            maxLength = 7 + 2
        case 212121: // 小書きの文字数
            maxLength = EditableType.smallWriting.maxLength
        case 222222: // ニックネームの文字数
            maxLength = EditableType.nickname.maxLength
        default:
            break
        }
        // textField内の文字数
        let textFieldTextCount = textField.text?.count ?? 0
        // 入力された文字数
        let stringCount = string.count
        // 最大文字数以上ならfalseを返す
        resultForLength = textFieldTextCount + stringCount <= maxLength
        // 文字列が0文字の場合、backspaceキーが押下されたということなので反映させる
        if string.isEmpty {
            // textField.deleteBackward() うまくいかない
            // 末尾の1文字を削除
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if isBackSpace == -92 {
                    print("Backspace was pressed")
                    return true
                }
            }
        }
        // 判定
        if !resultForCharacter {
            // 指定したスーパーセットの文字セットでないならfalseを返す
            return false
        } else if !resultForLength {
            // 最大文字数以上 入力制限はしない
            return true
        } else {
            return true
        }
    }
    // リターンキー押下でキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // キーボードを閉じる前
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //        print(#function)
        //        print("キーボードを閉じる前")
        return true
    }
    // キーボードを閉じたあと
    func textFieldDidEndEditing(_ textField: UITextField) {
        //        print(#function)
        //        print("キーボードを閉じた後")
        // フォーカス　効果　フォーカスが外れたら色を消す
        textField.layer.shadowColor = UIColor.clear.cgColor
        
        if textField.tag == 111 { // 借方勘定科目
            debit.title = textField.text
        } else if textField.tag == 222 { // 貸方勘定科目
            credit.title = textField.text
        } else if textField.tag == 555 { // 借方勘定科目
            debitElements[0].title = textField.text
        } else if textField.tag == 666 { // 貸方勘定科目
            creditElements[0].title = textField.text
        } else if textField.tag == 999 { // 借方勘定科目
            debitElements[1].title = textField.text
        } else if textField.tag == 101010 { // 貸方勘定科目
            creditElements[1].title = textField.text
        } else if textField.tag == 131313 { // 借方勘定科目
            debitElements[2].title = textField.text
        } else if textField.tag == 141414 { // 貸方勘定科目
            creditElements[2].title = textField.text
        } else if textField.tag == 171717 { // 借方勘定科目
            debitElements[3].title = textField.text
        } else if textField.tag == 181818 { // 貸方勘定科目
            creditElements[3].title = textField.text
        }
    }
    // TextFieldに入力され値が変化した時の処理の関数
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            // カンマを追加する
            if textField == textFieldAmountDebit || textField == textFieldAmountCredit ||
                textField == textFieldAmountDebit1 || textField == textFieldAmountCredit1 ||
                textField == textFieldAmountDebit2 || textField == textFieldAmountCredit2 ||
                textField == textFieldAmountDebit3 || textField == textFieldAmountCredit3 ||
                textField == textFieldAmountDebit4 || textField == textFieldAmountCredit4 { // 借方金額仮　貸方金額
                // 通らない
            } else if textField == textFieldSmallWritting {
                // 小書き
                smallWritting = text.description
            }
            // print("\(String(describing: sender.text))") // カンマを追加する前にシスアウトすると、カンマが上位のくらいから3桁ごとに自動的に追加される。
        }
    }
}

extension JournalEntryViewController: JournalEntryPresenterOutput {
    
    func setupUI() {
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
        // ニューモフィズム　ボタンとビューのデザインを指定する
        createEMTNeumorphicView()
        // UIパーツを作成
        createTextFieldForSmallwritting()
    }
    
    // MARK: - 生体認証パスコードロック
    
    // 生体認証パスコードロック画面へ遷移させる
    func showPassCodeLock() {
        // パスコードロックを設定していない場合は何もしない
        if !UserDefaults.standard.bool(forKey: "biometrics_switch") {
            return
        }
        // 生体認証パスコードロック　フォアグラウンドへ戻ったとき
        let ud = UserDefaults.standard
        let firstLunchKey = "biometrics"
        if ud.bool(forKey: firstLunchKey) {
            DispatchQueue.global(qos: .default).async {
                DispatchQueue.main.async {
                    // 生体認証パスコードロック
                    if let viewController = UIStoryboard(name: "PassCodeLockViewController", bundle: nil)
                        .instantiateViewController(withIdentifier: "PassCodeLockViewController") as? PassCodeLockViewController {
                        
                        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                            
                            // 現在のrootViewControllerにおいて一番上に表示されているViewControllerを取得する
                            var topViewController: UIViewController = rootViewController
                            while let presentedViewController = topViewController.presentedViewController {
                                topViewController = presentedViewController
                            }
                            
                            // すでにパスコードロック画面がかぶせてあるかを確認する
                            let isDisplayedPasscodeLock: Bool = topViewController.children.map {
                                $0 is PassCodeLockViewController
                            }
                                .contains(true)
                            
                            // パスコードロック画面がかぶせてなければかぶせる
                            if !isDisplayedPasscodeLock {
                                let nav = UINavigationController(rootViewController: viewController)
                                nav.modalPresentationStyle = .overFullScreen
                                nav.modalTransitionStyle   = .crossDissolve
                                topViewController.present(nav, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: UI更新
    
    func updateUI() {
        // 仕訳タイプ判定
        if journalEntryType != .CompoundJournalEntry && journalEntryType != .JournalEntry && journalEntryType != .AdjustingAndClosingEntry {
            indicatorView.isHidden = false
        } else {
            indicatorView.isHidden = true
        }
        // 仕訳タイプ判定
        if journalEntryType == .JournalEntry || journalEntryType == .AdjustingAndClosingEntry {
            // 単一仕訳/複合仕訳　切り替え
            compoundJournalEntrySegmentedControl.selectedSegmentIndex = UserDefaults.standard.bool(forKey: "compound_journal_entry") ? 1 : 0
            // 単一仕訳/複合仕訳　切り替え
            if compoundJournalEntrySegmentedControl.selectedSegmentIndex == 0 {
                // 仕訳 タブバーの仕訳タブからの遷移の場合
            } else {
                journalEntryType = .CompoundJournalEntry // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
            }
        }
        // 仕訳タイプ判定
        if journalEntryType == .CompoundJournalEntry { // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
            // タブバーの仕訳タブからの遷移の場合 表示させる
            compoundJournalEntrySegmentedControl.isHidden = false
            // 仕訳/決算整理仕訳　切り替え
            segmentedControl.isHidden = false
            // 仕訳に固定する
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.isEnabled = false
            // よく使う仕訳　エリア
            tableView.isHidden = true
            // よく使う仕訳　エリア
            journalEntryTemplateView.isHidden = true
            // 仕訳画面表示ボタン
            addButton.isHidden = true
            // 勘定科目エリア　余白
            spaceView.isHidden = false
            self.navigationItem.title = "仕訳"
            labelTitle.text = ""
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
        } else if journalEntryType == .JournalEntry { // 仕訳 タブバーの仕訳タブからの遷移の場合
            // タブバーの仕訳タブからの遷移の場合 表示させる
            compoundJournalEntrySegmentedControl.isHidden = false
            // 仕訳/決算整理仕訳　切り替え
            segmentedControl.isHidden = false
            // 仕訳に固定を解除する
            segmentedControl.isEnabled = true
            segmentedControl.isHidden = false
            // アプリ起動時に、アプリがバックグラウンドにいるとnilでクラッシュしてしまう対策
            if let tableView = tableView {
                // よく使う仕訳　エリア
                tableView.isHidden = false
            }
            if let journalEntryTemplateView = journalEntryTemplateView {
                // よく使う仕訳　エリア
                journalEntryTemplateView.isHidden = false
            }
            if let addButton = addButton {
                // 仕訳画面表示ボタン
                addButton.isHidden = false
            }
            if let spaceView = spaceView {
                // 勘定科目エリア　余白
                spaceView.isHidden = true
            }
            self.navigationItem.title = "仕訳"
            if let labelTitle = labelTitle {
                labelTitle.text = ""
            }
            // カルーセルを追加しても、仕訳画面に戻ってきても反映されないので、viewDidLoadからviewWillAppearへ移動
            // カルーセルをリロードする
            reloadCarousel()
            if let _ = datePicker {
                createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
            }
        } else if journalEntryType == .AdjustingAndClosingEntry {
            // タブバーの仕訳タブからの遷移の場合 表示させる
            compoundJournalEntrySegmentedControl.isHidden = false
            // 仕訳/決算整理仕訳　切り替え
            segmentedControl.isHidden = false
            // よく使う仕訳　エリア
            tableView.isHidden = false
            // よく使う仕訳　エリア
            journalEntryTemplateView.isHidden = false
            // 仕訳画面表示ボタン
            addButton.isHidden = false
            // 勘定科目エリア　余白
            spaceView.isHidden = true
            self.navigationItem.title = "決算整理仕訳"
            labelTitle.text = ""
            // カルーセルをリロードする
            reloadCarousel()
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
        } else if journalEntryType == .JournalEntries { // 仕訳 仕訳帳画面からの遷移の場合
            // タブバーの仕訳タブからの遷移以外の場合 表示させない
            compoundJournalEntrySegmentedControl.isHidden = true
            // 仕訳/決算整理仕訳　切り替え
            segmentedControl.isHidden = true
            // よく使う仕訳　エリア
            tableView.isHidden = false
            // 勘定科目エリア　余白
            spaceView.isHidden = true
            self.navigationItem.title = "仕訳"
            labelTitle.text = ""
            // カルーセルを追加しても、仕訳画面に戻ってきても反映されないので、viewDidLoadからviewWillAppearへ移動
            // カルーセルをリロードする
            reloadCarousel()
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
        } else if journalEntryType == .AdjustingAndClosingEntries { // 決算整理仕訳 精算表画面からの遷移の場合
            // タブバーの仕訳タブからの遷移以外の場合 表示させない
            compoundJournalEntrySegmentedControl.isHidden = true
            // 仕訳/決算整理仕訳　切り替え
            segmentedControl.isHidden = true
            // よく使う仕訳　エリア
            tableView.isHidden = false
            // 勘定科目エリア　余白
            spaceView.isHidden = true
            self.navigationItem.title = "決算整理仕訳"
            labelTitle.text = ""
            // カルーセルをリロードする
            reloadCarousel()
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
        } else if journalEntryType == .JournalEntriesFixing { // 仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
            // タブバーの仕訳タブからの遷移以外の場合 表示させない
            compoundJournalEntrySegmentedControl.isHidden = true
            // 仕訳/決算整理仕訳　切り替え
            segmentedControl.isHidden = true
            // よく使う仕訳　エリア
            tableView.isHidden = true
            // 勘定科目エリア　余白
            spaceView.isHidden = true
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
            // 通常仕訳
            labelTitle.text = "仕訳 編集"
            if let dataBaseJournalEntry = DataBaseManagerJournalEntry.shared.getJournalEntryWithNumber(number: primaryKey),
               // データベースに保持した日付をUIのピッカーに渡すために、yyyy/MM/dd形式でDate型へ変換するために使用する
               let date = DateManager.shared.dateFormatterStringToDate.date(from: dataBaseJournalEntry.date),
               let date = DateManager.shared.dateFormatterPicker.date(from: "\(date.month)/\(date.day)/\(date.year)") {
                datePicker.date = date // 注意：カンマの後にスペースがないとnilになる
                DispatchQueue.main.async {
                    self.debit = AccountTitleAmount(title: dataBaseJournalEntry.debit_category, amount: Int(dataBaseJournalEntry.debit_amount))
                    DispatchQueue.main.async {
                        self.credit = AccountTitleAmount(title: dataBaseJournalEntry.credit_category, amount: Int(dataBaseJournalEntry.credit_amount))
                        DispatchQueue.main.async {
                            self.view.endEditing(true)
                        }
                    }
                }
                smallWritting = dataBaseJournalEntry.smallWritting
            }
            inputButton.setTitle("更　新", for: UIControl.State.normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
        } else if journalEntryType == .AdjustingEntriesFixing { // 決算整理仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
            // タブバーの仕訳タブからの遷移以外の場合 表示させない
            compoundJournalEntrySegmentedControl.isHidden = true
            // 仕訳/決算整理仕訳　切り替え
            segmentedControl.isHidden = true
            // よく使う仕訳　エリア
            tableView.isHidden = true
            // 勘定科目エリア　余白
            spaceView.isHidden = true
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
            // 決算整理仕訳
            labelTitle.text = "決算整理仕訳 編集"
            if let dataBaseJournalEntry = DataBaseManagerAdjustingEntry.shared.getAdjustingEntryWithNumber(number: primaryKey),
               // データベースに保持した日付をUIのピッカーに渡すために、yyyy/MM/dd形式でDate型へ変換するために使用する
               let date = DateManager.shared.dateFormatterStringToDate.date(from: dataBaseJournalEntry.date),
               let date = DateManager.shared.dateFormatterPicker.date(from: "\(date.month)/\(date.day)/\(date.year)") {
                datePicker.date = date // 注意：カンマの後にスペースがないとnilになる
                DispatchQueue.main.async {
                    self.debit = AccountTitleAmount(title: dataBaseJournalEntry.debit_category, amount: Int(dataBaseJournalEntry.debit_amount))
                    DispatchQueue.main.async {
                        self.credit = AccountTitleAmount(title: dataBaseJournalEntry.credit_category, amount: Int(dataBaseJournalEntry.credit_amount))
                        DispatchQueue.main.async {
                            self.view.endEditing(true)
                        }
                    }
                }
                smallWritting = dataBaseJournalEntry.smallWritting
            }
            inputButton.setTitle("更　新", for: UIControl.State.normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
        } else if journalEntryType == .JournalEntriesPackageFixing { // 仕訳一括編集 仕訳帳画面からの遷移の場合
            // タブバーの仕訳タブからの遷移以外の場合 表示させない
            compoundJournalEntrySegmentedControl.isHidden = true
            // 仕訳/決算整理仕訳　切り替え
            segmentedControl.isHidden = true
            // 勘定科目エリア　余白
            spaceView.isHidden = true
            labelTitle.text = "仕訳 まとめて編集"
            // よく使う仕訳　エリア
            tableView.isHidden = true
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
            maskDatePickerButton.isHidden = false
            // デイトピッカーのマスク
            isMaskedDatePicker = false
            inputButton.setTitle("更　新", for: UIControl.State.normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
        }
        Task {
            // セットアップ AdMob
            await setupAdMob()
        }
        if let _ = coinCountLabel {
            // 入力数カウンタラベル
            updateCoinCountLabel()
        }
    }
    
    // MARK: インジゲーター
    // インジゲーターを開始
    func showActivityIndicatorView() {
        DispatchQueue.main.async {
            self.editButtonItem.isEnabled = false // 編集ボタン
            self.segmentedControl.isEnabled = false
            self.compoundJournalEntrySegmentedControl.isEnabled = false
            // 仕訳画面表示ボタン
            self.addButton.isEnabled = false
            
            // タブの無効化
            if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
                for tabBarItem in arrayOfTabBarItems {
                    if let tabBarItem = tabBarItem as? UITabBarItem {
                        tabBarItem.isEnabled = false
                    }
                }
            }
            // 背景になるView
            self.backView.backgroundColor = .mainColor
            // 表示位置を設定（画面中央）
            self.activityIndicatorView.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            // インジケーターのスタイルを指定（白色＆大きいサイズ）
            self.activityIndicatorView.style = UIActivityIndicatorView.Style.large
            
            self.activityIndicatorView.color = UIColor.mainColor
            // インジケーターを View に追加
            self.backView.addSubview(self.activityIndicatorView)
            // インジケーターを表示＆アニメーション開始
            self.activityIndicatorView.startAnimating()
            
            // tabBarControllerのViewを使う
            guard let tabBarView = self.tabBarController?.view else {
                return
            }
            // 背景をNavigationControllerのViewに貼り付け
            tabBarView.addSubview(self.backView)
            
            // サイズ合わせはAutoLayoutで
            self.backView.translatesAutoresizingMaskIntoConstraints = false
            self.backView.topAnchor.constraint(equalTo: tabBarView.topAnchor).isActive = true
            self.backView.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor).isActive = true
            self.backView.leftAnchor.constraint(equalTo: tabBarView.leftAnchor).isActive = true
            self.backView.rightAnchor.constraint(equalTo: tabBarView.rightAnchor).isActive = true
        }
    }
    // インジケーターを終了
    func finishActivityIndicatorView() {
        // 非同期処理などが終了したらメインスレッドでアニメーション終了
        DispatchQueue.main.async {
            // 非同期処理などを実行（今回は2秒間待つだけ）
            Thread.sleep(forTimeInterval: 1.0)
            self.editButtonItem.isEnabled = true // 編集ボタン
            self.segmentedControl.isEnabled = true
            self.compoundJournalEntrySegmentedControl.isEnabled = true
            // 仕訳画面表示ボタン
            self.addButton.isEnabled = true
            // アニメーション終了
            self.activityIndicatorView.stopAnimating()
            // タブの有効化
            if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
                for tabBarItem in arrayOfTabBarItems {
                    if let tabBarItem = tabBarItem as? UITabBarItem {
                        tabBarItem.isEnabled = true
                    }
                }
            }
            self.backView.removeFromSuperview()
        }
    }
    
    // MARK: - チュートリアル対応 ウォークスルー型
    
    // チュートリアル対応 ウォークスルー型
    func showWalkThrough() {
        // チュートリアル対応 ウォークスルー型　初回起動時
        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunch_WalkThrough"
        if userDefaults.bool(forKey: firstLunchKey) {
            DispatchQueue.global(qos: .default).async {
                // 非同期処理などを実行（今回は3秒間待つだけ）
                Thread.sleep(forTimeInterval: 0)
                DispatchQueue.main.async {
                    // チュートリアル対応 ウォークスルー型
                    if let viewController = UIStoryboard(
                        name: "WalkThroughViewController",
                        bundle: nil
                    ).instantiateViewController(
                        withIdentifier: "WalkThroughViewController"
                    ) as? WalkThroughViewController {
                        viewController.modalPresentationStyle = .fullScreen
                        self.present(viewController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // チュートリアル対応 コーチマーク型　コーチマークを開始
    func presentAnnotation() {
        // タブの無効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
            }
        }
        if let viewController = UIStoryboard(
            name: "JournalEntryViewController",
            bundle: nil
        ).instantiateViewController(
            withIdentifier: "Annotation_JournalEntry"
        ) as? AnnotationViewControllerJournalEntry {
            viewController.alpha = 0.7
            present(viewController, animated: true, completion: nil)
        }
    }
    
    // MARK: ダイアログ
    
    // ダイアログ　オフライン
    func showDialogForOfline() {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorNotification as? UINotificationFeedbackGenerator {
            generator.notificationOccurred(.error)
        }
        // ネットワークなし
        let alertController = UIAlertController(
            title: "インターネット未接続",
            message: "オフラインでは利用できません。\n\nスタンダードプランに\nアップグレードしていただくと、\nオフラインでも利用可能となります。",
            preferredStyle: .alert
        )
        
        // 選択肢の作成と追加
        // titleに選択肢のテキストを、styleに.defaultを
        // handlerにボタンが押された時の処理をクロージャで実装する
        alertController.addAction(
            UIAlertAction(
                title: "OK",
                style: .default,
                handler: { (action: UIAlertAction!) -> Void in
                    // OKボタン ダイアログ　オフライン
                    self.presenter.okButtonTappedDialogForOfline()
                }
            )
        )
        self.present(alertController, animated: true, completion: nil)
    }
    
    // ダイアログ　日付と借方勘定科目、貸方勘定科目、金額が同一
    func showDialogForSameJournalEntry(journalEntryType: JournalEntryType, journalEntryData: JournalEntryData) {
        // いづれかひとつに値があれば下記を実行する
        let alert = UIAlertController(
            title: "確認",
            message: "日付と借方勘定科目、貸方勘定科目、金額が同じ内容の仕訳がすでに存在します。そのまま仕訳を入力しますか？",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .destructive,
                handler: { _ in
                    print("OK アクションをタップした時の処理")
                    
                    self.presenter.inputButtonTapped(isForced: true, journalEntryType: journalEntryType, journalEntryData: journalEntryData, journalEntryDatas: nil, primaryKey: nil)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { _ in
                    print("Cancel アクションをタップした時の処理")
                }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    // ダイアログ　ほんとうに変更しますか？
    func showDialogForFinal(journalEntryData: JournalEntryData) {
        // いづれかひとつに値があれば下記を実行する
        let alert = UIAlertController(
            title: "最終確認",
            message: "ほんとうに変更しますか？\n日付: \(journalEntryData.date ?? "")\n借方勘定: \(journalEntryData.debit_category ?? "")\n貸方勘定: \(journalEntryData.credit_category ?? "")\n金額: \(journalEntryData.credit_amount?.description ?? "")\n小書き: \(journalEntryData.smallWritting ?? "")",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .destructive,
                handler: { _ in
                    print("OK アクションをタップした時の処理")
                    
                    self.presenter.inputButtonTapped(isForced: true, journalEntryType: self.journalEntryType, journalEntryData: journalEntryData, journalEntryDatas: nil, primaryKey: nil)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { _ in
                    print("Cancel アクションをタップした時の処理")
                }
            )
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    // ダイアログ　リワード広告　仕訳を入力する（広告動画を見る）/　広告を非表示（アップグレード）
    func showDialogForRewardAd() {
        // ポップアップを表示させる
        if let viewController = UIStoryboard(
            name: "PopUpDialogViewController",
            bundle: nil
        ).instantiateViewController(
            withIdentifier: "PopUpDialogViewController"
        ) as? PopUpDialogViewController {
            viewController.modalPresentationStyle = .overCurrentContext
            viewController.modalTransitionStyle = .crossDissolve
            // tabBarControllerのViewを使う
            guard let tabBarController = self.tabBarController else {
                // 遷移元画面が、仕訳入力後に、モーダル表示している場合
                self.present(viewController, animated: true, completion: nil)
                return
            }
            tabBarController.present(viewController, animated: true, completion: nil)
        }
    }
    
    // ダイアログ 記帳しました
    func showDialogForSucceed() {
        // 入力中のキーボード　小書き不要の場合に、入力ボタンを押下された場合 フォーカスされている状態を外す
        self.textFieldSmallWritting.resignFirstResponder()
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorNotification as? UINotificationFeedbackGenerator {
            generator.notificationOccurred(.success)
        }
        let alert = UIAlertController(title: "仕訳", message: "記帳しました", preferredStyle: .alert)
        self.present(alert, animated: true) { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true)
            }
        }
    }
    
    // MARK: 画面遷移
    
    // 画面を閉じる　仕訳帳へ編集した仕訳データを渡す
    func closeScreen(journalEntryData: JournalEntryData) {
        if let tabBarController = self.presentingViewController as? UITabBarController, // 一番基底となっているコントローラ
           let navigationController = tabBarController.selectedViewController as? UINavigationController, // 基底のコントローラから、現在選択されているコントローラを取得する
           let presentingViewController = navigationController.viewControllers.first as? JournalsViewController { // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
            // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                // 編集を終了する
                presentingViewController.setEditing(false, animated: true)
                presentingViewController.dBJournalEntry = journalEntryData
                presentingViewController.updateSelectedJournalEntries()
            })
        }
    }
    
    // アップグレード画面を表示
    func showUpgradeScreen() {
        DispatchQueue.main.async {
            if let viewController = UIStoryboard(
                name: "SettingsUpgradeViewController",
                bundle: nil
            ).instantiateViewController(withIdentifier: "SettingsUpgradeViewController") as? SettingsUpgradeViewController {
                // ナビゲーションバーを表示させる
                let navigation = UINavigationController(rootViewController: viewController)
                self.present(navigation, animated: true, completion: nil)
            }
        }
    }
    
    // 決算整理仕訳後に遷移元画面へ戻る
    func goBackToPreviousScreen() {
        // 精算表画面から入力の場合
        if let tabBarController = self.presentingViewController as? UITabBarController, // 一番基底となっているコントローラ
           let navigationController = tabBarController.selectedViewController as? UINavigationController, // 基底のコントローラから、現在選択されているコントローラを取得する
           let presentingViewController = navigationController.viewControllers[1] as? WSViewController { // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
            // viewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                presentingViewController.reloadData()
            })
        }
        // タブバーの仕訳タブから入力の場合
        else {
            // フィードバック
            if #available(iOS 10.0, *), let generator = feedbackGeneratorNotification as? UINotificationFeedbackGenerator {
                generator.notificationOccurred(.success)
            }
            let alert = UIAlertController(title: "決算整理仕訳", message: "記帳しました", preferredStyle: .alert)
            self.present(alert, animated: true) { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    // 勘定画面・仕訳帳画面へ戻る
    func goBackToJournalsScreen(number: Int) {
        // 勘定画面へ戻る
        if let navigationController = presentingViewController as? UINavigationController,
           let viewController = navigationController.topViewController as? GeneralLedgerAccountViewController {
            self.dismiss(animated: true, completion: { [viewController] () -> Void in
                // 仕訳入力ボタンから勘定画面へ遷移して入力が終わったときに呼ばれる。通常仕訳:0 決算整理仕訳:1
                viewController.reloadData()
            })
        }
        // 仕訳帳画面へ戻る
        if let tabBarController = self.presentingViewController as? UITabBarController, // 一番基底となっているコントローラ
           let navigationController = tabBarController.selectedViewController as? UINavigationController, // 基底のコントローラから、現在選択されているコントローラを取得する
           let presentingViewController = navigationController.viewControllers.first as? JournalsViewController { // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
            // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                presentingViewController.autoScrollToCell(number: number, tappedIndexPathSection: self.tappedIndexPath.section)
            })
        }
    }
    
    // 仕訳帳画面へ戻る
    func goBackToJournalsScreenJournalEntry(number: Int) {
        
        if let tabBarController = self.presentingViewController as? UITabBarController, // 一番基底となっているコントローラ
           let navigationController = tabBarController.selectedViewController as? UINavigationController, // 基底のコントローラから、現在選択されているコントローラを取得する
           let presentingViewController = navigationController.viewControllers.first as? JournalsViewController { // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
            // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                presentingViewController.autoScrollToCell(number: number, tappedIndexPathSection: 0) // 0:通常仕訳
            })
        }
    }
}

// 仕訳タイプ(仕訳 or 決算整理仕訳 or 編集)
enum JournalEntryType {
    // MARK: タブバーの仕訳タブ
    // 仕訳 タブバーの仕訳タブからの遷移の場合
    case JournalEntry
    // 決算整理仕訳 タブバーの仕訳タブからの遷移の場合
    case AdjustingAndClosingEntry
    // 仕訳 複合仕訳　タブバーの仕訳タブからの遷移の場合
    case CompoundJournalEntry
    
    // MARK: 仕訳帳画面
    // 仕訳 仕訳帳画面からの遷移の場合
    case JournalEntries
    
    // MARK: 精算表画面
    // 決算整理仕訳 精算表画面からの遷移の場合
    case AdjustingAndClosingEntries
    
    // MARK: 勘定画面・仕訳帳画面
    // 仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
    case JournalEntriesFixing
    // 決算整理仕訳編集 勘定画面・仕訳帳画面からの遷移の場合
    case AdjustingEntriesFixing
    
    // MARK: 仕訳帳画面
    // 仕訳一括編集 仕訳帳画面からの遷移の場合
    case JournalEntriesPackageFixing
    
    // MARK: 画面
    // よく使う仕訳 追加
    case SettingsJournalEntries
    // よく使う仕訳 更新
    case SettingsJournalEntriesFixing
    
    // 未決定
    case Undecided
}

// 取引要素
struct AccountTitleAmount {
    var title: String?
    var amount: Int?
}
