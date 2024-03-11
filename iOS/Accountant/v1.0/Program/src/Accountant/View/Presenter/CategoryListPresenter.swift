//
//  CategoryListPresenter.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/05/14.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

/// GUIアーキテクチャ　MVP
protocol CategoryListPresenterInput {
    
//    var dataBaseSettingsTaxonomyAccount: Results<DataBaseSettingsTaxonomyAccount> { get }

    func numberOfsections() -> Int
    func numberOfobjects(section: Int) -> Int
    func objects(forRow row: Int, section: Int) -> DataBaseSettingsTaxonomyAccount
    func titleForHeaderInSection(section: Int) -> String

    func viewDidLoad()
    func viewWillAppear()
    
    func deleteSettingsTaxonomyAccount(indexPath: IndexPath)
    func changeSwitch(tag: Int, isOn: Bool)
    func makeSerialNumbers(moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

protocol CategoryListPresenterOutput: AnyObject {
    func reloadData()
    func setupViewForViewDidLoad()
    func setupViewForViewWillAppear()
    func showToast()
}

final class CategoryListPresenter: CategoryListPresenterInput {
    
    // MARK: - var let
    
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
    private var objects14: Results<DataBaseSettingsTaxonomyAccount>
    private var objects15: Results<DataBaseSettingsTaxonomyAccount>
    private var objects16: Results<DataBaseSettingsTaxonomyAccount>
    private var objects17: Results<DataBaseSettingsTaxonomyAccount>
    private var objects18: Results<DataBaseSettingsTaxonomyAccount>
    private var objects19: Results<DataBaseSettingsTaxonomyAccount>
    private var objects20: Results<DataBaseSettingsTaxonomyAccount>
    private var objects21: Results<DataBaseSettingsTaxonomyAccount>
    private var objects22: Results<DataBaseSettingsTaxonomyAccount>
    
//    internal var dataBaseSettingsTaxonomyAccount: Results<DataBaseSettingsTaxonomyAccount>
    
    private weak var view: CategoryListPresenterOutput!
    private var model: CategoryListModelInput
    private var index: Int // index: 大区分
    
    init(view: CategoryListPresenterOutput, model: CategoryListModelInput, index: Int) {
        self.view = view
        self.model = model
        self.index = index
        
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
        
        objects14 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 6, rank1: nil)
        
        objects15 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 7, rank1: 13)
        objects16 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 7, rank1: 14)
        
        objects17 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 8, rank1: nil)
        
        objects18 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 9, rank1: 15)
        objects19 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 9, rank1: 16)
        
        objects20 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 10, rank1: 17)
        objects21 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 10, rank1: 18)
        
        objects22 = model.getDataBaseSettingsTaxonomyAccountInRank(rank0: 11, rank1: nil)
        
