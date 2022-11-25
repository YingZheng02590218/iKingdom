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
    func objects0100(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfobjects0102: Int { get }
    func objects0102(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfobjects0114: Int { get }
    func objects0114(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfobjects0115: Int { get }
    func objects0115(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfobjects0129: Int { get }
    func objects0129(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfobjects01210: Int { get }
    func objects01210(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfobjects01211: Int { get }
    func objects01211(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfobjects01213: Int { get }
    func objects01213(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfobjects010142: Int { get }
    func objects010142(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfobjects010143: Int { get }
    func objects010143(forRow row: Int) -> DataBaseSettingsTaxonomy
    var numberOfobjects010144: Int { get }
    func objects010144(forRow row: Int) -> DataBaseSettingsTaxonomy
    
    func viewDidLoad()
    func viewWillAppear()
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
    
    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }
    
    func company() -> String {
        return bSData.company
    }
    func fiscalYear() -> Int {
        return bSData.fiscalYear
    }
    func theDayOfReckoning() -> String {
        return bSData.theDayOfReckoning
    }
    
    var numberOfobjects0100: Int {
        return bSData.objects0100.count
    }
    func objects0100(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return bSData.objects0100[row]
    }
    
    var numberOfobjects0102: Int {
        return bSData.objects0102.count
    }
    func objects0102(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return bSData.objects0102[row]
    }
    
    var numberOfobjects0114: Int {
        return bSData.objects0114.count
    }
    func objects0114(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return bSData.objects0114[row]
    }
    
    var numberOfobjects0115: Int {
        return bSData.objects0115.count
    }
    func objects0115(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return bSData.objects0115[row]
    }
    
    var numberOfobjects0129: Int {
        return bSData.objects0129.count
    }
    func objects0129(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return bSData.objects0129[row]
    }
    
    var numberOfobjects01210: Int {
        return bSData.objects01210.count
    }
    func objects01210(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return bSData.objects01210[row]
    }
    
    var numberOfobjects01211: Int {
        return bSData.objects01211.count
    }
    func objects01211(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return bSData.objects01211[row]
    }
    
    var numberOfobjects01213: Int {
        return bSData.objects01213.count
    }
    func objects01213(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return bSData.objects01213[row]
    }
    
    var numberOfobjects010142: Int {
        return bSData.objects010142.count
    }
    func objects010142(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return bSData.objects010142[row]
    }
    
    var numberOfobjects010143: Int {
        return bSData.objects010143.count
    }
    func objects010143(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return bSData.objects010143[row]
    }
    
    var numberOfobjects010144: Int {
        return bSData.objects010144.count
    }
    func objects010144(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return bSData.objects010144[row]
    }

    func getTotalOfTaxonomy(numberOfSettingsTaxonomy: Int, lastYear: Bool) -> String  {// 勘定別の合計　計算
        return DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: numberOfSettingsTaxonomy, lastYear: lastYear)
    }
    
    // 中区分の合計を取得
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String {
        if lastYear {
            // 前年度
            switch rank1 {
            case 10: //株主資本
                return bSData.lastCapitalStock_total
            case 11: //評価・換算差額等 /その他の包括利益累計額 評価・換算差額等のこと
                return bSData.lastOtherCapitalSurpluses_total
                //　case 12: //新株予約権
                //　case 19: //非支配株主持分
            default:
                return ""
            }
        }
        else {
            // 今年度
            switch rank1 {
            case 10: //株主資本
                return bSData.CapitalStock_total
            case 11: //評価・換算差額等 /その他の包括利益累計額 評価・換算差額等のこと
                return bSData.OtherCapitalSurpluses_total
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
            case 0: //流動資産
                return bSData.lastCurrentAssets_total
            case 1: //固定資産
                return bSData.lastFixedAssets_total
            case 2: //繰延資産
                return bSData.lastDeferredAssets_total
            case 3: //流動負債
                return bSData.lastCurrentLiabilities_total
            case 4: //固定負債
                return bSData.lastFixedLiabilities_total
            default:
                return ""
            }
        }
        else {
            // 今年度
            switch rank0 {
            case 0: //流動資産
                return bSData.CurrentAssets_total
            case 1: //固定資産
                return bSData.FixedAssets_total
            case 2: //繰延資産
                return bSData.DeferredAssets_total
            case 3: //流動負債
                return bSData.CurrentLiabilities_total
            case 4: //固定負債
                return bSData.FixedLiabilities_total
            default:
                return ""
            }
        }
    }
    // 取得　五大区分　前年度表示対応
    func getTotalBig5(big5: Int, lastYear: Bool) -> String {
        if lastYear {
            switch big5 {
            case 0: //資産
                return bSData.lastAsset_total
            case 1: //負債
                return bSData.lastLiability_total
            case 2: //純資産
                return bSData.lastEquity_total
            case 3: //負債純資産
                return bSData.lastLiability_and_Equity_total
            default:
                return ""
            }
        }
        else {
            switch big5 {
            case 0: //資産
                return bSData.Asset_total
            case 1: //負債
                return bSData.Liability_total
            case 2: //純資産
                return bSData.Equity_total
            case 3: //負債純資産
                return bSData.Liability_and_Equity_total
            default:
                return ""
            }
        }
    }
    
    func checkSettingsPeriod() -> Bool {
        return DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() // 前年度の会計帳簿の存在有無を確認
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
        model.initializePDFMaker(bSData: bSData, completion: { PDFpath in
            
            self.PDFpath = PDFpath
            self.view.showPreview()
        })
    }
}
