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
        //        pickerViewView.isHidden = false
        
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
    
    @IBAction func doneButtonTapped(_ sender: EMTNeumorphicButton) {
        // ボタンを選択する
        sender.isSelected = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.doneButton.isSelected = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let objects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
                let groupName =  objects[self.pickerView.selectedRow(inComponent: 0)].groupName
                
                let alert = UIAlertController(title: "最終確認", message: "グループを 「\(groupName)」 に変更しますか？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action: UIAlertAction!) in
                    print("OK アクションをタップした時の処理")
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Cancel アクションをタップした時の処理")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: EMTNeumorphicButton) {
        // ボタンを選択する
        sender.isSelected = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.cancelButton.isSelected = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

extension GroupChoiceViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    // UIPickerViewの列の数 コンポーネントの数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1 // ドラムロールは1列
    }
    // UIPickerViewの行数、リストの数 コンポーネントの内のデータ
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup().count
    }
    // UIPickerViewの最初の表示 ホイールに表示する選択肢のタイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let objects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
        return objects[row].groupName
    }
}
