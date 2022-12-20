//
//  JournalEntryTemplateViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/05/10.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit
import EMTNeumorphicView

// よく使う仕訳クラス
class JournalEntryTemplateViewController: JournalEntryViewController {

//    @IBOutlet var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // UIパーツを作成
        createTextFieldForNickname() // テキストフィールド　ニックネームを作成

        if journalEntryType == "SettingsJournalEntries" {
            labelTitle.text = "よく使う仕訳"
            inputButton.setTitle("追　加", for: UIControl.State.normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
            deleteButton.isHidden = true
        } else if journalEntryType == "SettingsJournalEntriesFixing" {
            labelTitle.text = "よく使う仕訳"
            inputButton.setTitle("更　新", for: UIControl.State.normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
            deleteButton.isHidden = false
            // データベース　よく使う仕訳を追加
            let dataBaseManager = DataBaseManagerSettingsOperatingJournalEntry()
            let objects = dataBaseManager.getJournalEntry()
            primaryKey = objects[tappedIndexPath.row].number
            nicknameTextField.text = objects[tappedIndexPath.row].nickname
            textFieldCategoryDebit.text = objects[tappedIndexPath.row].debit_category
            textFieldAmountDebit.text = String(objects[tappedIndexPath.row].debit_amount)
            textFieldCategoryCredit.text = objects[tappedIndexPath.row].credit_category
            textFieldAmountCredit.text = String(objects[tappedIndexPath.row].credit_amount)
            textFieldSmallWritting.text = objects[tappedIndexPath.row].smallWritting
        }
        
//        if journalEntryType == "SettingsJournalEntries" || journalEntryType == "SettingsJournalEntriesFixing" { // よく使う仕訳の場合
//            carouselCollectionView.isHidden = true
//        }
        
//        if journalEntryType == "SettingsJournalEntries" || journalEntryType == "SettingsJournalEntriesFixing" { // よく使う仕訳の場合
//            buttonLeft.isHidden = true
//            datePicker.isHidden = true
//            buttonRight.isHidden = true
//            dateLabel.isHidden = true
//            nicknameTextField.isHidden = false
//        } else {
//            nicknameTextField.isHidden = true
//        }
        
        // 金額　電卓画面で入力した値を表示させる
        if let numbersOnDisplay = numbersOnDisplay {
            textFieldAmountDebit.text = StringUtility.shared.addComma(string: numbersOnDisplay.description)
            textFieldAmountCredit.text = StringUtility.shared.addComma(string: numbersOnDisplay.description)
        }
        
    }
    
    @IBOutlet var nicknameTextField: UITextField!
    // TextField作成 ニックネーム
    func createTextFieldForNickname() {
        nicknameTextField.delegate = self
        nicknameTextField.textAlignment = .center
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
    }
    
    @objc override func barButtonTapped(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 8: // ニックネームの場合 Done
            self.view.endEditing(true)
        case 88: // ニックネームの場合 Cancel
            nicknameTextField.text = ""
            self.view.endEditing(true)// textFieldDidEndEditingで貸方金額へコピーするのでtextを設定した後に実行
        default:
            self.view.endEditing(true)
        }
    }
    
    @IBAction override func inputButtonTapped(_ sender: EMTNeumorphicButton) {
        // シスログ出力
        // printによる出力はUTCになってしまうので、9時間ずれる
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current // UTC時刻を補正
        formatter.dateFormat = "yyyy/MM/dd"     // 注意：　小文字のyにしなければならない
        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
        var number = 0
        if journalEntryType == "SettingsJournalEntries" {
            var amountDebitTextField = ""
            if let text = textFieldAmountDebit.text {
                amountDebitTextField = StringUtility.shared.removeComma(string: text)
            }
            var amountCreditTextField = ""
            if let text = textFieldAmountCredit.text {
                amountCreditTextField = StringUtility.shared.removeComma(string: text)
            }
            // データベース　よく使う仕訳を追加
            let dataBaseManager = DataBaseManagerSettingsOperatingJournalEntry()
            number = dataBaseManager.addJournalEntry(
                nickname: nicknameTextField.text!,
                debitCategory: textFieldCategoryDebit.text!,
                debitAmount: Int64(amountDebitTextField) ?? 0, // カンマを削除してからデータベースに書き込む
                creditCategory: textFieldCategoryCredit.text!,
                creditAmount: Int64(amountCreditTextField) ?? 0, // カンマを削除してからデータベースに書き込む
                smallWritting: textFieldSmallWritting.text!
            )
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
                    presentingViewController.viewReload = true
                    presentingViewController.viewWillAppear(true)
                })
            }
        } else if journalEntryType == "SettingsJournalEntriesFixing" {
            var amountDebitTextField = ""
            if let text = textFieldAmountDebit.text {
                amountDebitTextField = StringUtility.shared.removeComma(string: text)
            }
            var amountCreditTextField = ""
            if let text = textFieldAmountCredit.text {
                amountCreditTextField = StringUtility.shared.removeComma(string: text)
            }
            // データベース　よく使う仕訳を更新
            let dataBaseManager = DataBaseManagerSettingsOperatingJournalEntry()
            number = dataBaseManager.updateJournalEntry(
                primaryKey: primaryKey,
                nickname: nicknameTextField.text!,
                debitCategory: textFieldCategoryDebit.text!,
                debitAmount: Int64(amountDebitTextField) ?? 0, // カンマを削除してからデータベースに書き込む
                creditCategory: textFieldCategoryCredit.text!,
                creditAmount: Int64(amountCreditTextField) ?? 0,// カンマを削除してからデータベースに書き込む
                smallWritting: textFieldSmallWritting.text!
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
                    presentingViewController.viewReload = true
                    presentingViewController.viewWillAppear(true)
                })
            }
        }
    }
    // 削除ボタン
    @IBOutlet var deleteButton: EMTNeumorphicButton!

    @IBAction func deleteButton(_ sender: Any) {
        // 確認のポップアップを表示したい
        self.showPopover()
    }
    // 削除機能 アラートのポップアップを表示
    private func showPopover() {
        let alert = UIAlertController(title: "削除", message: "よく使う仕訳を削除しますか？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
            print("OK アクションをタップした時の処理")
            // データベース　よく使う仕訳を削除
            let dataBaseManager = DataBaseManagerSettingsOperatingJournalEntry()
            if dataBaseManager.deleteJournalEntry(number: primaryKey) {
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
                        presentingViewController.viewReload = true
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
