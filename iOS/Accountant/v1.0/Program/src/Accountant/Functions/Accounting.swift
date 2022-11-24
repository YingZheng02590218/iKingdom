//
//  Accounting.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/11/21.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation

// 貸借対照表 Balance sheet
public enum BalanceSheet: Hashable {
    
    case block(Block)

    // 資産の部
    case assets(Assets)
    // 負債の部
    case liabilities(Liabilities)
    // 資本 純資産の部 Net assets
    case netAssets(NetAssets)
    
    // 流動資産
    case currentAssets(CurrentAssets)
    // 固定資産
    case nonCurrentAssets(NonCurrentAssets)
    // 繰延資産 Deferred assets
    case deferredAssets(DeferredAssets)
    // 流動負債 Current liabilities
    case currentLiabilities(CurrentLiabilities)
    // 固定負債 Fixed liabilities
    case fixedLiabilities(FixedLiabilities)

    
    // MARK: - 大区分

    public enum Block: String, CaseIterable, Hashable {
        // 資産の部 Assets
        case assets = "資産の部"
        // 負債の部 Liabilities
        case liabilities = "負債の部"
        // 純資産の部 Net assets
        case netAssets = "純資産の部"
        // 不使用
        case liabilityAndEquity = ""
        
        func getTotalAmount() -> String {
            switch self {
            case .assets: return "資産合計"
            case .liabilities: return "負債合計"
            case .netAssets: return "純資産合計"
            case .liabilityAndEquity: return "負債純資産合計"
            }
        }
    }

    // MARK: - 中区分
    
    public enum Assets: String, CaseIterable, Hashable {
        // 流動資産
        case currentAssets = "流動資産"
        // 固定資産
        case nonCurrentAssets = "固定資産"
        // 繰延資産
        case deferredAssets = "繰延資産"
        
        func getTotalAmount() -> String {
            switch self {
            case .currentAssets: return "流動資産合計"
            case .nonCurrentAssets: return "固定資産合計"
            case .deferredAssets: return "繰延資産合計"
            }
        }
    }
    
    public enum Liabilities: String, CaseIterable, Hashable {
        // 流動負債 Current liabilities
        case currentLiabilities = "流動負債"
        // 固定負債 Fixed liabilities
        case fixedLiabilities = "固定負債"
        
        func getTotalAmount() -> String {
            switch self {
            case .currentLiabilities: return "流動負債合計"
            case .fixedLiabilities: return "固定負債合計"
            }
        }
    }

    public enum NetAssets: String, CaseIterable, Hashable {
        // 株主資本　Shareholders' equity
        case cashAndCashEquivalents = "株主資本"
        // TODO: 勘定科目一覧の小区分で使用
//        // 評価・換算差額等　Valuation and translation adjustments
//        case valuationAndTranslationAdjustments = "評価・換算差額等"
        // その他の包括利益累計額 Accumulated other comprehensive income
        case accumulatedOtherComprehensiveIncome = "その他の包括利益累計額"
        // 新株予約権 Subscription rights to shares
        case subscriptionRightsToShares = "新株予約権"
        // 非支配株主持分 Non-controlling interests
        case nonControllingInterests = "非支配株主持分"
        
        func getTotalAmount() -> String {
            switch self {
            case .cashAndCashEquivalents: return "株主資本合計"
            case .accumulatedOtherComprehensiveIncome: return "その他の包括利益累計額合計"
                // 不使用
            case .subscriptionRightsToShares: return ""
                // 不使用
            case .nonControllingInterests: return ""
            }
        }
    }
    
    // MARK: - 小区分
    
    public enum CurrentAssets: String, CaseIterable, Hashable {
        // 当座資産　Cash and cash equivalents
        case cashAndCashEquivalents = "当座資産"
        // 棚卸資産 Inventories
        case inventories = "棚卸資産"
        // その他の流動資産 Other current assets
        case otherCurrentAssets = "その他の流動資産"
    }
    
    public enum NonCurrentAssets: String, CaseIterable, Hashable {
        // 有形固定資産 Tangible fixed assets (Property, plant and equipment)
        case tangibleFixedAssets = "有形固定資産"
        // 無形固定資産 Intangible assets
        case intangibleAssets = "無形固定資産"
        // 投資その他の資産 Investments
        case investments = "投資その他の資産"
    }
    
    public enum DeferredAssets: String, CaseIterable, Hashable {
        // 繰延資産
        case deferredAssets = "繰延資産"
    }
    
    public enum CurrentLiabilities: String, CaseIterable, Hashable {
        //　TODO: 仕入債務 accounts payable
        case accountsPayable = "仕入債務"
        //　TODO: その他の流動負債 other current liabilities
        case otherCurrentLiabilities = "その他の流動負債"
    }
    
    public enum FixedLiabilities: String, CaseIterable, Hashable {
        // 長期債務　long-term debt
        case longTermDebt = "長期債務"
    }
        
}
// 損益計算書
public enum ProfitAndLossStatement: Hashable {

    case block(Block)


    // MARK: - 大区分

//    public enum Block: String, CaseIterable, Hashable {
//        // 費用　Expense
//        case expense = "費用"
//        // 収益　Income
//        case income = "収益"
//    }

    // MARK: - 中区分

    public enum Block: String, CaseIterable, Hashable {
        // 売上高    Sales
        case Sales = "売上高"
        // 売上原価    Cost of goods sold
        case CostOfGoodsSold = "売上原価"
        // 販売費及び一般管理費    Selling, general and administrative expenses
        case SellingGeneralAndAdministrativeExpenses = "販売費及び一般管理費"
        // 営業外収益    Non-operating income
        case NonOperatingIncome = "営業外収益"
        // 営業外費用    Non-operating expenses
        case NonOperatingExpenses = "営業外費用"
        // 特別利益    Extraordinary profits
        case ExtraordinaryProfits = "特別利益"
        // 特別損失    Extraordinary loss
        case ExtraordinaryLoss = "特別損失"
        // 法人税、住民税及び事業税    Corporation tax, residential tax and business tax
        case IncomeTaxes = "法人税等"

        func getTotalAmount() -> String {
            switch self {
            case .Sales: return ""
            case .CostOfGoodsSold: return ""
            case .SellingGeneralAndAdministrativeExpenses: return "販売費及び一般管理費合計"
            case .NonOperatingIncome: return "営業外収益合計"
            case .NonOperatingExpenses: return "営業外費用合計"
            case .ExtraordinaryProfits: return "特別利益合計"
            case .ExtraordinaryLoss: return "特別損失合計"
            case .IncomeTaxes: return ""
            }
        }
    }

    // MARK: - 利益

    public enum Benefits: String, CaseIterable, Hashable {
        //売上総利益（損失）Gross profit (loss)
        case GrossProfitOrLoss = "売上総利益"
        //営業利益（損失）⇒ Operating income (loss)
        case OtherCapitalSurpluses_total = "営業利益"
        //経常利益（損失）⇒ Ordinary income (loss)
        case OrdinaryIncomeOrLoss = "経常利益"
        //税引前当期純利益（損失）⇒ Income (loss) before income taxes
        case IncomeOrLossBeforeIncomeTaxes = "税引前当期純利益"
        //当期純利益（損失）⇒ Net income (loss)
        case NetIncomeOrLoss = "当期純利益"
    }
}
