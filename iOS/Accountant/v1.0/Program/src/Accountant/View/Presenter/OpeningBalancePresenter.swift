//
//  OpeningBalancePresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol OpeningBalancePresenterInput {
    
    var company: String? { get }
    var fiscalYear: Int? { get }
    var theDayOfBeginningOfYear: String? { get }
    var fiscalYearOpening: Int? { get }
    
    func objects(category: String) -> DataBaseSettingTransferEntry?
    
    func numberOfsections() -> Int
    func numberOfobjects(section: Int) -> Int
    func objects(forRow row: Int, section: Int) -> DataBaseSettingsTaxonomyAccount
    
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    
    func debit_balance_total() -> String
    func credit_balance_total() -> String
    
    func setAmountValue(primaryKey: Int, numbersOnDisplay: Int, category: String, debitOrCredit: DebitOrCredit)
    func refreshTable()
}

protocol OpeningBalancePresenterOutput: AnyObject {
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
    func finishLoading()
}

final class OpeningBalancePresenter: OpeningBalancePresenterInput {
    
    // MARK: - var let
    
    var company: String?
    var fiscalYear: Int?
    var theDayOfBeginningOfYear: String?
    // 開いている帳簿の年度の取得　会計帳簿
    var fiscalYearOpening: Int?
    // 設定残高振替仕訳 開始残高
    private var dataBaseTransferEntries: Results<DataBaseSettingTransferEntry>
    // 設定勘定科目 貸借科目
    private var objects0: Results<DataBaseSettingsTaxonomyAccount>
    private var objects1: Results<DataBaseSettingsTaxonomyAccount>
    private var objects2: Results<DataBaseSettingsTaxonomyAccount>
    private var objects3: Results<DataBaseSettingsTaxonomyAccount>
    private var objects4: Results<DataBaseSettingsTaxonomyAccount>
    private var objects5: Results<DataBaseSettingsTaxonomyAccount>
    private var objects6: Results<DataBaseSettingsTaxonomyAccount>
    private var objects7: Results<DataBaseSettingsTaxonomyAccount>
    private var objects8: Results<DataBaseSettingsTaxonomyAccount>
    private var objects9: Results<DataBaseSettingsTaxonomyAccount>
    private var objects10: Results<DataBaseSettingsTaxonomyAccount>
    private var objects11: Results<DataBaseSettingsTaxonomyAccount>
    private var objects12: Results<DataBaseSettingsTaxonomyAccount>
    private var objects13: Results<DataBaseSettingsTaxonomyAccount>
    
    private weak var view: OpeningBalancePresenterOutput!
    private var model: OpeningBalanceModelInput
    
    init(view: OpeningBalancePresenterOutput, model: OpeningBalanceModelInput) {
        self.view = view
        self.model = model
        // 開始残高　残高振替仕訳をつくる
        model.createOpeningBalance()
        // 設定残高振替仕訳 開始残高
        dataBaseTransferEntries = model.getDataBaseTransferEntries()
        
        objects0 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 0, rank1: 0)
        objects1 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 0, rank1: 1)
        objects2 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 0, rank1: 2)
        
        objects3 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 1, rank1: 3)
        objects4 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 1, rank1: 4)
        objects5 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 1, rank1: 5)
        
        objects6 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 2, rank1: 6)
        
        objects7 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 3, rank1: 7)
        objects8 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 3, rank1: 8)
        
        objects9 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 4, rank1: 9)
        
        objects10 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 5, rank1: 10)
        objects11 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 5, rank1: 11)
        objects12 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 5, rank1: 12)
        objects13 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 5, rank1: 19)
    }
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        
        company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        // 一番古い会計帳簿の年度の期首　とする
        fiscalYear = DataBaseManagerSettingsPeriod.shared.getOldestPeriodYear()
        theDayOfBeginningOfYear = DateManager.shared.getTheDayOfBeginningOfYear()
        // 開いている帳簿の年度の取得　会計帳簿
        fiscalYearOpening = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        // 再計算 合計額を計算
        model.calculateAccountTotalAccount()
        
        view.setupViewForViewWillAppear()
    }
    
    func viewWillDisappear() {
        
        view.setupViewForViewWillDisappear()
    }
    
    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }
    
    func objects(category: String) -> DataBaseSettingTransferEntry? {
        dataBaseTransferEntries.filter({ $0.debit_category == category || $0.credit_category == category }).first
    }
    
    func numberOfsections() -> Int {
        14
    }
    
    func numberOfobjects(section: Int) -> Int {
        switch section {
            //     "流動資産"
        case 0: return objects0.count
        case 1: return objects1.count
        case 2: return objects2.count
            //     "固定資産"
        case 3: return objects3.count
        case 4: return objects4.count
        case 5: return objects5.count
            //     "繰延資産"
        case 6: return objects6.count
            //     "流動負債"
        case 7: return objects7.count
        case 8: return objects8.count
            //     "固定負債"
        case 9: return objects9.count
            //     "資本"
        case 10: return objects10.count
        case 11: return objects11.count
        case 12: return objects12.count
        case 13: return objects13.count
        default: //    ""
            return objects13.count
        }
    }
    
    func objects(forRow row: Int, section: Int) -> DataBaseSettingsTaxonomyAccount {
        switch section {
            //     "流動資産"
        case 0: return objects0[row]
        case 1: return objects1[row]
        case 2: return objects2[row]
            //     "固定資産"
        case 3: return objects3[row]
        case 4: return objects4[row]
        case 5: return objects5[row]
            //     "繰延資産"
        case 6: return objects6[row]
            //     "流動負債"
        case 7: return objects7[row]
        case 8: return objects8[row]
            //     "固定負債"
        case 9: return objects9[row]
            //     "資本"
        case 10: return objects10[row]
        case 11: return objects11[row]
        case 12: return objects12[row]
        case 13: return objects13[row]
        default: //    ""
            return objects13[row]
        }
    }
    
    // 借方　残高　集計
    func debit_balance_total() -> String {
        StringUtility.shared.setComma(amount: model.getTotalAmount(leftOrRight: 0))
    }
    // 貸方　残高　集計
    func credit_balance_total() -> String {
        StringUtility.shared.setComma(amount: model.getTotalAmount(leftOrRight: 1))
    }
    
    func setAmountValue(primaryKey: Int, numbersOnDisplay: Int, category: String, debitOrCredit: DebitOrCredit) {
        model.setAmountValue(primaryKey: primaryKey, numbersOnDisplay: numbersOnDisplay, category: category, debitOrCredit: debitOrCredit)
        // 再計算 合計額を計算
        model.calculateAccountTotalAccount()
        // 更新処理
        view.reloadData()
    }
    
    func refreshTable() {
        // FIXME: 最も古い年度の帳簿を対象にする
        // 全勘定の合計と残高を計算する
        model.initializeJournals(completion: { isFinished in
            print("Result is \(isFinished)")
            // 編集を終了する
            view.reloadData()
            // ローディング終了
            view.finishLoading()
        })
    }
}
