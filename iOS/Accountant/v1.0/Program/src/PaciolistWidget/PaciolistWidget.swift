//
//  PaciolistWidget.swift
//  PaciolistWidget
//
//  Created by Hisashi Ishihara on 2023/02/08.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

// TimelineProvider(プロトコル)は、Widgetの更新タイミングを提供します。
// そして、TimelineProviderには、以下3つの関数があります。
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
// Widgetの画面を定義する構造体です
// Widgetの画面に表示する内容を変更する場合、この構造体を編集します。
struct PaciolistWidgetEntryView : View {
    var entry: Provider.Entry
    // 借方　全体
    var left: Double {
        let left = (entry.accountingData.assets + entry.accountingData.expense)
        print("ウィジェット　借方　全体　金額", Int(left), "資産", Int(entry.accountingData.assets), "費用", Int(entry.accountingData.expense))
        return left
    }
    // 貸方　全体
    var right: Double {
        // 当期純利益　の場合
        if !(entry.accountingData.netIncomeOrLoss < 0) {
            // 当期純利益の場合、当期純利益を収益から差し引く。純資産Viewに重ねて表示させる。
            let right = (entry.accountingData.liabilities + entry.accountingData.netAssets + (entry.accountingData.income - entry.accountingData.netIncomeOrLoss))
            print("ウィジェット　貸方　全体　金額", Int(right), "負債", Int(entry.accountingData.liabilities), "純資産", Int(entry.accountingData.netAssets), "収益", Int(entry.accountingData.income - entry.accountingData.netIncomeOrLoss))
            return right
        } else {
            // 当期純損失の場合、当期純損失を純資産へ足す。純資産Viewに重ねて表示させる。
            let right = (entry.accountingData.liabilities + entry.accountingData.netAssets + (entry.accountingData.income + (entry.accountingData.netIncomeOrLoss * -1))) // 純資産に当期純損失を足す
            print("ウィジェット　貸方　全体　金額", Int(right), "負債", Int(entry.accountingData.liabilities), "純資産", Int(entry.accountingData.netAssets), "収益", Int(entry.accountingData.income + (entry.accountingData.netIncomeOrLoss * -1)))
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
            // 当期純損失の場合、当期純損失を純資産へ足す。純資産Viewに重ねて表示させる。
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
            if ((entry.accountingData.netIncomeOrLoss * -1) / entry.accountingData.expense).isNaN {
                return 0
            } else {
                print("ウィジェット　借方　当期純損失 / 費用", ((entry.accountingData.netIncomeOrLoss * -1) / entry.accountingData.expense))
                return ((entry.accountingData.netIncomeOrLoss * -1) / entry.accountingData.expense)
            }
        }
    }
    var incomeScale: Double { // 収益
        // 当期純利益　の場合
        if !(entry.accountingData.netIncomeOrLoss < 0) {
            // 当期純利益の場合、当期純利益を収益から差し引く。純資産Viewに重ねて表示させる。
            if ((entry.accountingData.income - entry.accountingData.netIncomeOrLoss) / left).isNaN {
                return 0
            } else {
                print("ウィジェット　貸方　収益", ((entry.accountingData.income - entry.accountingData.netIncomeOrLoss) / left))
                return ((entry.accountingData.income - entry.accountingData.netIncomeOrLoss) / left)
            }
        } else {
            if ((entry.accountingData.income) / left).isNaN {
                return 0
            } else {
                print("ウィジェット　貸方　収益", ((entry.accountingData.income) / left))
                return ((entry.accountingData.income) / left)
            }
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
        // 全体
        ZStack() {
            
            GeometryReader { geometry in
                // 借方貸方
                HStack(spacing: 0) {
                    // 借方
                    VStack(spacing: 0) {
                        // 資産
                        ZStack() {
                            Text("資産 ")
                                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topLeading)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                            
                            Text(convertAmount(amount: entry.accountingData.assets))
                                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topTrailing)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topTrailing)
                        .frame(height: minHeightCheck(minHeight: 0, height: geometry.size.height * assetsScale <= geometry.size.height ? geometry.size.height * assetsScale : geometry.size.height))
                        .addBorder(.gray, width: 0.5, cornerRadius: 1)
                        
                        // 費用
                        ZStack() {
                            // 当期純損失　の場合
                            if entry.accountingData.netIncomeOrLoss < 0 {
                                ZStack() {
                                    Text("費用 ")
                                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottomLeading)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .zIndex(0)
                                    
                                    Text(convertAmount(amount: entry.accountingData.expense - (entry.accountingData.netIncomeOrLoss * -1)))
                                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottomTrailing)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .zIndex(1)
                                }
                                
                                GeometryReader { geometry in
                                    VStack(spacing: 0) {
                                        ZStack() {
                                            Text("当期純損失 ")
                                                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topLeading)
                                                .font(.caption)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(1)
                                                .zIndex(0)
                                            
                                            Text(convertAmount(amount: entry.accountingData.netIncomeOrLoss * -1))
                                                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topTrailing)
                                                .background(Color.plColor)
                                                .font(.caption)
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(1)
                                                .zIndex(1)
                                            
                                            // Spacer() // レイアウト崩れる
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topTrailing)
                                    .frame(height: minHeightCheck(minHeight: 0, height: geometry.size.height * netIncomeOrLossScale <= geometry.size.height ? geometry.size.height * netIncomeOrLossScale : geometry.size.height))
                                    // .background(.green)
                                    .background(Color.mainColor2) // 重ねて表示させるので、背景が透過してしまう対策
                                    .addBorder(.gray, width: 0.5, cornerRadius: 1)
                                }
                            } else {
                                ZStack() {
                                    Text("費用 ")
                                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottomLeading)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .zIndex(0)
                                    
                                    Text(convertAmount(amount: entry.accountingData.expense))
                                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottomTrailing)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .zIndex(1)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottom)
                        .frame(height: minHeightCheck(minHeight: 0, height: geometry.size.height * expenseScale <= geometry.size.height ? geometry.size.height * expenseScale : geometry.size.height))
                        .background(Color.plColor)
                        .addBorder(.gray, width: 0.5, cornerRadius: 1)
                        
                    }
                    .frame(height: geometry.size.height)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // .background(.pink)
                    
