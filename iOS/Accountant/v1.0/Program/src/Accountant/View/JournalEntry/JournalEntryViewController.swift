//
//  JournalEntryViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/23.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import EMTNeumorphicView
import Firebase // イベントログ対応
import GoogleMobileAds // マネタイズ対応
import UIKit

// 仕訳クラス
class JournalEntryViewController: UIViewController {
    
    // MARK: - var let
    
    private var interstitial: GADInterstitialAd?
    // タイトルラベル
    @IBOutlet var labelTitle: UILabel!
    // 仕訳/決算整理仕訳　切り替え
    @IBOutlet var segmentedControl: UISegmentedControl!
    // よく使う仕訳　エリア　カルーセル
    @IBOutlet private var tableView: UITableView!
    // カルーセル　true: リロードする
    static var viewReload = false
    // ボタン　アウトレットコレクション
    @IBOutlet var arrayHugo: [EMTNeumorphicButton]!
    @IBOutlet var buttonRight: EMTNeumorphicButton!
    @IBOutlet private var buttonLeft: EMTNeumorphicButton!
    @IBOutlet var inputButton: EMTNeumorphicButton!
    @IBOutlet private var cancelButton: EMTNeumorphicButton!
    // デイトピッカー　日付
    @IBOutlet private var datePicker: UIDatePicker!
    let dateFormatter = DateFormatter()
    var isMaskedDatePicker = false // マスクフラグ
    
    @IBOutlet private var datePickerView: EMTNeumorphicView!
    @IBOutlet private var maskDatePickerButton: UIButton!
    // テキストフィールド　勘定科目、金額
    @IBOutlet var textFieldCategoryDebit: PickerTextField!
    @IBOutlet var textFieldCategoryCredit: PickerTextField!
    @IBOutlet var textFieldAmountDebit: UITextField!
    @IBOutlet var textFieldAmountCredit: UITextField!
    @IBOutlet var textFieldView: EMTNeumorphicView!
    // テキストフィールド　小書き
    @IBOutlet var textFieldSmallWritting: UITextField!
    @IBOutlet var smallWrittingTextFieldView: EMTNeumorphicView!
    // 小書き　カウンタ
    @IBOutlet var smallWritingCounterLabel: UILabel!
    // 小書き　エラーメッセージ
    var errorMessage: String?
    // テキストフィールド　勘定科目、小書きのキーボードが表示中フラグ
    var isShown = false
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
    private var timer: Timer? // Timerを保持する変数
    
    // 仕訳タイプ(仕訳 or 決算整理仕訳 or 編集)
    var journalEntryType: JournalEntryType = .JournalEntry // Journal Entries、Adjusting and Closing Entries, JournalEntriesPackageFixing
    
    // 仕訳編集　仕訳帳画面で選択されたセルの位置　仕訳か決算整理仕訳かの判定に使用する
    var tappedIndexPath = IndexPath(row: 0, section: 0)
    // 仕訳編集　編集の対象となる仕訳の連番
    var primaryKey: Int = 0
    // グループ
    var groupObjects = DataBaseManagerSettingsOperatingJournalEntryGroup.shared.getJournalEntryGroup()
    
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
    
