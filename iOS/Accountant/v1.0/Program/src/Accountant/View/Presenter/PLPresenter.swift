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
    
    var company: String? { get }
    var fiscalYear: Int? { get }
    var theDayOfReckoning: String? { get }
    
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()

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
    
    func refreshTable()
    
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String
    func getBenefitTotal(benefit: Int, lastYear: Bool) -> String
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String
}

protocol PLPresenterOutput: AnyObject {
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func setupViewForViewDidAppear()
}

final class PLPresenter: PLPresenterInput {

    // MARK: - var let
    
    var company: String?
    var fiscalYear: Int?
    var theDayOfReckoning: String?
    
    private var mid_category10:Results<DataBaseSettingsTaxonomy>
    private var mid_category6:Results<DataBaseSettingsTaxonomy>
    private var mid_category11:Results<DataBaseSettingsTaxonomy>
    private var mid_category7:Results<DataBaseSettingsTaxonomy>
    private var objects9:Results<DataBaseSettingsTaxonomy>
    
    private weak var view: PLPresenterOutput!
    private var model: PLModelInput
    
    init(view: PLPresenterOutput, model: PLModelInput) {
        self.view = view
        self.model = model
        
        mid_category10 = DataBaseManagerSettingsTaxonomy.shared.getBigCategory(category0: "1",category1: "1",category2: "6")//営業外収益10
        mid_category6 = DataBaseManagerSettingsTaxonomy.shared.getBigCategory(category0: "1",category1: "1",category2: "7")//営業外費用6
        mid_category11 = DataBaseManagerSettingsTaxonomy.shared.getBigCategory(category0: "1",category1: "1",category2: "9")//特別利益11
        mid_category7 = DataBaseManagerSettingsTaxonomy.shared.getBigCategory(category0: "1",category1: "1",category2: "10")//特別損失7
        objects9 = DataBaseManagerSettingsTaxonomy.shared.getBigCategory(category0: "1",category1: "1",category2: "4")//販売費及び一般管理費9

//        let objects9 = dataBaseManagerSettingsCategoryBSAndPL.getMiddleCategory(section: indexPath.section, small_category: 9)//販売費及び一般管理費9
    }
    
    // MARK: - Life cycle

    func viewDidLoad() {
        
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        
        company = DataBaseManagerAccountingBooksShelf.shared.getCompanyName()
        fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear()
        theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()
        // 損益計算書　再計算
        model.initializeBenefits()
        
        view.setupViewForViewWillAppear()
    }
    
    func viewDidAppear() {
        
        view.setupViewForViewDidAppear()
    }

    var numberOfmid_category10: Int {
        return mid_category10.count
    }
    func mid_category10(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return mid_category10[row]
    }
    
    var numberOfmid_category6: Int {
        return mid_category6.count
    }
    func mid_category6(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return mid_category6[row]
    }
    
    var numberOfmid_category11: Int {
        return mid_category11.count
    }
    func mid_category11(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return mid_category11[row]
    }
    
    var numberOfmid_category7: Int {
        return mid_category7.count
    }
    func mid_category7(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return mid_category7[row]
    }
    
    var numberOfobjects9: Int {
        return objects9.count
    }
    func objects9(forRow row: Int) -> DataBaseSettingsTaxonomy {
        return objects9[row]
    }
    
    func refreshTable() {
        // 損益計算書　初期化　再計算
        model.initializeBenefits()
        // 更新処理
        view.reloadData()
    }
    
    // 取得　階層0 大区分 前年度表示対応
    func getTotalRank0(big5: Int, rank0: Int, lastYear: Bool) -> String {
        return model.getTotalRank0(big5: big5, rank0: rank0, lastYear: lastYear)
    }
    // 利益　取得　前年度表示対応
    func getBenefitTotal(benefit: Int, lastYear: Bool) -> String {
        return model.getBenefitTotal(benefit: benefit, lastYear: lastYear)
    }
    // 取得　階層1 中区分　前年度表示対応
    func getTotalRank1(big5: Int, rank1: Int, lastYear: Bool) -> String {
        return model.getTotalRank1(big5: big5, rank1: rank1, lastYear: lastYear)
    }
}
