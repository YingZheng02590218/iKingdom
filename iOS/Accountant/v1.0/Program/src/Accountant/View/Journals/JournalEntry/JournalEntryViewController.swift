//
//  JournalEntryViewController.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/03/23.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import UIKit
import EMTNeumorphicView
import GoogleMobileAds // マネタイズ対応

// 仕訳クラス
class JournalEntryViewController: UIViewController, UITextFieldDelegate {
    
    // マネタイズ対応
    // 広告ユニットID
    let AdMobID = "ca-app-pub-7616440336243237/4964823000" // インタースティシャル
    // テスト用広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/4411468910" // インタースティシャル
    #if DEBUG
    let AdMobTest:Bool = true    // true:テスト
    #else
    let AdMobTest:Bool = false
    #endif
    private var interstitial: GADInterstitialAd?
    
    var categories :[String] = Array<String>()
    var subCategories_assets :[String] = Array<String>()
    var subCategories_liabilities :[String] = Array<String>()
    var subCategories_netAsset :[String] = Array<String>()
    var subCategories_expends :[String] = Array<String>()
    var subCategories_revenue :[String] = Array<String>()
    @IBOutlet var label_title: UILabel!
    
    // 仕訳タイプ(仕訳or決算整理仕訳or編集)
    var journalEntryType :String = "" // Journal Entries、Adjusting and Closing Entries
    var tappedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var primaryKey: Int = 0
    /// 電卓画面で入力された金額の値
    var numbersOnDisplay: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        // アプリ初期化
        let initial = Initial()
        initial.initialize()
//        // アップグレード機能　スタンダードプラン　まずinAppPurchaseを判断する receiptチェックする
//        let upgradeManager = UpgradeManager()
//        upgradeManager.verifyPurchase(PRODUCT_ID:"com.ikingdom.Accountant.autoRenewableSubscriptions.advertisingOff")
        // アップグレード機能
        if UserDefaults.standard.object(forKey: "buy") != nil {
            let count = UserDefaults.standard.object(forKey: "buy") as! Int
            if count == 1 {
                inAppPurchaseFlag = true
            }
        } else {
            inAppPurchaseFlag = false
        }

    }
    
    static var viewReload = false // リロードするかどうか
    /// 電卓画面から仕訳画面へ遷移したか
    var isFromClassicCalcuatorViewController = false
    // ビューが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool){
        // 金額を入力後に、電卓画面から仕訳画面へ遷移した場合
        if isFromClassicCalcuatorViewController {
            // 金額　電卓画面で入力した値を表示させる
            if let numbersOnDisplay = numbersOnDisplay {
                TextField_amount_debit.text = addComma(string: numbersOnDisplay.description)
                TextField_amount_credit.text = addComma(string: numbersOnDisplay.description)
                // TextField 貸方金額　入力後
                if TextField_amount_debit.text == "0"{
                    TextField_amount_debit.text = ""
                    TextField_amount_credit.text = ""
                }
                if TextField_amount_credit.text == "0"{
                    TextField_amount_credit.text = ""
                    TextField_amount_debit.text = ""
                }
                if TextField_SmallWritting.text == "" {
                    TextField_SmallWritting.becomeFirstResponder()// カーソルを移す
                }
            }
            // フラグを倒す
            isFromClassicCalcuatorViewController = false
        }
        else {
            // UIパーツを作成
            createTextFieldForCategory()
            createTextFieldForAmount()
            createTextFieldForSmallwritting()
            // 仕訳タイプ判定
            if journalEntryType == "JournalEntries" {
                label_title.text = "仕　訳"
                // カルーセルを追加しても、仕訳画面に戻ってきても反映されないので、viewDidLoadからviewWillAppearへ移動
                createCarousel() // カルーセルを作成
                if JournalEntryViewController.viewReload {
                    DispatchQueue.main.async {
                        self.carouselCollectionView.reloadData()
                        JournalEntryViewController.viewReload = false
                    }
                }
                createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
            }else if journalEntryType == "AdjustingAndClosingEntries" {
                label_title.text = "決算整理仕訳"
                createCarousel() // カルーセルを作成
                if JournalEntryViewController.viewReload {
                    DispatchQueue.main.async {
                        self.carouselCollectionView.reloadData()
                        JournalEntryViewController.viewReload = false
                    }
                }
                createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
            }else if journalEntryType == "JournalEntriesFixing" {
                label_title.text = "仕訳編集"
                createCarousel() // カルーセルを作成
                carouselCollectionView.isHidden = true
                createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
                // 仕訳データを取得
                let dataBaseManager = DataBaseManagerJournalEntry() //データベースマネジャー
                let objects = dataBaseManager.getJournalEntry(section: tappedIndexPath.section)
                let formatter = DateFormatter()
                formatter.locale = Locale.current
                formatter.timeZone = TimeZone.current // UTC時刻を補正
                formatter.dateFormat = "yyyy/MM/dd"     // 注意：　小文字のyにしなければならない
                
                if tappedIndexPath.row >= objects.count {
                    // 設定操作
                    let dataBaseManagerSettingsOperating = DataBaseManagerSettingsOperating()
                    let object = dataBaseManagerSettingsOperating.getSettingsOperating()
                    let objectss = dataBaseManager.getJournalAdjustingEntry(section: tappedIndexPath.section, EnglishFromOfClosingTheLedger0: object!.EnglishFromOfClosingTheLedger0, EnglishFromOfClosingTheLedger1: object!.EnglishFromOfClosingTheLedger1) // 決算整理仕訳 損益振替仕訳 資本振替仕訳
                    primaryKey = objectss[tappedIndexPath.row-objects.count].number
                    datePicker.date = formatter.date(from: objectss[tappedIndexPath.row-objects.count].date)!// 注意：カンマの後にスペースがないとnilになる
                    TextField_category_debit.text = objectss[tappedIndexPath.row-objects.count].debit_category
                    TextField_category_credit.text = objectss[tappedIndexPath.row-objects.count].credit_category
                    TextField_amount_debit.text = addComma(string: String(objectss[tappedIndexPath.row-objects.count].debit_amount))
                    TextField_amount_credit.text = addComma(string: String(objectss[tappedIndexPath.row-objects.count].credit_amount))
                    TextField_SmallWritting.text = objectss[tappedIndexPath.row-objects.count].smallWritting
                }else {
                    primaryKey = objects[tappedIndexPath.row].number
                    datePicker.date = formatter.date(from: objects[tappedIndexPath.row].date)!// 注意：カンマの後にスペースがないとnilになる
                    TextField_category_debit.text = objects[tappedIndexPath.row].debit_category
                    TextField_category_credit.text = objects[tappedIndexPath.row].credit_category
                    TextField_amount_debit.text = addComma(string: String(objects[tappedIndexPath.row].debit_amount))
                    TextField_amount_credit.text = addComma(string: String(objects[tappedIndexPath.row].credit_amount))
                    TextField_SmallWritting.text = objects[tappedIndexPath.row].smallWritting
                }
                inputButton.setTitle("更　新", for: UIControl.State.normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
            }else if journalEntryType == "" {
                label_title.text = "仕　訳"
                // カルーセルを追加しても、仕訳画面に戻ってきても反映されないので、viewDidLoadからviewWillAppearへ移動
                createCarousel() // カルーセルを作成
                if JournalEntryViewController.viewReload {
                    DispatchQueue.main.async {
                        self.carouselCollectionView.reloadData()
                        JournalEntryViewController.viewReload = false
                    }
                }
                createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
            }
        }
        // アップグレード機能　スタンダードプラン
        if !inAppPurchaseFlag {
            // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView プロパティを設定する
            if AdMobTest {
                // GADInterstitial を作成する
                let request = GADRequest()
                GADInterstitialAd.load(withAdUnitID:TEST_ID,
                                       request: request,
                                       completionHandler: { [self] ad, error in
                    if let error = error {
                        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                        return
                    }
                    interstitial = ad
                }
                )
            }
            else{
                let request = GADRequest()
                GADInterstitialAd.load(withAdUnitID:AdMobID,
                                       request: request,
                                       completionHandler: { [self] ad, error in
                    if let error = error {
                        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                        return
                    }
                    interstitial = ad
                }
                )
            }
        }
        if let _ = self.navigationController {
            // ナビゲーションを透明にする処理
            self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController!.navigationBar.shadowImage = UIImage()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        // チュートリアル対応　初回起動時　7行を追加
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch_JournalEntry"
        if ud.bool(forKey: firstLunchKey) {
            ud.set(false, forKey: firstLunchKey)
            ud.synchronize()
            // チュートリアル対応
            presentAnnotation()
        }
        //ここでUIKeyboardWillShowという名前の通知のイベントをオブザーバー登録をしている
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //ここでUIKeyboardWillHideという名前の通知のイベントをオブザーバー登録をしている
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//        // TODO: 動作確認用
//        // 名前を指定してStoryboardを取得する(Fourth.storyboard)
//        let storyboard: UIStoryboard = UIStoryboard(name: "PDFMakerViewController", bundle: nil)
//
//        // StoryboardIDを指定してViewControllerを取得する(PDFMakerViewController)
//        let fourthViewController = storyboard.instantiateViewController(withIdentifier: "PDFMakerViewController") as! PDFMakerViewController
//
//        self.present(fourthViewController, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        // 日付　ボタン作成
        createButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // チュートリアル対応
    func presentAnnotation() {
        let viewController = UIStoryboard(name: "JournalEntryViewController", bundle: nil).instantiateViewController(withIdentifier: "Annotation_JournalEntry") as! AnnotationViewControllerJournalEntry
        viewController.alpha = 0.5
        present(viewController, animated: true, completion: nil)
    }
    // カルーセル作成
    @IBOutlet var carouselCollectionView: UICollectionView!
    func createCarousel() {
        //xib読み込み
        let nib = UINib(nibName: "CarouselCollectionViewCell", bundle: .main)
        carouselCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
        
    }
    
    @IBOutlet var datePickerView: EMTNeumorphicView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func DatePicker(_ sender: UIDatePicker) {}
    // デートピッカー作成
    func createDatePicker() {
        // 現在時刻を取得
        let now :Date = Date() // UTC時間なので　9時間ずれる

        let f     = DateFormatter() //年
        let ff    = DateFormatter() //月
        let fff   = DateFormatter() //月日
        let ffff  = DateFormatter() //年月日
        let fffff = DateFormatter()
        let ffffff = DateFormatter()
        let ffff2 = DateFormatter() //年月日
        let timezone = DateFormatter()

        f.dateFormat    = DateFormatter.dateFormat(fromTemplate: "YYYY", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        f.timeZone = .current
        ff.dateFormat   = DateFormatter.dateFormat(fromTemplate: "MM", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        ff.timeZone = .current
        fff.dateFormat  = DateFormatter.dateFormat(fromTemplate: "MM/dd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        fff.timeZone = .current
        ffff.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        ffff.timeZone = .current
        fffff.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        fffff.timeZone = .current
        ffffff.dateFormat = DateFormatter.dateFormat(fromTemplate: "'T'HH:mm:ss.SSSZZZZZ", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        ffffff.timeZone = .current
//        timezone.dateFormat  = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ", options: 0, locale: Locale.current)
        ffff2.dateFormat = "yyyy-MM-dd"
        ffff2.timeZone = .current
        timezone.dateFormat  = "MM-dd"
        timezone.timeZone = .current
        timezone.locale = Locale(identifier: "en_US_POSIX")

        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let fiscalYear = object.dataBaseJournals?.fiscalYear
        let nowStringYear = fiscalYear!.description                            //　本年度
        let nowStringNextYear = (fiscalYear! + 1).description                  //　次年度
        let nowStringMonthDay = fff.string(from: now)                           // 現在時刻の月日
        
        // 設定決算日
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: fff.date(from: theDayOfReckoning)!)! // 決算日設定機能　年度開始日は決算日の翌日に設定する
        let dayOfStartInPeriod :Date = fff.date(from: fff.string(from: modifiedDate))! // 決算日設定機能　年度開始日
        let dayOfEndInPeriod :Date   = fff.date(from: theDayOfReckoning)! // 決算日設定機能 注意：nowStringYearは、開始日の日付が存在するかどうかを確認するために記述した。閏年など
        
        // 期間
        let dayOfStartInYear :Date   = fff.date(from: "01/01")!
        let dayOfEndInYear :Date     = fff.date(from: "12/31")!

        // デイトピッカーの最大値と最小値を設定
        if journalEntryType == "AdjustingAndClosingEntries" { // 決算整理仕訳の場合は日付を決算日に固定
            if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                print("### 会計期間が年をまたがない場合")
                datePicker.minimumDate = ffff2.date(from: nowStringYear + "-\(timezone.string(from: fff.date(from: theDayOfReckoning)!))")
                datePicker.maximumDate = ffff2.date(from: nowStringYear + "-\(timezone.string(from: fff.date(from: theDayOfReckoning)!))")
            }
            else { // 会計期間が年をまたぐ場合
                print("### 会計期間が年をまたぐ場合")
                datePicker.minimumDate = ffff2.date(from: nowStringNextYear + "-\(timezone.string(from: fff.date(from: theDayOfReckoning)!))")
                datePicker.maximumDate = ffff2.date(from: nowStringNextYear + "-\(timezone.string(from: fff.date(from: theDayOfReckoning)!))")
            }
        }
        else {
            if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                print("### 会計期間が年をまたがない場合")
                datePicker.minimumDate = ffff2.date(from: nowStringYear + "-\(timezone.string(from: modifiedDate))")
                datePicker.maximumDate = ffff2.date(from: nowStringYear + "-\(timezone.string(from: fff.date(from: theDayOfReckoning)!))")
            }
            else { // 会計期間が年をまたぐ場合
                // 01/01 以降か
                let Interval = (Calendar.current.dateComponents([.month], from: dayOfStartInYear, to: fff.date(from: nowStringMonthDay)! )).month
                // 設定決算日 未満か
                let Interval1 = (Calendar.current.dateComponents([.month], from: dayOfEndInPeriod, to: fff.date(from: nowStringMonthDay)! )).month
                // 年度開始日 以降か
                let Interval2 = (Calendar.current.dateComponents([.month], from: dayOfStartInPeriod, to: fff.date(from: nowStringMonthDay)! )).month
                // 12/31と同じ、もしくはそれ以前か
                let Interval3 = (Calendar.current.dateComponents([.month], from: dayOfEndInYear, to: fff.date(from: nowStringMonthDay)! )).month
                
                if Interval! >= 0  {
                    print("### 会計期間　1/01 以降")
                    if Interval1! <= 0 {
                        print("### 会計期間　設定決算日 未満")
                        // 決算日設定機能　注意：カンマの後にスペースがないとnilになる
                        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: fffff.date(from: theDayOfReckoning + "/" + nowStringYear + ", " + ffffff.string(from: now))!)
                        // 四月以降か
                        datePicker.maximumDate = ffff2.date(from: (nowStringNextYear + "-\(timezone.string(from: fff.date(from: theDayOfReckoning)!))"))
                    }
                    else if Interval2! >= 0 {
                        print("### 会計期間　年度開始日 以降")
                        if Interval3! <= 0 {
                            print("### 会計期間　12/31 以前")
                            // 決算日設定機能　注意：カンマの後にスペースがないとnilになる 04-02にすると04-01となる
                            datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: fffff.date(from: theDayOfReckoning + "/" + nowStringYear + ", " + ffffff.string(from: now))!)
                            // 04-01にすると03-31となる
                            datePicker.maximumDate = ffff2.date(from: nowStringNextYear + "-\(timezone.string(from: fff.date(from: theDayOfReckoning)!))")
                        }
                    }
                }
            }
        }
        // ピッカーの初期値
        if journalEntryType == "JournalEntriesFixing" { // 仕訳編集の場合
            // 決算日設定機能　何もしない viewDidLoad()で値を設定している
        }
        else if journalEntryType == "AdjustingAndClosingEntries" {
            if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                datePicker.date = fffff.date(from: theDayOfReckoning + "/" + nowStringYear + ", " + ffffff.string(from: now))!// 注意：カンマの後にスペースがないとnilになる
            }
            else {
                datePicker.date = fffff.date(from: theDayOfReckoning + "/" + nowStringNextYear + ", " + ffffff.string(from: now))!// 注意：カンマの後にスペースがないとnilになる
            }
        }
        else {
            datePicker.date = fffff.date(from: fff.string(from: now) + "/" + nowStringYear + ", " + ffffff.string(from: now))!// 注意：カンマの後にスペースがないとnilになる
        }
//        // 背景色
//        datePicker.backgroundColor = .systemBackground
        //　iOS14対応　モード　ドラムロールはwheels
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        else {
            // Fallback on earlier versions
        }
        
    }
    @IBOutlet var textFieldView: EMTNeumorphicView!
    @IBOutlet var smallWrittingTextFieldView: EMTNeumorphicView!
    
    // ボタンのデザインを指定する
    private func createButtons() {
        
        if let datePickerView = datePickerView {
            datePickerView.neumorphicLayer?.cornerRadius = 15
            datePickerView.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
            datePickerView.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
            datePickerView.neumorphicLayer?.edged = edged
            datePickerView.neumorphicLayer?.elementDepth = ELEMENTDEPTH
            datePickerView.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
        }
        
        if let Button_Left = Button_Left {
            Button_Left.setTitleColor(.ButtonTextColor, for: .normal)
            Button_Left.neumorphicLayer?.cornerRadius = 10
            Button_Left.setTitleColor(.ButtonTextColor, for: .selected)
            Button_Left.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
            Button_Left.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
            Button_Left.neumorphicLayer?.edged = edged
            Button_Left.neumorphicLayer?.elementDepth = ELEMENTDEPTH
            Button_Left.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
        }
        
        if let Button_Right = Button_Right {
            Button_Right.setTitleColor(.ButtonTextColor, for: .normal)
            Button_Right.neumorphicLayer?.cornerRadius = 10
            Button_Right.setTitleColor(.ButtonTextColor, for: .selected)
            Button_Right.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
            Button_Right.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
            Button_Right.neumorphicLayer?.edged = edged
            Button_Right.neumorphicLayer?.elementDepth = ELEMENTDEPTH
            Button_Right.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
        }
        
        if let textFieldView = textFieldView {
            textFieldView.neumorphicLayer?.cornerRadius = 15
            textFieldView.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
            textFieldView.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
            textFieldView.neumorphicLayer?.edged = edged
            textFieldView.neumorphicLayer?.elementDepth = ELEMENTDEPTH
            textFieldView.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
            textFieldView.neumorphicLayer?.depthType = .concave
        }
        
        if let smallWrittingTextFieldView = smallWrittingTextFieldView {
            smallWrittingTextFieldView.neumorphicLayer?.cornerRadius = 15
            smallWrittingTextFieldView.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
            smallWrittingTextFieldView.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
            smallWrittingTextFieldView.neumorphicLayer?.edged = edged
            smallWrittingTextFieldView.neumorphicLayer?.elementDepth = ELEMENTDEPTH
            smallWrittingTextFieldView.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
            smallWrittingTextFieldView.neumorphicLayer?.depthType = .concave
        }
        
//        inputButton.setTitle("入力", for: .normal)
        inputButton.setTitleColor(.ButtonTextColor, for: .normal)
        inputButton.neumorphicLayer?.cornerRadius = 15
        inputButton.setTitleColor(.ButtonTextColor, for: .selected)
        inputButton.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        inputButton.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        inputButton.neumorphicLayer?.edged = edged
        inputButton.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        inputButton.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
        
        Button_cancel.setTitleColor(.ButtonTextColor, for: .normal)
        Button_cancel.neumorphicLayer?.cornerRadius = 15
        Button_cancel.setTitleColor(.ButtonTextColor, for: .selected)
        Button_cancel.neumorphicLayer?.lightShadowOpacity = LIGHTSHADOWOPACITY
        Button_cancel.neumorphicLayer?.darkShadowOpacity = DARKSHADOWOPACITY
        Button_cancel.neumorphicLayer?.edged = edged
        Button_cancel.neumorphicLayer?.elementDepth = ELEMENTDEPTH
        Button_cancel.neumorphicLayer?.elementBackgroundColor = UIColor.systemPink.cgColor
        // Optional. if it is nil (default), elementBackgroundColor will be used as element color.
        Button_cancel.neumorphicLayer?.elementColor = UIColor.Background.cgColor

    }

    let LIGHTSHADOWOPACITY: Float = 0.3
    let DARKSHADOWOPACITY: Float = 0.5
    let ELEMENTDEPTH: CGFloat = 6
    let edged = false
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet weak var Button_Left: EMTNeumorphicButton!
    @IBAction func Button_Left(_ sender: UIButton) {
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
        
        let min = datePicker.minimumDate!
        if datePicker.date > min {
            let modifiedDate = Calendar.current.date(byAdding: .day, value: -1, to: datePicker.date)! // 1日前へ
            datePicker.date = modifiedDate
        }
    }
    @IBOutlet weak var Button_Right: EMTNeumorphicButton!
    @IBAction func Button_Right(_ sender: UIButton) {
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
        
        let max = datePicker.maximumDate!
        if datePicker.date < max {
            let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: datePicker.date)! // 1日次へ
            datePicker.date = modifiedDate
        }
    }
    
