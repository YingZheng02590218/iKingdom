//
//  ProfitAndLossStatementPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/11.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol ProfitAndLossStatementPresenterInput {
    
    var PDFpath: [URL]? { get }
    
    func company() -> String
    func fiscalYear() -> Int
    func theDayOfReckoning() -> String
    // 大区分:売上、売上原価 中区分:売上原価、製造原価
    func numberOfobjects(rank0: Int, rank1: Int) -> Int
    
    func objects(rank0: Int, rank1: Int, forRow row: Int) -> DataBaseSettingsTaxonomyAccount
    
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()
    
    func refreshTable()
    func pdfBarButtonItemTapped()
    
    func getTotalOfTaxonomyAccount(rank0: Int, rank1: Int, forRow row: Int, lastYear: Bool) -> String  // 勘定別の合計　計算
    func getTotalRank0(rank0: Int, lastYear: Bool) -> String
    func getTotalRank1(rank1: Int, lastYear: Bool) -> String
    func getBenefitTotal(benefit: Int, lastYear: Bool) -> String
}

protocol ProfitAndLossStatementPresenterOutput: AnyObject {
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
    func showPreview()
}
// 損益計算書　個人事業主
final class ProfitAndLossStatementPresenter: ProfitAndLossStatementPresenterInput {
    
    // MARK: - var let
    
    // 損益計算書のデータ
    var profitAndLossStatementData: ProfitAndLossStatementData
    // PDFのパス
    var PDFpath: [URL]?
    
    private weak var view: ProfitAndLossStatementPresenterOutput!
    private var model: ProfitAndLossStatementModelInput
    
    init(view: ProfitAndLossStatementPresenterOutput, model: ProfitAndLossStatementModelInput) {
        self.view = view
        self.model = model
        
        // 損益計算書　初期化　再計算
        profitAndLossStatementData = model.initializeBenefits()
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
        profitAndLossStatementData.company
    }
    
    func fiscalYear() -> Int {
        profitAndLossStatementData.fiscalYear
    }
    
    func theDayOfReckoning() -> String {
        profitAndLossStatementData.theDayOfReckoning
    }
    
    func numberOfobjects(rank0: Int, rank1: Int) -> Int {
        
        switch rank0 {
        case 6: //     "売上"
            switch rank1 {
            case 0: return profitAndLossStatementData.objects0.count
            default: return 0
            }
        case 7: //     "売上原価"
            switch rank1 {
            case 0: return profitAndLossStatementData.objects1.count
            case 1: return profitAndLossStatementData.objects2.count
            default: return 0
            }
        case 8: //     "販売費及び一般管理費"
            switch rank1 {
            case 0: return profitAndLossStatementData.objects3.count
            default: return 0
            }
        case 9: //     "営業外損益"
            switch rank1 {
            case 0: return profitAndLossStatementData.objects4.count
            case 1: return profitAndLossStatementData.objects5.count
            default: return 0
            }
        case 10: //    "特別損益"
            switch rank1 {
            case 0: return profitAndLossStatementData.objects6.count
            case 1: return profitAndLossStatementData.objects7.count
            default: return 0
            }
        case 11: //    "税金"
            switch rank1 {
            case 0: return profitAndLossStatementData.objects8.count
            default: return 0
            }
        default: //    ""
            return 0
        }
    }
    
    func objects(rank0: Int, rank1: Int, forRow row: Int) -> DataBaseSettingsTaxonomyAccount {
        
        switch rank0 {
        case 6: //     "売上"
            switch rank1 {
            case 0: return profitAndLossStatementData.objects0[row]
            default: return profitAndLossStatementData.objects0[row]
            }
        case 7: //     "売上原価"
            switch rank1 {
            case 0: return profitAndLossStatementData.objects1[row]
            case 1: return profitAndLossStatementData.objects2[row]
            default: return profitAndLossStatementData.objects2[row]
            }
        case 8: //     "販売費及び一般管理費"
            switch rank1 {
            case 0: return profitAndLossStatementData.objects3[row]
            default: return profitAndLossStatementData.objects3[row]
            }
        case 9: //     "営業外損益"
            switch rank1 {
            case 0: return profitAndLossStatementData.objects4[row]
            case 1: return profitAndLossStatementData.objects5[row]
            default: return profitAndLossStatementData.objects5[row]
            }
        case 10: //    "特別損益"
            switch rank1 {
            case 0: return profitAndLossStatementData.objects6[row]
            case 1: return profitAndLossStatementData.objects7[row]
            default: return profitAndLossStatementData.objects7[row]
            }
        case 11: //    "税金"
            switch rank1 {
            case 0: return profitAndLossStatementData.objects8[row]
            default: return profitAndLossStatementData.objects8[row]
            }
        default: //    ""
            return profitAndLossStatementData.objects8[row]
        }
    }
    
