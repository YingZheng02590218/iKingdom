//
//  ClassicCalcuatorViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/12/30.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import UIKit
import EMTNeumorphicView

class ClassicCalcuatorViewController: UIViewController {

    
    @IBOutlet var backgroundView: EMTNeumorphicView!
    @IBOutlet var labelView: EMTNeumorphicView!
    @IBOutlet var label: UILabel!
    
    @IBOutlet var button1: EMTNeumorphicButton!
    @IBOutlet var button2: EMTNeumorphicButton!
    @IBOutlet var button3: EMTNeumorphicButton!
    @IBOutlet var button4: EMTNeumorphicButton!
    @IBOutlet var button5: EMTNeumorphicButton!
    @IBOutlet var button6: EMTNeumorphicButton!
    @IBOutlet var button7: EMTNeumorphicButton!
    @IBOutlet var button8: EMTNeumorphicButton!
    @IBOutlet var button9: EMTNeumorphicButton!
    @IBOutlet var button0: EMTNeumorphicButton!
    
    @IBOutlet var buttonAc: EMTNeumorphicButton!
    @IBOutlet var buttonPlusMinus: EMTNeumorphicButton!
    @IBOutlet var buttonPercent: EMTNeumorphicButton!
    
    @IBOutlet var buttonDivied: EMTNeumorphicButton!
    @IBOutlet var buttonMultiple: EMTNeumorphicButton!
    @IBOutlet var buttonMinus: EMTNeumorphicButton!
    @IBOutlet var buttonPlus: EMTNeumorphicButton!
    
    @IBOutlet var buttonDot: EMTNeumorphicButton!
    @IBOutlet var buttonEqual: EMTNeumorphicButton!
    
    /// 演算の種類
    var hugoBox: FourArithmeticOperations = .undefined //String?
    /// 1つ目の値
    var box1: Int = DecimalNumbers.zero.rawValue
    /// 2つ目の値
    var box2: Int = DecimalNumbers.zero.rawValue
    /// 計算結果
    var numbersOnDisplay: Int = DecimalNumbers.zero.rawValue

//    var turn = true
//    var count = 0