//TextField
    @IBOutlet weak var TextField_category_debit: PickerTextField!
    @IBOutlet weak var TextField_category_credit: PickerTextField!
    @IBAction func TextField_category_debit(_ sender: UITextField) {
    }
    @IBAction func TextField_category_credit(_ sender: UITextField) {
    }
    // TextField作成　勘定科目
    func createTextFieldForCategory() {
        TextField_category_debit.delegate = self
        TextField_category_credit.delegate = self
        TextField_category_debit.setup(identifier: "identifier_debit")
        TextField_category_credit.setup(identifier: "identifier_credit")
        TextField_category_debit.textAlignment = .left
        TextField_category_credit.textAlignment = .right
    }
    
    @IBOutlet weak var TextField_amount_debit: UITextField!
    @IBOutlet weak var TextField_amount_credit: UITextField!
    @IBAction func TextField_amount_debit(_ sender: UITextField) {}
    @IBAction func TextField_amount_credit(_ sender: UITextField) {}
    // TextField作成 金額
    func createTextFieldForAmount() {
        TextField_amount_debit.delegate = self
        TextField_amount_credit.delegate = self
        TextField_amount_debit.textAlignment = .left
        TextField_amount_credit.textAlignment = .right
    // toolbar 借方 Done:Tag5 Cancel:Tag55
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)!, height: 44)
        toolbar.isTranslucent = true
        toolbar.barStyle = .default
        let doneButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonTapped(_:)))
        doneButtonItem.tag = 5
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(barButtonTapped(_:)))
        cancelItem.tag = 55
        toolbar.setItems([cancelItem, flexSpaceItem, doneButtonItem], animated: true)
