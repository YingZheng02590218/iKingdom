//
//  BSPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/01/23.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol BSPresenterInput {
    var bSData: BSData { get }

    var PDFpath: [URL]? { get }

    func company() -> String
    func fiscalYear() -> Int
    func theDayOfReckoning() -> String

    var numberOfobjects0100: Int { get }
    var numberOfobjects0102: Int { get }
    var numberOfobjects0114: Int { get }
    var numberOfobjects0115: Int { get }
    var numberOfobjects0129: Int { get }
    var numberOfobjects01210: Int { get }
    var numberOfobjects01211: Int { get }
    var numberOfobjects01213: Int { get }
    var numberOfobjects010142: Int { get }
    var numberOfobjects010143: Int { get }
    var numberOfobjects010144: Int { get }

    func objects0100(forRow row: Int) -> DataBaseSettingsTaxonomy
    func objects0102(forRow row: Int) -> DataBaseSettingsTaxonomy
    func objects0114(forRow row: Int) -> DataBaseSettingsTaxonomy
    func objects0115(forRow row: Int) -> DataBaseSettingsTaxonomy
    func objects0129(forRow row: Int) -> DataBaseSettingsTaxonomy
    func objects01210(forRow row: Int) -> DataBaseSettingsTaxonomy
    func objects01211(forRow row: Int) -> DataBaseSettingsTaxonomy
    func objects01213(forRow row: Int) -> DataBaseSettingsTaxonomy
    func objects010142(forRow row: Int) -> DataBaseSettingsTaxonomy
    func objects010143(forRow row: Int) -> DataBaseSettingsTaxonomy
    func objects010144(forRow row: Int) -> DataBaseSettingsTaxonomy

    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func viewDidAppear()

    func refreshTable()
    func pdfBarButtonItemTapped()

    func getTotalOfTaxonomy(numberOfSettingsTaxonomy: Int, lastYear: Bool) -> String  // 勘定別の合計　計算
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String
    func getTotalBig5(big5: Int, lastYear: Bool) -> String
    func checkSettingsPeriod() -> Bool
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String
}

protocol BSPresenterOutput: AnyObject {
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewWillDisappear()
    func setupViewForViewDidAppear()
    func showPreview()
}

final class BSPresenter: BSPresenterInput {

    // MARK: - var let

    // 貸借対照表のデータ
    var bSData: BSData
    // PDFのパス
    var PDFpath: [URL]?

    private weak var view: BSPresenterOutput!
    private var model: BSModelInput

    init(view: BSPresenterOutput, model: BSModelInput) {
        self.view = view
        self.model = model

        // 貸借対照表　計算
        bSData = model.initializeBS()
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
        view.setupViewForViewWillAppear()
    }

    func viewWillDisappear() {

        view.setupViewForViewWillDisappear()
    }

    func viewDidAppear() {
        view.setupViewForViewDidAppear()
    }

    func company() -> String {
        bSData.company
    }
    func fiscalYear() -> Int {
        bSData.fiscalYear
    }
    func theDayOfReckoning() -> String {
        bSData.theDayOfReckoning
    }

    var numberOfobjects0100: Int {
        bSData.objects0100.count
    }

    func objects0100(forRow row: Int) -> DataBaseSettingsTaxonomy {
        bSData.objects0100[row]
    }

    var numberOfobjects0102: Int {
        bSData.objects0102.count
    }

    func objects0102(forRow row: Int) -> DataBaseSettingsTaxonomy {
        bSData.objects0102[row]
    }

    var numberOfobjects0114: Int {
        bSData.objects0114.count
    }

    func objects0114(forRow row: Int) -> DataBaseSettingsTaxonomy {
        bSData.objects0114[row]
    }

    var numberOfobjects0115: Int {
        bSData.objects0115.count
    }

    func objects0115(forRow row: Int) -> DataBaseSettingsTaxonomy {
        bSData.objects0115[row]
    }

    var numberOfobjects0129: Int {
        bSData.objects0129.count
    }

    func objects0129(forRow row: Int) -> DataBaseSettingsTaxonomy {
        bSData.objects0129[row]
    }

    var numberOfobjects01210: Int {
        bSData.objects01210.count
    }

    func objects01210(forRow row: Int) -> DataBaseSettingsTaxonomy {
        bSData.objects01210[row]
    }
    
