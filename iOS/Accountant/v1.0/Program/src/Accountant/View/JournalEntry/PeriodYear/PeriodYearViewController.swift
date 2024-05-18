//
//  PeriodYearViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/04/18.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import UIKit

class PeriodYearViewController: UIViewController {
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var backgroundView: EMTNeumorphicView!
    @IBOutlet private var pickerViewViewView: EMTNeumorphicView!
    @IBOutlet private var doneButton: EMTNeumorphicButton!
    @IBOutlet private var cancelButton: EMTNeumorphicButton!
    
    /// モーダル上部に設置されるインジケータ
    private lazy var indicatorView: SemiModalIndicatorView = {
        let indicator = SemiModalIndicatorView()
        indicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(indicatorDidTap(_:))))
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ドラムロールの初期位置
        pickerView.selectRow(DataBaseManagerSettingsPeriod.shared.getMainBooksAllCount() - 1, inComponent: 0, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // viewDidLayoutSubviews()に書くと何度も呼ばれて、落ちる?
        createPicker()
    }
    
    // ピッカー作成
    func createPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = false
        //        pickerViewView.isHidden = false
        
        if let backgroundView = backgroundView {
            backgroundView.neumorphicLayer?.cornerRadius = 15
            backgroundView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            backgroundView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            backgroundView.neumorphicLayer?.edged = Constant.edged
            backgroundView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            backgroundView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
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
    
    @IBAction func doneButtonTapped(_ sender: EMTNeumorphicButton) {
        // 選択されていたボタンを選択解除する
        sender.isSelected = false
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.isSelected = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let fiscalYear = Int(self.getPeriodFromDB(row: self.pickerView.selectedRow(inComponent: 0)))
                
                let alert = UIAlertController(title: "最終確認", message: "年度を 「\(self.getPeriodFromDB(row: self.pickerView.selectedRow(inComponent: 0)))」 に変更しますか？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action: UIAlertAction!) in
                    print("OK アクションをタップした時の処理")
                    
                    if let tabBarController = self.presentingViewController as? UITabBarController, // 一番基底となっているコントローラ
                       let navigationController = tabBarController.selectedViewController as? UINavigationController, // 基底のコントローラから、現在選択されているコントローラを取得する
                       let presentingViewController = navigationController.viewControllers.first as? JournalsViewController { // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
                        // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
                        self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                            presentingViewController.updateFiscalYear(fiscalYear: fiscalYear!)
                            // 編集を終了する
                            presentingViewController.setEditing(false, animated: true)
                        })
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Cancel アクションをタップした時の処理")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: EMTNeumorphicButton) {
        // 選択されていたボタンを選択解除する
        sender.isSelected = false
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.isSelected = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // インジケータ タップ
    @objc
    private func indicatorDidTap(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PeriodYearViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    // UIPickerViewの列の数 コンポーネントの数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2 // ドラムロールは二列
    }
    // UIPickerViewの行数、リストの数 コンポーネントの内のデータ
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return DataBaseManagerSettingsPeriod.shared.getMainBooksAllCount()
        default:
            return 1
        }
    }
    // UIPickerViewの最初の表示 ホイールに表示する選択肢のタイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return getPeriodFromDB(row: row)
        default:
            return "年度"
        }
    }
    
    // 年度の選択肢
    private func getPeriodFromDB(row: Int) -> String {
        let objects = DataBaseManagerSettingsPeriod.shared.getMainBooksAll()
        return objects[row].fiscalYear.description
    }
}
