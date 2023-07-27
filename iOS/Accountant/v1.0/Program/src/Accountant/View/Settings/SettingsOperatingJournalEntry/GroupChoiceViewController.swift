//
//  GroupChoiceViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/07/18.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import UIKit

class GroupChoiceViewController: UIViewController {
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var pickerViewView: EMTNeumorphicView!
    @IBOutlet private var pickerViewViewView: EMTNeumorphicView!
    @IBOutlet private var doneButton: EMTNeumorphicButton!
    @IBOutlet private var cancelButton: EMTNeumorphicButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createPicker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ドラムロールの初期位置
        pickerView.selectRow(0, inComponent: 0, animated: true)
    }
    // ピッカー作成
    func createPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = false
        
        if let datePickerView = pickerViewView {
            datePickerView.neumorphicLayer?.cornerRadius = 15
            datePickerView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            datePickerView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            datePickerView.neumorphicLayer?.edged = Constant.edged
            datePickerView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            datePickerView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        }
        
        if let datePickerView = pickerViewViewView {
            datePickerView.neumorphicLayer?.cornerRadius = 15
            datePickerView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            datePickerView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            datePickerView.neumorphicLayer?.edged = Constant.edged
            datePickerView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            datePickerView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        }
        
        //        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.textColor, for: .normal)
        doneButton.neumorphicLayer?.cornerRadius = doneButton.frame.height / 2.2
        doneButton.contentVerticalAlignment = .fill
        doneButton.setTitleColor(.textColor, for: .selected)
        doneButton.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        doneButton.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        doneButton.neumorphicLayer?.edged = Constant.edged
        doneButton.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        doneButton.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        
        //        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.textColor, for: .normal)
        cancelButton.neumorphicLayer?.cornerRadius = cancelButton.frame.height / 2.2
        cancelButton.contentVerticalAlignment = .fill
        cancelButton.setTitleColor(.textColor, for: .selected)
        cancelButton.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        cancelButton.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        cancelButton.neumorphicLayer?.edged = Constant.edged
        cancelButton.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        cancelButton.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
    }
    
    @IBAction private func doneButtonTapped(_ sender: EMTNeumorphicButton) {
        // ボタンを選択する
        sender.isSelected = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.doneButton.isSelected = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // 確認ダイアログ
                self.showDialog()
            }
        }
    }
    
    @IBAction private func cancelButtonTapped(_ sender: EMTNeumorphicButton) {
        // ボタンを選択する
        sender.isSelected = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.cancelButton.isSelected = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    // 確認ダイアログ
    func showDialog() {
        let objects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
        let groupName = pickerView.selectedRow(inComponent: 0) == DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup().count ? "その他" : objects[pickerView.selectedRow(inComponent: 0)].groupName
        let number = pickerView.selectedRow(inComponent: 0) == DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup().count ? 0 : objects[self.pickerView.selectedRow(inComponent: 0)].number
        
        let alert = UIAlertController(title: "最終確認", message: "グループを 「\(groupName)」 に変更しますか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .destructive,
            handler: { _ in
                print("OK アクションをタップした時の処理")
                if let tabBarController = self.presentingViewController as? UITabBarController, // 基底となっているコントローラ
                   let splitViewController = tabBarController.selectedViewController as? UISplitViewController, // 基底のコントローラから、選択されているを取得する
                   let navigationController = splitViewController.viewControllers[0] as? UINavigationController { // スプリットコントローラから、現在選択されているコントローラを取得する
                    let navigationController2: UINavigationController
                    // iPadとiPhoneで動きが変わるので分岐する
                    if UIDevice.current.userInterfaceIdiom == .pad { // iPad
                        //        if UIDevice.current.orientation == .portrait { // ポートレート 上下逆さまだとポートレートとはならない
                        print(splitViewController.viewControllers.count)
                        if let navigationController0 = splitViewController.viewControllers[0] as? UINavigationController, // ナビゲーションバーコントローラの配下にあるビューコントローラーを取得
                           let navigationController1 = navigationController0.viewControllers[1] as? UINavigationController {
                            navigationController2 = navigationController1
                            print("iPad ビューコントローラーの階層")
                            if let presentingViewController = navigationController2.viewControllers[0] as? SettingsOperatingJournalEntryViewController { // 呼び出し元のビューコントローラーを取得
                                // viewWillAppearを呼び出す　更新のため
                                self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                                    presentingViewController.updateGroup(groupNumber: number)
                                    // 編集を終了する
                                    presentingViewController.setEditing(false, animated: true)
                                })
                            }
                        }
                    } else { // iPhone
                        print(splitViewController.viewControllers.count)
                        if let navigationController1 = navigationController.viewControllers[1] as? UINavigationController {
                            navigationController2 = navigationController1
                            print("iPhone ビューコントローラーの階層")
                            if let presentingViewController = navigationController2.viewControllers[0] as? SettingsOperatingJournalEntryViewController { // 呼び出し元のビューコントローラーを取得
                                // viewWillAppearを呼び出す　更新のため
                                self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                                    presentingViewController.updateGroup(groupNumber: number)
                                    // 編集を終了する
                                    presentingViewController.setEditing(false, animated: true)
                                })
                            }
                        }
                    }
                }
            }
        ))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            print("Cancel アクションをタップした時の処理")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension GroupChoiceViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    // UIPickerViewの列の数 コンポーネントの数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1 // ドラムロールは1列
    }
    // UIPickerViewの行数、リストの数 コンポーネントの内のデータ
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup().count + 1
    }
    // UIPickerViewの最初の表示 ホイールに表示する選択肢のタイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup().count {
            return "その他"
        } else {
            let objects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
            return objects[row].groupName
        }
    }
}
