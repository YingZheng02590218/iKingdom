//
//  PLPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/01/30.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol PLPresenterInput {

    var pLData: PLData { get }

    var PDFpath: [URL]? { get }

    func company() -> String
    func fiscalYear() -> Int
    func theDayOfReckoning() -> String
    
    var numberOfmidCategory10: Int { get }
    var numberOfmidCategory6: Int { get }
    var numberOfmidCategory11: Int { get }
    var numberOfmidCategory7: Int { get }
    var numberOfobjects9: Int { get }

    func midCategory10(forRow row: Int) -> DataBaseSettingsTaxonomy
    func midCategory6(forRow row: Int) -> DataBaseSettingsTaxonomy
    func mid_category11(forRow row: Int) -> DataBaseSettingsTaxonomy
    func mid_category7(forRow row: Int) -> DataBaseSettingsTaxonomy
    func objects9(forRow row: Int) -> DataBaseSettingsTaxonomy
    
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    
    func refreshTable()
    func pdfBarButtonItemTapped()

    func getTotalOfTaxonomy(numberOfSettingsTaxonomy: Int, lastYear: Bool) -> String  // 勘定別の合計　計算
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String
    func getBenefitTotal(benefit: Int, lastYear: Bool) -> String
    func checkSettingsPeriod() -> Bool
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String
}

protocol PLPresenterOutput: AnyObject {
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
    func showPreview()
}

final class PLPresenter: PLPresenterInput {

    // MARK: - var let
    
    // 損益計算書のデータ
    var pLData: PLData
    // PDFのパス
    var PDFpath: [URL]?
    
    private weak var view: PLPresenterOutput!
    private var model: PLModelInput
    
    init(view: PLPresenterOutput, model: PLModelInput) {
        self.view = view
        self.model = model
        
        // 損益計算書　初期化　再計算
        pLData = model.initializeBenefits()
    }
    
    // MARK: - Life cycle

    func viewDidLoad() {
        
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        
        view.setupViewForViewWillAppear()
    }

    func viewWillDisappear() {

        view.setupViewForViewWillDisappear()
    }
    
    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }

    func company() -> String {
        pLData.company
    }

    func fiscalYear() -> Int {
        pLData.fiscalYear
    }

    func theDayOfReckoning() -> String {
        pLData.theDayOfReckoning
    }
    
    var numberOfmidCategory10: Int {
        pLData.midCategory10.count
    }

    func midCategory10(forRow row: Int) -> DataBaseSettingsTaxonomy {
        pLData.midCategory10[row]
    }
    
    var numberOfmidCategory6: Int {
        pLData.midCategory6.count
    }

    func midCategory6(forRow row: Int) -> DataBaseSettingsTaxonomy {
        pLData.midCategory6[row]
    }
    
    var numberOfmidCategory11: Int {
        pLData.midCategory11.count
    }

    func mid_category11(forRow row: Int) -> DataBaseSettingsTaxonomy {
        pLData.midCategory11[row]
    }
    
    var numberOfmidCategory7: Int {
        pLData.midCategory7.count
    }

    func mid_category7(forRow row: Int) -> DataBaseSettingsTaxonomy {
        pLData.midCategory7[row]
    }
    
    var numberOfobjects9: Int {
        pLData.objects9.count
    }

    func objects9(forRow row: Int) -> DataBaseSettingsTaxonomy {
        pLData.objects9[row]
    }
    // TODO: 移動
    func getTotalOfTaxonomy(numberOfSettingsTaxonomy: Int, lastYear: Bool) -> String { // 勘定別の合計　計算
        return DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: numberOfSettingsTaxonomy, lastYear: lastYear)
    }
    
    // 取得　階層0 大区分 前年度表示対応
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String {
        if lastYear {
            // 前年度
            switch rank0 {
            case 6: // 営業収益9     売上
                return pLData.lastNetSales
            case 7: // 営業費用5     売上原価
                return pLData.lastCostOfGoodsSold
            case 8: // 営業費用5     販売費及び一般管理費
                return pLData.lastSellingGeneralAndAdministrativeExpenses
            case 11: // 税等8 法人税等 税金
                return pLData.lastIncomeTaxes
            default:
                return ""
            }
        } else {
            // 今年度
            switch rank0 {
            case 6: // 営業収益9     売上
                return pLData.netSales
            case 7: // 営業費用5     売上原価
                return pLData.costOfGoodsSold
            case 8: // 営業費用5     販売費及び一般管理費
                return pLData.sellingGeneralAndAdministrativeExpenses
            case 11: // 税等8 法人税等 税金
                return pLData.incomeTaxes
            default:
                return ""
            }
        }
    }
    // 利益　取得　前年度表示対応
    func getBenefitTotal(benefit: Int, lastYear: Bool) -> String {
        if lastYear {
            // 前年度
            switch benefit {
            case 0: // 売上総利益
                return pLData.lastGrossProfitOrLoss
            case 1: // 営業利益
                return pLData.lastOtherCapitalSurplusesTotal
            case 2: // 経常利益
                return pLData.lastOrdinaryIncomeOrLoss
            case 3: // 税引前当期純利益（損失）
                return pLData.lastIncomeOrLossBeforeIncomeTaxes
            case 4: // 当期純利益（損失）
                return pLData.lastNetIncomeOrLoss
            default:
                return ""
            }
        } else {
            // 今年度
            switch benefit {
            case 0: // 売上総利益
                return pLData.grossProfitOrLoss
            case 1: // 営業利益
                return pLData.otherCapitalSurplusesTotal
            case 2: // 経常利益
                return pLData.ordinaryIncomeOrLoss
            case 3: // 税引前当期純利益（損失）
                return pLData.incomeOrLossBeforeIncomeTaxes
            case 4: // 当期純利益（損失）
                return pLData.netIncomeOrLoss
            default:
                return ""
            }
        }
    }
    // 取得　階層1 中区分　前年度表示対応
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String {
        if lastYear {
            // 前年度
            switch rank1 {
            case 15: // 営業外収益10  営業外損益    営業外収益
                return pLData.lastNonOperatingIncome
            case 16: // 営業外費用6  営業外損益    営業外費用
                return pLData.lastNonOperatingExpenses
            case 17: // 特別利益11   特別損益    特別利益
                return pLData.lastExtraordinaryIncome
            case 18: // 特別損失7    特別損益    特別損失
                return pLData.lastExtraordinaryLosses
            default:
                return ""
            }
        } else {
            // 今年度
            switch rank1 {
            case 15: // 営業外収益10  営業外損益    営業外収益
                return pLData.nonOperatingIncome
            case 16: // 営業外費用6  営業外損益    営業外費用
                return pLData.nonOperatingExpenses
            case 17: // 特別利益11   特別損益    特別利益
                return pLData.extraordinaryIncome
            case 18: // 特別損失7    特別損益    特別損失
                return pLData.extraordinaryLosses
            default:
                return ""
            }
        }
    }
    
    func checkSettingsPeriod() -> Bool {
        DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() // 前年度の会計帳簿の存在有無を確認
    }
    
    func refreshTable() {
        // 損益計算書　初期化　再計算
        pLData = model.initializeBenefits()
        // 更新処理
        view.reloadData()
    }
    // 印刷機能
    func pdfBarButtonItemTapped() {
        // 初期化 PDFメーカー
        model.initializePDFMaker(pLData: pLData, completion: { PDFpath in
            
            self.PDFpath = PDFpath
            self.view.showPreview()
        })
    }
}
