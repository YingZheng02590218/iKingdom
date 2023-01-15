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
    var theDayOfReckoning: String? { get }

    var numberOfobjects: Int { get }

    func objects(forRow row: Int) -> SettingDataBaseTransferEntry

    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()

    func debit_balance_total() -> String
    func credit_balance_total() -> String

    func setAmountValue(primaryKey: Int, numbersOnDisplay: Int, category: String, debitOrCredit: DebitOrCredit)
}

protocol OpeningBalancePresenterOutput: AnyObject {
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
}

final class OpeningBalancePresenter: OpeningBalancePresenterInput {

    // MARK: - var let

    var company: String?
    var fiscalYear: Int?
    var theDayOfReckoning: String?
    // 設定残高振替仕訳 開始残高
    private var dataBaseTransferEntries: Results<SettingDataBaseTransferEntry>

    private weak var view: OpeningBalancePresenterOutput!
    private var model: OpeningBalanceModelInput

    init(view: OpeningBalancePresenterOutput, model: OpeningBalanceModelInput) {
        self.view = view
        self.model = model
        // 開始残高　残高振替仕訳をつくる
        model.createOpeningBalance()
        // 設定残高振替仕訳 開始残高
        dataBaseTransferEntries = model.getDataBaseTransferEntries()
    }

    // MARK: - Life cycle

    func viewDidLoad() {

        view.setupViewForViewDidLoad()
    }

    func viewWillAppear() {

        company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
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

    var numberOfobjects: Int {
        dataBaseTransferEntries.count
    }

    func objects(forRow row: Int) -> SettingDataBaseTransferEntry {
        dataBaseTransferEntries[row]
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
}
