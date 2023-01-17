//
//  ClassicCalculatorViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/12/30.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import UIKit

class ClassicCalculatorViewController: UIViewController {

    @IBOutlet private var backgroundView: EMTNeumorphicView!
    @IBOutlet private var labelView: EMTNeumorphicView!
    @IBOutlet private var label: UILabel!
    
    @IBOutlet private var button1: EMTNeumorphicButton!
    @IBOutlet private var button2: EMTNeumorphicButton!
    @IBOutlet private var button3: EMTNeumorphicButton!
    @IBOutlet private var button4: EMTNeumorphicButton!
    @IBOutlet private var button5: EMTNeumorphicButton!
    @IBOutlet private var button6: EMTNeumorphicButton!
    @IBOutlet private var button7: EMTNeumorphicButton!
    @IBOutlet private var button8: EMTNeumorphicButton!
    @IBOutlet private var button9: EMTNeumorphicButton!
    @IBOutlet private var button0: EMTNeumorphicButton!
    
    @IBOutlet private var buttonAc: EMTNeumorphicButton!
    @IBOutlet private var buttonPlusMinus: UIButton!
    @IBOutlet private var buttonPercent: UIButton!
    
    @IBOutlet private var buttonDivied: EMTNeumorphicButton!
    @IBOutlet private var buttonMultiple: EMTNeumorphicButton!
    @IBOutlet private var buttonMinus: EMTNeumorphicButton!
    @IBOutlet private var buttonPlus: EMTNeumorphicButton!
    
    @IBOutlet private var buttonDot: UIButton!
    @IBOutlet private var buttonEqual: EMTNeumorphicButton!

    // 設定残高振替仕訳　連番
    var primaryKey: Int = 0
    // 勘定科目名
    var category: String = ""
    // 電卓画面で入力中の金額は、借方か貸方か
    var debitOrCredit: DebitOrCredit = .credit