    // 勘定別の合計を取得　マイナス表示もつける
    func getTotalOfTaxonomyAccount(rank0: Int, rank1: Int, forRow row: Int, lastYear: Bool) -> String {
        let settingsTaxonomyAccount = objects(rank0: rank0, rank1: rank1, forRow: row)
        if lastYear {
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                return DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                    rank0: rank0,
                    rank1: rank1,
                    accountNameOfSettingsTaxonomyAccount: settingsTaxonomyAccount.category, // 勘定科目名
                    lastYear: lastYear
                )
            } else {
                return "-"
            }
        } else {
            return DataBaseManagerAccount.shared.getTotalOfTaxonomyAccount(
                rank0: rank0,
                rank1: rank1,
                accountNameOfSettingsTaxonomyAccount: settingsTaxonomyAccount.category, // 勘定科目名
                lastYear: lastYear
            )
        }
    }
    // 取得　階層0 大区分 前年度表示対応
    func getTotalRank0(rank0: Int, lastYear: Bool) -> String {
        if lastYear {
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                // 前年度
                switch rank0 {
                case 6: // 営業収益9     売上
                    return profitAndLossStatementData.lastNetSales
                case 7: // 営業費用5     売上原価
                    return profitAndLossStatementData.lastCostOfGoodsSold
                case 8: // 営業費用5     販売費及び一般管理費
                    return profitAndLossStatementData.lastSellingGeneralAndAdministrativeExpenses
                case 11: // 税等8 法人税等 税金
                    return profitAndLossStatementData.lastIncomeTaxes
                default:
                    return ""
                }
            } else {
                return "-"
            }
        } else {
            // 今年度
            switch rank0 {
            case 6: // 営業収益9     売上
                return profitAndLossStatementData.netSales
            case 7: // 営業費用5     売上原価
                return profitAndLossStatementData.costOfGoodsSold
            case 8: // 営業費用5     販売費及び一般管理費
                return profitAndLossStatementData.sellingGeneralAndAdministrativeExpenses
            case 11: // 税等8 法人税等 税金
                return profitAndLossStatementData.incomeTaxes
            default:
                return ""
            }
        }
    }
    // 取得　階層1 中区分　前年度表示対応
    func getTotalRank1(rank1: Int, lastYear: Bool) -> String {
        if lastYear {
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                // 前年度
                switch rank1 {
                case 15: // 営業外収益10  営業外損益
                    return profitAndLossStatementData.lastNonOperatingIncome
                case 16: // 営業外費用6  営業外損益
                    return profitAndLossStatementData.lastNonOperatingExpenses
                case 17: // 特別利益11   特別損益
                    return profitAndLossStatementData.lastExtraordinaryIncome
                case 18: // 特別損失7    特別損益
                    return profitAndLossStatementData.lastExtraordinaryLosses
                default:
                    return ""
                }
            } else {
                return "-"
            }
        } else {
            // 今年度
            switch rank1 {
            case 15: // 営業外収益10  営業外損益
                return profitAndLossStatementData.nonOperatingIncome
            case 16: // 営業外費用6  営業外損益
                return profitAndLossStatementData.nonOperatingExpenses
            case 17: // 特別利益11   特別損益
                return profitAndLossStatementData.extraordinaryIncome
            case 18: // 特別損失7    特別損益
                return profitAndLossStatementData.extraordinaryLosses
            default:
                return ""
            }
        }
    }
    // 利益　取得　前年度表示対応
    func getBenefitTotal(benefit: Int, lastYear: Bool) -> String {
        if lastYear {
            if DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() { // 前年度の会計帳簿の存在有無を確認
                // 前年度
                switch benefit {
                case 0: // 売上総利益
                    return profitAndLossStatementData.lastGrossProfitOrLoss
                case 1: // 営業利益
                    return profitAndLossStatementData.lastOtherCapitalSurplusesTotal
                case 2: // 経常利益
                    return profitAndLossStatementData.lastOrdinaryIncomeOrLoss
                case 3: // 税引前当期純利益（損失）
                    return profitAndLossStatementData.lastIncomeOrLossBeforeIncomeTaxes
                case 4: // 当期純利益（損失）
                    return profitAndLossStatementData.lastNetIncomeOrLoss
                default:
                    return ""
                }
            } else {
                return "-"
            }
        } else {
            // 今年度
            switch benefit {
            case 0: // 売上総利益
                return profitAndLossStatementData.grossProfitOrLoss
            case 1: // 営業利益
                return profitAndLossStatementData.otherCapitalSurplusesTotal
            case 2: // 経常利益
                return profitAndLossStatementData.ordinaryIncomeOrLoss
            case 3: // 税引前当期純利益（損失）
                return profitAndLossStatementData.incomeOrLossBeforeIncomeTaxes
            case 4: // 当期純利益（損失）
                return profitAndLossStatementData.netIncomeOrLoss
            default:
                return ""
            }
        }
    }
    
    func refreshTable() {
        // 損益計算書　初期化　再計算
        profitAndLossStatementData = model.initializeBenefits()
        // 更新処理
        view.reloadData()
    }
    // 印刷機能
    func pdfBarButtonItemTapped() {
        // 初期化 PDFメーカー
        model.initializePdfMaker(profitAndLossStatementData: profitAndLossStatementData, completion: { PDFpath in
            
            self.PDFpath = PDFpath
            self.view.showPreview()
        })
    }
}