    var numberOfobjects01211: Int {
        bSData.objects01211.count
    }

    func objects01211(forRow row: Int) -> DataBaseSettingsTaxonomy {
        bSData.objects01211[row]
    }

    var numberOfobjects01213: Int {
        bSData.objects01213.count
    }

    func objects01213(forRow row: Int) -> DataBaseSettingsTaxonomy {
        bSData.objects01213[row]
    }

    var numberOfobjects010142: Int {
        bSData.objects010142.count
    }

    func objects010142(forRow row: Int) -> DataBaseSettingsTaxonomy {
        bSData.objects010142[row]
    }

    var numberOfobjects010143: Int {
        bSData.objects010143.count
    }

    func objects010143(forRow row: Int) -> DataBaseSettingsTaxonomy {
        bSData.objects010143[row]
    }

    var numberOfobjects010144: Int {
        bSData.objects010144.count
    }

    func objects010144(forRow row: Int) -> DataBaseSettingsTaxonomy {
        bSData.objects010144[row]
    }

    func getTotalOfTaxonomy(numberOfSettingsTaxonomy: Int, lastYear: Bool) -> String { // 勘定別の合計　計算
        DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: numberOfSettingsTaxonomy, lastYear: lastYear)
    }
    // 中区分の合計を取得
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String {
        if lastYear {
            // 前年度
            switch rank1 {
            case 10: // 株主資本
                return bSData.lastCapitalStockTotal
            case 11: // 評価・換算差額等 /その他の包括利益累計額 評価・換算差額等のこと
                return bSData.lastOtherCapitalSurplusesTotal
                //　case 12: //新株予約権
                //　case 19: //非支配株主持分
            default:
                return ""
            }
        } else {
            // 今年度
            switch rank1 {
            case 10: // 株主資本
                return bSData.capitalStockTotal
            case 11: // 評価・換算差額等 /その他の包括利益累計額 評価・換算差額等のこと
                return bSData.otherCapitalSurplusesTotal
                //　case 12: //新株予約権
                //　case 19: //非支配株主持分
            default:
                return ""
            }
        }
    }
    // 取得　階層0 大区分 前年度表示対応
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String {
        if lastYear {
            // 前年度
            switch rank0 {
            case 0: // 流動資産
                return bSData.lastCurrentAssetsTotal
            case 1: // 固定資産
                return bSData.lastFixedAssetsTotal
            case 2: // 繰延資産
                return bSData.lastDeferredAssetsTotal
            case 3: // 流動負債
                return bSData.lastCurrentLiabilitiesTotal
            case 4: // 固定負債
                return bSData.lastFixedLiabilitiesTotal
            default:
                return ""
            }
        } else {
            // 今年度
            switch rank0 {
            case 0: // 流動資産
                return bSData.currentAssetsTotal
            case 1: // 固定資産
                return bSData.fixedAssetsTotal
            case 2: // 繰延資産
                return bSData.deferredAssetsTotal
            case 3: // 流動負債
                return bSData.currentLiabilitiesTotal
            case 4: // 固定負債
                return bSData.fixedLiabilitiesTotal
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
                return bSData.lastAssetTotal
            case 1: // 負債
                return bSData.lastLiabilityTotal
            case 2: // 純資産
                return bSData.lastEquityTotal
            case 3: // 負債純資産
                return bSData.lastLiabilityAndEquityTotal
            default:
                return ""
            }
        } else {
            switch big5 {
            case 0: // 資産
                return bSData.assetTotal
            case 1: // 負債
                return bSData.liabilityTotal
            case 2: // 純資産
                return bSData.equityTotal
            case 3: // 負債純資産
                return bSData.liabilityAndEquityTotal
            default:
                return ""
            }
        }
    }

    func checkSettingsPeriod() -> Bool {
        DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() // 前年度の会計帳簿の存在有無を確認
    }

    func refreshTable() {
        // 貸借対照表　初期化　再計算
        bSData = model.initializeBS()
        // 更新処理
        view.reloadData()
    }
    // 印刷機能
    func pdfBarButtonItemTapped() {
        // 初期化 PDFメーカー
        model.initializePdfMaker(bSData: bSData, completion: { PDFpath in
            self.PDFpath = PDFpath
            self.view.showPreview()
        })
    }
}
