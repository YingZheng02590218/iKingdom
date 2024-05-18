//
//  SettingsOperatingJournalEntryGroupDetailViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/07/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import UIKit

// グループ詳細
class SettingsOperatingJournalEntryGroupDetailViewController: UIViewController {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var textFieldCounterLabel: UILabel!
    @IBOutlet var inputButton: EMTNeumorphicButton!
    @IBOutlet var textFieldView: EMTNeumorphicView!
    // エラーメッセージ
    var errorMessage: String?
    // 編集　グループ一覧画面で選択されたセルの位置
    var tappedIndexPath: IndexPath?

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title設定
        navigationItem.title = "グループ詳細"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
        
        setupTextField()
        // ニューモフィズム　ボタンとビューのデザインを指定する
        createEMTNeumorphicView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 編集　グループ一覧画面で選択されたセルの位置
        if let tappedIndexPath = tappedIndexPath {
            let objects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
            // 初期値
            textField.text = objects[tappedIndexPath.row].groupName
        }
    }
    // ダークモード　切り替え時に色が更新されない場合の対策
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // ニューモフィズム　ボタンとビューのデザインを指定する
        createEMTNeumorphicView()
    }

    func setupTextField() {
        textField.delegate = self
        // テキストの入力位置を指すライン、これはカーソルではなくキャレット(caret)と呼ぶそうです。
        textField.tintColor = UIColor.accentColor
        // 文字サイズを指定
        textField.adjustsFontSizeToFitWidth = true // TextField 文字のサイズを合わせる
        textField.minimumFontSize = 17
        
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
        textField.inputAccessoryView = toolbar
        
        textField.layer.borderWidth = 0.5
        // 最大文字数
        textField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // MARK: EMTNeumorphicView
    // ニューモフィズム　ボタンとビューのデザインを指定する
    func createEMTNeumorphicView() {
        
        if let textFieldView = textFieldView {
            textFieldView.neumorphicLayer?.cornerRadius = 15
            textFieldView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            textFieldView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            textFieldView.neumorphicLayer?.edged = Constant.edged
            textFieldView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            textFieldView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
            textFieldView.neumorphicLayer?.depthType = .concave
        }
        // 編集　グループ一覧画面で選択されたセルの位置
        if let tappedIndexPath = tappedIndexPath {
            inputButton.setTitle("更　新", for: .normal)
        } else {
            inputButton.setTitle("登　録", for: .normal)
        }
        inputButton.setTitleColor(.accentColor, for: .normal)
        inputButton.neumorphicLayer?.cornerRadius = 15
        inputButton.setTitleColor(.accentColor, for: .selected)
        inputButton.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        inputButton.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        inputButton.neumorphicLayer?.edged = Constant.edged
        inputButton.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        inputButton.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
    }
    
    // MARK: キーボード
    // UIKeyboardWillShow通知を受けて、実行される関数
    @objc
    func keyboardWillShow(notification: NSNotification) {
        // 小書きを入力中は、画面を上げる
        if textField.isEditing {
            guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            // テキストフィールドの下辺
            let txtLimit = textField.frame.origin.y + textField.frame.height + 8.0
            
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
        
        self.view.endEditing(true)
    }
    
    // 登録ボタン
    @IBAction func addButtonTapped(_ sender: EMTNeumorphicButton) {
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
        if self.textInputCheckForSettingsJournalEntryGroup() {
            // 編集　グループ一覧画面で選択されたセルの位置
            if let tappedIndexPath = tappedIndexPath {
                let objects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
                DataBaseManagerSettingsOperatingJournalEntryGroup.shared.updateJournalEntryGroup(primaryKey: objects[tappedIndexPath.row].number, groupName: textField.text ?? "")
            } else {
                DataBaseManagerSettingsOperatingJournalEntryGroup.shared.addJournalEntryGroup(groupName: textField.text ?? "")
            }
            // ダイアログ 登録しました
            showDialogForSucceed()
            JournalEntryViewController.viewReload = true
        }
    }
    // ダイアログ 記帳しました
    func showDialogForSucceed() {
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorNotification as? UINotificationFeedbackGenerator {
            generator.notificationOccurred(.success)
        }
        let alert = UIAlertController(title: "グループ", message: "登録しました", preferredStyle: .alert)
        self.present(alert, animated: true) { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    // 入力チェック　バリデーション よく使う仕訳のグループ
    func textInputCheckForSettingsJournalEntryGroup() -> Bool {
        // ニックネーム　バリデーションチェック
        switch ErrorValidation().validateSettingsJournalEntryGroup(text: textField.text ?? "") {
        case .success, .unvalidated:
            errorMessage = nil
        case .failure(let message):
            errorMessage = message
            showErrorMessage(completion: {
                // TextFieldのキーボードを自動的に表示する
                self.textField.becomeFirstResponder()
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.dismiss(animated: true, completion: nil)
                completion()
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension SettingsOperatingJournalEntryGroupDetailViewController: UITextFieldDelegate {
    
    // キーボード起動時
    //    textFieldShouldBeginEditing
    //    textFieldDidBeginEditing
    // リターン押下時
    //    textFieldShouldReturn before responder
    //    textFieldShouldEndEditing
    //    textFieldDidEndEditing
    //    textFieldShouldReturn
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // 入力開始 テキストフィールがタップされ、入力可能になったあと
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // フォーカス　効果　ドロップシャドウをかける
        textField.layer.shadowOpacity = 1.4
        textField.layer.shadowRadius = 4
        textField.layer.shadowColor = UIColor.calculatorDisplay.cgColor
        textField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
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
        // 入力チェック
        let notAllowedCharacters = CharacterSet(charactersIn: ",") // 除外したい文字。絵文字はInterface BuilderのKeyboardTypeで除外してある。
        let characterSet = CharacterSet(charactersIn: string)
        // 指定したスーパーセットの文字セットならfalseを返す
        resultForCharacter = !(notAllowedCharacters.isSuperset(of: characterSet))
        
        // 入力チェック　文字数最大数を設定
        var maxLength: Int = 0 // 文字数最大値を定義
        // グループ名の文字数
        maxLength = EditableType.group.maxLength
        
        // textField内の文字数
        let textFieldNumber = textField.text?.count ?? 0    // todo
        // 入力された文字数
        let stringNumber = string.count
        // 最大文字数以上ならfalseを返す
        resultForLength = textFieldNumber + stringNumber <= maxLength
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
    }
    // TextFieldに入力され値が変化した時の処理の関数
    @objc
    func textFieldDidChange(_ sender: UITextField) {
        if let text = sender.text {
            // グループ名　文字数カウンタ
            let maxLength = EditableType.group.maxLength
            textFieldCounterLabel.font = .boldSystemFont(ofSize: 15)
            textFieldCounterLabel.text = "\(maxLength - text.count)/\(maxLength)  "
            if text.count > maxLength {
                textFieldCounterLabel.textColor = .systemPink
            } else {
                textFieldCounterLabel.textColor = text.count >= maxLength - 3 ? .systemYellow : .systemGreen
            }
            if text.count == maxLength {
                // フィードバック
                if #available(iOS 10.0, *), let generator = feedbackGeneratorNotification as? UINotificationFeedbackGenerator {
                    generator.notificationOccurred(.error)
                }
            }
        }
    }
}
