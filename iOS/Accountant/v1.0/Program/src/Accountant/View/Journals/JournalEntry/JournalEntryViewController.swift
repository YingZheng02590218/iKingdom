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
class JournalEntryViewController: UIViewController {
    
    // MARK: - var let

    private var interstitial: GADInterstitialAd?
 
    // 初期化画面　ロゴ
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var logoImageView: UIView!
    // 初期化画面　インジゲーター
    var activityIndicatorView = UIActivityIndicatorView()
    // タイトルラベル
    @IBOutlet var label_title: UILabel!
    // 仕訳/決算整理仕訳　切り替え
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    // コレクションビュー　カルーセル　よく使う仕訳
    @IBOutlet var carouselCollectionView: UICollectionView!
    static var viewReload = false // カルーセル　リロードするかどうか
    // ボタン　アウトレットコレクション
    @IBOutlet var arrayHugo: [EMTNeumorphicButton]!
    @IBOutlet weak var Button_Right: EMTNeumorphicButton!
    @IBOutlet weak var Button_Left: EMTNeumorphicButton!
    @IBOutlet var inputButton: EMTNeumorphicButton!
    @IBOutlet var Button_cancel: EMTNeumorphicButton!
    // デイトピッカー　日付
    @IBOutlet weak var datePicker: UIDatePicker!
    let dateFormatter = DateFormatter()
    var isMaskedDatePicker = false // マスクフラグ

    @IBOutlet var datePickerView: EMTNeumorphicView!
    @IBOutlet weak var maskDatePickerButton: UIButton!
    // テキストフィールド　勘定科目、金額
    @IBOutlet weak var TextField_category_debit: PickerTextField!
    @IBOutlet weak var TextField_category_credit: PickerTextField!
    @IBOutlet weak var TextField_amount_debit: UITextField!
    @IBOutlet weak var TextField_amount_credit: UITextField!
    @IBOutlet var textFieldView: EMTNeumorphicView!
    // テキストフィールド　小書き
    @IBOutlet weak var TextField_SmallWritting: UITextField!
    @IBOutlet var smallWrittingTextFieldView: EMTNeumorphicView!

    private var timer: Timer? // Timerを保持する変数
    
    // 仕訳タイプ(仕訳or決算整理仕訳or編集)
    var journalEntryType :String = "" // Journal Entries、Adjusting and Closing Entries, JournalEntriesPackageFixing
    
    // 仕訳編集　仕訳帳画面で選択されたセルの位置　仕訳か決算整理仕訳かの判定に使用する
    var tappedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    // 仕訳編集　編集の対象となる仕訳の連番
    var primaryKey: Int = 0

    /// 電卓画面から仕訳画面へ遷移したか
    var isFromClassicCalcuatorViewController = false
    /// 電卓画面で入力された金額の値
    var numbersOnDisplay: Int?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 仕訳タイプ判定
        if journalEntryType == "" {
            // 初期化処理
            initialize()
        }
        self.navigationItem.title = "仕訳"
        //largeTitle表示
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // ニューモフィズム　ボタンとビューのデザインを指定する
        createEMTNeumorphicView()
        