    // 金額　電卓画面で入力した値を表示させる
    func setAmountValue(numbersOnDisplay: Int) {
        // 金額を入力後に、電卓画面から仕訳画面へ遷移した場合
        textFieldAmountDebit.text = StringUtility.shared.addComma(string: numbersOnDisplay.description)
        textFieldAmountCredit.text = StringUtility.shared.addComma(string: numbersOnDisplay.description)
        // TextField 貸方金額　入力後
        if textFieldAmountDebit.text == "0"{
            textFieldAmountDebit.text = ""
            textFieldAmountCredit.text = ""
        }
        if textFieldAmountCredit.text == "0"{
            textFieldAmountCredit.text = ""
            textFieldAmountDebit.text = ""
        }
        // 仕訳一括編集ではない場合 よく使う仕訳ではない場合
        if journalEntryType != .JournalEntriesPackageFixing  && // 仕訳一括編集 仕訳帳画面からの遷移の場合
            journalEntryType != .SettingsJournalEntries  && // よく使う仕訳 追加
            journalEntryType != .SettingsJournalEntriesFixing { // よく使う仕訳 更新
            
            if textFieldSmallWritting.text == "" {
                textFieldSmallWritting.becomeFirstResponder() // カーソルを移す
            }
        }
    }
    // よく使う仕訳　エリア カルーセルをリロードする
    func reloadCarousel() {
        if JournalEntryViewController.viewReload {
            DispatchQueue.main.async { [self] in
                // よく使う仕訳で選択した勘定科目が入っている可能性があるので、初期化
                self.textFieldCategoryDebit.text = nil
                textFieldCategoryCredit.text = nil
                // よく使う仕訳　エリア
                tableView.reloadData()
                
                JournalEntryViewController.viewReload = false
            }
        }
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
        let nowStringHHmmss = DateManager.shared.dateFormatterHHmmss.string(from: now)
        let nowStringYYYY = DateManager.shared.dateFormatterYYYY.string(from: now)
        // 設定決算日
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        guard let dayOfEndInPeriod: Date   = DateManager.shared.dateFormatterMMdd.date(from: theDayOfReckoning) else { return } // 決算日設定機能 注意：nowStringYearは、開始日の日付が存在するかどうかを確認するために記述した。閏年など
        guard let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: dayOfEndInPeriod) else { return } // 決算日設定機能　年度開始日は決算日の翌日に設定する
        guard let dayOfStartInPeriod: Date = DateManager.shared.dateFormatterMMdd.date(from: DateManager.shared.dateFormatterMMdd.string(from: modifiedDate)) else { return } // 決算日設定機能　年度開始日
        // 期間
        guard let dayOfStartInYear: Date       = DateManager.shared.dateFormatterMMdd.date(from: "01/01") else { return }
        guard let dayOfEndInYear: Date         = DateManager.shared.dateFormatterMMdd.date(from: "12/31") else { return }
        guard let nowStringMonthDayMMdd: Date  = DateManager.shared.dateFormatterMMdd.date(from: nowStringMonthDay) else { return }
        guard let yyyyMMddHHmmss: Date         = DateManager.shared.dateFormatteryyyyMMddHHmmss.date(from: theDayOfReckoning + "/" + nowStringYear + ", " + nowStringHHmmss) else { return }
        guard let yyyyMMddHHmmssNextYear: Date = DateManager.shared.dateFormatteryyyyMMddHHmmss.date(from: theDayOfReckoning + "/" + nowStringNextYear + ", " + nowStringHHmmss) else { return }
        guard let yyyyMMddHHmmssNow: Date = DateManager.shared.dateFormatteryyyyMMddHHmmss.date(from: nowStringMonthDay + "/" + nowStringYYYY + ", " + nowStringHHmmss) else { return }
        // リワード広告が表示されたあと、日付が現在日時にリセットされる
        // guard let yyyyMMddHHmmssNowCurrent = Date.convertDate(from: nowStringMonthDay + "/" + nowStringYYYY + ", " + nowStringHHmmss, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ") else { return }
        // print(yyyyMMddHHmmssNowCurrent.toString(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"))
        