    /// 演算の種類
    var hugoBox: FourArithmeticOperations = .undefined // String?
    /// 1つ目の値
    var box1: Int = DecimalNumbers.zero.rawValue
    /// 2つ目の値
    var box2: Int = DecimalNumbers.zero.rawValue
    /// 計算結果
    var numbersOnDisplay: Int = DecimalNumbers.zero.rawValue

//    var turn = true
//    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        numAction()
//        hugoAction()
//        plusMinusAction()
//        dotAction()
//        percentAction()
        equalAction()
        acAction()
        // viewDidLayoutSubviews()に書くと何度も呼ばれて、落ちる
        layout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func layout() {
        
        //　左上と右上を角丸にする設定
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backgroundView.layer.cornerRadius = 20
        backgroundView.clipsToBounds = true
        backgroundView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        backgroundView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        backgroundView.neumorphicLayer?.edged = Constant.edged
        backgroundView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        backgroundView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor

        // Default is 1.
        labelView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        // Default is 0.3.
        labelView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        // Adding a thin border on the edge of the element.
        labelView.neumorphicLayer?.edged = true
        labelView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        labelView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor

//        label.font = UIFont(name: "DSEG14 Classic-Regular", size: 34)
        label.text = numbersOnDisplay.description
        label.textAlignment = .right
        
        button1.setTitle("1", for: .normal)
        button1.setTitleColor(.textColor, for: .normal)
        button1.neumorphicLayer?.cornerRadius = button1.frame.height / 2.2
        button1.contentVerticalAlignment = .fill
//        button1.contentHorizontalAlignment = .fill
        button1.setTitleColor(.textColor, for: .selected)
        button1.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button1.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button1.neumorphicLayer?.edged = Constant.edged
        button1.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button1.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        
        button2.setTitle("2", for: .normal)
        button2.setTitleColor(.textColor, for: .normal)
        button2.neumorphicLayer?.cornerRadius = button2.frame.height / 2.2
        button2.contentVerticalAlignment = .fill
//        button2.contentHorizontalAlignment = .fill
        button2.setTitleColor(.textColor, for: .selected)
        button2.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button2.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button2.neumorphicLayer?.edged = Constant.edged
        button2.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button2.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor

        button3.setTitle("3", for: .normal)
        button3.setTitleColor(.textColor, for: .normal)
        button3.neumorphicLayer?.cornerRadius = button3.frame.height / 2.2
        button3.contentVerticalAlignment = .fill
//        button3.contentHorizontalAlignment = .fill
        button3.setTitleColor(.textColor, for: .selected)
        button3.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button3.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button3.neumorphicLayer?.edged = Constant.edged
        button3.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button3.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor


        button4.setTitle("4", for: .normal)
        button4.setTitleColor(.textColor, for: .normal)
        button4.neumorphicLayer?.cornerRadius = button4.frame.height / 2.2
        button4.contentVerticalAlignment = .fill
//        button4.contentHorizontalAlignment = .fill
        button4.setTitleColor(.textColor, for: .selected)
        button4.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button4.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button4.neumorphicLayer?.edged = Constant.edged
        button4.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button4.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor

        button5.setTitle("5", for: .normal)
        button5.setTitleColor(.textColor, for: .normal)
        button5.neumorphicLayer?.cornerRadius = button5.frame.height / 2.2
        button5.contentVerticalAlignment = .fill
//        button5.contentHorizontalAlignment = .fill
        button5.setTitleColor(.textColor, for: .selected)
        button5.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button5.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button5.neumorphicLayer?.edged = Constant.edged
        button5.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button5.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor

        button6.setTitle("6", for: .normal)
        button6.setTitleColor(.textColor, for: .normal)
        button6.neumorphicLayer?.cornerRadius = button6.frame.height / 2.2
        button6.contentVerticalAlignment = .fill
//        button6.contentHorizontalAlignment = .fill
        button6.setTitleColor(.textColor, for: .selected)
        button6.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button6.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button6.neumorphicLayer?.edged = Constant.edged
        button6.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button6.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor


        button7.setTitle("7", for: .normal)
        button7.setTitleColor(.textColor, for: .normal)
        button7.neumorphicLayer?.cornerRadius = button7.frame.height / 2.2
        button7.contentVerticalAlignment = .fill
//        button7.contentHorizontalAlignment = .fill
        button7.setTitleColor(.textColor, for: .selected)
        button7.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button7.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button7.neumorphicLayer?.edged = Constant.edged
        button7.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button7.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor

        button8.setTitle("8", for: .normal)
        button8.setTitleColor(.textColor, for: .normal)
        button8.neumorphicLayer?.cornerRadius = button8.frame.height / 2.2
        button8.contentVerticalAlignment = .fill
//        button8.contentHorizontalAlignment = .fill
        button8.setTitleColor(.textColor, for: .selected)
        button8.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button8.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button8.neumorphicLayer?.edged = Constant.edged
        button8.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button8.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor

        button9.setTitle("9", for: .normal)
        button9.setTitleColor(.textColor, for: .normal)
        button9.neumorphicLayer?.cornerRadius = button9.frame.height / 2.2
        button9.contentVerticalAlignment = .fill
//        button9.contentHorizontalAlignment = .fill
        button9.setTitleColor(.textColor, for: .selected)
        button9.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button9.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button9.neumorphicLayer?.edged = Constant.edged
        button9.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button9.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor


        button0.setTitle("0", for: .normal)
        button0.setTitleColor(.textColor, for: .normal)
        button0.neumorphicLayer?.cornerRadius = button0.frame.height / 2.2
        button0.contentVerticalAlignment = .fill
//        button0.contentHorizontalAlignment = .fill
        button0.setTitleColor(.textColor, for: .selected)
        button0.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        button0.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        button0.neumorphicLayer?.edged = Constant.edged
        button0.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        button0.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor

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
        buttonEqual.setTitleColor(.textColor, for: .normal)
        buttonEqual.neumorphicLayer?.cornerRadius = buttonEqual.frame.height / 2.2
        buttonEqual.contentVerticalAlignment = .fill
//        buttonEqual.contentHorizontalAlignment = .fill
        buttonEqual.setTitleColor(.textColor, for: .selected)
        buttonEqual.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        buttonEqual.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        buttonEqual.neumorphicLayer?.edged = Constant.edged
        buttonEqual.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        buttonEqual.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor

        buttonAc.setTitle("AC", for: .normal)
        buttonAc.setTitleColor(.textColor, for: .normal)
        buttonAc.neumorphicLayer?.cornerRadius = buttonAc.frame.height / 2.2
        buttonAc.contentVerticalAlignment = .fill
//        buttonAc.contentHorizontalAlignment = .fill
        buttonAc.setTitleColor(.textColor, for: .selected)
        buttonAc.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        buttonAc.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        buttonAc.neumorphicLayer?.edged = Constant.edged
        buttonAc.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        buttonAc.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor

//        buttonPlusMinus.setTitle("+/-", for: .normal)
//        buttonPlusMinus.backgroundColor = .lightGray
//        buttonPlusMinus.setTitleColor(.black, for: .normal)
//        buttonPlusMinus.layer.cornerRadius = buttonPlusMinus.frame.height / 2.2
        
//        buttonPercent.setTitle("%", for: .normal)
//        buttonPercent.backgroundColor = .lightGray
//        buttonPercent.setTitleColor(.black, for: .normal)
//        buttonPercent.layer.cornerRadius = buttonPercent.frame.height / 2.2
        
    }
    
