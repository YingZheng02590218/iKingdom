//
//  JournalsPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/02/01.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol JournalsPresenterInput {
    
    var company: String? { get }
    var fiscalYear: Int? { get }
    var theDayOfReckoning: String? { get }
    
    var numberOfobjects: Int { get }
    func numberOfDatabaseJournalEntries(forSection: Int) -> Int
    var numberOfobjectsss: Int { get }
    var numberOfobjectsOut: Int { get }

    func objects(forRow row: Int) -> DataBaseJournalEntry
    func databaseJournalEntries(forSection: Int, forRow row: Int) -> DataBaseJournalEntry?
    func objectsss(forRow row: Int) -> DataBaseAdjustingEntry
    func objectsOut(forRow row: Int) -> DataBaseJournalEntry?

    var filePath: URL? { get }
    
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    
    func refreshTable(isEditing: Bool)
    func cellLongPressed()
    func pdfBarButtonItemTapped(yearMonth: String?)
    func csvBarButtonItemTapped(yearMonth: String?)
    func deleteJournalEntry(number: Int) -> Bool
    func deleteAdjustingJournalEntry(number: Int) -> Bool
    func updateFiscalYear(indexPaths: [IndexPath], fiscalYear: Int)
    func updateSelectedJournalEntries(indexPaths: [IndexPath], dBJournalEntry: JournalEntryData)
    func autoScroll(number: Int, tappedIndexPathSection: Int)
}

protocol JournalsPresenterOutput: AnyObject {
    func showActivityIndicatorView()
    func finishActivityIndicatorView()
    func reloadData(primaryKeys: [Int]?, primaryKeysAdjusting: [Int]?)
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
    func setupCellLongPressed()
    func autoScroll(number: Int, tappedIndexPathSection: Int)
    func showPreview()
}

final class JournalsPresenter: JournalsPresenterInput {
    
    // MARK: - var let
    
    var company: String?
    var fiscalYear: Int?
    var theDayOfReckoning: String?
    // 通常仕訳　全
    private var objects: Results<DataBaseJournalEntry>
    // 通常仕訳 勘定別に月別に取得
    private var databaseJournalEntriesSection0: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection1: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection2: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection3: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection4: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection5: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection6: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection7: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection8: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection9: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection10: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection11: Results<DataBaseJournalEntry>?
    private var databaseJournalEntriesSection12: Results<DataBaseJournalEntry>?
    // 決算整理仕訳
    private var objectsss: Results<DataBaseAdjustingEntry>
    
    // PDF,CSVファイルのパス
    var filePath: URL?
    let sectionOfJournalEntryOut = 14

    private weak var view: JournalsPresenterOutput!
    private var model: JournalsModelInput
    