//        doneButtonItem.isEnabled = false
        // previous, next, paste ボタンを消す
        self.TextField_amount_debit.inputAssistantItem.leadingBarButtonGroups.removeAll()
        TextField_amount_debit.inputAccessoryView = toolbar
    // toolbar2 貸方 Done:Tag6 Cancel:Tag66
        let toolbar2 = UIToolbar()
        toolbar2.frame = CGRect(x: 0, y: 0, width: (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)!, height: 44)
        toolbar2.isTranslucent = true
        toolbar2.barStyle = .default
        let doneButtonItem2 = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonTapped(_:)))
        doneButtonItem2.tag = 6
        let flexSpaceItem2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelItem2 = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(barButtonTapped(_:)))
        cancelItem2.tag = 66
        toolbar2.setItems([cancelItem2,flexSpaceItem2, doneButtonItem2], animated: true)
//        doneButtonItem2.isEnabled = false
        // previous, next, paste ボタンを消す
        self.TextField_amount_credit.inputAssistantItem.leadingBarButtonGroups.removeAll()
//        self.TextField_amount_credit.inputAssistantItem.trailingBarButtonGroups.removeAll()
        TextField_amount_credit.inputAccessoryView = toolbar2
        // TextFieldに入力された値に反応
        TextField_amount_debit.addTarget(self, action: #selector(textFieldDidChange),for: UIControl.Event.editingChanged)
        TextField_amount_credit.addTarget(self, action: #selector(textFieldDidChange),for: UIControl.Event.editingChanged)
        //3桁ごとにカンマ区切りするフォーマット
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
    }
    // TextFieldをタップしても呼ばれない
    @IBAction func TapGestureRecognizer(_ sender: Any) {// この前に　touchesBegan が呼ばれている
        self.view.endEditing(true)
    }

    @IBOutlet weak var TextField_SmallWritting: UITextField!
    @IBAction func TextField_SmallWritting(_ sender: UITextField) {}
    // TextField作成 小書き
    func createTextFieldForSmallwritting() {
        TextField_SmallWritting.delegate = self
        TextField_SmallWritting.textAlignment = .center
// toolbar 小書き Done:Tag Cancel:Tag
       let toolbar = UIToolbar()
       toolbar.frame = CGRect(x: 0, y: 0, width: (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width)!, height: 44)
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
       TextField_SmallWritting.inputAccessoryView = toolbar
    }
        
    // UIKeyboardWillShow通知を受けて、実行される関数
    @objc func keyboardWillShow(notification: NSNotification) {
        // 小書きを入力中は、画面を上げる
        if TextField_SmallWritting.isEditing {
            guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            animateWithKeyboard(notification: notification) { keyboardFrame in
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height - 150
                } else {
                    let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                    self.view.frame.origin.y -= suggestionHeight - 150
                }
            }
        }
    }
    // UIKeyboardWillShow通知を受けて、実行される関数
    @objc func keyboardWillHide(notification: NSNotification) {
        animateWithKeyboard(notification: notification) { _ in
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    }
    // キーボードのアニメーションに合わせてViewをアニメーションさせる
    func animateWithKeyboard(notification: NSNotification, animations: ((_ keyboardFrame: CGRect) -> Void)?) {
        // キーボードのdurationを抽出 *1
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let duration = notification.userInfo![durationKey] as! Double

        // キーボードのframeを抽出する *2
        let frameKey = UIResponder.keyboardFrameEndUserInfoKey
        let keyboardFrameValue = notification.userInfo![frameKey] as! NSValue

        // アニメーション曲線を抽出する *3
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
        let curveValue = notification.userInfo![curveKey] as! Int
        let curve = UIView.AnimationCurve(rawValue: curveValue)!

        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            // ここにアニメーション化したいレイアウト変更を記述する
            animations?(keyboardFrameValue.cgRectValue)
            self.view?.layoutIfNeeded()
        }
        animator.startAnimation()
    }

    // TextFieldに入力され値が変化した時の処理の関数
    @objc func textFieldDidChange(_ sender: UITextField) {
//    func textFieldEditingChanged(_ sender: UITextField){
        if sender.text != "" {
            // カンマを追加する
            if sender == TextField_amount_debit || sender == TextField_amount_credit { // 借方金額仮　貸方金額
                sender.text = "\(addComma(string: String(sender.text!)))"
            }
            print("\(String(describing: sender.text))") // カンマを追加する前にシスアウトすると、カンマが上位のくらいから3桁ごとに自動的に追加される。
        }
    }
    // TextFieldのキーボードについているBarButtonが押下された時
    @objc func barButtonTapped(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 5://借方金額の場合 Done
            if TextField_amount_debit.text == "0"{
                TextField_amount_debit.text = ""
                Label_Popup.text = "金額が0となっています"
            }else if TextField_amount_debit.text == ""{
                Label_Popup.text = "金額が空白となっています"
            }else{
                self.view.endEditing(true) // 注意：キーボードを閉じた後にbecomeFirstResponderをしないと二重に表示される
                if TextField_category_credit.text == "" {
                    //TextFieldのキーボードを自動的に表示する　借方金額　→ 貸方勘定科目
                    TextField_category_credit.becomeFirstResponder()
                }
                Label_Popup.text = ""
            }
            break
        case 55://借方金額の場合 Cancel
            TextField_amount_debit.text = ""
            TextField_amount_credit.text = ""
            Label_Popup.text = ""
            self.view.endEditing(true)// textFieldDidEndEditingで貸方金額へコピーするのでtextを設定した後に実行
            break
        case 6://貸方金額の場合 Done
            if TextField_amount_credit.text == "0"{
                TextField_amount_credit.text = ""
                Label_Popup.text = "金額が0となっています"
            }else if TextField_amount_credit.text == "" {
                Label_Popup.text = "金額が空白となっています"
            }else{
                self.view.endEditing(true) // 注意：キーボードを閉じた後にbecomeFirstResponderをしないと二重に表示される
                if TextField_SmallWritting.text == "" {
                    // カーソルを小書きへ移す
                    self.TextField_SmallWritting.becomeFirstResponder()
                }
                Label_Popup.text = ""
            }
            break
        case 66://貸方金額の場合 Cancel
            TextField_amount_debit.text = ""
            TextField_amount_credit.text = ""
            Label_Popup.text = ""
            self.view.endEditing(true)// textFieldDidEndEditingで借方金額へコピーするのでtextを設定した後に実行
            break
        case 7://小書きの場合 Done
            self.view.endEditing(true)
            break
        case 77://小書きの場合 Cancel
            TextField_SmallWritting.text = ""
            self.view.endEditing(true)
            break
        default:
            self.view.endEditing(true)
            break
        }
    }
    // キーボード起動時
    //    textFieldShouldBeginEditing
    //    textFieldDidBeginEditing
    // リターン押下時
    //    textFieldShouldReturn before responder
    //    textFieldShouldEndEditing
    //    textFieldDidEndEditing
    //    textFieldShouldReturn
    
    // テキストフィールがタップされ、入力可能になったあと
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == TextField_amount_debit || textField == TextField_amount_credit { // 借方金額　貸方金額
            self.view.endEditing(true)
        }
    }
    // 文字クリア
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //todo
        if textField.text == "" {
            return true
        }else if textField.text == "" {
            return true
        }else if textField.text == "" {
            return true
        }else{
            return false
        }
    }
    // textFieldに文字が入力される際に呼ばれる　入力チェック(半角数字、文字数制限)
    // 戻り値にtrueを返すと入力した文字がTextFieldに反映され、falseを返すと入力した文字が反映されない。
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var resultForCharacter = false
        var resultForLength = false
        // 入力チェック　数字のみに制限
        if textField == TextField_amount_debit || textField == TextField_amount_credit { // 借方金額仮　貸方金額
//            let allowedCharacters = CharacterSet(charactersIn:",0123456789")//Here change this characters based on your requirement
//            let characterSet = CharacterSet(charactersIn: string)
//            // 指定したスーパーセットの文字セットでないならfalseを返す
//            resultForCharacter = allowedCharacters.isSuperset(of: characterSet)
        }else{  // 小書き　ニックネーム
            let notAllowedCharacters = CharacterSet(charactersIn:",") // 除外したい文字。絵文字はInterface BuilderのKeyboardTypeで除外してある。
            let characterSet = CharacterSet(charactersIn: string)
            // 指定したスーパーセットの文字セットならfalseを返す
            resultForCharacter = !(notAllowedCharacters.isSuperset(of: characterSet))
        }
        // 入力チェック　文字数最大数を設定
        var maxLength: Int = 0 // 文字数最大値を定義
        switch textField.tag {
        case 333,444: // 金額の文字数 + カンマの数 (100万円の位まで入力可能とする)
            maxLength = 7 + 2
        case 555: // 小書きの文字数
            maxLength = 25
        case 888: // ニックネームの文字数
            maxLength = 25
        default:
            break
        }
        // textField内の文字数
        let textFieldNumber = textField.text?.count ?? 0    //todo
        // 入力された文字数
        let stringNumber = string.count
        // 最大文字数以上ならfalseを返す
        resultForLength = textFieldNumber + stringNumber <= maxLength
        // 文字列が0文字の場合、backspaceキーが押下されたということなので一文字削除する
        if(string == "") {
            textField.deleteBackward()
        }
        // 判定
        if !resultForCharacter { // 指定したスーパーセットの文字セットでないならfalseを返す
            return false
        }else if !resultForLength { // 最大文字数以上ならfalseを返す
            return false
        }else {
            return true
        }
    }
    //カンマ区切りに変換（表示用）
    let formatter = NumberFormatter() // プロパティの設定はcreateTextFieldForAmountで行う
    func addComma(string :String) -> String {
        if(string != "") { // ありえないでしょう
            let string = removeComma(string: string) // カンマを削除してから、カンマを追加する処理を実行する
            return formatter.string(from: NSNumber(value: Double(string)!))!
        }else{
            return ""
        }
    }
    //カンマ区切りを削除（計算用）
    func removeComma(string :String) -> String{
        let string = string.replacingOccurrences(of: ",", with: "")
        return string
    }
    //リターンキーが押されたとき
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.text {
        case "勘定科目":
            Label_Popup.text = "勘定科目を入力してください"
            return false
        case "":// ありえない　リターンキーを押せないため
            Label_Popup.text = "空白となっています"
            return false
        case "金額":
            Label_Popup.text = "金額を入力してください"
            return false
        case "0":
            textField.text = ""
            Label_Popup.text = "金額が0となっています"
            return false
        default:
            Label_Popup.text = ""//ポップアップの文字表示をクリア
            //resignFirstResponder()メソッドを利用します。
            textField.resignFirstResponder()
            return true
        }
    }
    //TextField キーボード以外の部分をタッチ　 TextFieldをタップしても呼ばれない
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {// この後に TapGestureRecognizer が呼ばれている
        // 初期値を再設定
        setInitialData()
        // touchesBeganメソッドをオーバーライドします。
        self.view.endEditing(true)
    }
    // 初期値を再設定
    func setInitialData() {
        if TextField_amount_debit.text == "" {
            if TextField_amount_credit.text != "" || TextField_amount_credit.text != "" {
                TextField_amount_debit.text = TextField_amount_credit.text
            }
        }
        if TextField_amount_credit.text == "" {
            if TextField_amount_debit.text != "" || TextField_amount_debit.text != "" {
                TextField_amount_credit.text = TextField_amount_debit.text
            }
        }
    }
    //キーボードを閉じる前
    func textFieldShouldEndEditing(_ textField:UITextField) -> Bool {
//        print(#function)
//        print("キーボードを閉じる前")
        return true
    }
    //キーボードを閉じたあと
    func textFieldDidEndEditing(_ textField:UITextField){
//        print(#function)
//        print("キーボードを閉じた後")
//Segueを場合分け
        if textField.tag == 111 {
//            TextField_category_debit.text = result  //ここで値渡し
            if TextField_category_debit.text == "" {
            }else if TextField_category_credit.text == TextField_category_debit.text { // 貸方と同じ勘定科目の場合
                TextField_category_debit.text = ""
            }else {
                if TextField_category_credit.text == "" {
                    TextField_category_credit.becomeFirstResponder()
                }
            }
            Label_Popup.text = ""//ポップアップの文字表示をクリア
        }else if textField.tag == 222 {
//            TextField_category_credit.text = result  //ここで値渡し
            if TextField_category_credit.text == "" {
            }else if TextField_category_credit.text == TextField_category_debit.text { // 借方と同じ勘定科目の場合
                TextField_category_credit.text = ""
            }else {
//                TextField_amount_credit.becomeFirstResponder() //貸方金額は不使用のため
                if TextField_amount_debit.text == "" {
                    TextField_amount_debit.becomeFirstResponder()// カーソルを金額へ移す
                }
            }
            Label_Popup.text = ""//ポップアップの文字表示をクリア
        }
    }
    
    @IBOutlet var arrayHugo: [EMTNeumorphicButton]!

    
    private var timer: Timer?                           // Timerを保持する変数
    @IBOutlet weak var Label_Popup: UILabel!
    @IBOutlet var inputButton: EMTNeumorphicButton!// 入力ボタン
    // 入力ボタン
    @IBAction func Button_Input(_ sender: EMTNeumorphicButton) {
        // 選択されていたボタンを選択解除する
        let newArray = arrayHugo.filter { $0.isSelected == true}
        for i in newArray {
            i.isSelected = false
        }
        // ボタンを選択する
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sender.isSelected = !sender.isSelected
        }
        // シスログ出力
        // printによる出力はUTCになってしまうので、9時間ずれる
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current // UTC時刻を補正
        formatter.dateFormat = "yyyy/MM/dd"     // 注意：　小文字のyにしなければならない
        
        if textInputCheck() { // 入力チェック
            // データベース　仕訳データを追加
            let dataBaseManager = DataBaseManagerJournalEntry()
            // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
            var number = 0
            // 仕訳タイプ判定　仕訳、決算整理仕訳、編集
            if journalEntryType == "AdjustingAndClosingEntries" {
                number = dataBaseManager.addAdjustingJournalEntry(
                    date: formatter.string(from: datePicker.date),
                    debit_category: TextField_category_debit.text!,
                    debit_amount: Int64(removeComma(string: TextField_amount_debit.text!))!, //カンマを削除してからデータベースに書き込む
                    credit_category: TextField_category_credit.text!,
                    credit_amount: Int64(removeComma(string: TextField_amount_credit.text!))!,//カンマを削除してからデータベースに書き込む
                    smallWritting: TextField_SmallWritting.text!
                )
                let tabBarController = self.presentingViewController as! UITabBarController // 一番基底となっているコントローラ
                let navigationController = tabBarController.selectedViewController as! UINavigationController // 基底のコントローラから、現在選択されているコントローラを取得する
                let presentingViewController = navigationController.viewControllers[1] as! WSViewController // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
                // viewWillAppearを呼び出す　更新のため
                self.dismiss(animated: true, completion: {
                    [presentingViewController] () -> Void in
                    presentingViewController.reloadData()
                })
            }else if journalEntryType == "JournalEntriesFixing" {
                //
                let objects = dataBaseManager.getJournalEntry(section: tappedIndexPath.section)
                if tappedIndexPath.row >= objects.count {
                    // データベースに書き込む
                    number = dataBaseManager.updateAdjustingJournalEntry(
                        primaryKey: primaryKey,
                        date: formatter.string(from: datePicker.date),
                        debit_category: TextField_category_debit.text!,
                        debit_amount: Int64(removeComma(string: TextField_amount_debit.text!))!, //カンマを削除してからデータベースに書き込む
                        credit_category: TextField_category_credit.text!,
                        credit_amount: Int64(removeComma(string: TextField_amount_credit.text!))!,//カンマを削除してからデータベースに書き込む
                        smallWritting: TextField_SmallWritting.text!
                    )
                }else {
                    // データベースに書き込む
                    number = dataBaseManager.updateJournalEntry(
                        primaryKey: primaryKey,
                        date: formatter.string(from: datePicker.date),
                        debit_category: TextField_category_debit.text!,
                        debit_amount: Int64(removeComma(string: TextField_amount_debit.text!))!, //カンマを削除してからデータベースに書き込む
                        credit_category: TextField_category_credit.text!,
                        credit_amount: Int64(removeComma(string: TextField_amount_credit.text!))!,//カンマを削除してからデータベースに書き込む
                        smallWritting: TextField_SmallWritting.text!
                    )
                }
                let tabBarController = self.presentingViewController as! UITabBarController // 一番基底となっているコントローラ
                let navigationController = tabBarController.selectedViewController as! UINavigationController // 基底のコントローラから、現在選択されているコントローラを取得する
                let presentingViewController = navigationController.viewControllers[0] as! JournalsViewController // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
                // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
                self.dismiss(animated: true, completion: {
                    [presentingViewController] () -> Void in
                    presentingViewController.autoScroll(number: number)
                })
            }else if journalEntryType == "JournalEntries" {
                number = dataBaseManager.addJournalEntry(
                    date: formatter.string(from: datePicker.date),
                    debit_category: TextField_category_debit.text!,
                    debit_amount: Int64(removeComma(string: TextField_amount_debit.text!))!, //カンマを削除してからデータベースに書き込む
                    credit_category: TextField_category_credit.text!,
                    credit_amount: Int64(removeComma(string: TextField_amount_credit.text!))!,//カンマを削除してからデータベースに書き込む
                    smallWritting: TextField_SmallWritting.text!
                )
                let tabBarController = self.presentingViewController as! UITabBarController // 一番基底となっているコントローラ
                let navigationController = tabBarController.selectedViewController as! UINavigationController // 基底のコントローラから、現在選択されているコントローラを取得する
                //                        let nc = viewController.presentingViewController as! UINavigationController
                let presentingViewController = navigationController.viewControllers[0] as! JournalsViewController // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
                // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
                self.dismiss(animated: true, completion: {
                    [presentingViewController] () -> Void in
                    // ViewController(仕訳画面)を閉じた時に、TabBarControllerが選択中の遷移元であるTableViewController(仕訳帳画面)で行いたい処理
                    //                                    presentingViewController.viewWillAppear(true)
                    presentingViewController.autoScroll(number: number)
                })
            }else if journalEntryType == "" { // タブバーの仕訳タブからの遷移の場合
                number = dataBaseManager.addJournalEntry(
                    date: formatter.string(from: datePicker.date),
                    debit_category: TextField_category_debit.text!,
                    debit_amount: Int64(removeComma(string: TextField_amount_debit.text!))!, //カンマを削除してからデータベースに書き込む
                    credit_category: TextField_category_credit.text!,
                    credit_amount: Int64(removeComma(string: TextField_amount_credit.text!))!,//カンマを削除してからデータベースに書き込む
                    smallWritting: TextField_SmallWritting.text!
                )
                self.dismiss(animated: true, completion: {
                    [presentingViewController] () -> Void in
                    self.Label_Popup.text = "仕訳を記帳しました" //ポップアップの文字表示
                    // ⑤ Timer のスケジューリング重複を回避
                    guard self.timer == nil else { return }
                    // ① Timerのスケジューリングと保持
                    self.timer = Timer.scheduledTimer(
                        timeInterval: 4, // 計測する時間を設定
                        target: self,
                        selector: #selector(self.handleTimer(_:)), // 一定時間経過した後に実行する関数を指定
                        userInfo: nil,
                        repeats: false // 繰り返し呼び出し
                    )
                })
                // アップグレード機能　スタンダードプラン
                if !inAppPurchaseFlag {
                    // マネタイズ対応
                    // 乱数　1から6までのIntを生成
                    let iValue = Int.random(in: 1 ... 6)
                    if iValue % 2 == 0 {
                        if interstitial != nil {
                            interstitial?.present(fromRootViewController: self)
                        } else {
                          print("Ad wasn't ready")
                        }
                    }
                }
            }
            
        }
    }
    // 入力チェック
    func textInputCheck() -> Bool {
        if TextField_category_debit.text != "" && TextField_category_debit.text != "" {
            if TextField_category_credit.text != "" && TextField_category_credit.text != "" {
                if TextField_amount_debit.text != "" && TextField_amount_debit.text != "" && TextField_amount_debit.text != "0" {
                    if TextField_amount_credit.text != "" && TextField_amount_credit.text != "" && TextField_amount_credit.text != "0" {
                        if TextField_SmallWritting.text == "" {
                            TextField_SmallWritting.text = ""
                        }
                        return true // OK
                    }else{
                        Label_Popup.text = "金額を入力してください"
                        //未入力のTextFieldのキーボードを自動的に表示する
                        TextField_amount_credit.becomeFirstResponder()
                        return false // NG
                    }
                }else{
                    Label_Popup.text = "金額を入力してください"
                    //未入力のTextFieldのキーボードを自動的に表示する
                    TextField_amount_debit.becomeFirstResponder()
                    return false // NG
                }
            }else{
                Label_Popup.text = "貸方勘定科目を入力してください"
                //未入力のTextFieldのキーボードを自動的に表示する
                TextField_category_credit.becomeFirstResponder()
                return false // NG
            }
        }else{
            Label_Popup.text = "借方勘定科目を入力してください"
            //未入力のTextFieldのキーボードを自動的に表示する
            TextField_category_debit.becomeFirstResponder()
            return false // NG
        }
    }
    
    @objc private func handleTimer(_ timer: Timer) {
        self.Label_Popup.text = "" //ポップアップの文字表示
        // ③ Timer のスケジューリングを破棄
        timer.invalidate()
    }
    
    @IBOutlet var Button_cancel: EMTNeumorphicButton!
    @IBAction func Button_cancel(_ sender: UIButton) {
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
        TextField_category_debit.text = ""
        TextField_category_credit.text = ""
        TextField_amount_debit.text = ""
        TextField_amount_credit.text = ""
        TextField_SmallWritting.text = ""
        // 終了させる　仕訳帳画面へ戻る
        self.dismiss(animated: true, completion: nil)
    }

}
// プロトコル定義
extension JournalEntryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //collectionViewの要素の数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // データベース　仕訳テンプレートを追加
        let dataBaseManager = DataBaseManagerSettingsOperatingJournalEntry()
        let objects = dataBaseManager.getJournalEntry()
        return objects.count
    }
    //collectionViewのセルを返す（セルの内容を決める）
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CarouselCollectionViewCell
        // データベース　仕訳テンプレートを追加
        let dataBaseManager = DataBaseManagerSettingsOperatingJournalEntry()
        let objects = dataBaseManager.getJournalEntry()
        if "" != objects[indexPath.row].nickname {
            cell.nicknameLabel.text = objects[indexPath.row].nickname
        }
        return cell
    }
