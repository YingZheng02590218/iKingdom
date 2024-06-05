//
//  ClassicCalculatorViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/12/30.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import AudioToolbox
import EMTNeumorphicView
import UIKit

class ClassicCalculatorViewController: UIViewController {
    
    @IBOutlet private var backgroundView: EMTNeumorphicView!
    @IBOutlet private var labelView: EMTNeumorphicView!
    @IBOutlet private var label: UILabel!
    
    @IBOutlet private var buttonAc: EMTNeumorphicButton!
    // TODO: 使用していない
    @IBOutlet private var buttonPlusMinus: UIButton!
    @IBOutlet private var buttonPercent: UIButton!
    @IBOutlet private var buttonDivied: EMTNeumorphicButton!
    @IBOutlet private var buttonMultiple: EMTNeumorphicButton!
    @IBOutlet private var buttonMinus: EMTNeumorphicButton!
    @IBOutlet private var buttonPlus: EMTNeumorphicButton!
    
    @IBOutlet private var button9: EMTNeumorphicButton!
    @IBOutlet private var button8: EMTNeumorphicButton!
    @IBOutlet private var button7: EMTNeumorphicButton!
    @IBOutlet private var button6: EMTNeumorphicButton!
    @IBOutlet private var button5: EMTNeumorphicButton!
    @IBOutlet private var button4: EMTNeumorphicButton!
    @IBOutlet private var button3: EMTNeumorphicButton!
    @IBOutlet private var button2: EMTNeumorphicButton!
    @IBOutlet private var button1: EMTNeumorphicButton!
    @IBOutlet private var button0: EMTNeumorphicButton!
    @IBOutlet private var buttonDoubleZero: EMTNeumorphicButton!
    
    @IBOutlet private var buttonEqual: EMTNeumorphicButton!
    
    @IBOutlet private var arrayHugo: [EMTNeumorphicButton]!
    /// モーダル上部に設置されるインジケータ
    private lazy var indicatorView: SemiModalIndicatorView = {
        let indicator = SemiModalIndicatorView()
        indicator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(indicatorDidTap(_:))))
        return indicator
    }()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActions()
        // viewDidLayoutSubviews()に書くと何度も呼ばれて、落ちる
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // viewDidLayoutSubviews()に書くと何度も呼ばれて、落ちる?
        setupLayout()
    }
    
    // MARK: - Setup
    
    func setupLayout() {
        if let backgroundView = backgroundView {
            //　左上と右上を角丸にする設定
            backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            backgroundView.layer.cornerRadius = 20
            backgroundView.clipsToBounds = true
            backgroundView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            backgroundView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            backgroundView.neumorphicLayer?.edged = Constant.edged
            backgroundView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            backgroundView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        }
        
        if let labelView = labelView {
            // Default is 1.
            labelView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            // Default is 0.3.
            labelView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            // Adding a thin border on the edge of the element.
            labelView.neumorphicLayer?.edged = true
            labelView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            labelView.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        }
        
        if let label = label {
            // label.font = UIFont(name: "DSEG14 Classic-Regular", size: 34)
            label.text = numbersOnDisplay.description
            label.textAlignment = .right
        }
        
        for button in arrayHugo {
            // button.setTitle("1", for: .normal)
            button.setTitleColor(.textColor, for: .normal)
            button.neumorphicLayer?.cornerRadius = button.frame.height / 2.8
            button.contentVerticalAlignment = .fill
            // button.contentHorizontalAlignment = .fill
            button.setTitleColor(.textColor, for: .selected)
            button.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            button.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            button.neumorphicLayer?.edged = Constant.edged
            button.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            button.neumorphicLayer?.elementBackgroundColor = UIColor.baseColor.cgColor
        }
        
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
    
    func setupActions() {
        buttonAc.addTarget(self, action: #selector(clickAc(_:)), for: .touchUpInside)
        
        buttonDoubleZero.addTarget(self, action: #selector(numClick(_:)), for: .touchUpInside)
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
        
        buttonEqual.addTarget(self, action: #selector(clickEqual(_:)), for: .touchUpInside)
    }
    
    // MARK: - Action
    
    @objc
    func clickAc(_ sender: EMTNeumorphicButton) {
        // システムサウンドを鳴らす
        AudioServicesPlaySystemSound(1_155) // key_press_delete.caf
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
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
        
        numbersOnDisplay = DecimalNumbers.zero.rawValue
        box1 = DecimalNumbers.zero.rawValue // nil
        box2 = DecimalNumbers.zero.rawValue // nil
        hugoBox = .undefined
        
        label.text = numbersOnDisplay.description
    }
    
    // 数字ボタンを押下
    @objc
    func numClick(_ sender: EMTNeumorphicButton) {
        // システムサウンドを鳴らす
        AudioServicesPlaySystemSound(1_123) // key_press_click.caf
        // フィードバック
        if #available(iOS 10.0, *), let generator = feedbackGeneratorMedium as? UIImpactFeedbackGenerator {
            generator.impactOccurred()
        }
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
        case buttonDoubleZero:
            // 入力チェック 文字数最大数を設定
            if sentText.description.count > 6 {
                return
            }
            numbersOnDisplay = sentText * 100 + DecimalNumbers.zero.rawValue + DecimalNumbers.zero.rawValue
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
    
    // イコールボタン押下
    // 入力値を設定する
    // ビジネスロジックを呼び出す
    // box1 四則演算子 box2 = 計算結果
    @objc
    func clickEqual(_ sender: EMTNeumorphicButton) {
        // システムサウンドを鳴らす
        AudioServicesPlaySystemSound(1_156) // key_press_modifier.caf
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.closeScreen()
        }
    }
    
    func closeScreen() {
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
        // 仕訳帳画面（仕訳編集、決算整理仕訳編集、仕訳まとめて編集）、勘定画面（仕訳編集、決算整理仕訳編集）、よく使う仕訳画面からの遷移の場合
        if let presentingViewController2 = presentingViewController as? JournalEntryViewController {
            // viewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: { [presentingViewController2] () -> Void in
                // ViewController(電卓画面)を閉じた時に、遷移元であるViewController(仕訳画面)で行いたい処理
                presentingViewController2.setAmountValue(numbersOnDisplay: self.numbersOnDisplay)
            })
            return
        }
        // 仕訳帳画面（仕訳）、精算表画面（決算整理仕訳）からの遷移の場合
        if let navigationController = presentingViewController as? UINavigationController,
           let presentingViewController2 = navigationController.topViewController as? JournalEntryViewController {
            // viewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: { [presentingViewController2] () -> Void in
                // ViewController(電卓画面)を閉じた時に、遷移元であるViewController(仕訳画面)で行いたい処理
                presentingViewController2.setAmountValue(numbersOnDisplay: self.numbersOnDisplay)
            })
            return
        }
        // タブバーの仕訳タブからの遷移の場合
        // モーダルの起動元はタブコントローラ
        if let tabBarController = presentingViewController as? UITabBarController,
           // タブで選択中のナビゲーションコントローラ
           let navigationController = tabBarController.selectedViewController as? UINavigationController,
           // ナビゲーションコントローラの最前面を取得
           let presentingViewController2 = navigationController.topViewController as? JournalEntryViewController {
            // viewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: { [presentingViewController2] () -> Void in
                // ViewController(電卓画面)を閉じた時に、遷移元であるViewController(仕訳画面)で行いたい処理
                presentingViewController2.setAmountValue(numbersOnDisplay: self.numbersOnDisplay)
            })
            return
        }
    }
    
    // インジケータ タップ
    @objc
    private func indicatorDidTap(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
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