    @IBOutlet private var arrayHugo: [EMTNeumorphicButton]!
    
    // 数字ボタンを押下
    @objc func numClick(_ sender: EMTNeumorphicButton) {
        // 選択されていたボタンを選択解除する
        let newArray = arrayHugo.filter { $0.isSelected == true}
        for i in newArray {
            i.isSelected = false
        }
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.isSelected = !sender.isSelected
        }
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

        // 開始残高画面からの遷移の場合
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
                    print(navigationController0.viewControllers.count)
                    print(navigationController0.viewControllers[1])
                    print(navigationController2.viewControllers.count)
                    print(navigationController2.viewControllers[0])
                    print("iPad ビューコントローラーの階層")
                    //            print("splitViewController[0]      : ", splitViewController.viewControllers[0])     // UINavigationController
                    //            print("splitViewController[1]      : ", splitViewController.viewControllers[1] )    // UINavigationController
                    //            print("  navigationController[0]   : ", navigationController.viewControllers[0])    // SettingsTableViewController
                    //            print("    navigationController2[0]: ", navigationController2.viewControllers[0])   // OpeningBalanceViewController
                    if let presentingViewController = navigationController2.viewControllers[0] as? OpeningBalanceViewController { // 呼び出し元のビューコントローラーを取得
                        self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                            // ViewController(電卓画面)を閉じた時に、遷移元であるViewController(仕訳画面)で行いたい処理
                            presentingViewController.setAmountValue(
                                primaryKey: self.primaryKey,
                                numbersOnDisplay: self.numbersOnDisplay,
                                category: self.category,
                                debitOrCredit: self.debitOrCredit
                            )
                        })
                    }
                }
            } else { // iPhone
                print(splitViewController.viewControllers.count)
                if let navigationController1 = navigationController.viewControllers[1] as? UINavigationController {
                    navigationController2 = navigationController1
                    //             navigationController2 = navigationController.viewControllers[0] as! UINavigationController // ナビゲーションバーコントローラの配下にあるビューコントローラーを取得
                    print("iPhone ビューコントローラーの階層")
                    print("splitViewController[0]      : ", splitViewController.viewControllers[0])     // UINavigationController
                    print("  navigationController[0]   : ", navigationController.viewControllers[0])    // SettingsTableViewController
                    print("  navigationController[1]   : ", navigationController.viewControllers[1])    // UINavigationController
                    print("    navigationController2[0]: ", navigationController2.viewControllers[0])   // OpeningBalanceViewController
                    if let presentingViewController = navigationController2.viewControllers[0] as? OpeningBalanceViewController { // 呼び出し元のビューコントローラーを取得
                        self.dismiss(animated: true, completion: { [presentingViewController] () -> Void in
                            // ViewController(電卓画面)を閉じた時に、遷移元であるViewController(仕訳画面)で行いたい処理
                            presentingViewController.setAmountValue(
                                primaryKey: self.primaryKey,
                                numbersOnDisplay: self.numbersOnDisplay,
                                category: self.category,
                                debitOrCredit: self.debitOrCredit
                            )
                        })
                    }
                }
            }
        }

        if let presentingViewController2 = presentingViewController as? OpeningBalanceViewController {
            // viewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: { [presentingViewController2] () -> Void in

            })
            return
        }
        // 仕訳帳、決算整理仕訳、仕訳編集画面からの遷移の場合
        if let presentingViewController2 = presentingViewController as? JournalEntryViewController {
            // viewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: { [presentingViewController2] () -> Void in
                // ViewController(電卓画面)を閉じた時に、遷移元であるViewController(仕訳画面)で行いたい処理
                presentingViewController2.setAmountValue(numbersOnDisplay: self.numbersOnDisplay)
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
            self.dismiss(animated: true, completion: { [presentingViewController2] () -> Void in
                // ViewController(電卓画面)を閉じた時に、遷移元であるViewController(仕訳画面)で行いたい処理
                presentingViewController2.setAmountValue(numbersOnDisplay: self.numbersOnDisplay)
            })
              return
        }
    }
    
    func equalAction() {
        buttonEqual.addTarget(self, action: #selector(clickEqual(_:)), for: .touchUpInside)
    }
    
    @objc func clickAc(_ sender: EMTNeumorphicButton) {
        // 選択されていたボタンを選択解除する
        let newArray = arrayHugo.filter { $0.isSelected == true}
        for i in newArray {
            i.isSelected = false
        }
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            sender.isSelected = !sender.isSelected
        }
        
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