//        dataBaseSettingsTaxonomyAccount = model.getSettingsSwitchingOn(rank0: index)
    }
    
    func numberOfsections() -> Int {
        
        switch index {
        case 0: //     "流動資産"
            return 3
        case 1: //     "固定資産"
            return 3
        case 2: //     "繰延資産"
            return 1
        case 3: //     "流動負債"
            return 2
        case 4: //     "固定負債"
            return 1
        case 5: //     "資本"
            return 4
        case 6: //     "売上"
            return 1
        case 7: //     "売上原価"
            return 2
        case 8: //     "販売費及び一般管理費"
            return 1
        case 9: //     "営業外損益"
            return 2
        case 10: //    "特別損益"
            return 2
        case 11: //    "税金"
            return 1
        default: //    ""
            return 0
        }
    }
    
    func titleForHeaderInSection(section: Int) -> String {
        
        switch index {
        case 0: //     "流動資産"
            switch section {
            case 0: return "当座資産"
            case 1: return "棚卸資産"
            case 2: return "その他の流動資産"
            default: return ""
            }
        case 1: //     "固定資産"
            switch section {
            case 0: return "有形固定資産"
            case 1: return "無形固定資産"
            case 2: return "投資その他の資産"
            default: return ""
            }
        case 2: //     "繰延資産"
            switch section {
            case 0: return "繰延資産"
            default: return ""
            }
        case 3: //     "流動負債"
            switch section {
            case 0: return "仕入債務"
            case 1: return "その他の流動負債"
            default: return ""
            }
        case 4: //     "固定負債"
            switch section {
            case 0: return "長期債務"
            default: return ""
            }
        case 5: //     "資本"
            switch section {
            case 0: return "株主資本"
            case 1: return "評価・換算差額等"
            case 2: return "新株予約権"
            case 3: return "非支配株主持分"
            default: return ""
            }
        case 6: //     "売上"
            switch section {
            case 0: return ""
            default: return ""
            }
        case 7: //     "売上原価"
            switch section {
            case 0: return "売上原価"
            case 1: return "製造原価"
            default: return ""
            }
        case 8: //     "販売費及び一般管理費"
            switch section {
            case 0: return ""
            default: return ""
            }
        case 9: //     "営業外損益"
            switch section {
            case 0: return "営業外収益"
            case 1: return "営業外費用"
            default: return ""
            }
        case 10: //    "特別損益"
            switch section {
            case 0: return "特別利益"
            case 1: return "特別損失"
            default: return ""
            }
        case 11: //    "税金"
            switch section {
            case 0: return ""
            default: return ""
            }
        default: //    ""
            return ""
        }
    }
    
    func numberOfobjects(section: Int) -> Int {
        
        switch index {
        case 0: //     "流動資産"
            switch section {
            case 0: return objects0.count
            case 1: return objects1.count
            case 2: return objects2.count
            default: return 0
            }
        case 1: //     "固定資産"
            switch section {
            case 0: return objects3.count
            case 1: return objects4.count
            case 2: return objects5.count
            default: return 0
            }
        case 2: //     "繰延資産"
            switch section {
            case 0: return objects6.count
            default: return 0
            }
        case 3: //     "流動負債"
            switch section {
            case 0: return objects7.count
            case 1: return objects8.count
            default: return 0
            }
        case 4: //     "固定負債"
            switch section {
            case 0: return objects9.count
            default: return 0
            }
        case 5: //     "資本"
            switch section {
            case 0: return objects10.count
            case 1: return objects11.count
            case 2: return objects12.count
            case 3: return objects13.count
            default: return 0
            }
        case 6: //     "売上"
            switch section {
            case 0: return objects14.count
            default: return 0
            }
        case 7: //     "売上原価"
            switch section {
            case 0: return objects15.count
            case 1: return objects16.count
            default: return 0
            }
        case 8: //     "販売費及び一般管理費"
            switch section {
            case 0: return objects17.count
            default: return 0
            }
        case 9: //     "営業外損益"
            switch section {
            case 0: return objects18.count
            case 1: return objects19.count
            default: return 0
            }
        case 10: //    "特別損益"
            switch section {
            case 0: return objects20.count
            case 1: return objects21.count
            default: return 0
            }
        case 11: //    "税金"
            switch section {
            case 0: return objects22.count
            default: return 0
            }
        default: //    ""
            return 0
        }
    }
    
    func objects(forRow row: Int, section: Int) -> DataBaseSettingsTaxonomyAccount {
        
        switch index {
        case 0: //     "流動資産"
            switch section {
            case 0: return objects0[row]
            case 1: return objects1[row]
            case 2: return objects2[row]
            default: return objects2[row]
            }
        case 1: //     "固定資産"
            switch section {
            case 0: return objects3[row]
            case 1: return objects4[row]
            case 2: return objects5[row]
            default: return objects5[row]
            }
        case 2: //     "繰延資産"
            switch section {
            case 0: return objects6[row]
            default: return objects6[row]
            }
        case 3: //     "流動負債"
            switch section {
            case 0: return objects7[row]
            case 1: return objects8[row]
            default: return objects8[row]
            }
        case 4: //     "固定負債"
            switch section {
            case 0: return objects9[row]
            default: return objects9[row]
            }
        case 5: //     "資本"
            switch section {
            case 0: return objects10[row]
            case 1: return objects11[row]
            case 2: return objects12[row]
            case 3: return objects13[row]
            default: return objects13[row]
            }
        case 6: //     "売上"
            switch section {
            case 0: return objects14[row]
            default: return objects14[row]
            }
        case 7: //     "売上原価"
            switch section {
            case 0: return objects15[row]
            case 1: return objects16[row]
            default: return objects16[row]
            }
        case 8: //     "販売費及び一般管理費"
            switch section {
            case 0: return objects17[row]
            default: return objects17[row]
            }
        case 9: //     "営業外損益"
            switch section {
            case 0: return objects18[row]
            case 1: return objects19[row]
            default: return objects19[row]
            }
        case 10: //    "特別損益"
            switch section {
            case 0: return objects20[row]
            case 1: return objects21[row]
            default: return objects21[row]
            }
        case 11: //    "税金"
            switch section {
            case 0: return objects22[row]
            default: return objects22[row]
            }
        default: //    ""
            return objects22[row]
        }
    }

    func objects(section: Int) -> Results<DataBaseSettingsTaxonomyAccount> {
        
        switch index {
        case 0: //     "流動資産"
            switch section {
            case 0: return objects0
            case 1: return objects1
            case 2: return objects2
            default: return objects2
            }
        case 1: //     "固定資産"
            switch section {
            case 0: return objects3
            case 1: return objects4
            case 2: return objects5
            default: return objects5
            }
        case 2: //     "繰延資産"
            switch section {
            case 0: return objects6
            default: return objects6
            }
        case 3: //     "流動負債"
            switch section {
            case 0: return objects7
            case 1: return objects8
            default: return objects8
            }
        case 4: //     "固定負債"
            switch section {
            case 0: return objects9
            default: return objects9
            }
        case 5: //     "資本"
            switch section {
            case 0: return objects10
            case 1: return objects11
            case 2: return objects12
            case 3: return objects13
            default: return objects13
            }
        case 6: //     "売上"
            switch section {
            case 0: return objects14
            default: return objects14
            }
        case 7: //     "売上原価"
            switch section {
            case 0: return objects15
            case 1: return objects16
            default: return objects16
            }
        case 8: //     "販売費及び一般管理費"
            switch section {
            case 0: return objects17
            default: return objects17
            }
        case 9: //     "営業外損益"
            switch section {
            case 0: return objects18
            case 1: return objects19
            default: return objects19
            }
        case 10: //    "特別損益"
            switch section {
            case 0: return objects20
            case 1: return objects21
            default: return objects21
            }
        case 11: //    "税金"
            switch section {
            case 0: return objects22
            default: return objects22
            }
        default: //    ""
            return objects22
        }
    }

    func viewDidLoad() {
        
        view.setupViewForViewDidLoad()
    }
    
    func viewWillAppear() {
        
        view.setupViewForViewWillAppear()
    }
    // 削除　設定勘定科目
    func deleteSettingsTaxonomyAccount(indexPath: IndexPath) {

        let result = model.deleteSettingsTaxonomyAccount(number: self.objects(forRow: indexPath.row, section: indexPath.section).number)
        if result == true {
            view.reloadData()
            // 仕訳画面のカルーセルをリロードする
            JournalEntryViewController.viewReload = true
        } else {
            print("削除失敗　設定勘定科目")
        }
    }
    // トグルスイッチの切り替え　データベースを更新
    func changeSwitch(tag: Int, isOn: Bool) {
        // 引数：連番、トグルスイッチ.有効無効
        model.updateSettingsCategorySwitching(tag: tag, isOn: isOn)
        // 表示科目のスイッチを設定する　勘定科目がひとつもなければOFFにする
        DataBaseManagerSettingsTaxonomy.shared.updateSettingsCategoryBSAndPLSwitching(number: tag)
    }
    
    // 採番　設定勘定科目 並び替えの順序のためのシリアルナンバーを更新する
    // カルーセルのタブの識別 移動前　移動後
    func makeSerialNumbers(moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 入れ替え時の処理を実装する
        if sourceIndexPath.section == destinationIndexPath.section {
            // 移動前
            let settingTaxonomies = objects(section: sourceIndexPath.section)
            // 構造体に変換する
            let objects = settingTaxonomies.map { object -> SeializingObject in
                let number = object.number
                let serialNumber = object.serialNumber
                return SeializingObject(number: number, serialNumber: serialNumber)
            }
            print(objects)
            // ソート
            var sortedSettingTaxonomies = objects.sorted(by: { $0.serialNumber < $1.serialNumber })
            print(sortedSettingTaxonomies)
            // 順序を並び替える用
            let offset = sourceIndexPath.row > destinationIndexPath.row ? destinationIndexPath.row : destinationIndexPath.row + 1
            print(sourceIndexPath.row, destinationIndexPath.row)
            print(offset)
            // 並び替え
            sortedSettingTaxonomies.move(fromOffsets: IndexSet([sourceIndexPath.row]), toOffset: offset)
            print(sortedSettingTaxonomies)
            // 採番　並び替えの順序のためのシリアルナンバーを更新する
            DatabaseManagerSettingsTaxonomyAccount.shared.makeSerialNumbers(objects: sortedSettingTaxonomies)
        } else {
            view.showToast()
        }
    }
}
// 連番とシリアルナンバーを格納する構造体
struct SeializingObject: CustomStringConvertible {
    let number: Int
    let serialNumber: Int

    var description: String {
        return "Object(number: \(number), serialNumber: \(serialNumber))"
    }
}
