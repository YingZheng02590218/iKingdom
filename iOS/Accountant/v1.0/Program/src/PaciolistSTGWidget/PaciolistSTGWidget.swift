//
//  PaciolistSTGWidget.swift
//  PaciolistSTGWidget
//
//  Created by Hisashi Ishihara on 2023/02/09.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    // Widgetの初期表示を行う関数です。
    func placeholder(in context: Context) -> SimpleEntry {
        let accountingData = AccountingData(
            assets: UserDefaults.appGroup.double(forKey: UserDefaults.Keys.assets.rawValue),
            liabilities: UserDefaults.appGroup.double(forKey: UserDefaults.Keys.liabilities.rawValue),
            netAssets: UserDefaults.appGroup.double(forKey: UserDefaults.Keys.netAssets.rawValue),
            expense: UserDefaults.appGroup.double(forKey: UserDefaults.Keys.expense.rawValue),
            income: UserDefaults.appGroup.double(forKey: UserDefaults.Keys.income.rawValue),
            netIncomeOrLoss: UserDefaults.appGroup.double(forKey: UserDefaults.Keys.netIncomeOrLoss.rawValue)
        )
        return SimpleEntry(date: Date(), accountingData: accountingData, configuration: ConfigurationIntent())
    }
    // Widgetをホーム画面に追加時、Widget Gallaryでの画面に表示するデータを作成する関数です。
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let accountingData = AccountingData(
            assets: 700000,
            liabilities: 300000,
            netAssets: 400000,
            expense: 300000,
            income: 500000,
            netIncomeOrLoss: 200000
        )
        let entry = SimpleEntry(date: Date(), accountingData: accountingData, configuration: configuration)
        completion(entry)
    }
    // WidgetKitへタイムラインを提供する関数です。
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let accountingData = AccountingData(
            assets: UserDefaults.appGroup.double(forKey: UserDefaults.Keys.assets.rawValue),
            liabilities: UserDefaults.appGroup.double(forKey: UserDefaults.Keys.liabilities.rawValue),
            netAssets: UserDefaults.appGroup.double(forKey: UserDefaults.Keys.netAssets.rawValue),
            expense: UserDefaults.appGroup.double(forKey: UserDefaults.Keys.expense.rawValue),
            income: UserDefaults.appGroup.double(forKey: UserDefaults.Keys.income.rawValue),
            netIncomeOrLoss: UserDefaults.appGroup.double(forKey: UserDefaults.Keys.netIncomeOrLoss.rawValue)
        )
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, accountingData: accountingData, configuration: configuration)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let accountingData: AccountingData
    
    let configuration: ConfigurationIntent
}
struct AccountingData {
    
    let assets: Double
    let liabilities: Double
    let netAssets: Double
    
    let expense: Double
    let income: Double
    
    let netIncomeOrLoss: Double
}

struct PaciolistSTGWidgetEntryView : View {
    var entry: Provider.Entry
    // 借方　全体
    var left: Double {
        let left = (entry.accountingData.assets + entry.accountingData.expense)
        print("ウィジェット　借方　全体", left)
        return left
    }
    // 貸方　全体
    var right: Double {
        // 当期純利益　の場合
        if !(entry.accountingData.netIncomeOrLoss < 0) {
            let right = (entry.accountingData.liabilities + entry.accountingData.netAssets + entry.accountingData.income)
            print("ウィジェット　貸方　全体", right)
            return right
        } else {
            let right = (entry.accountingData.liabilities + entry.accountingData.netAssets + entry.accountingData.income) + (entry.accountingData.netIncomeOrLoss * -1) // 純資産に当期純損失を足す
            print("ウィジェット　貸方　全体", right)
            return right
        }
    }
    // 借方
    var assetsScale: Double { // 資産
        // 数値が NaN（Not a Number）か判定する
        if (entry.accountingData.assets / right).isNaN {
            return 0
        } else {
            print("ウィジェット　借方　資産", (entry.accountingData.assets / right))
            return (entry.accountingData.assets / right)
        }
    }
    var expenseScale: Double { // 費用
        if (entry.accountingData.expense / right).isNaN {
            return 0
        } else {
            print("ウィジェット　借方　費用", (entry.accountingData.expense / right))
            return (entry.accountingData.expense / right)
        }
    }
    