    init(view: JournalsPresenterOutput, model: JournalsModelInput) {
        self.view = view
        self.model = model
        
        // 通常仕訳　全
        objects = model.getJournalEntriesInJournals(yearMonth: nil)
        // 月別の月末日を取得 12ヶ月分
        let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
        for i in 0..<lastDays.count {
            // 通常仕訳 月別に取得
            let dataBaseJournalEntries = model.getJournalEntriesInJournals(
                yearMonth: "\(lastDays[i].year)" + "/" + "\(String(format: "%02d", lastDays[i].month))"
            )
            switch i {
            case 0:
                databaseJournalEntriesSection0 = dataBaseJournalEntries
            case 1:
                databaseJournalEntriesSection1 = dataBaseJournalEntries
            case 2:
                databaseJournalEntriesSection2 = dataBaseJournalEntries
            case 3:
                databaseJournalEntriesSection3 = dataBaseJournalEntries
            case 4:
                databaseJournalEntriesSection4 = dataBaseJournalEntries
            case 5:
                databaseJournalEntriesSection5 = dataBaseJournalEntries
            case 6:
                databaseJournalEntriesSection6 = dataBaseJournalEntries
            case 7:
                databaseJournalEntriesSection7 = dataBaseJournalEntries
            case 8:
                databaseJournalEntriesSection8 = dataBaseJournalEntries
            case 9:
                databaseJournalEntriesSection9 = dataBaseJournalEntries
            case 10:
                databaseJournalEntriesSection10 = dataBaseJournalEntries
            case 11:
                databaseJournalEntriesSection11 = dataBaseJournalEntries
            case 12:
                databaseJournalEntriesSection12 = dataBaseJournalEntries
            default:
                break
            }
        }
        // 決算整理仕訳
        objectsss = model.getJournalAdjustingEntry(yearMonth: nil)
    }
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        self.company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        self.fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        self.theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        DispatchQueue.main.async {
            // 会計年度を切り替えした場合、仕訳帳をリロードして選択された年度のデータを表示する
            // 通常仕訳　全
            self.objects = self.model.getJournalEntriesInJournals(yearMonth: nil)
            // 月別の月末日を取得 12ヶ月分
            let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
            for i in 0..<lastDays.count {
                // 通常仕訳 月別に取得
                let dataBaseJournalEntries = self.model.getJournalEntriesInJournals(
                    yearMonth: "\(lastDays[i].year)" + "/" + "\(String(format: "%02d", lastDays[i].month))"
                )
                switch i {
                case 0:
                    self.databaseJournalEntriesSection0 = dataBaseJournalEntries
                case 1:
                    self.databaseJournalEntriesSection1 = dataBaseJournalEntries
                case 2:
                    self.databaseJournalEntriesSection2 = dataBaseJournalEntries
                case 3:
                    self.databaseJournalEntriesSection3 = dataBaseJournalEntries
                case 4:
                    self.databaseJournalEntriesSection4 = dataBaseJournalEntries
                case 5:
                    self.databaseJournalEntriesSection5 = dataBaseJournalEntries
                case 6:
                    self.databaseJournalEntriesSection6 = dataBaseJournalEntries
                case 7:
                    self.databaseJournalEntriesSection7 = dataBaseJournalEntries
                case 8:
                    self.databaseJournalEntriesSection8 = dataBaseJournalEntries
                case 9:
                    self.databaseJournalEntriesSection9 = dataBaseJournalEntries
                case 10:
                    self.databaseJournalEntriesSection10 = dataBaseJournalEntries
                case 11:
                    self.databaseJournalEntriesSection11 = dataBaseJournalEntries
                case 12:
                    self.databaseJournalEntriesSection12 = dataBaseJournalEntries
                default:
                    break
                }
            }
            // 決算整理仕訳
            self.objectsss = self.model.getJournalAdjustingEntry(yearMonth: nil)
        }
        self.view.setupViewForViewWillAppear()
    }
    
    func viewWillDisappear() {
        
        view.setupViewForViewWillDisappear()
    }
    
    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }
    
    var numberOfobjects: Int {
        objects.count
    }
    
    func objects(forRow row: Int) -> DataBaseJournalEntry {
        objects[row]
    }
  
    // 通常仕訳　月次残高
    func numberOfDatabaseJournalEntries(forSection: Int) -> Int {
        switch forSection {
            // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
        case 0:
            return databaseJournalEntriesSection0?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        case 1:
            return databaseJournalEntriesSection1?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        case 2:
            return databaseJournalEntriesSection2?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        case 3:
            return databaseJournalEntriesSection3?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        case 4:
            return databaseJournalEntriesSection4?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        case 5:
            return databaseJournalEntriesSection5?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        case 6:
            return databaseJournalEntriesSection6?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        case 7:
            return databaseJournalEntriesSection7?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        case 8:
            return databaseJournalEntriesSection8?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        case 9:
            return databaseJournalEntriesSection9?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        case 10:
            return databaseJournalEntriesSection10?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        case 11:
            return databaseJournalEntriesSection11?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        case 12:
            return databaseJournalEntriesSection12?.filter({ DateManager.shared.isInPeriod(date: $0.date) }).count ?? 0
        default:
            return 0
        }
    }
    // 通常仕訳　月次残高
    func databaseJournalEntries(forSection: Int, forRow row: Int) -> DataBaseJournalEntry? {
        switch forSection {
            // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
        case 0:
            return databaseJournalEntriesSection0?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        case 1:
            return databaseJournalEntriesSection1?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        case 2:
            return databaseJournalEntriesSection2?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        case 3:
            return databaseJournalEntriesSection3?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        case 4:
            return databaseJournalEntriesSection4?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        case 5:
            return databaseJournalEntriesSection5?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        case 6:
            return databaseJournalEntriesSection6?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        case 7:
            return databaseJournalEntriesSection7?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        case 8:
            return databaseJournalEntriesSection8?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        case 9:
            return databaseJournalEntriesSection9?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        case 10:
            return databaseJournalEntriesSection10?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        case 11:
            return databaseJournalEntriesSection11?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        case 12:
            return databaseJournalEntriesSection12?.filter({ DateManager.shared.isInPeriod(date: $0.date) })[row]
        default:
            return nil
        }
    }

    var numberOfobjectsss: Int {
        objectsss.count
    }
    
    func objectsss(forRow row: Int) -> DataBaseAdjustingEntry {
        objectsss[row]
    }
    // 会計期間外の仕訳
    var numberOfobjectsOut: Int {
        // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
        objects.filter({ !DateManager.shared.isInPeriod(date: $0.date) }).count
    }
    // 会計期間外の仕訳
    func objectsOut(forRow row: Int) -> DataBaseJournalEntry? {
        // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
        objects.filter({ !DateManager.shared.isInPeriod(date: $0.date) })[safe: row]
    }
    
    func refreshTable(isEditing: Bool) {
        if !isEditing {
            // インジゲーターを開始
            view.showActivityIndicatorView()
            DispatchQueue.global(qos: .default).async {
                // 全勘定の合計と残高を計算する
                self.model.initializeJournals(completion: { isFinished in
                    print("Result is \(isFinished)")
                    // 重要: 仕訳データを参照する際、メインスレッドで行う
                    DispatchQueue.main.async {
                        // 通常仕訳　全
                        self.objects = self.model.getJournalEntriesInJournals(yearMonth: nil)
                        // 月別の月末日を取得 12ヶ月分
                        let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
                        for i in 0..<lastDays.count {
                            // 通常仕訳 月別に取得
                            let dataBaseJournalEntries = self.model.getJournalEntriesInJournals(
                                yearMonth: "\(lastDays[i].year)" + "/" + "\(String(format: "%02d", lastDays[i].month))"
                            )
                            switch i {
                            case 0:
                                self.databaseJournalEntriesSection0 = dataBaseJournalEntries
                            case 1:
                                self.databaseJournalEntriesSection1 = dataBaseJournalEntries
                            case 2:
                                self.databaseJournalEntriesSection2 = dataBaseJournalEntries
                            case 3:
                                self.databaseJournalEntriesSection3 = dataBaseJournalEntries
                            case 4:
                                self.databaseJournalEntriesSection4 = dataBaseJournalEntries
                            case 5:
                                self.databaseJournalEntriesSection5 = dataBaseJournalEntries
                            case 6:
                                self.databaseJournalEntriesSection6 = dataBaseJournalEntries
                            case 7:
                                self.databaseJournalEntriesSection7 = dataBaseJournalEntries
                            case 8:
                                self.databaseJournalEntriesSection8 = dataBaseJournalEntries
                            case 9:
                                self.databaseJournalEntriesSection9 = dataBaseJournalEntries
                            case 10:
                                self.databaseJournalEntriesSection10 = dataBaseJournalEntries
                            case 11:
                                self.databaseJournalEntriesSection11 = dataBaseJournalEntries
                            case 12:
                                self.databaseJournalEntriesSection12 = dataBaseJournalEntries
                            default:
                                break
                            }
                        }
                        // 決算整理仕訳
                        self.objectsss = self.model.getJournalAdjustingEntry(yearMonth: nil)
                        // 更新処理
                        self.view.reloadData(primaryKeys: nil, primaryKeysAdjusting: nil)
                        // インジケーターを終了
                        self.view.finishActivityIndicatorView()
                        // 月次推移表を更新する　true: リロードする
                        Constant.needToReload = true
                    }
                })
            }
        } else {
            // 更新処理
            view.reloadData()
        }
    }
    
    func cellLongPressed() {
        
        view.setupCellLongPressed()
    }
    // 印刷機能
    func pdfBarButtonItemTapped(yearMonth: String? = nil) {
        // 初期化 PDFメーカー
        model.initializePdfMaker(yearMonth: yearMonth, completion: { filePath in
            
            self.filePath = filePath
            self.view.showPreview()
        })
    }
    
    // CSV機能
    func csvBarButtonItemTapped(yearMonth: String? = nil) {
        // 初期化
        model.initializeCsvMaker(yearMonth: yearMonth, completion: { csvPath in
            
            self.filePath = csvPath
            self.view.showPreview()
        })
    }
    
    func autoScroll(number: Int, tappedIndexPathSection: Int) {
        DispatchQueue.main.async {
            // 通常仕訳　全
            self.objects = self.model.getJournalEntriesInJournals(yearMonth: nil)
            // 会計期間外の仕訳
            var fixedTappedIndexPathSection: Int = tappedIndexPathSection
            // 月別の月末日を取得 12ヶ月分
            let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
            for i in 0..<lastDays.count {
                // 通常仕訳 月別に取得
                let dataBaseJournalEntries = self.model.getJournalEntriesInJournals(
                    yearMonth: "\(lastDays[i].year)" + "/" + "\(String(format: "%02d", lastDays[i].month))"
                )
                switch i {
                case 0:
                    self.databaseJournalEntriesSection0 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 0
                case 1:
                    self.databaseJournalEntriesSection1 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 1
                case 2:
                    self.databaseJournalEntriesSection2 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 2
                case 3:
                    self.databaseJournalEntriesSection3 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 3
                case 4:
                    self.databaseJournalEntriesSection4 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 4
                case 5:
                    self.databaseJournalEntriesSection5 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 5
                case 6:
                    self.databaseJournalEntriesSection6 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 6
                case 7:
                    self.databaseJournalEntriesSection7 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 7
                case 8:
                    self.databaseJournalEntriesSection8 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 8
                case 9:
                    self.databaseJournalEntriesSection9 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 9
                case 10:
                    self.databaseJournalEntriesSection10 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 10
                case 11:
                    self.databaseJournalEntriesSection11 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 11
                case 12:
                    self.databaseJournalEntriesSection12 = dataBaseJournalEntries
                    // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                    fixedTappedIndexPathSection = dataBaseJournalEntries.filter({ DateManager.shared.isInPeriod(date: $0.date) })
                        .filter({ number == $0.number })
                        .isEmpty ? fixedTappedIndexPathSection : 12
                default:
                    break
                }
            }
            // 決算整理仕訳
            self.objectsss = self.model.getJournalAdjustingEntry(yearMonth: nil)
            // 会計期間外の仕訳 から　通常仕訳　へ変わった場合に対応する。その逆もしかり。
            if tappedIndexPathSection != 13 { // 決算整理仕訳　以外
                // 会計期間外の仕訳　仕訳の年度が、帳簿の年度とあっているかを判定する
                fixedTappedIndexPathSection = self.objects.filter({ !DateManager.shared.isInPeriod(date: $0.date) })
                    .filter({ number == $0.number })
                    .isEmpty ? fixedTappedIndexPathSection : self.sectionOfJournalEntryOut
            } else {
                // 決算整理仕訳
                fixedTappedIndexPathSection = tappedIndexPathSection
            }
            // オートスクロール
            self.view.autoScroll(number: number, tappedIndexPathSection: fixedTappedIndexPathSection)
        }
    }
    // 削除　仕訳
    func deleteJournalEntry(number: Int) -> Bool {
        // 月次推移表を更新する　true: リロードする
        Constant.needToReload = true
        return DataBaseManagerJournalEntry.shared.deleteJournalEntry(number: number)
    }
    // 削除　決算整理仕訳
    func deleteAdjustingJournalEntry(number: Int) -> Bool {
        // 月次推移表を更新する　true: リロードする
        Constant.needToReload = true
        return DataBaseManagerAdjustingEntry.shared.deleteAdjustingJournalEntry(number: number)
    }
    // 年度を変更する
    func updateFiscalYear(indexPaths: [IndexPath], fiscalYear: Int) {
        // 一括変更の処理
        var numbers: [Int] = []
        var numbersAdjusting: [Int] = []
        
        for indexPath in indexPaths {
            if indexPath.section != 13 && indexPath.section != sectionOfJournalEntryOut && indexPath.section != 15 {
                if let object = self.databaseJournalEntries(forSection: indexPath.section, forRow: indexPath.row) {
                    // 仕訳の連番を保持
                    numbers.append(object.number)
                }
            } else if indexPath.section == 13 {
                // 決算整理仕訳の連番を保持
                numbersAdjusting.append(self.objectsss(forRow: indexPath.row).number)
            } else if indexPath.section == self.sectionOfJournalEntryOut {
                if let object = self.objectsOut(forRow: indexPath.row) {
                    // 会計期間外の仕訳の連番を保持
                    numbers.append(object.number)
                }
            } else {
                // 空白行
            }
        }
        for number in numbers {
            // 仕訳データを更新
            _ = model.updateJournalEntry(
                primaryKey: number,
                fiscalYear: fiscalYear
            )
        }
        for number in numbersAdjusting {
            // 決算整理仕訳データを更新
            _ = model.updateAdjustingJournalEntry(
                primaryKey: number,
                fiscalYear: fiscalYear
            )
        }
        // view にリロードさせる
        self.view.reloadData(primaryKeys: nil, primaryKeysAdjusting: nil)
        // 月次推移表を更新する　true: リロードする
        Constant.needToReload = true
    }
    // 仕訳データを編集した通りに更新する
    func updateSelectedJournalEntries(indexPaths: [IndexPath], dBJournalEntry: JournalEntryData) {
        // インジゲーターを開始
        view.showActivityIndicatorView()
        
        var numbers: [Int] = []
        var numbersAdjusting: [Int] = []
        for indexPath in indexPaths {
            if indexPath.section != 13 && indexPath.section != sectionOfJournalEntryOut && indexPath.section != 15 {
                if let object = self.databaseJournalEntries(forSection: indexPath.section, forRow: indexPath.row) {
                    // 仕訳の連番を保持
                    numbers.append(object.number)
                }
            } else if indexPath.section == 13 {
                // 決算整理仕訳の連番を保持
                numbersAdjusting.append(self.objectsss(forRow: indexPath.row).number)
            } else if indexPath.section == self.sectionOfJournalEntryOut {
                if let object = self.objectsOut(forRow: indexPath.row) {
                    // 会計期間外の仕訳の連番を保持
                    numbers.append(object.number)
                }
            } else {
                // 空白行
            }
        }
        DispatchQueue.global(qos: .default).async {
            var primaryKeys: [Int] = []
            var primaryKeysAdjusting: [Int] = []
            // 一括変更の処理
            for number in numbers {
                // 仕訳データを更新
                self.model.updateJournalEntry(
                    primaryKey: number,
                    date: dBJournalEntry.date,
                    debitCategory: dBJournalEntry.debit_category,
                    debitAmount: dBJournalEntry.debit_amount,
                    creditCategory: dBJournalEntry.credit_category,
                    creditAmount: dBJournalEntry.credit_amount,
                    smallWritting: dBJournalEntry.smallWritting,
                    completion: { primaryKey in
                        print("Result is \(primaryKey)")
                        primaryKeys.append(primaryKey)
                    }
                )
            }
            for number in numbersAdjusting {
                // 決算整理仕訳データを更新
                _ = self.model.updateAdjustingJournalEntry(
                    primaryKey: number,
                    date: dBJournalEntry.date,
                    debitCategory: dBJournalEntry.debit_category,
                    debitAmount: dBJournalEntry.debit_amount,
                    creditCategory: dBJournalEntry.credit_category,
                    creditAmount: dBJournalEntry.credit_amount,
                    smallWritting: dBJournalEntry.smallWritting,
                    completion: { primaryKey in
                        print("Result is \(primaryKey)")
                        primaryKeysAdjusting.append(primaryKey)
                    }
                )
            }
            // 重要: 仕訳データを参照する際、メインスレッドで行う
            DispatchQueue.main.async {
                // 通常仕訳　全
                self.objects = self.model.getJournalEntriesInJournals(yearMonth: nil)
                // 月別の月末日を取得 12ヶ月分
                let lastDays = DateManager.shared.getTheDayOfEndingOfMonth()
                for i in 0..<lastDays.count {
                    // 通常仕訳 月別に取得
                    let dataBaseJournalEntries = self.model.getJournalEntriesInJournals(
                        yearMonth: "\(lastDays[i].year)" + "/" + "\(String(format: "%02d", lastDays[i].month))"
                    )
                    switch i {
                    case 0:
                        self.databaseJournalEntriesSection0 = dataBaseJournalEntries
                    case 1:
                        self.databaseJournalEntriesSection1 = dataBaseJournalEntries
                    case 2:
                        self.databaseJournalEntriesSection2 = dataBaseJournalEntries
                    case 3:
                        self.databaseJournalEntriesSection3 = dataBaseJournalEntries
                    case 4:
                        self.databaseJournalEntriesSection4 = dataBaseJournalEntries
                    case 5:
                        self.databaseJournalEntriesSection5 = dataBaseJournalEntries
                    case 6:
                        self.databaseJournalEntriesSection6 = dataBaseJournalEntries
                    case 7:
                        self.databaseJournalEntriesSection7 = dataBaseJournalEntries
                    case 8:
                        self.databaseJournalEntriesSection8 = dataBaseJournalEntries
                    case 9:
                        self.databaseJournalEntriesSection9 = dataBaseJournalEntries
                    case 10:
                        self.databaseJournalEntriesSection10 = dataBaseJournalEntries
                    case 11:
                        self.databaseJournalEntriesSection11 = dataBaseJournalEntries
                    case 12:
                        self.databaseJournalEntriesSection12 = dataBaseJournalEntries
                    default:
                        break
                    }
                }
                // 決算整理仕訳
                self.objectsss = self.model.getJournalAdjustingEntry(yearMonth: nil)
                // view にリロードさせる
                self.view.reloadData(primaryKeys: primaryKeys, primaryKeysAdjusting: primaryKeysAdjusting)
                // インジケーターを終了
                self.view.finishActivityIndicatorView()
                // 月次推移表を更新する　true: リロードする
                Constant.needToReload = true
            }
        }
    }
}