                    // 貸方
                    VStack(spacing: 0) {
                        // 負債
                        ZStack() {
                            Text("負債 ")
                                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topLeading)
                            // .background(.brown)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                            
                            Text(convertAmount(amount: entry.accountingData.liabilities))
                                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topTrailing)
                            // .background(.brown)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topTrailing)
                        .frame(height: minHeightCheck(minHeight: 0, height: geometry.size.height * liabilitiesScale <= geometry.size.height ? geometry.size.height * liabilitiesScale : geometry.size.height))
                        .addBorder(.gray, width: 0.5, cornerRadius: 1)
                        
                        // 純資産
                        ZStack() {
                            // 当期純利益　の場合
                            if !(entry.accountingData.netIncomeOrLoss < 0) {
                                ZStack() {
                                    Text("純資産 ")
                                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topLeading)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .zIndex(0)
                                    
                                    Text(convertAmount(amount: entry.accountingData.netAssets + (entry.accountingData.netIncomeOrLoss * -1)))
                                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topTrailing)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .zIndex(1)
                                }
                                .zIndex(0)
                                
                                // 当期純利益が0円の場合　表示させない
                                if !(entry.accountingData.netIncomeOrLoss == 0) {
                                    GeometryReader { geometry in
                                        VStack(spacing: 0) {
                                            
                                            Spacer()
                                            
                                            ZStack() {
                                                Text("当期純利益 ")
                                                    .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottomLeading)
                                                    .font(.caption)
                                                    .multilineTextAlignment(.leading)
                                                    .lineLimit(1)
                                                    .zIndex(0)
                                                
                                                Text(convertAmount(amount: entry.accountingData.netIncomeOrLoss))
                                                    .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottomTrailing)
                                                    .background(Color.plColor)
                                                    .font(.caption)
                                                    .multilineTextAlignment(.leading)
                                                    .lineLimit(1)
                                                    .zIndex(1)
                                            }
                                            .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottomTrailing)
                                            .frame(height: minHeightCheck(minHeight: 0, height: geometry.size.height * netIncomeOrLossScale <= geometry.size.height ? geometry.size.height * netIncomeOrLossScale : geometry.size.height))
                                            .background(Color.mainColor2) // 重ねて表示させるので、背景が透過してしまう対策
                                            .addBorder(.gray, width: 0.5, cornerRadius: 1)
                                        }
                                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottomTrailing)
                                        .zIndex(1)
                                    }
                                }
                            } else {
                                ZStack() {
                                    Text("純資産 ")
                                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topLeading) // 資本振替 当期純利益の分を差し引く
                                    // .background(.secondary)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .zIndex(0)
                                    
                                    Text(convertAmount(amount: entry.accountingData.netAssets + (entry.accountingData.netIncomeOrLoss * -1)))
                                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topTrailing) // 資本振替 当期純利益の分を差し引く
                                    // .background(.secondary)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .zIndex(1)
                                }
                                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topLeading) // 資本振替 当期純利益の分を差し引く
                                .zIndex(0)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topTrailing) // 資本振替 当期純利益の分を差し引く
                        .frame(height: minHeightCheck(minHeight: 0, height: geometry.size.height * netAssetsScale <= geometry.size.height ? geometry.size.height * netAssetsScale : geometry.size.height))
                        .addBorder(.gray, width: 0.5, cornerRadius: 1)
                        // .background(.mint)
                        
                        // 当期純利益　の場合
                        if !(entry.accountingData.netIncomeOrLoss < 0) {
                            // 収益　が0円の場合　表示させない
                            if !(entry.accountingData.income - entry.accountingData.netIncomeOrLoss == 0) {
                                // 収益
                                ZStack() {
                                    Text("収益 ")
                                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottomLeading)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .zIndex(0)
                                    
                                    Text(convertAmount(amount: entry.accountingData.income - entry.accountingData.netIncomeOrLoss))
                                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottomTrailing)
                                        .background(Color.plColor)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .zIndex(1)
                                }
                                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topLeading) // 資本振替 当期純利益の分を差し引く
                                .frame(height: minHeightCheck(minHeight: 0, height: geometry.size.height * incomeScale <= geometry.size.height ? geometry.size.height * incomeScale : geometry.size.height))
                                .addBorder(.gray, width: 0.5, cornerRadius: 1)
                            }
                        } else {
                            // 収益
                            ZStack() {
                                Text("収益 ")
                                    .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottomLeading)
                                    .font(.caption)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                                    .zIndex(0)
                                
                                Text(convertAmount(amount: entry.accountingData.income))
                                    .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .bottomTrailing)
                                    .background(Color.plColor)
                                    .font(.caption)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                                    .zIndex(1)
                            }
                            .frame(maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height, alignment: .topLeading) // 資本振替 当期純利益の分を差し引く
                            .frame(height: minHeightCheck(minHeight: 0, height: geometry.size.height * incomeScale <= geometry.size.height ? geometry.size.height * incomeScale : geometry.size.height))
                            .addBorder(.gray, width: 0.5, cornerRadius: 1)
                        }
                    }
                    .frame(height: geometry.size.height)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // .background(.mint)
                }
                .frame(height: geometry.size.height)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.mainColor2)
            }
            .padding(13)
            .background(Color.baseColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(0)
            
            Text("\("Paciolist")")
                .font(.caption)
                .fontWeight(.heavy)
                .shadow(color: .gray, radius: 0, x: 0, y: 2)  // 記述位置を変更
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, 16)
                .zIndex(1)
            
            Text("\("(単位: 千円)")")
                .font(.caption)
                .fontWeight(.ultraLight)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 16)
                .zIndex(1)
        }
        // .background(Color.pink)
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
    static let appGroup = UserDefaults(suiteName: "group.com.ikingdom.Accountant")!
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

