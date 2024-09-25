//
//  JournalEntryTemplateViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/10.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import UIKit

// よく使う仕訳クラス
class JournalEntryTemplateViewController: JournalEntryViewController {
    
    @IBOutlet private var nicknameTextField: UITextField!
    @IBOutlet private var nicknameCounterLabel: UILabel!
    @IBOutlet private var nicknameView: EMTNeumorphicView!
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
    // 仕訳画面で入力された仕訳の内容
    var journalEntryData: JournalEntryData? {
        didSet {
            DispatchQueue.main.async {
                if let journalEntryData = self.journalEntryData {
                    DispatchQueue.main.async {
                        self.debit = AccountTitleAmount(title: journalEntryData.debit_category, amount: Int(journalEntryData.debit_amount ?? 0))
                        DispatchQueue.main.async {
                            self.credit = AccountTitleAmount(title: journalEntryData.credit_category, amount: Int(journalEntryData.credit_amount ?? 0))
                            DispatchQueue.main.async {
                                self.view.endEditing(true)
                            }
                        }
                    }
                    self.smallWritting = journalEntryData.smallWritting
                }
            }
        }
    }
    // ニックネーム
    var nickname: String? {
        didSet {
            nicknameTextField.text = nickname
            // ニックネーム　文字数カウンタ
            let maxLength = EditableType.nickname.maxLength
            nicknameCounterLabel.font = .boldSystemFont(ofSize: 15)
            nicknameCounterLabel.text = "\(maxLength - (nickname?.count ?? 0))/\(maxLength)  "
            if nickname?.count ?? 0 > maxLength {
                nicknameCounterLabel.textColor = .systemPink
            } else {
                nicknameCounterLabel.textColor = nickname?.count ?? 0 >= maxLength - 3 ? .systemYellow : .systemGreen
            }
            if nickname?.count == maxLength {
                // フィードバック
                if #available(iOS 10.0, *), let generator = feedbackGeneratorNotification as? UINotificationFeedbackGenerator {
                    generator.notificationOccurred(.error)
                }
            }
        }
    }
    // TODO: テキストフィールドから値を取得しているところは、変数で管理するように変更する
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // UIパーツを作成
        createTextFieldForNickname() // テキストフィールド　ニックネームを作成
        
        if journalEntryType == .SettingsJournalEntries {
            labelTitle.text = "よく使う仕訳"
            inputButton.setTitle("追　加", for: UIControl.State.normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
            deleteButton.isHidden = true
        } else if journalEntryType == .SettingsJournalEntriesFixing {
            labelTitle.text = "よく使う仕訳 編集"
            inputButton.setTitle("更　新", for: UIControl.State.normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
            deleteButton.isHidden = false
            // データベース　よく使う仕訳を追加
            let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(number: primaryKey)
            if let object = objects.first {
                primaryKey = object.number
                nickname = object.nickname
                let dBJournalEntry = JournalEntryData(
                    date: nil,
                    debit_category: object.debit_category,
                    debit_amount: object.debit_amount,
                    credit_category: object.credit_category,
                    credit_amount: object.credit_amount,
                    smallWritting: object.smallWritting
                )
                journalEntryData = dBJournalEntry
            }
        }
    }
    
    override func createEMTNeumorphicView() {
        super.createEMTNeumorphicView()
        
        if let view = nicknameView {
            view.neumorphicLayer?.cornerRadius = 15
            view.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            view.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            view.neumorphicLayer?.edged = Constant.edged
            view.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            view.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
            view.neumorphicLayer?.depthType = .concave
        }
    }
    // TextField作成 ニックネーム
    func createTextFieldForNickname() {
        nicknameTextField.delegate = self
        // テキストの入力位置を指すライン、これはカーソルではなくキャレット(caret)と呼ぶそうです。
        nicknameTextField.tintColor = UIColor.accentColor
        // toolbar 小書き Done:Tag Cancel:Tag
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)!, height: 44)
        //       toolbar.backgroundColor = UIColor.clear// 名前で指定する
        //       toolbar.barTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)// RGBで指定する    alpha 0透明　1不透明
        toolbar.isTranslucent = true
        //       toolbar.barStyle = .default
        let doneButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonTapped(_:)))
        doneButtonItem.tag = 8
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(barButtonTapped(_:)))
        cancelItem.tag = 88
        toolbar.setItems([cancelItem, flexSpaceItem, doneButtonItem], animated: true)
        nicknameTextField.inputAccessoryView = toolbar
        
        nicknameTextField.layer.borderWidth = 0.5
        // 最大文字数
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    // TextFieldに入力され値が変化した時の処理の関数
    @objc
    override func textFieldDidChange(_ sender: UITextField) {
        super.textFieldDidChange(sender)
        
        if let text = sender.text {
            if sender == nicknameTextField {
                nickname = text.description
            }
        }
    }
    
    @objc
    override func barButtonTapped(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 8: // ニックネームの場合 Done
            self.view.endEditing(true)
        case 88: // ニックネームの場合 Cancel
            self.view.endEditing(true)// textFieldDidEndEditingで貸方金額へコピーするのでtextを設定した後に実行
        default:
            self.view.endEditing(true)
        }
    }
    
    @IBAction override func inputButtonTapped(_ sender: EMTNeumorphicButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorHeavy as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // 選択されていたボタンを選択解除する
        sender.isSelected = false
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.isSelected = !sender.isSelected
        }
        // バリデーションチェック
        if self.textInputCheckForSettingsJournalEntries() {
            if journalEntryType == .SettingsJournalEntries {
                // 追加
                buttonTappedForSettingsJournalEntries()
            } else if journalEntryType == .SettingsJournalEntriesFixing {
                // 更新
                buttonTappedForSettingsJournalEntriesFixing()
            }
        }
        // シスログ出力
        // printによる出力はUTCになってしまうので、9時間ずれる
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current // UTC時刻を補正
        formatter.dateFormat = "yyyy/MM/dd"     // 注意：　小文字のyにしなければならない
        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
    }
    // 入力チェック　バリデーション よく使う仕訳
    func textInputCheckForSettingsJournalEntries() -> Bool {
        // ニックネーム　バリデーションチェック
        switch ErrorValidation().validateNickname(text: nickname ?? "") {
        case .success, .unvalidated:
            errorMessage = nil
        case .failure(let message):
            errorMessage = message
            showErrorMessage(completion: {
                // TextFieldのキーボードを自動的に表示する
                self.nicknameTextField.becomeFirstResponder()
            })
            return false // NG
        }
        // バリデーション 勘定科目
        switch ErrorValidation().validate(creditText: credit.title, debitText: debit.title) {
        case .success, .unvalidated:
            errorMessage = nil
        case .failure(let message):
            errorMessage = message
            showErrorMessage(completion: {
            })
            return false // NG
        }
        // バリデーション 金額　貸借一致
        switch ErrorValidation().validate(creditAmount: credit.amount, debitAmount: debit.amount) {
        case .success, .unvalidated:
            errorMessage = nil
        case .failure(let message):
            errorMessage = message
            showErrorMessage(completion: {
                // 未入力のTextFieldのキーボードを自動的に表示する
                self.textFieldAmountCredit.becomeFirstResponder()
            })
            return false // NG
        }
        // バリデーションチェック　小書き　
        switch ErrorValidation().validateSmallWriting(text: textFieldSmallWritting.text ?? "") {
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
    // 追加
    func buttonTappedForSettingsJournalEntries() {
        var number = 0
        // データベース　よく使う仕訳を追加
        number = DataBaseManagerSettingsOperatingJournalEntry.shared.addJournalEntry(
            nickname: nickname ?? "",
            debitCategory: debit.title ?? "",
            debitAmount: Int64(debit.amount ?? 0),
            creditCategory: credit.title ?? "",
            creditAmount: Int64(credit.amount ?? 0),
            smallWritting: smallWritting ?? ""
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 設定よく使う仕訳画面
            if let tabBarController = self.presentingViewController as? UITabBarController, // 基底となっているコントローラ
               let splitViewController = tabBarController.selectedViewController as? UISplitViewController, // 基底のコントローラから、選択されているを取得する
               let navigationController = splitViewController.viewControllers[0] as? UINavigationController, // スプリットコントローラから、現在選択されているコントローラを取得する
               let navigationController2 = navigationController.viewControllers[1] as? UINavigationController,
               let presentingViewController = navigationController2.viewControllers[0] as? SettingsOperatingJournalEntryViewController { // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
                // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
                print(navigationController.viewControllers[0])
                print(navigationController.viewControllers[1])
                // 画面を閉じる
                self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                    presentingViewController.viewWillAppear(true)
                })
            } else {
                // 仕訳画面 タブバー
                if let tabBarController = self.presentingViewController as? UITabBarController, // 基底となっているコントローラ
                   let navigationController = tabBarController.selectedViewController as? UINavigationController,
                   let presentingViewController = navigationController.topViewController as? JournalEntryViewController {
                    print(navigationController.topViewController)
                    print(navigationController.viewControllers)
                    // 画面を閉じる
                    self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                        presentingViewController.viewWillAppear(true)
                    })
                }
                // 仕訳帳画面（仕訳編集、決算整理仕訳編集）、勘定画面（仕訳編集、決算整理仕訳編集）からの遷移の場合
                if let presentingViewController = self.presentingViewController as? JournalEntryViewController {
                    // viewWillAppearを呼び出す　更新のため
                    self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                        presentingViewController.viewWillAppear(true)
                    })
                }
                // 仕訳帳画面（仕訳）、精算表画面（決算整理仕訳）からの遷移の場合
                if let navigationController = self.presentingViewController as? UINavigationController,
                   let presentingViewController = navigationController.topViewController as? JournalEntryViewController {
                    // 画面を閉じる
                    self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                        presentingViewController.viewWillAppear(true)
                    })
                }
            }
        }
    }
    // 更新
    func buttonTappedForSettingsJournalEntriesFixing() {
        var number = 0
        // データベース　よく使う仕訳を更新
        number = DataBaseManagerSettingsOperatingJournalEntry.shared.updateJournalEntry(
            primaryKey: primaryKey,
            nickname: nickname ?? "",
            debitCategory: debit.title ?? "",
            debitAmount: Int64(debit.amount ?? 0),
            creditCategory: credit.title ?? "",
            creditAmount: Int64(credit.amount ?? 0),
            smallWritting: smallWritting ?? ""
        )
        if let tabBarController = self.presentingViewController as? UITabBarController, // 基底となっているコントローラ
           let splitViewController = tabBarController.selectedViewController as? UISplitViewController, // 基底のコントローラから、選択されているを取得する
           let navigationController = splitViewController.viewControllers[0]  as? UINavigationController, // スプリットコントローラから、現在選択されているコントローラを取得する
           let navigationController2 = navigationController.viewControllers[1] as? UINavigationController,
           let presentingViewController = navigationController2.viewControllers[0] as? SettingsOperatingJournalEntryViewController { // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
            print(navigationController.viewControllers[0])
            print(navigationController.viewControllers[1])
            // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
            // 画面を閉じる
            self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                presentingViewController.viewWillAppear(true)
            })
        }
    }
    
    override func cancelButtonTapped(_ sender: EMTNeumorphicButton) {
        super.cancelButtonTapped(sender)
        // 取引要素 ニックネーム
        nickname = nil
    }
    // 削除ボタン
    @IBOutlet private var deleteButton: EMTNeumorphicButton!
    
    @IBAction func deleteButton(_ sender: EMTNeumorphicButton) {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
        // 選択されていたボタンを選択解除する
        sender.isSelected = false
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.isSelected = !sender.isSelected
        }
        // 確認のポップアップを表示したい
        self.showPopover()
    }
    // 削除機能 アラートのポップアップを表示
    private func showPopover() {
        let alert = UIAlertController(title: "削除", message: "よく使う仕訳を削除しますか？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [self] (action: UIAlertAction!) in
            print("OK アクションをタップした時の処理")
            // データベース　よく使う仕訳を削除
            if DataBaseManagerSettingsOperatingJournalEntry.shared.deleteJournalEntry(number: primaryKey) {
                if let tabBarController = self.presentingViewController as? UITabBarController, // 基底となっているコントローラ
                   let splitViewController = tabBarController.selectedViewController as? UISplitViewController, // 基底のコントローラから、選択されているを取得する
                   let navigationController = splitViewController.viewControllers[0] as? UINavigationController, // スプリットコントローラから、現在選択されているコントローラを取得する
                   let navigationController2 = navigationController.viewControllers[1] as? UINavigationController,
                   let presentingViewController = navigationController2.viewControllers[0] as? SettingsOperatingJournalEntryViewController { // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
                    print(navigationController.viewControllers[0])
                    print(navigationController.viewControllers[1])
                    // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
                    // 画面を閉じる
                    self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                        presentingViewController.viewWillAppear(true)
                    })
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 日付　ボタン作成
        createButtons()
    }
    
    // ボタンのデザインを指定する
    private func createButtons() {
        
        if let deleteButton = deleteButton {
            deleteButton.setTitleColor(.textColor, for: .normal)
            deleteButton.neumorphicLayer?.cornerRadius = 15
            deleteButton.setTitleColor(.textColor, for: .selected)
            deleteButton.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            deleteButton.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            deleteButton.neumorphicLayer?.edged = Constant.edged
            deleteButton.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            deleteButton.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
            // Optional. if it is nil (default), elementBackgroundColor will be used as element color.
            deleteButton.neumorphicLayer?.elementColor = UIColor.baseColor.cgColor
            let backImage = UIImage(named: "delete-delete_symbol")?.withRenderingMode(.alwaysTemplate)
            deleteButton.setImage(backImage, for: UIControl.State.normal)
            // アイコン画像の色を指定する
            deleteButton.tintColor = .accentColor
        }
    }
}