//    //セル間の間隔を指定
//    private func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimunLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 20
//    }
    //セルのサイズ(CGSize)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height * 1.5, height: collectionView.frame.height - 15)
    }
    //余白の調整（UIImageを拡大、縮小している）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //top:ナビゲーションバーの高さ分上に移動
        return UIEdgeInsets(top: 0,left: 3,bottom: 3,right: 3)
    }
    ///セルの選択時に背景色を変化させる
    ///今度はセルが選択状態になった時に背景色が青に変化するようにしてみます。
    ///以下の3つのメソッドはデフォルトでtrueなので、このケースでは実装しなくても良いです。
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("Highlighted: \(indexPath)")
        // データベース　仕訳テンプレートを追加
        let dataBaseManager = DataBaseManagerSettingsOperatingJournalEntry()
        let objects = dataBaseManager.getJournalEntry()
        TextField_category_debit.text = objects[indexPath.row].debit_category
        TextField_amount_debit.text = String(objects[indexPath.row].debit_amount)
        TextField_category_credit.text = objects[indexPath.row].credit_category
        TextField_amount_credit.text = String(objects[indexPath.row].credit_amount)
        TextField_SmallWritting.text = objects[indexPath.row].smallWritting
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        print("Unhighlighted: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true  // 変更
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