// Widgetがプログラムで最初に実行されるエントリーポイントになります。
struct PaciolistWidget: Widget {
    // kind : Widgetの識別子
    let kind: String = "PaciolistWidget"
    // provider : Widgetの更新タイミング(TimeLine ※2 )をWidgetKitに提供するプロバイダ
    
    var body: some WidgetConfiguration {
        // IntentConfiguration：ユーザ設定可能なプロパティを持たないWidgetを実装する際に利用する型
        // StaticConfiguration：ユーザーが設定可能なプロパティを持つWidgetを実装する際に利用する型
        // IntentConfigurationを利用する場合、Widget Extensionをプロジェクトに導入時に 『Include Configuration Intentのチェックボックスをオン』 にする必要があります。
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            PaciolistWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("B/S and P/L") // 『Widgetの名称』
        .description("This is an map of B/S and P/L widget.") // 『Widgetの説明』
    }
}

struct PaciolistWidget_Previews: PreviewProvider {
    static var previews: some View {
        let accountingData = AccountingData(
            assets: 700000,
            liabilities: 300000,
            netAssets: 400000,
            expense: 300000,
            income: 500000,
            netIncomeOrLoss: 200000
        )
        PaciolistWidgetEntryView(entry: SimpleEntry(date: Date(), accountingData: accountingData, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
