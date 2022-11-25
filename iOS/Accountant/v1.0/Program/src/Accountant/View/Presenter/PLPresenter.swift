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
    
    var numberOfmid_category10: Int { get }
    func mid_category10(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfmid_category6: Int { get }
    func mid_category6(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfmid_category11: Int { get }
    func mid_category11(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfmid_category7: Int { get }
    func mid_category7(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfobjects9: Int { get }
    func objects9(forRow row: Int) -> DataBaseSettingsTaxonomy
    
    func viewDidLoad()
    func viewWillAppear()
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
    
    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }

    func company() -> String {
        return pLData.company
    }
    func fiscalYear() -> Int {
        return pLData.fiscalYear
    }
    func theDayOfReckoning() -> String {
        return pLData.theDayOfReckoning
    }
    
    var numberOfmid_category10: Int {
        return pLData.mid_category10.count
    }
    func mid_category10(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return pLData.mid_category10[row]
    }
    
    var numberOfmid_category6: Int {
        return pLData.mid_category6.count
    }
    func mid_category6(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return pLData.mid_category6[row]
    }
    
    var numberOfmid_category11: Int {
        return pLData.mid_category11.count
    }
    func mid_category11(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return pLData.mid_category11[row]
    }
    
    var numberOfmid_category7: Int {
        return pLData.mid_category7.count
    }
    func mid_category7(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return pLData.mid_category7[row]
    }
    
    var numberOfobjects9: Int {
        return pLData.objects9.count
    }
    func objects9(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return pLData.objects9[row]
    }
    // TODO: 移動
    func getTotalOfTaxonomy(numberOfSettingsTaxonomy: Int, lastYear: Bool) -> String  {// 勘定別の合計　計算
        return DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: numberOfSettingsTaxonomy, lastYear: lastYear)
    }
    
    // 取得　階層0 大区分 前年度表示対応
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String {
        if lastYear {
            // 前年度
            switch rank0 {
            case 6: //営業収益9     売上
                return pLData.lastNetSales
            case 7: //営業費用5     売上原価
                return pLData.lastCostOfGoodsSold
            case 8: //営業費用5     販売費及び一般管理費
                return pLData.lastSellingGeneralAndAdministrativeExpenses
            case 11: //税等8 法人税等 税金
                return pLData.lastIncomeTaxes
            default:
                return ""
            }
        }
        else {
            // 今年度
            switch rank0 {
            case 6: //営業収益9     売上
                return pLData.NetSales
            case 7: //営業費用5     売上原価
                return pLData.CostOfGoodsSold
            case 8: //営業費用5     販売費及び一般管理費
                return pLData.SellingGeneralAndAdministrativeExpenses
            case 11: //税等8 法人税等 税金
                return pLData.IncomeTaxes
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
            case 0: //売上総利益
                return pLData.lastGrossProfitOrLoss
            case 1: //営業利益
                return pLData.lastOtherCapitalSurpluses_total
            case 2: //経常利益
                return pLData.lastOrdinaryIncomeOrLoss
            case 3: //税引前当期純利益（損失）
                return pLData.lastIncomeOrLossBeforeIncomeTaxes
            case 4: //当期純利益（損失）
                return pLData.lastNetIncomeOrLoss
            default:
                return ""
            }
        }
        else {
            // 今年度
            switch benefit {
            case 0: //売上総利益
                return pLData.GrossProfitOrLoss
            case 1: //営業利益
                return pLData.OtherCapitalSurpluses_total
            case 2: //経常利益
                return pLData.OrdinaryIncomeOrLoss
            case 3: //税引前当期純利益（損失）
                return pLData.IncomeOrLossBeforeIncomeTaxes
            case 4: //当期純利益（損失）
                return pLData.NetIncomeOrLoss
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
            case 15: //営業外収益10  営業外損益    営業外収益
                return pLData.lastNonOperatingIncome
            case 16: //営業外費用6  営業外損益    営業外費用
                return pLData.lastNonOperatingExpenses
            case 17: //特別利益11   特別損益    特別利益
                return pLData.lastExtraordinaryIncome
            case 18: //特別損失7    特別損益    特別損失
                return pLData.lastExtraordinaryLosses
            default:
                return ""
            }
        }
        else {
            // 今年度
            switch rank1 {
            case 15: //営業外収益10  営業外損益    営業外収益
                return pLData.NonOperatingIncome
            case 16: //営業外費用6  営業外損益    営業外費用
                return pLData.NonOperatingExpenses
            case 17: //特別利益11   特別損益    特別利益
                return pLData.ExtraordinaryIncome
            case 18: //特別損失7    特別損益    特別損失
                return pLData.ExtraordinaryLosses
            default:
                return ""
            }
        }
    }
    
    func checkSettingsPeriod() -> Bool {
        return DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() // 前年度の会計帳簿の存在有無を確認
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