    // 貸方
    var liabilitiesScale: Double { // 負債
        if (entry.accountingData.liabilities / left).isNaN {
            return 0
        } else {
            print("ウィジェット　貸方　負債", (entry.accountingData.liabilities / left))
            return (entry.accountingData.liabilities / left)
        }
    }
    var netAssetsScale: Double { // 純資産
        // 当期純利益　の場合
        if !(entry.accountingData.netIncomeOrLoss < 0) {
            if ((entry.accountingData.netAssets) / left).isNaN {
                return 0
            } else {
                // 資本振替 当期純利益の分を差し引かない
                print("ウィジェット　貸方　純資産", ((entry.accountingData.netAssets) / left))
                return ((entry.accountingData.netAssets) / left)
            }
        } else {
            if ((entry.accountingData.netAssets + (entry.accountingData.netIncomeOrLoss * -1)) / left).isNaN { // 純資産に当期純損失を足す
                return 0
            } else {
                print("ウィジェット　貸方　純資産", ((entry.accountingData.netAssets + (entry.accountingData.netIncomeOrLoss * -1)) / left))
                return ((entry.accountingData.netAssets + (entry.accountingData.netIncomeOrLoss * -1)) / left) // 純資産に当期純損失を足す
            }
        }
    }
    var netIncomeOrLossScale: Double { // 当期純利益　当期純損失
        // 当期純利益　の場合
        if !(entry.accountingData.netIncomeOrLoss < 0) {
            if (entry.accountingData.netIncomeOrLoss / entry.accountingData.netAssets).isNaN {
                return 0
            } else {
                print("ウィジェット　貸方　当期純利益 / 純資産", (entry.accountingData.netIncomeOrLoss / entry.accountingData.netAssets))
                return (entry.accountingData.netIncomeOrLoss / entry.accountingData.netAssets)
            }
        } else {
            if ((entry.accountingData.netIncomeOrLoss * -1) / entry.accountingData.assets).isNaN { // 純資産に当期純損失を足す
                return 0
            } else {
                print("ウィジェット　借方　当期純損失 / 資産", ((entry.accountingData.netIncomeOrLoss * -1) / entry.accountingData.assets))
                return ((entry.accountingData.netIncomeOrLoss * -1) / entry.accountingData.assets) // 純資産に当期純損失を足す
            }
        }
    }
    var incomeScale: Double { // 収益
        if ((entry.accountingData.income) / left).isNaN {
            return 0
        } else {
            print("ウィジェット　貸方　収益", ((entry.accountingData.income) / left))
            return ((entry.accountingData.income) / left)
        }
    }
    
    func minHeightCheck(minHeight: Double, height: Double) -> Double {
        // レイアウト崩れのため、一旦不使用
        //        if minHeight > height {
        //            return minHeight
        //        } else {
        return height
        //        }
    }
    