    let LIGHTSHADOWOPACITY: Float = 0.3
    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numAction()
//        hugoAction()
//        plusMinusAction()
//        dotAction()
//        percentAction()
        equalAction()
        acAction()
    }
    
    override func viewWillLayoutSubviews() {
        layout()
    }

    
    func layout() {
        
        backgroundView.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

        // Default is 1.
        labelView.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        // Default is 0.3.
        labelView.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        // Adding a thin border on the edge of the element.
        labelView.neumorphicLayer?.edged = true
        labelView.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        labelView.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

        label.font = UIFont(name: "DSEG14 Classic-Regular", size: 34)
        label.text = numbersOnDisplay.description
        label.textAlignment = .right
        
        button1.setTitle("1", for: .normal)
        button1.setTitleColor(.ButtonTextColor, for: .normal)
        button1.neumorphicLayer?.cornerRadius = button1.frame.height / 2.2
        button1.contentVerticalAlignment = .fill
//        button1.contentHorizontalAlignment = .fill
        button1.setTitleColor(.ButtonTextColor, for: .selected)
        button1.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        button1.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        button1.neumorphicLayer?.edged = true
        button1.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        button1.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
        
        button2.setTitle("2", for: .normal)
        button2.setTitleColor(.ButtonTextColor, for: .normal)
        button2.neumorphicLayer?.cornerRadius = button2.frame.height / 2.2
        button2.contentVerticalAlignment = .fill
//        button2.contentHorizontalAlignment = .fill
        button2.setTitleColor(.ButtonTextColor, for: .selected)
        button2.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        button2.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        button2.neumorphicLayer?.edged = true
        button2.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        button2.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

        button3.setTitle("3", for: .normal)
        button3.setTitleColor(.ButtonTextColor, for: .normal)
        button3.neumorphicLayer?.cornerRadius = button3.frame.height / 2.2
        button3.contentVerticalAlignment = .fill
//        button3.contentHorizontalAlignment = .fill
        button3.setTitleColor(.ButtonTextColor, for: .selected)
        button3.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        button3.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        button3.neumorphicLayer?.edged = true
        button3.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        button3.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

        
        
        button4.setTitle("4", for: .normal)
        button4.setTitleColor(.ButtonTextColor, for: .normal)
        button4.neumorphicLayer?.cornerRadius = button4.frame.height / 2.2
        button4.contentVerticalAlignment = .fill
//        button4.contentHorizontalAlignment = .fill
        button4.setTitleColor(.ButtonTextColor, for: .selected)
        button4.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        button4.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        button4.neumorphicLayer?.edged = true
        button4.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        button4.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

        button5.setTitle("5", for: .normal)
        button5.setTitleColor(.ButtonTextColor, for: .normal)
        button5.neumorphicLayer?.cornerRadius = button5.frame.height / 2.2
        button5.contentVerticalAlignment = .fill
//        button5.contentHorizontalAlignment = .fill
        button5.setTitleColor(.ButtonTextColor, for: .selected)
        button5.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        button5.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        button5.neumorphicLayer?.edged = true
        button5.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        button5.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

        button6.setTitle("6", for: .normal)
        button6.setTitleColor(.ButtonTextColor, for: .normal)
        button6.neumorphicLayer?.cornerRadius = button6.frame.height / 2.2
        button6.contentVerticalAlignment = .fill
//        button6.contentHorizontalAlignment = .fill
        button6.setTitleColor(.ButtonTextColor, for: .selected)
        button6.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        button6.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        button6.neumorphicLayer?.edged = true
        button6.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        button6.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

        
        
        button7.setTitle("7", for: .normal)
        button7.setTitleColor(.ButtonTextColor, for: .normal)
        button7.neumorphicLayer?.cornerRadius = button7.frame.height / 2.2
        button7.contentVerticalAlignment = .fill
//        button7.contentHorizontalAlignment = .fill
        button7.setTitleColor(.ButtonTextColor, for: .selected)
        button7.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        button7.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        button7.neumorphicLayer?.edged = true
        button7.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        button7.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

        button8.setTitle("8", for: .normal)
        button8.setTitleColor(.ButtonTextColor, for: .normal)
        button8.neumorphicLayer?.cornerRadius = button8.frame.height / 2.2
        button8.contentVerticalAlignment = .fill
//        button8.contentHorizontalAlignment = .fill
        button8.setTitleColor(.ButtonTextColor, for: .selected)
        button8.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        button8.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        button8.neumorphicLayer?.edged = true
        button8.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        button8.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

        button9.setTitle("9", for: .normal)
        button9.setTitleColor(.ButtonTextColor, for: .normal)
        button9.neumorphicLayer?.cornerRadius = button9.frame.height / 2.2
        button9.contentVerticalAlignment = .fill
//        button9.contentHorizontalAlignment = .fill
        button9.setTitleColor(.ButtonTextColor, for: .selected)
        button9.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        button9.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        button9.neumorphicLayer?.edged = true
        button9.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        button9.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

        
        
        button0.setTitle("0", for: .normal)
        button0.setTitleColor(.ButtonTextColor, for: .normal)
        button0.neumorphicLayer?.cornerRadius = button0.frame.height / 2.2
        button0.contentVerticalAlignment = .fill
//        button0.contentHorizontalAlignment = .fill
        button0.setTitleColor(.ButtonTextColor, for: .selected)
        button0.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        button0.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        button0.neumorphicLayer?.edged = true
        button0.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        button0.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

//        buttonDivied.setTitle("÷", for: .normal)
//        buttonDivied.backgroundColor = .orange
//        buttonDivied.layer.cornerRadius = buttonDivied.frame.height / 2.2
//
//        buttonMultiple.setTitle("×", for: .normal)
//        buttonMultiple.backgroundColor = .orange
//        buttonMultiple.layer.cornerRadius = buttonMultiple.frame.height / 2.2
//
//        buttonPlus.setTitle("+", for: .normal)
//        buttonPlus.backgroundColor = .orange
//        buttonPlus.layer.cornerRadius = buttonPlus.frame.height / 2.2
//
//        buttonMinus.setTitle("-", for: .normal)
//        buttonMinus.backgroundColor = .orange
//        buttonMinus.layer.cornerRadius = buttonMinus.frame.height / 2.2
        
//        buttonDot.setTitle(".", for: .normal)
//        buttonDot.backgroundColor = .darkGray
//        buttonDot.layer.cornerRadius = buttonDot.frame.height / 2.2
        
        buttonEqual.setTitle("=", for: .normal)
        buttonEqual.setTitleColor(.ButtonTextColor, for: .normal)
        buttonEqual.neumorphicLayer?.cornerRadius = buttonEqual.frame.height / 2.2
        buttonEqual.contentVerticalAlignment = .fill
//        buttonEqual.contentHorizontalAlignment = .fill
        buttonEqual.setTitleColor(.ButtonTextColor, for: .selected)
        buttonEqual.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        buttonEqual.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        buttonEqual.neumorphicLayer?.edged = true
        buttonEqual.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        buttonEqual.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

        buttonAc.setTitle("AC", for: .normal)
        buttonAc.setTitleColor(.ButtonTextColor, for: .normal)
        buttonAc.neumorphicLayer?.cornerRadius = buttonAc.frame.height / 2.2
        buttonAc.contentVerticalAlignment = .fill
//        buttonAc.contentHorizontalAlignment = .fill
        buttonAc.setTitleColor(.ButtonTextColor, for: .selected)
        buttonAc.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        buttonAc.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        buttonAc.neumorphicLayer?.edged = true
        buttonAc.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        buttonAc.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor

//        buttonPlusMinus.setTitle("+/-", for: .normal)
//        buttonPlusMinus.backgroundColor = .lightGray
//        buttonPlusMinus.setTitleColor(.black, for: .normal)
//        buttonPlusMinus.layer.cornerRadius = buttonPlusMinus.frame.height / 2.2
        
//        buttonPercent.setTitle("%", for: .normal)
//        buttonPercent.backgroundColor = .lightGray
//        buttonPercent.setTitleColor(.black, for: .normal)
//        buttonPercent.layer.cornerRadius = buttonPercent.frame.height / 2.2
        
    }
    
    // 数字ボタンを押下
    @objc func numClick(_ sender: EMTNeumorphicButton) {
        // 選択されていたボタンを選択解除する
        let arrayHugo = [buttonAc,button0,button1,button2,button3,button4,button5,button6,button7,button8,button9]
        let newArray = arrayHugo.filter { $0?.isSelected == true}
        for i in newArray {
            i?.isSelected = false
        }
        // ボタンを選択する
        sender.isSelected = !sender.isSelected


        let sentText = numbersOnDisplay// ?? DecimalNumbers.zero.rawValue

        // 入力チェック 文字数最大数を設定
        if sentText.description.count > 7 {
            return
        }
        
        switch sender {
        case button0:
            numbersOnDisplay = sentText * 10 + DecimalNumbers.zero.rawValue
        case button1:
            numbersOnDisplay = sentText * 10 + DecimalNumbers.one.rawValue
        case button2:
            numbersOnDisplay = sentText * 10 + DecimalNumbers.two.rawValue
        case button3:
            numbersOnDisplay = sentText * 10 + DecimalNumbers.three.rawValue
        case button4:
            numbersOnDisplay = sentText * 10 + DecimalNumbers.four.rawValue
        case button5:
            numbersOnDisplay = sentText * 10 + DecimalNumbers.five.rawValue
        case button6:
            numbersOnDisplay = sentText * 10 + DecimalNumbers.six.rawValue
        case button7:
            numbersOnDisplay = sentText * 10 + DecimalNumbers.seven.rawValue
        case button8:
            numbersOnDisplay = sentText * 10 + DecimalNumbers.eight.rawValue
        case button9:
            numbersOnDisplay = sentText * 10 + DecimalNumbers.nine.rawValue
        default:
            break
        }
        
        label.text = numbersOnDisplay.description
    }
    func numAction() {
        
        button0.addTarget(self, action: #selector(numClick(_:)), for: .touchUpInside)
        button1.addTarget(self, action: #selector(numClick(_:)), for: .touchUpInside)
        button2.addTarget(self, action: #selector(numClick(_:)), for: .touchUpInside)
        button3.addTarget(self, action: #selector(numClick(_:)), for: .touchUpInside)
        button4.addTarget(self, action: #selector(numClick(_:)), for: .touchUpInside)
        button5.addTarget(self, action: #selector(numClick(_:)), for: .touchUpInside)
        button6.addTarget(self, action: #selector(numClick(_:)), for: .touchUpInside)
        button7.addTarget(self, action: #selector(numClick(_:)), for: .touchUpInside)
        button8.addTarget(self, action: #selector(numClick(_:)), for: .touchUpInside)
        button9.addTarget(self, action: #selector(numClick(_:)), for: .touchUpInside)
    }
    
//    @objc func clickHugo(_ sender: UIButton) {
//
//        calculate()
//
//        switch sender {
//        case buttonDivied:
//            hugoBox = FourArithmeticOperations.division
//        case buttonMultiple:
//            hugoBox = FourArithmeticOperations.multiplication
//        case buttonPlus:
//            hugoBox = FourArithmeticOperations.addition
//        case buttonMinus:
//            hugoBox = FourArithmeticOperations.subtraction
//        default:
//            hugoBox = FourArithmeticOperations.undefined
//            break
//        }
//        // 選択されていたボタンを選択解除する
//        let arrayHugo = [buttonDivied,buttonMultiple,buttonPlus,buttonMinus]
//        let newArray = arrayHugo.filter { $0?.backgroundColor != .orange}
//        for i in newArray {
//            i?.backgroundColor = .orange
//            i?.setTitleColor(.white, for: .normal)
//        }
//        sender.backgroundColor = .white
//        sender.setTitleColor(.orange, for: .normal)
//
//
//        count = 0
//    }
//    func hugoAction() {
//
//        buttonDivied.addTarget(self, action: #selector(clickHugo(_:)), for: .touchUpInside)
//        buttonMultiple.addTarget(self, action: #selector(clickHugo(_:)), for: .touchUpInside)
//        buttonPlus.addTarget(self, action: #selector(clickHugo(_:)), for: .touchUpInside)
//        buttonMinus.addTarget(self, action: #selector(clickHugo(_:)), for: .touchUpInside)
//    }

//
//    func calculate() {
//        // 左辺　が空の場合
//        if hugoBox == .undefined {//nil {
//            // 計算結果をUIに表示させる
//            label.text = numbersOnDisplay.description//"0"
//            // 計算結果を1つ目の値に代入する
//            box1 = numbersOnDisplay//label.text!
//            // 計算結果を初期化する
//            numbersOnDisplay = DecimalNumbers.zero.rawValue
//        }
//        else if hugoBox == .plusMinus {
//            if numbersOnDisplay == DecimalNumbers.zero.rawValue {
//                numbersOnDisplay = box1
//            }
//            numbersOnDisplay *= -1
//
//            // 計算結果をUIに表示させる
//            label.text = numbersOnDisplay.description//"0"
//            // 計算結果を1つ目の値に代入する
//            box1 = numbersOnDisplay
//            // 計算結果を初期化する
//            numbersOnDisplay = DecimalNumbers.zero.rawValue
//            // 演算の種類を初期化する
//            hugoBox = .undefined
//        }
//        else if hugoBox == .percent {
//            if numbersOnDisplay == DecimalNumbers.zero.rawValue {
//                numbersOnDisplay = box1
//            }
//            let text = numbersOnDisplay
//            let textDouble = Double(text)
//            let textPercent = textDouble / 100
//            // 計算結果をUIに表示させる
//            label.text = textPercent.description
//            // 計算結果を1つ目の値に代入する
//            box1 = Int(textPercent) // キャストしなければならない
//            // 計算結果を初期化する
//            numbersOnDisplay = DecimalNumbers.zero.rawValue
//            // 演算の種類を初期化する
//            hugoBox = .undefined
//        }
//        else { // 右辺　が空の場合
//            if numbersOnDisplay != DecimalNumbers.zero.rawValue {
//                box2 = numbersOnDisplay
//
//                let firstNum : NSDecimalNumber = NSDecimalNumber(value: box1)
//                let secondNum : NSDecimalNumber = NSDecimalNumber(value: box2)
//
//                switch hugoBox {
//                case .division:
//                    // 0割対策
//                    if box2 == DecimalNumbers.zero.rawValue {
//                        numbersOnDisplay = box1
//                    }
//                    else {
//                        let result: NSDecimalNumber = firstNum.dividing(by:secondNum)
//                        numbersOnDisplay = Int(truncating: result)//("\(result.intValu)")
//                    }
//                case .multiplication:
//                    let result: NSDecimalNumber = firstNum.multiplying(by: secondNum)
//                    numbersOnDisplay = Int(truncating: result)//("\(result.stringValue)")
//                case .addition:
//                    let result: NSDecimalNumber = firstNum.adding(secondNum)
//                    numbersOnDisplay = Int(truncating: result)//("\(result.stringValue)")
//                case .subtraction:
//                    let result: NSDecimalNumber = firstNum.subtracting(secondNum)
//                    numbersOnDisplay = Int(truncating: result)//("\(result.stringValue)")
//                default:
//                    break
//                }
//                // 2つ目の値を初期化する
//                box2 = DecimalNumbers.zero.rawValue//nil
//                // 計算結果をUIに表示させる
//                label.text = numbersOnDisplay.description//"0"
//                // 計算結果を1つ目の値に代入する
//                box1 = numbersOnDisplay
//                // 計算結果を初期化する
//                numbersOnDisplay = DecimalNumbers.zero.rawValue
//                // 演算の種類を初期化する
//                hugoBox = .undefined
//            }
//        }
//    }
    // イコールボタン押下
    // 入力値を設定する
    // ビジネスロジックを呼び出す
    // box1 四則演算子 box2 = 計算結果
    @objc func clickEqual(_ sender: UIButton) {
 
//        calculate()
        
        // 仕訳帳、決算整理仕訳、仕訳編集画面からの遷移の場合
        if let presentingViewController2 = presentingViewController as? JournalEntryViewController {
            // viewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: {
                [presentingViewController2] () -> Void in
                // ViewController(電卓画面)を閉じた時に、遷移元であるViewController(仕訳画面)で行いたい処理
                presentingViewController2.numbersOnDisplay = self.numbersOnDisplay
                presentingViewController2.viewWillAppear(true)
            })
            return
        }
        
        // 通常の仕訳画面からの遷移の場合
        // モーダルの起動元はタブコントローラ
        guard let tabBarController = presentingViewController as? UITabBarController else {
            print("Could not find tabbar Controller")
            return
        }
        // タブで選択中のナビゲーションコントローラ
        guard let navigationController = tabBarController.selectedViewController as? UINavigationController else {
            print("Could not find avigation nController")
            return
        }
        // ナビゲーションコントローラの最前面を取得
        if let presentingViewController2 = navigationController.topViewController as? JournalEntryViewController {
            // viewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: {
                [presentingViewController2] () -> Void in
                // ViewController(電卓画面)を閉じた時に、遷移元であるViewController(仕訳画面)で行いたい処理
                presentingViewController2.numbersOnDisplay = self.numbersOnDisplay
                presentingViewController2.viewWillAppear(true)
            })
              return
        }
    }
    
    func equalAction() {
        buttonEqual.addTarget(self, action: #selector(clickEqual(_:)), for: .touchUpInside)
    }
    
    @objc func clickAc(_ sender: EMTNeumorphicButton) {
        // 選択されていたボタンを選択解除する
        let arrayHugo = [buttonAc,button0,button1,button2,button3,button4,button5,button6,button7,button8,button9]
        let newArray = arrayHugo.filter { $0?.isSelected == true}
        for i in newArray {
            i?.isSelected = false
        }
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        
//        label.text = "0"
        numbersOnDisplay = DecimalNumbers.zero.rawValue
        box1 = DecimalNumbers.zero.rawValue//nil
        box2 = DecimalNumbers.zero.rawValue//nil
        hugoBox = .undefined
//        count = 0
        
//        let arrayHugo = [buttonDivied, buttonMultiple, buttonPlus, buttonMinus]
//        let newArray = arrayHugo.filter { $0?.backgroundColor != .orange}
//        for i in newArray {
//            i?.backgroundColor = .orange
//            i?.setTitleColor(.white, for: .normal)
//        }
        
        label.text = numbersOnDisplay.description
    }
    
    func acAction() {
        buttonAc.addTarget(self, action: #selector(clickAc(_:)), for: .touchUpInside)
    }
    
//    @objc func clickPlusMinus(_ sender: UIButton) {
//
//        hugoBox = FourArithmeticOperations.plusMinus
//        calculate()
//    }
//    func plusMinusAction() {
//        buttonPlusMinus.addTarget(self, action: #selector(clickPlusMinus(_:)), for: .touchUpInside)
//
//    }
//
//    @objc func clickDot(_ sender: UIButton) {
//
//        if count < 1 {
//            if label.text == "0" {
//                label.text = "0."
//            }
//            else {
//                label.text = label.text! + sender.currentTitle!
//            }
//        }
//        count = count + 1
//    }
//
//    func dotAction() {
//        buttonDot.addTarget(self, action: #selector(clickDot(_:)), for: .touchUpInside)
//
//    }
    
//    @objc func clickPercent(_ sender: UIButton) {
//
//        hugoBox = FourArithmeticOperations.percent
//        calculate()
//    }
//
//    func percentAction() {
//        buttonPercent.addTarget(self, action: #selector(clickPercent(_:)), for: .touchUpInside)
//    }
}

enum FourArithmeticOperations {
    case addition        // +    plus                    sum
    case subtraction     // -    minus                   difference
    case multiplication  // ×    times, multiplied by    product
    case division        // ÷    divided by              quotient
    case undefined
//    case plusMinus
//    case percent
}

enum DecimalNumbers: Int {
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
}