        // デイトピッカーの最大値と最小値を設定
        if journalEntryType == .AdjustingAndClosingEntries || // 決算整理仕訳 精算表画面からの遷移の場合
            journalEntryType == .AdjustingAndClosingEntry {
            // 決算整理仕訳の場合は日付を決算日に固定
            if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                print("### 会計期間が年をまたがない場合")
                datePicker.minimumDate = DateManager.shared.dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(DateManager.shared.timezone.string(from: dayOfEndInPeriod))")
                print(DateManager.shared.dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(DateManager.shared.timezone.string(from: dayOfEndInPeriod))"))
                datePicker.maximumDate = DateManager.shared.dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(DateManager.shared.timezone.string(from: dayOfEndInPeriod))")
            } else { // 会計期間が年をまたぐ場合
                print("### 会計期間が年をまたぐ場合")
                datePicker.minimumDate = DateManager.shared.dateFormatteryyyyMMdd.date(from: nowStringNextYear + "-\(DateManager.shared.timezone.string(from: dayOfEndInPeriod))")
                datePicker.maximumDate = DateManager.shared.dateFormatteryyyyMMdd.date(from: nowStringNextYear + "-\(DateManager.shared.timezone.string(from: dayOfEndInPeriod))")
            }
        } else if journalEntryType == .JournalEntriesFixing { // 仕訳編集 仕訳帳画面からの遷移の場合
            // 決算日設定機能　何もしない
        } else if journalEntryType == .JournalEntriesPackageFixing { // 仕訳一括編集 仕訳帳画面からの遷移の場合
            
        } else {
            if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                print("### 会計期間が年をまたがない場合")
                datePicker.minimumDate = DateManager.shared.dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(DateManager.shared.timezone.string(from: modifiedDate))")
                print(DateManager.shared.dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(DateManager.shared.timezone.string(from: modifiedDate))"))
                datePicker.maximumDate = DateManager.shared.dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(DateManager.shared.timezone.string(from: dayOfEndInPeriod))")
                print(DateManager.shared.dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(DateManager.shared.timezone.string(from: dayOfEndInPeriod))"))
            } else { // 会計期間が年をまたぐ場合
                // 01/01 以降か
                guard let interval = (Calendar.current.dateComponents([.month], from: dayOfStartInYear, to: nowStringMonthDayMMdd)).month else { return }
                // 設定決算日 未満か
                guard let interval1 = (Calendar.current.dateComponents([.month], from: dayOfEndInPeriod, to: nowStringMonthDayMMdd)).month else { return }
                // 年度開始日 以降か
                guard let interval2 = (Calendar.current.dateComponents([.month], from: dayOfStartInPeriod, to: nowStringMonthDayMMdd)).month else { return }
                // 12/31と同じ、もしくはそれ以前か
                guard let interval3 = (Calendar.current.dateComponents([.month], from: dayOfEndInYear, to: nowStringMonthDayMMdd)).month else { return }
                
                if interval >= 0 {
                    print("### 会計期間　1/01 以降")
                    if interval1 <= 0 {
                        print("### 会計期間　設定決算日 未満")
                        // 決算日設定機能　注意：カンマの後にスペースがないとnilになる
                        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: yyyyMMddHHmmss)
                        // 四月以降か
                        datePicker.maximumDate = DateManager.shared.dateFormatteryyyyMMdd.date(from: (nowStringNextYear + "-\(DateManager.shared.timezone.string(from: dayOfEndInPeriod))"))
                    } else if interval2 >= 0 {
                        print("### 会計期間　年度開始日 以降")
                        if interval3 <= 0 {
                            print("### 会計期間　12/31 以前")
                            // 決算日設定機能　注意：カンマの後にスペースがないとnilになる 04-02にすると04-01となる
                            datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: yyyyMMddHHmmss)
                            // 04-01にすると03-31となる
                            datePicker.maximumDate = DateManager.shared.dateFormatteryyyyMMdd.date(from: nowStringNextYear + "-\(DateManager.shared.timezone.string(from: dayOfEndInPeriod))")
                        }
                    }
                }
            }
        }
        // ピッカーの初期値
        if journalEntryType == .JournalEntriesFixing { // 仕訳編集 仕訳帳画面からの遷移の場合
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
        //        inputButton.setTitle("入力", for: .normal)
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
    }
    
    // MARK: PickerTextField
    // TextField作成　勘定科目
    func createTextFieldForCategory() {
        textFieldCategoryDebit.delegate = self
        textFieldCategoryCredit.delegate = self

        textFieldCategoryDebit.textAlignment = .left
        textFieldCategoryCredit.textAlignment = .right
        
        textFieldCategoryDebit.layer.borderWidth = 0.5
        textFieldCategoryCredit.layer.borderWidth = 0.5
        
        textFieldCategoryDebit.setup()
        textFieldCategoryCredit.setup()
    }
    
    // MARK: UITextField
    // TextField作成 金額
    func createTextFieldForAmount() {
        textFieldAmountDebit.delegate = self
        textFieldAmountCredit.delegate = self
        
        textFieldAmountDebit.textAlignment = .left
        textFieldAmountCredit.textAlignment = .right
        
        textFieldAmountDebit.layer.borderWidth = 0.5
        textFieldAmountCredit.layer.borderWidth = 0.5
    }
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
    // 初期値を再設定
    func setInitialData() {
        if textFieldAmountDebit.text == "" {
            if textFieldAmountCredit.text != "" || textFieldAmountCredit.text != "" {
                textFieldAmountDebit.text = textFieldAmountCredit.text
            }
        }
        if textFieldAmountCredit.text == "" {
            if textFieldAmountDebit.text != "" || textFieldAmountDebit.text != "" {
                textFieldAmountCredit.text = textFieldAmountDebit.text
            }
        }
    }
    
    // MARK: GADInterstitialAd
    // セットアップ AdMob　アップグレード機能　スタンダードプラン
    func setupAdMob() {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView プロパティを設定する
            // GADInterstitial を作成する
            let request = GADRequest()
            GADInterstitialAd.load(
                withAdUnitID: Constant.ADMOBIDINTERSTITIAL,
                request: request,
                completionHandler: { [self] ad, error in
                    if let error = error {
                        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                        return
                    }
                    interstitial = ad
                    interstitial?.fullScreenContentDelegate = self
                }
            )
        }
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
            labelTitle.text = ""
            self.navigationItem.title = "仕訳"
        } else {
            journalEntryType = .AdjustingAndClosingEntry // 決算整理仕訳 タブバーの仕訳タブからの遷移の場合
            labelTitle.text = ""
            self.navigationItem.title = "決算整理仕訳"
        }
        // デイトピッカー作成
        createDatePicker()
    }
    
    // MARK: UIButton
    // デイトピッカーのマスク
    @IBAction func maskDatePickerButtonTapped(_ sender: Any) {
        // マスクを取る
        maskDatePickerButton.isHidden = true
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            sender.isSelected = !sender.isSelected
        }
        
        let min = datePicker.minimumDate!
        if datePicker.date > min {
            let modifiedDate = Calendar.current.date(byAdding: .day, value: -1, to: datePicker.date)! // 1日前へ
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            sender.isSelected = !sender.isSelected
        }
        
        let max = datePicker.maximumDate!
        if datePicker.date < max {
            let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: datePicker.date)! // 1日次へ
            datePicker.date = modifiedDate
        }
    }
    
    // MARK: UITextField
    @IBAction private func textFieldCategoryDebit(_ sender: UITextField) {}
    @IBAction private func textFieldCategoryCredit(_ sender: UITextField) {}
    
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
        // 初期値を再設定
        setInitialData()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sender.isSelected = !sender.isSelected
        }
        
        if journalEntryType == .JournalEntriesPackageFixing { // 仕訳一括編集 仕訳帳画面からの遷移の場合
            // バリデーションチェック ひとつでも変更されているか、小書き
            if textInputCheckForJournalEntriesPackageFixing() {
                presenter.inputButtonTapped(journalEntryType: journalEntryType)
            }
        } else { // 一括編集以外
            // バリデーションチェック　全て入力されているか
            if textInputCheck() {
                presenter.inputButtonTapped(journalEntryType: journalEntryType)
            }
        }
    }
    
    // 仕訳一括編集　の処理
    func buttonTappedForJournalEntriesPackageFixing() -> JournalEntryData {
        // バリデーションチェック
        var datePicker: String?
        if isMaskedDatePicker {
            datePicker = dateFormatter.string(from: self.datePicker.date)
        } else {
            datePicker = nil
        }
        var textFieldCategoryDebit: String?
        if let text = self.textFieldCategoryDebit.text {
            if !text.isEmpty {
                textFieldCategoryDebit = text
            }
        } else {
            textFieldCategoryDebit = nil
        }
        var textFieldCategoryCredit: String?
        if let text = self.textFieldCategoryCredit.text {
            if !text.isEmpty {
                textFieldCategoryCredit = text
            }
        } else {
            textFieldCategoryCredit = nil
        }
        var textFieldAmountDebit: Int64?
        if let text = self.textFieldAmountDebit.text {
            textFieldAmountDebit = Int64(StringUtility.shared.removeComma(string: text))
        } else {
            textFieldAmountDebit = nil
        }
        var textFieldAmountCredit: Int64?
        if let text = self.textFieldAmountCredit.text {
            textFieldAmountCredit = Int64(StringUtility.shared.removeComma(string: text))
        } else {
            textFieldAmountCredit = nil
        }
        var textFieldSmallWritting: String?
        if let text = self.textFieldSmallWritting.text {
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
    
    // 決算整理仕訳　の処理
    func buttonTappedForAdjustingAndClosingEntries() -> JournalEntryData? {
        // データベース　仕訳データを追加
        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
        if let textFieldCategoryDebit = textFieldCategoryDebit.text,
           let textFieldAmountDebit = textFieldAmountDebit.text,
           let textFieldCategoryCredit = textFieldCategoryCredit.text,
           let textFieldAmountCredit = textFieldAmountCredit.text,
           let textFieldAmountDebitInt64 = Int64(StringUtility.shared.removeComma(string: textFieldAmountDebit)),
           let textFieldAmountCreditInt64 = Int64(StringUtility.shared.removeComma(string: textFieldAmountCredit)),
           let textFieldSmallWritting = textFieldSmallWritting.text {
            
            let dBJournalEntry = JournalEntryData(
                date: dateFormatter.string(from: datePicker.date),
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
    
    // 仕訳編集　の処理
    func buttonTappedForJournalEntriesFixing() -> (JournalEntryData?, Int, Int) {
        // データベース　仕訳データを追加
        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
        if let textFieldCategoryDebit = textFieldCategoryDebit.text,
           let textFieldAmountDebit = textFieldAmountDebit.text,
           let textFieldCategoryCredit = textFieldCategoryCredit.text,
           let textFieldAmountCredit = textFieldAmountCredit.text,
           let textFieldAmountDebitInt64 = Int64(StringUtility.shared.removeComma(string: textFieldAmountDebit)),
           let textFieldAmountCreditInt64 = Int64(StringUtility.shared.removeComma(string: textFieldAmountCredit)),
           let textFieldSmallWritting = textFieldSmallWritting.text {
            
            let dBJournalEntry = JournalEntryData(
                date: dateFormatter.string(from: datePicker.date),
                debit_category: textFieldCategoryDebit,
                debit_amount: textFieldAmountDebitInt64,
                credit_category: textFieldCategoryCredit,
                credit_amount: textFieldAmountCreditInt64,
                smallWritting: textFieldSmallWritting
            )
            
            return (dBJournalEntry, tappedIndexPath.section, primaryKey) // 1:決算整理仕訳
        }
        
        return (nil, tappedIndexPath.section, primaryKey)
    }
    
    // 仕訳　の処理
    func buttonTappedForJournalEntries() -> JournalEntryData? {
        // データベース　仕訳データを追加
        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
        if let textFieldCategoryDebit = textFieldCategoryDebit.text,
           let textFieldAmountDebit = textFieldAmountDebit.text,
           let textFieldCategoryCredit = textFieldCategoryCredit.text,
           let textFieldAmountCredit = textFieldAmountCredit.text,
           let textFieldAmountDebitInt64 = Int64(StringUtility.shared.removeComma(string: textFieldAmountDebit)),
           let textFieldAmountCreditInt64 = Int64(StringUtility.shared.removeComma(string: textFieldAmountCredit)),
           let textFieldSmallWritting = textFieldSmallWritting.text {
            
            let dBJournalEntry = JournalEntryData(
                date: dateFormatter.string(from: datePicker.date),
                debit_category: textFieldCategoryDebit,
                debit_amount: textFieldAmountDebitInt64,
                credit_category: textFieldCategoryCredit,
                credit_amount: textFieldAmountCreditInt64,
                smallWritting: textFieldSmallWritting
            )
            // イベントログ
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterContentType: Constant.JOURNALS,
                AnalyticsParameterItemID: Constant.ADDJOURNALENTRY
            ])
            
            return dBJournalEntry
        }
        
        return nil
    }
    
    // タブバーの仕訳タブからの遷移の場合
    func buttonTappedForJournalEntriesOnTabBar() -> JournalEntryData? {
        // データベース　仕訳データを追加
        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
        if let textFieldCategoryDebit = textFieldCategoryDebit.text,
           let textFieldAmountDebit = textFieldAmountDebit.text,
           let textFieldCategoryCredit = textFieldCategoryCredit.text,
           let textFieldAmountCredit = textFieldAmountCredit.text,
           let textFieldAmountDebitInt64 = Int64(StringUtility.shared.removeComma(string: textFieldAmountDebit)),
           let textFieldAmountCreditInt64 = Int64(StringUtility.shared.removeComma(string: textFieldAmountCredit)),
           let textFieldSmallWritting = textFieldSmallWritting.text {
            
            let dBJournalEntry = JournalEntryData(
                date: dateFormatter.string(from: datePicker.date),
                debit_category: textFieldCategoryDebit,
                debit_amount: textFieldAmountDebitInt64,
                credit_category: textFieldCategoryCredit,
                credit_amount: textFieldAmountCreditInt64,
                smallWritting: textFieldSmallWritting
            )
            // イベントログ
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterContentType: Constant.JOURNALENTRY,
                AnalyticsParameterItemID: Constant.ADDJOURNALENTRY
            ])
            
            return dBJournalEntry
        }
        
        return nil
    }
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
    
    // 入力チェック
    func textInputCheck() -> Bool {
        // バリデーション 借方勘定科目
        guard textInputCheck(text: textFieldCategoryDebit.text, editableType: .categoryDebit, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 未入力のTextFieldのキーボードを自動的に表示する
                self.textFieldCategoryDebit.becomeFirstResponder()
            }
        }) else {
            return false // NG
        }
        
        // バリデーション 貸方勘定科目
        guard textInputCheck(text: textFieldCategoryCredit.text, editableType: .categoryCredit, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 未入力のTextFieldのキーボードを自動的に表示する
                self.textFieldCategoryCredit.becomeFirstResponder()
            }
        }) else {
            return false // NG
        }
        // バリデーション 勘定科目
        guard textInputCheck(creditText: textFieldCategoryCredit.text, debitText: textFieldCategoryDebit.text, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 未入力のTextFieldのキーボードを自動的に表示する
                self.textFieldCategoryCredit.becomeFirstResponder()
            }
        }) else {
            return false // NG
        }
        // バリデーション 金額
        guard textInputCheck(text: textFieldAmountDebit.text, editableType: .amount, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 未入力のTextFieldのキーボードを自動的に表示する
                self.textFieldAmountDebit.becomeFirstResponder()
            }
        }) else {
            return false // NG
        }
        
        // バリデーション 金額
        guard textInputCheck(text: textFieldAmountCredit.text, editableType: .amount, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // 未入力のTextFieldのキーボードを自動的に表示する
                self.textFieldAmountCredit.becomeFirstResponder()
            }
        }) else {
            return false // NG
        }
        
        // 小書き　バリデーションチェック
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
    // バリデーション 勘定科目、金額
    func textInputCheck(text: String?, editableType: EditableType, completion: @escaping () -> Void) -> Bool {
        // バリデーションチェック
        switch ErrorValidation().validateEmpty(text: text, editableType: editableType) {
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
    // バリデーション 勘定科目
    func textInputCheck(creditText: String?, debitText: String?, completion: @escaping () -> Void) -> Bool {
        // バリデーションチェック
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
    // エラーダイアログ
    func showErrorMessage(completion: @escaping () -> Void) {
        // フィードバック
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        let alert = UIAlertController(title: "エラー", message: errorMessage, preferredStyle: .alert)
        self.present(alert, animated: true) { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true, completion: nil)
                completion()
            }
        }
    }
    // インタースティシャル広告を表示　マネタイズ対応
    func showAd() {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            
            var iValue = 0
            // 仕訳が50件以上入力済みの場合は毎回広告を表示する　マネタイズ対応
            let results = DataBaseManagerJournalEntry.shared.getJournalEntryCount()
            if results.count <= 10 {
                // 仕訳10件以下　広告を表示しない
                iValue = 1
            } else if results.count <= 50 {
                // 乱数　1から6までのIntを生成
                iValue = Int.random(in: 1 ... 6)
            }
            if iValue % 2 == 0 {
                if interstitial != nil {
                    interstitial?.present(fromRootViewController: self)
                } else {
                    print("Ad wasn't ready")
                    // セットアップ AdMob
                    setupAdMob()
                }
            }
        }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            sender.isSelected = !sender.isSelected
        }
        textFieldCategoryDebit.text = ""
        textFieldCategoryCredit.text = ""
        textFieldAmountDebit.text = ""
        textFieldAmountCredit.text = ""
        textFieldSmallWritting.text = ""
        // 終了させる　仕訳帳画面か精算表画面へ戻る
        if journalEntryType != .JournalEntry && // 仕訳 タブバーの仕訳タブからの遷移の場合
            journalEntryType != .AdjustingAndClosingEntry { // 決算整理仕訳 タブバーの仕訳タブからの遷移の場合
            self.dismiss(animated: true, completion: nil)
        }
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
        // セットアップ AdMob
        setupAdMob()
        // 広告を閉じた
        presenter.adDidDismissFullScreenContent()
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension JournalEntryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func initTable() {
        // 仕訳テンプレート画面では使用しない
        if let tableView = tableView {
            tableView.delegate = self
            tableView.dataSource = self
            let cellName = "CarouselTableViewCell"
            tableView.register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
            tableView.separatorColor = .accentColor
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groupObjects.count + 1 // グループ　その他
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarouselTableViewCell", for: indexPath) as! CarouselTableViewCell
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
        let height = (collectionView.bounds.size.height / 2) - 10
        return CGSize(width: size.width + 20.0, height: height < 0 ? 0 : height)
    }
    // 余白の調整（UIImageを拡大、縮小している）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // top:ナビゲーションバーの高さ分上に移動
        return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
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
        // データベース　よく使う仕訳
        let objects = DataBaseManagerSettingsOperatingJournalEntry.shared.getJournalEntry(
            group: collectionView.tag // グループ　その他 collectionView.tag == 0
        )
        textFieldCategoryDebit.text = objects[indexPath.row].debit_category
        textFieldAmountDebit.text = StringUtility.shared.addComma(string: String(objects[indexPath.row].debit_amount))
        textFieldCategoryCredit.text = objects[indexPath.row].credit_category
        textFieldAmountCredit.text = StringUtility.shared.addComma(string: String(objects[indexPath.row].credit_amount))
        textFieldSmallWritting.text = objects[indexPath.row].smallWritting
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        print("Unhighlighted: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        true  // 変更
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: \(indexPath)")
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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
        if textField == textFieldAmountDebit || textField == textFieldAmountCredit {
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
        textField.layer.shadowOpacity = 1.4
        textField.layer.shadowRadius = 4
        textField.layer.shadowColor = UIColor.calculatorDisplay.cgColor
        textField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        
        // 2列目のComponentをリロードする
        if textField == textFieldCategoryDebit {
            textFieldCategoryDebit.reloadComponent()
        } else if textField == textFieldCategoryCredit {
            textFieldCategoryCredit.reloadComponent()
        }
        // 借方金額　貸方金額
        if textField == textFieldAmountDebit || textField == textFieldAmountCredit {
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
        if textField == textFieldAmountDebit || textField == textFieldAmountCredit { // 借方金額仮　貸方金額
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
        case 333, 444: // 金額の文字数 + カンマの数 (100万円の位まで入力可能とする)
            maxLength = 7 + 2
        case 555: // 小書きの文字数
            maxLength = EditableType.smallWriting.maxLength
        case 888: // ニックネームの文字数
            maxLength = EditableType.nickname.maxLength
        default:
            break
        }
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
        
        if textField.tag == 111 { // 借方勘定科目
            if textFieldCategoryDebit.text == "" {
                // 未入力
            } else if textFieldCategoryCredit.text == textFieldCategoryDebit.text { // 貸方と同じ勘定科目の場合
                // 同じ勘定科目を指定できるように変更
                // textFieldCategoryDebit.text = ""
            } else {
                // 仕訳一括編集ではない場合 よく使う仕訳ではない場合
                if journalEntryType != .JournalEntriesPackageFixing && // 仕訳一括編集 仕訳帳画面からの遷移の場合
                    journalEntryType != .SettingsJournalEntries  && // よく使う仕訳 追加
                    journalEntryType != .SettingsJournalEntriesFixing { // よく使う仕訳 更新
                    if textFieldCategoryCredit.text == "" {
                        textFieldCategoryCredit.becomeFirstResponder()
                    }
                }
            }
        } else if textField.tag == 222 { // 貸方勘定科目
            if textFieldCategoryCredit.text == "" {
                // 未入力
            } else if textFieldCategoryCredit.text == textFieldCategoryDebit.text { // 借方と同じ勘定科目の場合
                // 同じ勘定科目を指定できるように変更
                // textFieldCategoryCredit.text = ""
            } else {
                // TextField_amount_credit.becomeFirstResponder() //貸方金額は不使用のため
                // 仕訳一括編集ではない場合 よく使う仕訳ではない場合
                if journalEntryType != .JournalEntriesPackageFixing && // 仕訳一括編集 仕訳帳画面からの遷移の場合
                    journalEntryType != .SettingsJournalEntries && // よく使う仕訳 追加
                    journalEntryType != .SettingsJournalEntriesFixing { // よく使う仕訳 更新
                    
                    if textFieldAmountDebit.text == "" {
                        textFieldAmountDebit.becomeFirstResponder() // カーソルを金額へ移す
                    }
                }
            }
        }
    }
    // TextFieldに入力され値が変化した時の処理の関数
    @objc
    func textFieldDidChange(_ sender: UITextField) {
        if let text = sender.text {
            // カンマを追加する
            if sender == textFieldAmountDebit || sender == textFieldAmountCredit { // 借方金額仮　貸方金額
                sender.text = "\(StringUtility.shared.addComma(string: text))"
            } else if sender == textFieldSmallWritting {
                // 小書き　文字数カウンタ
                let maxLength = EditableType.smallWriting.maxLength
                smallWritingCounterLabel.font = .boldSystemFont(ofSize: 15)
                smallWritingCounterLabel.text = "\(maxLength - text.count)/\(maxLength)  "
                if text.count > maxLength {
                    smallWritingCounterLabel.textColor = .systemPink
                } else {
                    smallWritingCounterLabel.textColor = text.count >= maxLength - 3 ? .systemYellow : .systemGreen
                }
                if text.count == maxLength {
                    // フィードバック
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
            }
            // print("\(String(describing: sender.text))") // カンマを追加する前にシスアウトすると、カンマが上位のくらいから3桁ごとに自動的に追加される。
        }
    }
}

extension JournalEntryViewController: JournalEntryPresenterOutput {
    
    func setupUI() {
        self.navigationItem.title = "仕訳"
        // largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .accentColor
        
        // ニューモフィズム　ボタンとビューのデザインを指定する
        createEMTNeumorphicView()
        // セットアップ
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current // UTC時刻を補正
        dateFormatter.dateFormat = "yyyy/MM/dd"     // 注意：　小文字のyにしなければならない
        // よく使う仕訳　エリア
        initTable()
        // UIパーツを作成
        createTextFieldForCategory()
        createTextFieldForAmount()
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
    
    func updateUI() {
        // 勘定科目
        textFieldCategoryDebit.updateUI()
        textFieldCategoryCredit.updateUI()
        // 仕訳タイプ判定
        if journalEntryType == .JournalEntries { // 仕訳 仕訳帳画面からの遷移の場合
            labelTitle.text = "仕　訳"
            // カルーセルを追加しても、仕訳画面に戻ってきても反映されないので、viewDidLoadからviewWillAppearへ移動
            // カルーセルをリロードする
            reloadCarousel()
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
        } else if journalEntryType == .AdjustingAndClosingEntries { // 決算整理仕訳 精算表画面からの遷移の場合
            labelTitle.text = "決算整理仕訳"
            // カルーセルをリロードする
            reloadCarousel()
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
        } else if journalEntryType == .JournalEntry { // 仕訳 タブバーの仕訳タブからの遷移の場合
            labelTitle.text = ""
            // カルーセルを追加しても、仕訳画面に戻ってきても反映されないので、viewDidLoadからviewWillAppearへ移動
            // カルーセルをリロードする
            reloadCarousel()
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
        } else if journalEntryType == .AdjustingAndClosingEntry {
            labelTitle.text = ""
            // カルーセルをリロードする
            reloadCarousel()
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
        } else if journalEntryType == .JournalEntriesFixing { // 仕訳編集 仕訳帳画面からの遷移の場合
            // よく使う仕訳　エリア
            tableView.isHidden = true
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
            // 仕訳データを取得
            if tappedIndexPath.section == 1 {
                // 決算整理仕訳
                labelTitle.text = "決算整理仕訳編集"
                if let dataBaseJournalEntry = DataBaseManagerAdjustingEntry.shared.getAdjustingEntryWithNumber(number: primaryKey),
                   let data = dateFormatter.date(from: dataBaseJournalEntry.date) {
                    datePicker.date = data // 注意：カンマの後にスペースがないとnilになる
                    textFieldCategoryDebit.text = dataBaseJournalEntry.debit_category
                    textFieldCategoryCredit.text = dataBaseJournalEntry.credit_category
                    textFieldAmountDebit.text = StringUtility.shared.addComma(string: String(dataBaseJournalEntry.debit_amount))
                    textFieldAmountCredit.text = StringUtility.shared.addComma(string: String(dataBaseJournalEntry.credit_amount))
                    textFieldSmallWritting.text = dataBaseJournalEntry.smallWritting
                }
            } else {
                // 通常仕訳
                labelTitle.text = "仕訳編集"
                if let dataBaseJournalEntry = DataBaseManagerJournalEntry.shared.getJournalEntryWithNumber(number: primaryKey),
                   let data = dateFormatter.date(from: dataBaseJournalEntry.date) {
                    datePicker.date = data // 注意：カンマの後にスペースがないとnilになる
                    textFieldCategoryDebit.text = dataBaseJournalEntry.debit_category
                    textFieldCategoryCredit.text = dataBaseJournalEntry.credit_category
                    textFieldAmountDebit.text = StringUtility.shared.addComma(string: String(dataBaseJournalEntry.debit_amount))
                    textFieldAmountCredit.text = StringUtility.shared.addComma(string: String(dataBaseJournalEntry.credit_amount))
                    textFieldSmallWritting.text = dataBaseJournalEntry.smallWritting
                }
            }
            inputButton.setTitle("更　新", for: UIControl.State.normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
        } else if journalEntryType == .JournalEntriesPackageFixing { // 仕訳一括編集 仕訳帳画面からの遷移の場合
            labelTitle.text = "仕訳まとめて編集"
            // よく使う仕訳　エリア
            tableView.isHidden = true
            createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
            maskDatePickerButton.isHidden = false
            isMaskedDatePicker = false
            inputButton.setTitle("更　新", for: UIControl.State.normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
        }
        // セットアップ AdMob
        setupAdMob()
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
    // ダイアログ　オフライン
    func showDialogForOfline() {
        // フィードバック
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        // ネットワークなし
        let alertController = UIAlertController(title: "インターネット未接続", message: "オフラインでは利用できません。\n\nスタンダードプランに\nアップグレードしていただくと、\nオフラインでも利用可能となります。", preferredStyle: .alert)
        
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
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            print("OK アクションをタップした時の処理")
            
            self.presenter.okButtonTappedDialogForSameJournalEntry(journalEntryType: journalEntryType, journalEntryData: journalEntryData)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            print("Cancel アクションをタップした時の処理")
        }))
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
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            print("OK アクションをタップした時の処理")
            
            self.presenter.okButtonTappedDialogForFinal(journalEntryData: journalEntryData)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            print("Cancel アクションをタップした時の処理")
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
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
        // 乱数　1から6までのIntを生成
        let iValue = Int.random(in: 1 ... 6)
        if iValue % 2 == 0 {
            DispatchQueue.main.async {
                if let viewController = UIStoryboard(
                    name: "SettingsUpgradeViewController",
                    bundle: nil
                ).instantiateViewController(withIdentifier: "SettingsUpgradeViewController") as? SettingsUpgradeViewController {
                    self.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // ダイアログ 記帳しました
    func showDialogForSucceed() {
        // 入力中のキーボード　小書き不要の場合に、入力ボタンを押下された場合 フォーカスされている状態を外す
        self.textFieldSmallWritting.resignFirstResponder()
        // フィードバック
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        let alert = UIAlertController(title: "仕訳", message: "記帳しました", preferredStyle: .alert)
        self.present(alert, animated: true) { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true, completion: { [self] () -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0 ... 1.5)) {
                        self.showAd()
                    }
                })
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
            // イベントログ
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterContentType: Constant.WORKSHEET,
                AnalyticsParameterItemID: Constant.ADDADJUSTINGJOURNALENTRY
            ])
        }
        // タブバーの仕訳タブから入力の場合
        else {
            // フィードバック
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            let alert = UIAlertController(title: "決算整理仕訳", message: "記帳しました", preferredStyle: .alert)
            self.present(alert, animated: true) { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.dismiss(animated: true, completion: { [self] () -> Void in
                        self.showAd()
                    })
                }
            }
            // イベントログ
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterContentType: Constant.JOURNALENTRY,
                AnalyticsParameterItemID: Constant.ADDADJUSTINGJOURNALENTRY
            ])
        }
    }
    // 仕訳帳画面へ戻る
    func goBackToJournalsScreen(number: Int) {
        
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
    // 仕訳 仕訳帳画面からの遷移の場合
    case JournalEntries
    // 決算整理仕訳 精算表画面からの遷移の場合
    case AdjustingAndClosingEntries
    // 仕訳 タブバーの仕訳タブからの遷移の場合
    case JournalEntry
    // 決算整理仕訳 タブバーの仕訳タブからの遷移の場合
    case AdjustingAndClosingEntry
    // 仕訳編集 仕訳帳画面からの遷移の場合
    case JournalEntriesFixing
    // 仕訳一括編集 仕訳帳画面からの遷移の場合
    case JournalEntriesPackageFixing
    // よく使う仕訳 追加
    case SettingsJournalEntries
    // よく使う仕訳 更新
    case SettingsJournalEntriesFixing
}