        // セットアップ
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current // UTC時刻を補正
        dateFormatter.dateFormat = "yyyy/MM/dd"     // 注意：　小文字のyにしなければならない
    }
    // ビューが表示される直前に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        // 金額を入力後に、電卓画面から仕訳画面へ遷移した場合
        if isFromClassicCalcuatorViewController {
            // 金額　電卓画面で入力した値を表示させる
            if let numbersOnDisplay = numbersOnDisplay {
                TextField_amount_debit.text = StringUtility.shared.addComma(string: numbersOnDisplay.description)
                TextField_amount_credit.text = StringUtility.shared.addComma(string: numbersOnDisplay.description)
                // TextField 貸方金額　入力後
                if TextField_amount_debit.text == "0"{
                    TextField_amount_debit.text = ""
                    TextField_amount_credit.text = ""
                }
                if TextField_amount_credit.text == "0"{
                    TextField_amount_credit.text = ""
                    TextField_amount_debit.text = ""
                }
                if journalEntryType != "JournalEntriesPackageFixing" { // 仕訳一括編集ではない場合
                    if TextField_SmallWritting.text == "" {
                        TextField_SmallWritting.becomeFirstResponder() // カーソルを移す
                    }
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
            if journalEntryType == "JournalEntries" { // 仕訳
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
            else if journalEntryType == "AdjustingAndClosingEntries" { // 決算整理仕訳
                label_title.text = "決算整理仕訳"
                createCarousel() // カルーセルを作成
                if JournalEntryViewController.viewReload {
                    DispatchQueue.main.async {
                        self.carouselCollectionView.reloadData()
                        JournalEntryViewController.viewReload = false
                    }
                }
                createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
            }
            else if journalEntryType == "JournalEntriesPackageFixing" { // 仕訳一括編集
                label_title.text = "仕訳まとめて編集"
                createCarousel() // カルーセルを作成
                carouselCollectionView.isHidden = true
                createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
                maskDatePickerButton.isHidden = false
                isMaskedDatePicker = false
                inputButton.setTitle("更　新", for: UIControl.State.normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
            }
            else if journalEntryType == "JournalEntriesFixing" { // 仕訳編集
                createCarousel() // カルーセルを作成
                carouselCollectionView.isHidden = true
                createDatePicker() // 決算日設定機能　決算日を変更後に仕訳画面に反映させる
                // 仕訳データを取得
                let dataBaseManager = DataBaseManagerJournalEntry() //データベースマネジャー
                
                if tappedIndexPath.section == 1 {
// 決算整理仕訳
                    label_title.text = "決算整理仕訳編集"
                    if let dataBaseJournalEntry = dataBaseManager.getAdjustingEntryWithNumber(number: primaryKey) {
                        datePicker.date = dateFormatter.date(from: dataBaseJournalEntry.date)! // 注意：カンマの後にスペースがないとnilになる
                        TextField_category_debit.text = dataBaseJournalEntry.debit_category
                        TextField_category_credit.text = dataBaseJournalEntry.credit_category
                        TextField_amount_debit.text = StringUtility.shared.addComma(string: String(dataBaseJournalEntry.debit_amount))
                        TextField_amount_credit.text = StringUtility.shared.addComma(string: String(dataBaseJournalEntry.credit_amount))
                        TextField_SmallWritting.text = dataBaseJournalEntry.smallWritting
                    }
                }
                else {
// 通常仕訳
                    label_title.text = "仕訳編集"
                    if let dataBaseJournalEntry = dataBaseManager.getJournalEntryWithNumber(number: primaryKey) {
                        datePicker.date = dateFormatter.date(from: dataBaseJournalEntry.date)! // 注意：カンマの後にスペースがないとnilになる
                        TextField_category_debit.text = dataBaseJournalEntry.debit_category
                        TextField_category_credit.text = dataBaseJournalEntry.credit_category
                        TextField_amount_debit.text = StringUtility.shared.addComma(string: String(dataBaseJournalEntry.debit_amount))
                        TextField_amount_credit.text = StringUtility.shared.addComma(string: String(dataBaseJournalEntry.credit_amount))
                        TextField_SmallWritting.text = dataBaseJournalEntry.smallWritting
                    }
                }
                inputButton.setTitle("更　新", for: UIControl.State.normal)// 注意：Title: Plainにしないと、Attributeでは変化しない。
            }
            else if journalEntryType == "" {
                label_title.text = ""
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
        
        // セットアップ AdMob
        setupAdMob()
        
        // ナビゲーションを透明にする処理
        if let navigationController = self.navigationController {
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController.navigationBar.shadowImage = UIImage()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
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
        
        // チュートリアル対応 ウォークスルー型
        showWalkThrough()
    }
    
    override func viewDidLayoutSubviews() {
        // ニューモフィズム　ボタンとビューのデザインを指定する
        createEMTNeumorphicView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - ロゴとインジゲーターのアニメーション

    func initialize() {
        // インジゲーターを開始
        showActivityIndicatorView()
        // データベース初期化
        let initial = Initial()
        initial.initialize()
        // インジケーターを終了
        finishActivityIndicatorView()
    }
    // インジゲーターを開始
    func showActivityIndicatorView() {
        if let logoImageView = logoImageView {
            logoImageView.isHidden = false
            // 表示位置を設定（画面中央）
            activityIndicatorView.center = CGPoint(x:view.center.x, y: view.center.y + 60)
            // インジケーターのスタイルを指定（白色＆大きいサイズ）
            activityIndicatorView.style = UIActivityIndicatorView.Style.large
            // インジケーターを View に追加
            view.addSubview(activityIndicatorView)
            // インジケーターを表示＆アニメーション開始
            activityIndicatorView.startAnimating()
        }
    }
    // インジケーターを終了
    func finishActivityIndicatorView() {
        DispatchQueue.global(qos: .default).async {
            // 非同期処理などが終了したらメインスレッドでアニメーション終了
            DispatchQueue.main.async {
                // ロゴをアニメーションさせる
                self.showAnimation()
                // 非同期処理などを実行（今回は2秒間待つだけ）
                Thread.sleep(forTimeInterval: 0.5)
                // アニメーション終了
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    // ロゴをアニメーションさせる
    func showAnimation() {
        // 少し縮小するアニメーション
        if let logoLabel = self.logoLabel {
            UIView.animate(withDuration: 0.9,
                           delay: 0.2,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: { () in
                logoLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }, completion: { (Bool) in
                
            })
            // 拡大させて、消えるアニメーション
            UIView.animate(withDuration: 0.4,
                           delay: 0.2,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: { () in
                self.logoLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.logoLabel.alpha = 0
            }, completion: { (Bool) in
                self.logoImageView.removeFromSuperview()
            })
        }
    }
    
    // MARK: - チュートリアル対応 ウォークスルー型

    // チュートリアル対応 ウォークスルー型
    func showWalkThrough() {
        // チュートリアル対応 ウォークスルー型　初回起動時
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch_WalkThrough"
        if ud.bool(forKey: firstLunchKey) {
            DispatchQueue.global(qos: .default).async {
                // 非同期処理などを実行（今回は3秒間待つだけ）
                Thread.sleep(forTimeInterval: 1)
                DispatchQueue.main.async {
                    // チュートリアル対応 ウォークスルー型
                    let viewController = UIStoryboard(name: "WalkThroughViewController", bundle: nil).instantiateViewController(withIdentifier: "WalkThroughViewController") as! WalkThroughViewController
                    viewController.modalPresentationStyle = .fullScreen
                    self.present(viewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - チュートリアル対応 コーチマーク型
    
    // チュートリアル対応 コーチマーク型
    // ウォークスルーが終了後に、呼び出される
    func showAnnotation() {
        // チュートリアル対応 コーチマーク型　初回起動時　7行を追加
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch_JournalEntry"
        if ud.bool(forKey: firstLunchKey) {
            DispatchQueue.global(qos: .default).async {
            ud.set(false, forKey: firstLunchKey)
            ud.synchronize()
                DispatchQueue.main.async {
                    // コーチマークを開始
                    self.presentAnnotation()
                }
            }
        }
        else {
            // コーチマークを終了
            self.finishAnnotation()
        }
    }
    // チュートリアル対応 コーチマーク型　コーチマークを開始
    func presentAnnotation() {
        //タブの無効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
            }
        }
        let viewController = UIStoryboard(name: "JournalEntryViewController", bundle: nil).instantiateViewController(withIdentifier: "Annotation_JournalEntry") as! AnnotationViewControllerJournalEntry
        viewController.alpha = 0.7
        present(viewController, animated: true, completion: nil)
    }
    // チュートリアル対応 コーチマーク型　コーチマークを終了
    func finishAnnotation() {
        //タブの有効化
        if let arrayOfTabBarItems = self.tabBarController?.tabBar.items as NSArray? {
            for tabBarItem in arrayOfTabBarItems {
                if let tabBarItem = tabBarItem as? UITabBarItem {
                    tabBarItem.isEnabled = true
                }
            }
        }
        // チュートリアル対応 赤ポチ型　初回起動時　7行を追加
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch_SettingsCategory"
        if ud.bool(forKey: firstLunchKey) { // 設定勘定科目のコーチマークが表示されていない場合
            DispatchQueue.main.async {
                // 赤ポチを開始
                self.tabBarController?.viewControllers?[4].tabBarItem.badgeValue = ""
            }
        }
    }
    
    // MARK: - Setting

    // MARK: UICollectionView
    // カルーセル作成
    func createCarousel() {
        //xib読み込み
        let nib = UINib(nibName: "CarouselCollectionViewCell", bundle: .main)
        carouselCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
    }
    
    // MARK: UIDatePicker
    // デートピッカー作成
    func createDatePicker() {
        // 現在時刻を取得
        let now :Date = Date() // UTC時間なので　9時間ずれる

        let dateFormatterYYYY = DateFormatter() // 年
        let dateFormatterMM = DateFormatter() // 月
        let dateFormatterMMdd = DateFormatter() // 月/日
        let dateFormatteryyyyMMddHHmmss = DateFormatter() // 年-月-日 時分秒
        let dateFormatterHHmmss = DateFormatter() // 時分秒
        let dateFormatteryyyyMMdd = DateFormatter() // 年-月-日
        let timezone = DateFormatter() // 月-日

        dateFormatterYYYY.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatterYYYY.timeZone = .current
        dateFormatterMM.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatterMM.timeZone = .current
        
        dateFormatterMMdd.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatterMMdd.timeZone = .current
        
        dateFormatteryyyyMMddHHmmss.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatteryyyyMMddHHmmss.timeZone = .current
        dateFormatterHHmmss.dateFormat = DateFormatter.dateFormat(fromTemplate: "'T'HH:mm:ss.SSSZZZZZ", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatterHHmmss.timeZone = .current
        
        dateFormatteryyyyMMdd.dateFormat = "yyyy-MM-dd"
        dateFormatteryyyyMMdd.timeZone = .current
        timezone.dateFormat  = "MM-dd"
        timezone.timeZone = .current
        timezone.locale = Locale(identifier: "en_US_POSIX")

        // 開いている会計帳簿の年度を取得
        let object = DataBaseManagerSettingsPeriod.shared.getSettingsPeriod(lastYear: false)
        let fiscalYear = object.dataBaseJournals?.fiscalYear
        let nowStringYear = fiscalYear!.description                            //　本年度
        let nowStringNextYear = (fiscalYear! + 1).description                  //　次年度
        let nowStringMonthDay = dateFormatterMMdd.string(from: now)                           // 現在時刻の月日
        
        // 設定決算日
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: dateFormatterMMdd.date(from: theDayOfReckoning)!)! // 決算日設定機能　年度開始日は決算日の翌日に設定する
        let dayOfStartInPeriod :Date = dateFormatterMMdd.date(from: dateFormatterMMdd.string(from: modifiedDate))! // 決算日設定機能　年度開始日
        let dayOfEndInPeriod :Date   = dateFormatterMMdd.date(from: theDayOfReckoning)! // 決算日設定機能 注意：nowStringYearは、開始日の日付が存在するかどうかを確認するために記述した。閏年など
        
        // 期間
        let dayOfStartInYear :Date   = dateFormatterMMdd.date(from: "01/01")!
        let dayOfEndInYear :Date     = dateFormatterMMdd.date(from: "12/31")!

        // デイトピッカーの最大値と最小値を設定
        if journalEntryType == "AdjustingAndClosingEntries" { // 決算整理仕訳
            // 決算整理仕訳の場合は日付を決算日に固定
            if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                print("### 会計期間が年をまたがない場合")
                datePicker.minimumDate = dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(timezone.string(from: dateFormatterMMdd.date(from: theDayOfReckoning)!))")
                print(dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(timezone.string(from: dateFormatterMMdd.date(from: theDayOfReckoning)!))"))
                datePicker.maximumDate = dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(timezone.string(from: dateFormatterMMdd.date(from: theDayOfReckoning)!))")
            }
            else { // 会計期間が年をまたぐ場合
                print("### 会計期間が年をまたぐ場合")
                datePicker.minimumDate = dateFormatteryyyyMMdd.date(from: nowStringNextYear + "-\(timezone.string(from: dateFormatterMMdd.date(from: theDayOfReckoning)!))")
                datePicker.maximumDate = dateFormatteryyyyMMdd.date(from: nowStringNextYear + "-\(timezone.string(from: dateFormatterMMdd.date(from: theDayOfReckoning)!))")
            }
        }
        else if journalEntryType == "JournalEntriesFixing" { // 仕訳編集
            // 決算日設定機能　何もしない
        }
        else if journalEntryType == "JournalEntriesPackageFixing" { // 仕訳一括編集
            
        }
        else {
            if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                print("### 会計期間が年をまたがない場合")
                datePicker.minimumDate = dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(timezone.string(from: modifiedDate))")
                print(dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(timezone.string(from: modifiedDate))"))
                datePicker.maximumDate = dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(timezone.string(from: dateFormatterMMdd.date(from: theDayOfReckoning)!))")
                print(dateFormatteryyyyMMdd.date(from: nowStringYear + "-\(timezone.string(from: dateFormatterMMdd.date(from: theDayOfReckoning)!))"))
            }
            else { // 会計期間が年をまたぐ場合
                // 01/01 以降か
                let Interval = (Calendar.current.dateComponents([.month], from: dayOfStartInYear, to: dateFormatterMMdd.date(from: nowStringMonthDay)! )).month
                // 設定決算日 未満か
                let Interval1 = (Calendar.current.dateComponents([.month], from: dayOfEndInPeriod, to: dateFormatterMMdd.date(from: nowStringMonthDay)! )).month
                // 年度開始日 以降か
                let Interval2 = (Calendar.current.dateComponents([.month], from: dayOfStartInPeriod, to: dateFormatterMMdd.date(from: nowStringMonthDay)! )).month
                // 12/31と同じ、もしくはそれ以前か
                let Interval3 = (Calendar.current.dateComponents([.month], from: dayOfEndInYear, to: dateFormatterMMdd.date(from: nowStringMonthDay)! )).month
                
                if Interval! >= 0  {
                    print("### 会計期間　1/01 以降")
                    if Interval1! <= 0 {
                        print("### 会計期間　設定決算日 未満")
                        // 決算日設定機能　注意：カンマの後にスペースがないとnilになる
                        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: dateFormatteryyyyMMddHHmmss.date(from: theDayOfReckoning + "/" + nowStringYear + ", " + dateFormatterHHmmss.string(from: now))!)
                        // 四月以降か
                        datePicker.maximumDate = dateFormatteryyyyMMdd.date(from: (nowStringNextYear + "-\(timezone.string(from: dateFormatterMMdd.date(from: theDayOfReckoning)!))"))
                    }
                    else if Interval2! >= 0 {
                        print("### 会計期間　年度開始日 以降")
                        if Interval3! <= 0 {
                            print("### 会計期間　12/31 以前")
                            // 決算日設定機能　注意：カンマの後にスペースがないとnilになる 04-02にすると04-01となる
                            datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: dateFormatteryyyyMMddHHmmss.date(from: theDayOfReckoning + "/" + nowStringYear + ", " + dateFormatterHHmmss.string(from: now))!)
                            // 04-01にすると03-31となる
                            datePicker.maximumDate = dateFormatteryyyyMMdd.date(from: nowStringNextYear + "-\(timezone.string(from: dateFormatterMMdd.date(from: theDayOfReckoning)!))")
                        }
                    }
                }
            }
        }
        // ピッカーの初期値
        if journalEntryType == "JournalEntriesFixing" { // 仕訳編集
            // 決算日設定機能　何もしない viewDidLoad()で値を設定している
        }
        else if journalEntryType == "JournalEntriesPackageFixing" { // 仕訳一括編集
            
        }
        else if journalEntryType == "AdjustingAndClosingEntries" { // 決算整理仕訳
            if theDayOfReckoning == "12/31" { // 会計期間が年をまたがない場合
                datePicker.date = dateFormatteryyyyMMddHHmmss.date(from: theDayOfReckoning + "/" + nowStringYear + ", " + dateFormatterHHmmss.string(from: now))!// 注意：カンマの後にスペースがないとnilになる
            }
            else {
                datePicker.date = dateFormatteryyyyMMddHHmmss.date(from: theDayOfReckoning + "/" + nowStringNextYear + ", " + dateFormatterHHmmss.string(from: now))!// 注意：カンマの後にスペースがないとnilになる
            }
        }
        else {
            datePicker.date = dateFormatteryyyyMMddHHmmss.date(from: dateFormatterMMdd.string(from: now) + "/" + dateFormatterYYYY.string(from: now) + ", " + dateFormatterHHmmss.string(from: now))!// 注意：カンマの後にスペースがないとnilになる
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
    // MARK: EMTNeumorphicView
    // ニューモフィズム　ボタンとビューのデザインを指定する
    private func createEMTNeumorphicView() {

        if let datePickerView = datePickerView {
            datePickerView.neumorphicLayer?.cornerRadius = 15
            datePickerView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            datePickerView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            datePickerView.neumorphicLayer?.edged = Constant.edged
            datePickerView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            datePickerView.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
        }
        
        if let Button_Left = Button_Left {
            Button_Left.setTitleColor(.ButtonTextColor, for: .normal)
            Button_Left.neumorphicLayer?.cornerRadius = 10
            Button_Left.setTitleColor(.ButtonTextColor, for: .selected)
            Button_Left.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            Button_Left.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            Button_Left.neumorphicLayer?.edged = Constant.edged
            Button_Left.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            Button_Left.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
            let backImage = UIImage(named: "icons8-戻る-25")?.withRenderingMode(.alwaysTemplate)
            Button_Left.setImage(backImage, for: UIControl.State.normal)
            // アイコン画像の色を指定する
            Button_Left.tintColor = .TextColor
        }
        
        if let Button_Right = Button_Right {
            Button_Right.setTitleColor(.ButtonTextColor, for: .normal)
            Button_Right.neumorphicLayer?.cornerRadius = 10
            Button_Right.setTitleColor(.ButtonTextColor, for: .selected)
            Button_Right.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            Button_Right.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            Button_Right.neumorphicLayer?.edged = Constant.edged
            Button_Right.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            Button_Right.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
            let backImage = UIImage(named: "icons8-進む-25")?.withRenderingMode(.alwaysTemplate)
            Button_Right.setImage(backImage, for: UIControl.State.normal)
            // アイコン画像の色を指定する
            Button_Right.tintColor = .TextColor
        }
        
        if let textFieldView = textFieldView {
            textFieldView.neumorphicLayer?.cornerRadius = 15
            textFieldView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            textFieldView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            textFieldView.neumorphicLayer?.edged = Constant.edged
            textFieldView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            textFieldView.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
            textFieldView.neumorphicLayer?.depthType = .concave
        }
        
        if let smallWrittingTextFieldView = smallWrittingTextFieldView {
            smallWrittingTextFieldView.neumorphicLayer?.cornerRadius = 15
            smallWrittingTextFieldView.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
            smallWrittingTextFieldView.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
            smallWrittingTextFieldView.neumorphicLayer?.edged = Constant.edged
            smallWrittingTextFieldView.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
            smallWrittingTextFieldView.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
            smallWrittingTextFieldView.neumorphicLayer?.depthType = .concave
        }
        
//        inputButton.setTitle("入力", for: .normal)
        inputButton.setTitleColor(.ButtonTextColor, for: .normal)
        inputButton.neumorphicLayer?.cornerRadius = 15
        inputButton.setTitleColor(.ButtonTextColor, for: .selected)
        inputButton.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        inputButton.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        inputButton.neumorphicLayer?.edged = Constant.edged
        inputButton.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        inputButton.neumorphicLayer?.elementBackgroundColor = UIColor.Background.cgColor
        
        Button_cancel.setTitleColor(.ButtonTextColor, for: .normal)
        Button_cancel.neumorphicLayer?.cornerRadius = 15
        Button_cancel.setTitleColor(.ButtonTextColor, for: .selected)
        Button_cancel.neumorphicLayer?.lightShadowOpacity = Constant.LIGHTSHADOWOPACITY
        Button_cancel.neumorphicLayer?.darkShadowOpacity = Constant.DARKSHADOWOPACITY
        Button_cancel.neumorphicLayer?.edged = Constant.edged
        Button_cancel.neumorphicLayer?.elementDepth = Constant.ELEMENTDEPTH
        Button_cancel.neumorphicLayer?.elementBackgroundColor = UIColor.systemPink.cgColor
        // Optional. if it is nil (default), elementBackgroundColor will be used as element color.
        Button_cancel.neumorphicLayer?.elementColor = UIColor.Background.cgColor
        let backImage = UIImage(named: "icons8-削除-25-2")?.withRenderingMode(.alwaysTemplate)
        Button_cancel.setImage(backImage, for: UIControl.State.normal)
        // アイコン画像の色を指定する
        Button_cancel.tintColor = .TextColor
    }

    // MARK: PickerTextField
    // TextField作成　勘定科目
    func createTextFieldForCategory() {
        TextField_category_debit.delegate = self
        TextField_category_credit.delegate = self
        TextField_category_debit.setup(identifier: "identifier_debit")
        TextField_category_credit.setup(identifier: "identifier_credit")
        TextField_category_debit.textAlignment = .left
        TextField_category_credit.textAlignment = .right
    }
    
    // MARK: UITextField
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
    }
    // TextField作成 小書き
    func createTextFieldForSmallwritting() {
        TextField_SmallWritting.delegate = self
        TextField_SmallWritting.textAlignment = .center
        // テキストの入力位置を指すライン、これはカーソルではなくキャレット(caret)と呼ぶそうです。
        TextField_SmallWritting.tintColor = UIColor.black

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
    
    // MARK: GADInterstitialAd
    // セットアップ AdMob　アップグレード機能　スタンダードプラン
    func setupAdMob() {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            // マネタイズ対応　注意：viewDidLoad()ではなく、viewWillAppear()に実装すること
            // GADBannerView プロパティを設定する
            // GADInterstitial を作成する
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: Constant.ADMOB_ID_INTERSTITIAL,
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
        if segmentedControl.selectedSegmentIndex == 0 {
            // 仕訳タイプ判定
            journalEntryType = "" // 仕訳
            label_title.text = ""
            self.navigationItem.title = "仕訳"
        }
        else {
            journalEntryType = "AdjustingAndClosingEntries" // 決算整理仕訳
            label_title.text = ""
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
    
    // MARK: UITextField
    @IBAction func TextField_category_debit(_ sender: UITextField) {}
    @IBAction func TextField_category_credit(_ sender: UITextField) {}
    @IBAction func TextField_SmallWritting(_ sender: UITextField) {}
        
    // MARK: キーボード
    // TextFieldをタップしても呼ばれない
    @IBAction func TapGestureRecognizer(_ sender: Any) {// この前に　touchesBegan が呼ばれている
        self.view.endEditing(true)
    }
    // UIKeyboardWillShow通知を受けて、実行される関数
    @objc func keyboardWillShow(notification: NSNotification) {
        // 小書きを入力中は、画面を上げる
        if TextField_SmallWritting.isEditing {
            guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            // テキストフィールドの下辺
            let txtLimit = TextField_SmallWritting.frame.origin.y + TextField_SmallWritting.frame.height + 8.0

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
    @objc func keyboardWillHide(notification: NSNotification) {
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
    // TextFieldのキーボードについているBarButtonが押下された時
    @objc func barButtonTapped(_ sender: UIBarButtonItem) {
        
        switch sender.tag {
        case 5://借方金額の場合 Done
            if TextField_amount_debit.text == "0" {
                TextField_amount_debit.text = ""
            }
            else if TextField_amount_debit.text == "" {
            }
            else {
                self.view.endEditing(true) // 注意：キーボードを閉じた後にbecomeFirstResponderをしないと二重に表示される
                if TextField_category_credit.text == "" {
                    if journalEntryType != "JournalEntriesPackageFixing" { // 仕訳一括編集ではない場合
                        //TextFieldのキーボードを自動的に表示する　借方金額　→ 貸方勘定科目
                        TextField_category_credit.becomeFirstResponder()
                    }
                }
            }
            break
        case 55://借方金額の場合 Cancel
            TextField_amount_debit.text = ""
            TextField_amount_credit.text = ""
            self.view.endEditing(true) // textFieldDidEndEditingで貸方金額へコピーするのでtextを設定した後に実行
            break
        case 6://貸方金額の場合 Done
            if TextField_amount_credit.text == "0" {
                TextField_amount_credit.text = ""
            }
            else if TextField_amount_credit.text == "" {
            }
            else {
                self.view.endEditing(true) // 注意：キーボードを閉じた後にbecomeFirstResponderをしないと二重に表示される
                if TextField_SmallWritting.text == "" {
                    if journalEntryType != "JournalEntriesPackageFixing" { // 仕訳一括編集ではない場合
                        // カーソルを小書きへ移す
                        self.TextField_SmallWritting.becomeFirstResponder()
                    }
                }
            }
            break
        case 66://貸方金額の場合 Cancel
            TextField_amount_debit.text = ""
            TextField_amount_credit.text = ""
            self.view.endEditing(true) // textFieldDidEndEditingで借方金額へコピーするのでtextを設定した後に実行
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
    //TextField キーボード以外の部分をタッチ　 TextFieldをタップしても呼ばれない
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {// この後に TapGestureRecognizer が呼ばれている
        // 初期値を再設定
        setInitialData()
        // touchesBeganメソッドをオーバーライドします。
        self.view.endEditing(true)
    }
    
    // MARK: EMTNeumorphicButton
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
        
        if journalEntryType == "JournalEntriesPackageFixing" { // 仕訳一括編集
            
            buttonTappedForJournalEntriesPackageFixing()
        }
        else { // 一括編集以外
            
            // バリデーションチェック
            if self.textInputCheck() {
                
                // オフラインの場合広告が表示できないので、ネットワーク接続を確認する
                if Network.shared.isOnline() ||
                    // アップグレード機能　スタンダードプラン サブスクリプション購読済み
                    UpgradeManager.shared.inAppPurchaseFlag {
                    //ネットワークあり
                    // 仕訳タイプ判定　仕訳、決算整理仕訳、編集、一括編集
                    if self.journalEntryType == "AdjustingAndClosingEntries" { // 決算整理仕訳
                        
                        self.buttonTappedForAdjustingAndClosingEntries()
                    }
                    else if self.journalEntryType == "JournalEntriesFixing" { // 仕訳編集
                        
                        self.buttonTappedForJournalEntriesFixing()
                    }
                    else if self.journalEntryType == "JournalEntries" { // 仕訳
                        
                        self.buttonTappedForJournalEntries()
                    }
                    else if self.journalEntryType == "" { // タブバーの仕訳タブからの遷移の場合
                        
                        self.buttonTappedForJournalEntriesOnTabBar()
                    }
                }
                else {
                    //ネットワークなし
                    let alertController = UIAlertController(title: "インターネット未接続", message: "オフラインでは利用できません。\n\nスタンダードプランに\nアップグレードしていただくと、\nオフラインでも利用可能となります。", preferredStyle: .alert)
                    
                    // 選択肢の作成と追加
                    // titleに選択肢のテキストを、styleに.defaultを
                    // handlerにボタンが押された時の処理をクロージャで実装する
                    alertController.addAction(
                        UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: {
                                          (action: UIAlertAction!) -> Void in
                                          // オフラインの場合広告が表示できないので、ネットワーク接続を確認する
                                          if Network.shared.isOnline() {
                                              // アップグレード画面を表示
                                              let viewController = UIStoryboard(name: "SettingsUpgradeTableViewController", bundle: nil).instantiateViewController(withIdentifier: "SettingsUpgradeTableViewController") as! SettingsUpgradeTableViewController
                                              self.present(viewController, animated: true, completion: nil)
                                          }
                                          else {

                                          }
                                      })
                    )
                    self.present(alertController, animated: true, completion: nil)
                }
            }

        }
    }
    
    // 仕訳一括編集　の処理
    func buttonTappedForJournalEntriesPackageFixing() {
        // バリデーションチェック
        var datePicker: String? = nil
        if isMaskedDatePicker {
            datePicker = dateFormatter.string(from: self.datePicker.date)
        }
        var textField_category_debit: String? = nil
        if let _ = self.TextField_category_debit.text {
            if self.TextField_category_debit.text != "" {
                textField_category_debit = self.TextField_category_debit.text!
            }
        }
        var textField_category_credit: String? = nil
        if let _ = self.TextField_category_credit.text {
            if self.TextField_category_credit.text != "" {
                textField_category_credit = self.TextField_category_credit.text!
            }
        }
        var textField_amount_debit: Int64? = nil
        if let _ = self.TextField_amount_debit.text {
            textField_amount_debit = Int64(StringUtility.shared.removeComma(string: self.TextField_amount_debit.text!))
        }
        var textField_amount_credit: Int64? = nil
        if let _ = self.TextField_amount_credit.text {
            textField_amount_credit = Int64(StringUtility.shared.removeComma(string: self.TextField_amount_credit.text!))
        }
        var textField_SmallWritting: String? = nil
        if let _ = self.TextField_SmallWritting.text {
            if self.TextField_SmallWritting.text != "" {
                textField_SmallWritting = self.TextField_SmallWritting.text!
            }
        }
        
        let dBJournalEntry = DBJournalEntry(
            date: datePicker,
            debit_category: textField_category_debit,
            debit_amount: textField_amount_debit,
            credit_category: textField_category_credit,
            credit_amount: textField_amount_credit,
            smallWritting: textField_SmallWritting
        )
        
        if dBJournalEntry.checkPropertyIsNil() {
            let alert = UIAlertController(title: "なにも入力されていません", message: "変更したい項目に入力してください", preferredStyle: .alert)
            self.present(alert, animated: true) { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        else {
            // いづれかひとつに値があれば下記を実行する
            let alert = UIAlertController(title: "最終確認", message: "ほんとうに変更しますか？\n日付: \(dBJournalEntry.date ?? "")\n借方勘定: \(dBJournalEntry.debit_category ?? "")\n貸方勘定: \(dBJournalEntry.credit_category ?? "")\n金額: \(dBJournalEntry.credit_amount?.description ?? "")\n小書き: \(dBJournalEntry.smallWritting ?? "")", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {
                (action: UIAlertAction!) in
                print("OK アクションをタップした時の処理")
                let tabBarController = self.presentingViewController as! UITabBarController // 一番基底となっているコントローラ
                let navigationController = tabBarController.selectedViewController as! UINavigationController // 基底のコントローラから、現在選択されているコントローラを取得する
                let presentingViewController = navigationController.viewControllers.first as! JournalsViewController // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
                // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
                self.dismiss(animated: true, completion: {
                    [presentingViewController] () -> Void in
                    // 編集を終了する
                    presentingViewController.setEditing(false, animated: true)
                    presentingViewController.dBJournalEntry = dBJournalEntry
                    presentingViewController.updateSelectedJournalEntries()
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (action: UIAlertAction!) in
                print("Cancel アクションをタップした時の処理")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // 決算整理仕訳　の処理
    func buttonTappedForAdjustingAndClosingEntries() {
        // データベース　仕訳データを追加
        let dataBaseManager = DataBaseManagerJournalEntry()
        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
        var number = 0
        number = dataBaseManager.addAdjustingJournalEntry(
            date: dateFormatter.string(from: datePicker.date),
            debit_category: TextField_category_debit.text!,
            debit_amount: Int64(StringUtility.shared.removeComma(string: TextField_amount_debit.text!))!, //カンマを削除してからデータベースに書き込む
            credit_category: TextField_category_credit.text!,
            credit_amount: Int64(StringUtility.shared.removeComma(string: TextField_amount_credit.text!))!,//カンマを削除してからデータベースに書き込む
            smallWritting: TextField_SmallWritting.text!
        )
        // 精算表画面から入力の場合
        if let tabBarController = self.presentingViewController as? UITabBarController { // 一番基底となっているコントローラ
            let navigationController = tabBarController.selectedViewController as! UINavigationController // 基底のコントローラから、現在選択されているコントローラを取得する
            let presentingViewController = navigationController.viewControllers[1] as! WSViewController // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
            // viewWillAppearを呼び出す　更新のため
            self.dismiss(animated: true, completion: {
                [presentingViewController] () -> Void in
                presentingViewController.reloadData()
            })
        }
        // タブバーの仕訳タブから入力の場合
        else {
            let alert = UIAlertController(title: "仕訳", message: "記帳しました", preferredStyle: .alert)
            self.present(alert, animated: true) { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.dismiss(animated: true, completion: {
                        [self] () -> Void in
                        self.showAd()
                    })
                }
            }
        }
    }
    
    // 仕訳編集　の処理
    func buttonTappedForJournalEntriesFixing() {
        // データベース　仕訳データを追加
        let dataBaseManager = DataBaseManagerJournalEntry()
        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
        var number = 0
        if tappedIndexPath.section == 1 { // 決算整理仕訳
            // データベースに書き込む
            dataBaseManager.updateAdjustingJournalEntry(
                primaryKey: primaryKey,
                date: dateFormatter.string(from: datePicker.date),
                debit_category: TextField_category_debit.text!,
                debit_amount: Int64(StringUtility.shared.removeComma(string: TextField_amount_debit.text!))!, //カンマを削除してからデータベースに書き込む
                credit_category: TextField_category_credit.text!,
                credit_amount: Int64(StringUtility.shared.removeComma(string: TextField_amount_credit.text!))!,//カンマを削除してからデータベースに書き込む
                smallWritting: TextField_SmallWritting.text!,
                completion: { primaryKey in
                    print("Result is \(primaryKey)")
                    number = primaryKey
                })
        }
        else { // 仕訳
            // データベースに書き込む
            dataBaseManager.updateJournalEntry(
                primaryKey: primaryKey,
                date: dateFormatter.string(from: datePicker.date),
                debit_category: TextField_category_debit.text!,
                debit_amount: Int64(StringUtility.shared.removeComma(string: TextField_amount_debit.text!))!, //カンマを削除してからデータベースに書き込む
                credit_category: TextField_category_credit.text!,
                credit_amount: Int64(StringUtility.shared.removeComma(string: TextField_amount_credit.text!))!,//カンマを削除してからデータベースに書き込む
                smallWritting: TextField_SmallWritting.text!,
                completion: { primaryKey in
                    print("Result is \(primaryKey)")
                    number = primaryKey
                })
        }
        let tabBarController = self.presentingViewController as! UITabBarController // 一番基底となっているコントローラ
        let navigationController = tabBarController.selectedViewController as! UINavigationController // 基底のコントローラから、現在選択されているコントローラを取得する
        let presentingViewController = navigationController.viewControllers[0] as! JournalsViewController // ナビゲーションバーコントローラの配下にある最初のビューコントローラーを取得
        // TableViewControllerJournalEntryのviewWillAppearを呼び出す　更新のため
        self.dismiss(animated: true, completion: {
            [presentingViewController] () -> Void in
            presentingViewController.autoScrollToCell(number: number, tappedIndexPathSection: self.tappedIndexPath.section)
        })
    }
    
    // 仕訳　の処理
    func buttonTappedForJournalEntries() {
        // データベース　仕訳データを追加
        let dataBaseManager = DataBaseManagerJournalEntry()
        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
        var number = 0
        number = dataBaseManager.addJournalEntry(
            date: dateFormatter.string(from: datePicker.date),
            debit_category: TextField_category_debit.text!,
            debit_amount: Int64(StringUtility.shared.removeComma(string: TextField_amount_debit.text!))!, //カンマを削除してからデータベースに書き込む
            credit_category: TextField_category_credit.text!,
            credit_amount: Int64(StringUtility.shared.removeComma(string: TextField_amount_credit.text!))!,//カンマを削除してからデータベースに書き込む
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
            presentingViewController.autoScrollToCell(number: number, tappedIndexPathSection: 0) // 0:通常仕訳
        })
    }
    
    // タブバーの仕訳タブからの遷移の場合
    func buttonTappedForJournalEntriesOnTabBar() {
        // データベース　仕訳データを追加
        let dataBaseManager = DataBaseManagerJournalEntry()
        // Int型は数字以外の文字列が入っていると例外発生する　入力チェックで弾く
        var number = 0
        number = dataBaseManager.addJournalEntry(
            date: dateFormatter.string(from: datePicker.date),
            debit_category: TextField_category_debit.text!,
            debit_amount: Int64(StringUtility.shared.removeComma(string: TextField_amount_debit.text!))!, //カンマを削除してからデータベースに書き込む
            credit_category: TextField_category_credit.text!,
            credit_amount: Int64(StringUtility.shared.removeComma(string: TextField_amount_credit.text!))!,//カンマを削除してからデータベースに書き込む
            smallWritting: TextField_SmallWritting.text!
        )
        let alert = UIAlertController(title: "仕訳", message: "記帳しました", preferredStyle: .alert)
        self.present(alert, animated: true) { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true, completion: {
                    [self] () -> Void in
                    self.showAd()
                })
            }
        }
    }
    // 入力チェック　バリデーション
    func textInputCheck() -> Bool {
        
        if TextField_category_debit.text != "" && TextField_category_debit.text != "" {
            if TextField_category_credit.text != "" && TextField_category_credit.text != "" {
                if TextField_amount_debit.text != "" && TextField_amount_debit.text != "" && TextField_amount_debit.text != "0" {
                    if TextField_amount_credit.text != "" && TextField_amount_credit.text != "" && TextField_amount_credit.text != "0" {
                        if TextField_SmallWritting.text == "" {
                            TextField_SmallWritting.text = ""
                        }
                        return true // OK
                    }
                    else {
                        let alert = UIAlertController(title: "金額", message: "入力してください", preferredStyle: .alert)
                        self.present(alert, animated: true) { () -> Void in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.dismiss(animated: true, completion: nil)
                                //未入力のTextFieldのキーボードを自動的に表示する
                                self.TextField_amount_credit.becomeFirstResponder()
                            }
                        }
                        return false // NG
                    }
                }
                else {
                    let alert = UIAlertController(title: "金額", message: "入力してください", preferredStyle: .alert)
                    self.present(alert, animated: true) { () -> Void in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.dismiss(animated: true, completion: nil)
                            //未入力のTextFieldのキーボードを自動的に表示する
                            self.TextField_amount_debit.becomeFirstResponder()
                        }
                    }
                    return false // NG
                }
            }
            else {
                let alert = UIAlertController(title: "貸方勘定科目", message: "入力してください", preferredStyle: .alert)
                self.present(alert, animated: true) { () -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.dismiss(animated: true, completion: nil)
                        //未入力のTextFieldのキーボードを自動的に表示する
                        self.TextField_category_credit.becomeFirstResponder()
                    }
                }
                return false // NG
            }
        }
        else {
            let alert = UIAlertController(title: "借方勘定科目", message: "入力してください", preferredStyle: .alert)
            self.present(alert, animated: true) { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.dismiss(animated: true, completion: nil)
                    //未入力のTextFieldのキーボードを自動的に表示する
                    self.TextField_category_debit.becomeFirstResponder()
                }
            }
            return false // NG
        }
    }
    // インタースティシャル広告を表示　マネタイズ対応
    func showAd() {
        // アップグレード機能　スタンダードプラン
        if !UpgradeManager.shared.inAppPurchaseFlag {
            
            var iValue = 0
            // 仕訳が50件以上入力済みの場合は毎回広告を表示する　マネタイズ対応
            let dataBaseManagerJournalEntry = DataBaseManagerJournalEntry()
            let results = dataBaseManagerJournalEntry.getJournalEntryCount()
            if results.count <= 10 {
                // 仕訳10件以下　広告を表示しない
                iValue = 1
            }
            else if results.count <= 50 {
                // 乱数　1から6までのIntを生成
                iValue = Int.random(in: 1 ... 6)
            }
            if iValue % 2 == 0 {
                if interstitial != nil {
                    interstitial?.present(fromRootViewController: self)
                }
                else {
                    print("Ad wasn't ready")
                    // セットアップ AdMob
                    setupAdMob()
                }
            }
        }
    }
    
    // MARK: UIButton
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
    }
}

// MARK: - UICollectionViewDelegate

extension JournalEntryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //collectionViewの要素の数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // データベース　よく使う仕訳を追加
        let dataBaseManager = DataBaseManagerSettingsOperatingJournalEntry()
        let objects = dataBaseManager.getJournalEntry()
        return objects.count
    }
    //collectionViewのセルを返す（セルの内容を決める）
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CarouselCollectionViewCell
        // データベース　よく使う仕訳を追加
        let dataBaseManager = DataBaseManagerSettingsOperatingJournalEntry()
        let objects = dataBaseManager.getJournalEntry()
        cell.nicknameLabel.text = objects[indexPath.row].nickname
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
        // データベース　よく使う仕訳を追加
        let dataBaseManager = DataBaseManagerSettingsOperatingJournalEntry()
        let objects = dataBaseManager.getJournalEntry()
        TextField_category_debit.text = objects[indexPath.row].debit_category
        TextField_amount_debit.text = StringUtility.shared.addComma(string: String(objects[indexPath.row].debit_amount))
        TextField_category_credit.text = objects[indexPath.row].credit_category
        TextField_amount_credit.text = StringUtility.shared.addComma(string: String(objects[indexPath.row].credit_amount))
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
    
    // テキストフィールがタップされ、入力可能になったあと
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // フォーカス　効果　ドロップシャドウをかける
        textField.layer.shadowOpacity = 1.4
        textField.layer.shadowRadius = 4
        textField.layer.shadowColor = UIColor.CalculatorDisplay.cgColor
        textField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)

        // 借方金額　貸方金額
        if textField == TextField_amount_debit || textField == TextField_amount_credit {
            self.view.endEditing(true)
        }
    }
    // 文字クリア
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //todo
        if textField.text == "" {
            return true
        }
        else {
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
        }
        else {  // 小書き　ニックネーム
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
        }
        else if !resultForLength { // 最大文字数以上ならfalseを返す
            return false
        }
        else {
            return true
        }
    }
    //キーボードを閉じる前
    func textFieldShouldEndEditing(_ textField:UITextField) -> Bool {
//        print(#function)
//        print("キーボードを閉じる前")
        return true
    }
    //キーボードを閉じたあと
    func textFieldDidEndEditing(_ textField:UITextField) {
//        print(#function)
//        print("キーボードを閉じた後")
        // フォーカス　効果　フォーカスが外れたら色を消す
        textField.layer.shadowColor = UIColor.clear.cgColor

        //Segueを場合分け
        if textField.tag == 111 {
            if TextField_category_debit.text == "" {
            }
            else if TextField_category_credit.text == TextField_category_debit.text { // 貸方と同じ勘定科目の場合
                TextField_category_debit.text = ""
            }
            else {
                if journalEntryType != "JournalEntriesPackageFixing" { // 仕訳一括編集ではない場合
                    if TextField_category_credit.text == "" {
                        TextField_category_credit.becomeFirstResponder()
                    }
                }
            }
        }
        else if textField.tag == 222 {
            if TextField_category_credit.text == "" {
            }
            else if TextField_category_credit.text == TextField_category_debit.text { // 借方と同じ勘定科目の場合
                TextField_category_credit.text = ""
            }
            else {
                // TextField_amount_credit.becomeFirstResponder() //貸方金額は不使用のため
                if journalEntryType != "JournalEntriesPackageFixing" { // 仕訳一括編集ではない場合
                    if TextField_amount_debit.text == "" {
                        TextField_amount_debit.becomeFirstResponder() // カーソルを金額へ移す
                    }
                }
            }
        }
    }
    // TextFieldに入力され値が変化した時の処理の関数
    @objc func textFieldDidChange(_ sender: UITextField) {
//    func textFieldEditingChanged(_ sender: UITextField){
        if sender.text != "" {
            // カンマを追加する
            if sender == TextField_amount_debit || sender == TextField_amount_credit { // 借方金額仮　貸方金額
                sender.text = "\(StringUtility.shared.addComma(string: String(sender.text!)))"
            }
            print("\(String(describing: sender.text))") // カンマを追加する前にシスアウトすると、カンマが上位のくらいから3桁ごとに自動的に追加される。
        }
    }
    
}
