//
//  Utilitity.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/05/12.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation

class DateManager {
    
    public static let shared = DateManager()
    
    private init() {
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatter.timeZone = .current
        
        dateFormatterMMdd.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatterMMdd.timeZone = .current
        
        dateFormatteryyyyMMddHHmmss.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatteryyyyMMddHHmmss.timeZone = .current
        
        dateFormatteryyyyMMdd.dateFormat = "yyyy-MM-dd"
        dateFormatteryyyyMMdd.timeZone = .current
        
        timezone.dateFormat = "MM-dd"
        timezone.timeZone = .current
        timezone.locale = Locale(identifier: "en_US_POSIX")
        
        dateFormatterHHmmss.dateFormat = DateFormatter.dateFormat(fromTemplate: "'T'HH:mm:ss.SSSZZZZZ", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatterHHmmss.timeZone = .current
        
        dateFormatterYYYY.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatterYYYY.timeZone = .current
    }
    
    let now = Date() // UTC時間なので　9時間ずれる
    
    let formatter = DateFormatter() // 年/月/日 時:分
    let dateFormatter = DateFormatter() // 年/月/日
    let dateFormatterMMdd = DateFormatter() // 月/日
    
    let dateFormatteryyyyMMddHHmmss = DateFormatter() // 年-月-日 時分秒
    let dateFormatteryyyyMMdd = DateFormatter() // 年-月-日
    let timezone = DateFormatter() // 月-日
    
    let dateFormatterHHmmss = DateFormatter() // 時分秒
    
    let dateFormatterYYYY = DateFormatter() // 年
    
    // 期中：期首～期末までの間の期間。
    // 年度変更機能 引数の日付が、会計期間の範囲内に入っているかどうかを判定する
    func isInPeriod(date: String) -> Bool {
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear() // 年度
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning()                  // 決算日
        var fiscalYearFixed = 0 // 補正値
        if theDayOfReckoning == "12/31" {
            fiscalYearFixed = 0 // 年度と同じ年
        } else {
            fiscalYearFixed = 1 // 年度 + 1年
        }
        // 今年度の決算日　決算日 + 年度 + 時分秒
        let fullTheDayOfReckoning = dateFormatteryyyyMMddHHmmss.date(from: theDayOfReckoning + "/" + String(fiscalYear + fiscalYearFixed) + ", " + dateFormatterHHmmss.string(from: now))!
        // 年度開始日　決算日の翌日に設定する
        var dayOfStartInPeriod = Calendar.current.date(byAdding: .year, value: -1, to: fullTheDayOfReckoning)! // 今年度の決算日 -１年
        dayOfStartInPeriod = Calendar.current.date(byAdding: .day, value: 1, to: dayOfStartInPeriod)!          // 今年度の決算日 +１日
        // 形式を変換する　"yyyy/MM/dd"　→ "yyyy-MM-dd"
        let objectDate = dateFormatteryyyyMMdd.date(from: date)
        // 形式を変換する　"yyyy/MM/dd"　→ "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let journalEntryDate = dateFormatteryyyyMMddHHmmss.date(from: dateFormatter.string(from: objectDate ?? Date()) + ", " + dateFormatterHHmmss.string(from: now))!
        print("####開始日　", dayOfStartInPeriod)
        print("####仕訳日付", date)
        print("####変換後　", journalEntryDate)
        print("####決算日　", fullTheDayOfReckoning)
        print(journalEntryDate < dayOfStartInPeriod, fullTheDayOfReckoning < journalEntryDate)
        
        if journalEntryDate < dayOfStartInPeriod || fullTheDayOfReckoning < journalEntryDate {
            return false // 範囲外
        } else {
            return true // 範囲内
        }
    }
    // 期首：会計期間の開始日。Beginning of Year
    // 期末：会計期間の最終日。決算日とも言います。
    func getBeginningOfYearDate() -> String {
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear() // 年度
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning() // 決算日
        var fiscalYearFixed = 0 // 補正値
        if theDayOfReckoning == "12/31" {
            fiscalYearFixed = 0 // 年度と同じ年
        } else {
            fiscalYearFixed = 1 // 年度 + 1年
        }
        // 今年度の決算日　決算日 + 年度 + 時分秒
        let fullTheDayOfReckoning = dateFormatteryyyyMMddHHmmss.date(from: theDayOfReckoning + "/" + String(fiscalYear + fiscalYearFixed) + ", " + dateFormatterHHmmss.string(from: now))!
        // 年度開始日　決算日の翌日に設定する
        var dayOfStartInPeriod = Calendar.current.date(byAdding: .year, value: -1, to: fullTheDayOfReckoning)! // 今年度の決算日 -１年
        dayOfStartInPeriod = Calendar.current.date(byAdding: .day, value: 1, to: dayOfStartInPeriod)! // 前年度の決算日 ＋１日
        return dateFormatterYYYY.string(from: dayOfStartInPeriod) + "/" + dateFormatterMMdd.string(from: dayOfStartInPeriod)
    }
    
    func getDate() -> String {
        
        formatter.string(from: Date())
    }
}
