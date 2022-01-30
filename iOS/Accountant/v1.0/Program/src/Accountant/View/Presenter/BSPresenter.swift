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
    
    var company: String? { get }
    var fiscalYear: Int? { get }
    var theDayOfReckoning: String? { get }
    
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
}

final class BSPresenter: BSPresenterInput {

    // MARK: - var let

    var company: String?
    var fiscalYear: Int?
    var theDayOfReckoning: String?
    
    private var objects0100:Results<DataBaseSettingsTaxonomy>
    private var objects0102:Results<DataBaseSettingsTaxonomy>
    private var objects0114:Results<DataBaseSettingsTaxonomy>
    private var objects0115:Results<DataBaseSettingsTaxonomy>
    private var objects0129:Results<DataBaseSettingsTaxonomy>
    private var objects01210:Results<DataBaseSettingsTaxonomy>
    private var objects01211:Results<DataBaseSettingsTaxonomy>
    private var objects01213:Results<DataBaseSettingsTaxonomy>
    private var objects010142:Results<DataBaseSettingsTaxonomy>
    private var objects010143:Results<DataBaseSettingsTaxonomy>
    private var objects010144:Results<DataBaseSettingsTaxonomy>
    
    private weak var view: BSPresenterOutput!
    private var model: BSModelInput
    
    init(view: BSPresenterOutput, model: BSModelInput) {
        self.view = view
        self.model = model

//        貸借対照表に表示する項目ごとの合計値を計算する
//        データベースへ書き込む
//        データベースから読み出す
//        ビューへ表示する
        
        // 階層3　中区分ごとの数を取得
        objects0100 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "0",category3: "0") // 流動資産
        objects0102 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "0",category3: "2") // 繰延資産
        objects0114 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "1",category3: "4") // 流動負債
        objects0115 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "1",category3: "5") // 固定負債
        objects0129 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "9") //株主資本14
        objects01210 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "10") //評価・換算差額等15
        //            0    1    2    11                    新株予約権
        //            0    1    2    12                    自己新株予約権
        //            0    1    2    13                    非支配株主持分
        //            0    1    2    14                    少数株主持分
        objects01211 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "11")//新株予約権16
        objects01213 = DataBaseManagerSettingsTaxonomy.shared.getMiddleCategory(category0: "0",category1: "1",category2: "2",category3: "13")//非支配株主持分22
        // 階層4 小区分
        objects010142 = DataBaseManagerSettingsTaxonomy.shared.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "42") // 有形固定資産3
        objects010143 = DataBaseManagerSettingsTaxonomy.shared.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "43") // 無形固定資産4
        objects010144 = DataBaseManagerSettingsTaxonomy.shared.getSmallCategory(category0: "0",category1: "1",category2: "0",category3: "1",category4: "44") // 投資その他の資産5
    }
    
    // MARK: - Life cycle

    func viewDidLoad() {
        
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        
        fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        // 貸借対照表　計算
        model.initializeBS()
        
        view.setupViewForViewWillAppear()
    }
    
    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }
    
    
    var numberOfobjects0100: Int {
        return objects0100.count
    }
    func objects0100(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return objects0100[row]
    }
    
    var numberOfobjects0102: Int {
        return objects0102.count
    }
    func objects0102(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return objects0102[row]
    }
    
    var numberOfobjects0114: Int {
        return objects0114.count
    }
    func objects0114(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return objects0114[row]
    }
    
    var numberOfobjects0115: Int {
        return objects0115.count
    }
    func objects0115(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return objects0115[row]
    }
    
    var numberOfobjects0129: Int {
        return objects0129.count
    }
    func objects0129(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return objects0129[row]
    }
    
    var numberOfobjects01210: Int {
        return objects01210.count
    }
    func objects01210(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return objects01210[row]
    }
    
    var numberOfobjects01211: Int {
        return objects01211.count
    }
    func objects01211(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return objects01211[row]
    }
    
    var numberOfobjects01213: Int {
        return objects01213.count
    }
    func objects01213(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return objects01213[row]
    }
    
    var numberOfobjects010142: Int {
        return objects010142.count
    }
    func objects010142(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return objects010142[row]
    }
    
    var numberOfobjects010143: Int {
        return objects010143.count
    }
    func objects010143(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return objects010143[row]
    }
    
    var numberOfobjects010144: Int {
        return objects010144.count
    }
    func objects010144(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return objects010144[row]
    }

    func getTotalOfTaxonomy(numberOfSettingsTaxonomy: Int, lastYear: Bool) -> String  {// 勘定別の合計　計算
        return DataBaseManagerTaxonomy.shared.getTotalOfTaxonomy(numberOfSettingsTaxonomy: numberOfSettingsTaxonomy, lastYear: lastYear)
    }
    
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String {

        return model.getTotalRank0(big5: big5, rank0: rank0, lastYear: lastYear)
    }
    
    func refreshTable() {
        // 貸借対照表　初期化　再計算
        model.initializeBS()
        // 更新処理
        view.reloadData()
    }
    
    func getTotalBig5(big5: Int, lastYear: Bool) -> String {
        return model.getTotalBig5(big5: big5, lastYear: lastYear)
    }
    
    func checkSettingsPeriod() -> Bool {
        return DataBaseManagerSettingsPeriod.shared.checkSettingsPeriod() // 前年度の会計帳簿の存在有無を確認
    }
    
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String {
        return model.getTotalRank1(big5: big5, rank1: rank1, lastYear: lastYear) // 中区分の合計を取得

    }
}
