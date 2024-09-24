//
//  BalacneSheetPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/02.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol BalacneSheetPresenterInput {
    
    var PDFpath: [URL]? { get }
    
    func company() -> String
    func fiscalYear() -> Int
    func theDayOfReckoning() -> String
    // 大区分:流動資産 中区分:当座資産
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
    func getTotalBig5(big5: Int, lastYear: Bool) -> String
}

protocol BalacneSheetPresenterOutput: AnyObject {
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
    func showPreview()
}
// 貸借対照表　個人事業主
final class BalacneSheetPresenter: BalacneSheetPresenterInput {
    
    // MARK: - var let
    
    // 貸借対照表のデータ
    var balanceSheetData: BalanceSheetData
    // PDFのパス
    var PDFpath: [URL]?
    
    private weak var view: BalacneSheetPresenterOutput!
    private var model: BalanceSheetModelInput
    
    init(view: BalacneSheetPresenterOutput, model: BalanceSheetModelInput) {
        self.view = view
        self.model = model
        
        // 貸借対照表　計算
        balanceSheetData = model.initializeBS()
        //        貸借対照表に表示する項目ごとの合計値を計算する
        //        データベースへ書き込む
        //        データベースから読み出す
        //        ビューへ表示する
    }
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        // 貸借対照表　計算
        balanceSheetData = model.initializeBS()

        view.setupViewForViewWillAppear()
    }
    
    func viewWillDisappear() {
        view.setupViewForViewWillDisappear()
    }
    
    func viewDidAppear() {
        view.setupViewForViewDidAppear()
    }
    
    func company() -> String {
        balanceSheetData.company
    }
    func fiscalYear() -> Int {
        balanceSheetData.fiscalYear
    }
    func theDayOfReckoning() -> String {
        balanceSheetData.theDayOfReckoning
    }
    
    func numberOfobjects(rank0: Int, rank1: Int) -> Int {
        
        switch rank0 {
        case 0: //     "流動資産"
            switch rank1 {
            case 0: return balanceSheetData.objects0.count
            case 1: return balanceSheetData.objects1.count
            case 2: return balanceSheetData.objects2.count
            default: return 0
            }
        case 1: //     "固定資産"
            switch rank1 {
            case 0: return balanceSheetData.objects3.count
            case 1: return balanceSheetData.objects4.count
            case 2: return balanceSheetData.objects5.count
            default: return 0
            }
        case 2: //     "繰延資産"
            switch rank1 {
            case 0: return balanceSheetData.objects6.count
            default: return 0
            }
        case 3: //     "流動負債"
            switch rank1 {
            case 0: return balanceSheetData.objects7.count
            case 1: return balanceSheetData.objects8.count
            default: return 0
            }
        case 4: //     "固定負債"
            switch rank1 {
            case 0: return balanceSheetData.objects9.count
            default: return 0
            }
        case 5: //     "資本"
            switch rank1 {
            case 0: return balanceSheetData.objects10.count
            case 1: return balanceSheetData.objects11.count
            case 2: return balanceSheetData.objects12.count
            case 3: return balanceSheetData.objects13.count
            default: return 0
            }
        default: //    ""
            return 0
        }
    }
    
    func objects(rank0: Int, rank1: Int, forRow row: Int) -> DataBaseSettingsTaxonomyAccount {
        
        switch rank0 {
        case 0: //     "流動資産"
            switch rank1 {
            case 0: return balanceSheetData.objects0[row]
            case 1: return balanceSheetData.objects1[row]
            case 2: return balanceSheetData.objects2[row]
            default: return balanceSheetData.objects2[row]
            }
        case 1: //     "固定資産"
            switch rank1 {
            case 0: return balanceSheetData.objects3[row]
            case 1: return balanceSheetData.objects4[row]
            case 2: return balanceSheetData.objects5[row]
            default: return balanceSheetData.objects5[row]
            }
        case 2: //     "繰延資産"
            switch rank1 {
            case 0: return balanceSheetData.objects6[row]
            default: return balanceSheetData.objects6[row]
            }
        case 3: //     "流動負債"
            switch rank1 {
            case 0: return balanceSheetData.objects7[row]
            case 1: return balanceSheetData.objects8[row]
            default: return balanceSheetData.objects8[row]
            }
        case 4: //     "固定負債"
            switch rank1 {
            case 0: return balanceSheetData.objects9[row]
            default: return balanceSheetData.objects9[row]
            }
        case 5: //     "資本"
            switch rank1 {
            case 0: return balanceSheetData.objects10[row]
            case 1: return balanceSheetData.objects11[row]
            case 2: return balanceSheetData.objects12[row]
            case 3: return balanceSheetData.objects13[row]
            default: return balanceSheetData.objects13[row]
            }
        default: //    ""
            return balanceSheetData.objects10[row]
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
                case 0: // 流動資産
                    return balanceSheetData.lastCurrentAssetsTotal
                case 1: // 固定資産
                    return balanceSheetData.lastFixedAssetsTotal
                case 2: // 繰延資産
                    return balanceSheetData.lastDeferredAssetsTotal
                case 3: // 流動負債
                    return balanceSheetData.lastCurrentLiabilitiesTotal
                case 4: // 固定負債
                    return balanceSheetData.lastFixedLiabilitiesTotal
                default:
                    return ""
                }
            } else {
                return "-"
            }
        } else {
            // 今年度
            switch rank0 {
            case 0: // 流動資産
                return balanceSheetData.currentAssetsTotal
            case 1: // 固定資産
                return balanceSheetData.fixedAssetsTotal
            case 2: // 繰延資産
                return balanceSheetData.deferredAssetsTotal
            case 3: // 流動負債
                return balanceSheetData.currentLiabilitiesTotal
            case 4: // 固定負債
                return balanceSheetData.fixedLiabilitiesTotal
            default:
                return ""
            }
        }
    }
    // 取得　五大区分　前年度表示対応
    func getTotalBig5(big5: Int, lastYear: Bool) -> String {
        if lastYear {
            switch big5 {
            case 0: // 資産
                return balanceSheetData.lastAssetTotal
            case 1: // 負債
                return balanceSheetData.lastLiabilityTotal
            case 2: // 純資産
                return balanceSheetData.lastEquityTotal
            case 3: // 負債純資産
                return balanceSheetData.lastLiabilityAndEquityTotal
            default:
                return ""
            }
        } else {
            switch big5 {
            case 0: // 資産
                return balanceSheetData.assetTotal
            case 1: // 負債
                return balanceSheetData.liabilityTotal
            case 2: // 純資産
                return balanceSheetData.equityTotal
            case 3: // 負債純資産
                return balanceSheetData.liabilityAndEquityTotal
            default:
                return ""
            }
        }
    }
    
    func refreshTable() {
        // 貸借対照表　初期化　再計算
        balanceSheetData = model.initializeBS()
        // 更新処理
        view.reloadData()
    }
    // 印刷機能
    func pdfBarButtonItemTapped() {
        // 初期化 PDFメーカー
        model.initializePdfMaker(balanceSheetData: balanceSheetData, completion: { PDFpath in
            self.PDFpath = PDFpath
            self.view.showPreview()
        })
    }
}