    func convertAmount(amount: Double) -> String {
        // 小数点第2位や3位など任意の桁数で丸め処理
        let fixedAmount = floor(amount / 1000)
        // 文字列型に変換して小数点の表示桁数を調整
        return String(format: "%.0f", fixedAmount)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack() {
                VStack(spacing: 0) {
                    //                    HStack(spacing: 0) {
                    //                        Text("\(String(format: "%.0f", left))")
                    //                        Text("\(assetsScale + expenseScale)")
                    //                            .font(.caption)
                    //                            .frame(maxWidth: .infinity, alignment: .leading)
                    //
                    //                        Text("\(String(format: "%.0f", right))")
                    //                        Text("\(liabilitiesScale + netAssetsScale + netIncomeOrLossScale + incomeScale)")
                    //                            .font(.caption)
                    //                            .frame(maxWidth: .infinity, alignment: .trailing)
                    //                    }
                    //                    Text("\(left == right ? "true" : "false\(left - right)")")
                    //                        .font(.caption)
                    Text("\("(単位: 千円)")")
                        .font(.caption)
                        .fontWeight(.ultraLight)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
                .zIndex(1)
                
                HStack(spacing: 0) {
                    // 借方
                    VStack(spacing: 0) {
                        // 資産
                        // 当期純損失　の場合
                        if entry.accountingData.netIncomeOrLoss < 0 {
                            ZStack(alignment: .bottom) {
                                //　Text("\(assetsScale)")
                                Text("\(convertAmount(amount: entry.accountingData.assets - (entry.accountingData.netIncomeOrLoss * -1)))") // 純資産に当期純損失を足す
                                    .frame(maxWidth: .infinity, minHeight: 15, maxHeight: geometry.size.height - 15, alignment: .topTrailing)
                                // 調整するため、高さを指定しない
                                //                             .frame(height: minHeightCheck(minHeight: 15, height: geometry.size.height * assetsScale <= geometry.size.height - 15 ? geometry.size.height * assetsScale : geometry.size.height - 15))
                                //                                    .background(.yellow)
                                    .font(.caption)
                                //                                .addBorder(.gray, width: 0.5, cornerRadius: 1)
                                    .zIndex(0)
                                
                                GeometryReader { geometry in
                                    VStack(spacing: 0) {
                                        
                                        Spacer()
                                        
                                        //　Text("\(netIncomeOrLossScale)")
                                        Text("\(convertAmount(amount: entry.accountingData.netIncomeOrLoss * -1))")
                                            .frame(maxWidth: .infinity, minHeight: 15, maxHeight: geometry.size.height - 45, alignment: .topTrailing)
                                        // 調整するため、高さを指定しない
                                            .frame(height: minHeightCheck(minHeight: 15, height: geometry.size.height * netIncomeOrLossScale <= geometry.size.height - 45 ? geometry.size.height * netIncomeOrLossScale : geometry.size.height - 45))
                                            .background(Color.plColor)
                                            .font(.caption)
                                            .addBorder(.gray, width: 0.5, cornerRadius: 1)
                                            .zIndex(1)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 15, maxHeight: geometry.size.height - 15, alignment: .bottom)
                            .frame(height: minHeightCheck(minHeight: 15, height: geometry.size.height * assetsScale <= geometry.size.height - 15 ? geometry.size.height * assetsScale : geometry.size.height - 15))
                            //                            .background(Color.pink)
                            .addBorder(.gray, width: 0.5, cornerRadius: 1)
                            
                        } else {
                            //　Text("\(assetsScale)")
                            Text("\(convertAmount(amount: entry.accountingData.assets))")
                                .frame(maxWidth: .infinity, minHeight: 15, maxHeight: geometry.size.height - 15, alignment: .topTrailing)
                            // 調整するため、高さを指定しない
                                .frame(height: minHeightCheck(minHeight: 15, height: geometry.size.height * assetsScale <= geometry.size.height - 15 ? geometry.size.height * assetsScale : geometry.size.height - 15))
                                .font(.caption)
                                .addBorder(.gray, width: 0.5, cornerRadius: 1)
                        }
                        
                        //　Text("\(expenseScale)")
                        Text("\(convertAmount(amount: entry.accountingData.expense))")
                            .frame(maxWidth: .infinity, minHeight: 15, maxHeight: geometry.size.height - 15, alignment: .topTrailing)
                            .frame(height: minHeightCheck(minHeight: 15, height: geometry.size.height * expenseScale <= geometry.size.height - 15 ? geometry.size.height * expenseScale : geometry.size.height - 15))
                        //                            .background(.green)
                            .background(Color.plColor)
                            .font(.caption)
                            .addBorder(.gray, width: 0.5, cornerRadius: 1)
                    }
                    .frame(height: geometry.size.height)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // .background(.pink)
                    
                    // 貸方
                    VStack(spacing: 0) {
                        //　Text("\(liabilitiesScale)")
                        Text("\(convertAmount(amount: entry.accountingData.liabilities))")
                            .frame(maxWidth: .infinity, minHeight: 15, maxHeight: geometry.size.height - 45, alignment: .topTrailing)
                            .frame(height: minHeightCheck(minHeight: 15, height: geometry.size.height * liabilitiesScale <= geometry.size.height - 45 ? geometry.size.height * liabilitiesScale : geometry.size.height - 45))
                        // .background(.brown)
                            .font(.caption)
                            .addBorder(.gray, width: 0.5, cornerRadius: 1)
                        
                        // 純資産
                        ZStack() {
                            //　Text("\(netAssetsScale)")
                            Text("\(convertAmount(amount: entry.accountingData.netAssets + (entry.accountingData.netIncomeOrLoss * -1)))")
                                .frame(maxWidth: .infinity, minHeight: 15, maxHeight: geometry.size.height - 45, alignment: .topTrailing) // 資本振替 当期純利益の分を差し引く
                            //                                .frame(height: minHeightCheck(minHeight: 15, height: geometry.size.height * netAssetsScale <= geometry.size.height - 45 ? geometry.size.height * netAssetsScale : geometry.size.height - 45))
                            // .background(.secondary)
                                .font(.caption)
                            //                                .addBorder(.gray, width: 0.5, cornerRadius: 1)
                            
                            // 当期純利益　の場合
                            if !(entry.accountingData.netIncomeOrLoss < 0) {
                                //　Text("\(netIncomeOrLossScale)")
                                Text("\(convertAmount(amount: entry.accountingData.netIncomeOrLoss))")
                                    .frame(maxWidth: .infinity, minHeight: 15, maxHeight: geometry.size.height - 45, alignment: .bottomTrailing)
                                // 調整するため、高さを指定しない
                                    .frame(height: minHeightCheck(minHeight: 15, height: geometry.size.height * netIncomeOrLossScale <= geometry.size.height - 45 ? geometry.size.height * netIncomeOrLossScale : geometry.size.height - 45))
                                    .background(Color.plColor)
                                    .font(.caption)
                                    .addBorder(.gray, width: 0.5, cornerRadius: 1)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 15, maxHeight: geometry.size.height - 45, alignment: .topTrailing) // 資本振替 当期純利益の分を差し引く
                        .frame(height: minHeightCheck(minHeight: 15, height: geometry.size.height * netAssetsScale <= geometry.size.height - 45 ? geometry.size.height * netAssetsScale : geometry.size.height - 45))
                        .addBorder(.gray, width: 0.5, cornerRadius: 1)
                        
                        //　Text("\(incomeScale)")
                        Text("\(convertAmount(amount: entry.accountingData.income))")
                            .frame(maxWidth: .infinity, minHeight: 15, maxHeight: geometry.size.height - 45, alignment: .topTrailing) // 資本振替 当期純利益の分を差し引く
                            .frame(height: minHeightCheck(minHeight: 15, height: geometry.size.height * incomeScale <= geometry.size.height - 45 ? geometry.size.height * incomeScale : geometry.size.height - 45))
                            .background(Color.plColor)
                            .font(.caption)
                            .addBorder(.gray, width: 0.5, cornerRadius: 1)
                    }
                    .frame(height: geometry.size.height)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // .background(.mint)
                }
                .frame(height: geometry.size.height)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.mainColor2)
            }
            //            .background(Color.pink)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(13)
        .background(Color.baseColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
extension View {
    func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S: ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
            .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}
typealias Key = UserDefaults.Keys

extension UserDefaults {
    static let appGroup = UserDefaults(suiteName: "group.com.ikingdom.AccountantSTG")!
    //App Groupsの名前が書かれている。
    //UserDefaultsの中の住所のようなもの。
    //appGroupと出てきたら、これのこと。これが共通だと、
    //アプリが違っていても共通の場所のデータを読み書きできる。
}

extension UserDefaults {
    enum Keys: String {
        case assets
        case liabilities
        case netAssets
        
        case expense
        case income
        
        case netIncomeOrLoss
    }
}
struct PaciolistSTGWidget: Widget {
    let kind: String = "PaciolistSTGWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            PaciolistSTGWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("B/S and P/L") // 『Widgetの名称』
        .description("This is an map of B/S and P/L widget.") // 『Widgetの説明』
    }
}

struct PaciolistSTGWidget_Previews: PreviewProvider {
    static var previews: some View {
        //        let accountingData = AccountingData(
        //            assets: 700000,
        //            liabilities: 300000,
        //            netAssets: 400000,
        //            expense: 300000,
        //            income: 500000,
        //            netIncomeOrLoss: 200000
        //        )
        let accountingData = AccountingData(
            assets:          700000,
            liabilities:     300000,
            netAssets:       400000,
            expense:         500000,
            income:          500000,
            netIncomeOrLoss: 000000
        )
        //        let accountingData = AccountingData(
        //            assets:           200000,
        //            liabilities:      100000,
        //            netAssets:        100000,
        //            expense:          100000,
        //            income:                0,
        //            netIncomeOrLoss: -100000
        //        )
        PaciolistSTGWidgetEntryView(entry: SimpleEntry(date: Date(), accountingData: accountingData, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
