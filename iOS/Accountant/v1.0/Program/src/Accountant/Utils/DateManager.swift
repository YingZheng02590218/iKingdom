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
        // UIのピッカーで選択した日付を、データベースにに渡すために、yyyy/MM/dd形式でDate型へ変換するために使用する
        // dateFormatterPicker.dateFormat = "yyyy/MM/dd"     // 注意：　小文字のyにしなければならない
        dateFormatterPicker.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatterPicker.calendar = Calendar(identifier: .gregorian)
        // dateFormatterPicker.timeZone = TimeZone.current // UTC時刻を補正
        dateFormatterPicker.timeZone = TimeZone(secondsFromGMT: 0 * 60 * 60)
        // dateFormatterPicker.locale = Locale.current
        
        // データベースに保持した日付をUIのピッカーに渡すために、yyyy/MM/dd形式でDate型へ変換するために使用する
        dateFormatterStringToDate.dateFormat = "yyyy/MM/dd"
        dateFormatterStringToDate.calendar = Calendar(identifier: .gregorian)
        dateFormatterStringToDate.timeZone = TimeZone(secondsFromGMT: 0 * 60 * 60)
        dateFormatterStringToDate.locale = Locale(identifier: "en_US_POSIX")
        
        // 現在日時
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        // TODO: locale
        formatter.calendar = Calendar(identifier: .gregorian)
        // TODO: timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX") // この書き方は効かない
        
        // 会計期間の範囲内に入っているかどうかを判定する
        // dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0 * 60 * 60)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // 会計期間の範囲内に入っているかどうかを判定する
        dateFormatteryyyyMMdd.dateFormat = "yyyy-MM-dd"
        // dateFormatteryyyyMMdd.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatteryyyyMMdd.calendar = Calendar(identifier: .gregorian)
        dateFormatteryyyyMMdd.timeZone = TimeZone(secondsFromGMT: 0 * 60 * 60)
        dateFormatteryyyyMMdd.locale = Locale(identifier: "en_US_POSIX")
        
        // 期首　月日
        dateFormatterMMdd.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatterMMdd.calendar = Calendar(identifier: .gregorian)
        dateFormatterMMdd.timeZone = TimeZone(secondsFromGMT: 0 * 60 * 60)
        
        // ピッカーの初期値 最大値　最小値
        dateFormatteryyyyMMddHHmmss.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatteryyyyMMddHHmmss.calendar = Calendar(identifier: .gregorian)
        dateFormatteryyyyMMddHHmmss.timeZone = TimeZone(secondsFromGMT: 0 * 60 * 60)
        
        // ピッカーの初期値 最大値　最小値
        dateFormatterYYYY.dateFormat = DateFormatter.dateFormat(fromTemplate: "YYYY", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatterYYYY.calendar = Calendar(identifier: .gregorian)
        dateFormatterYYYY.timeZone = TimeZone(secondsFromGMT: 0 * 60 * 60)
        
        // ピッカーの初期値 最大値　最小値
        timezone.dateFormat = "MM-dd"
        // timezone.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM-dd", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        timezone.calendar = Calendar(identifier: .gregorian)
        timezone.timeZone = TimeZone(secondsFromGMT: 0 * 60 * 60)
        // TODO: locale これで効いてる？
        // timezone.locale = Locale(identifier: "en_US_POSIX")
        
        // ピッカーの初期値 最大値　最小値
        dateFormatterHHmmss.dateFormat = DateFormatter.dateFormat(fromTemplate: "'T'HH:mm:ss.SSSZZZZZ", options: 0, locale: Locale(identifier: "en_US_POSIX"))
        dateFormatterHHmmss.calendar = Calendar(identifier: .gregorian)
        dateFormatterHHmmss.timeZone = TimeZone(secondsFromGMT: 0 * 60 * 60)
    }
    
    let now = Date() // UTC時間なので　9時間ずれる
    let calendar = Calendar(identifier: .gregorian)

    let dateFormatterPicker = DateFormatter() // 年/月/日
    let dateFormatterStringToDate = DateFormatter() // 年/月/日
    let formatter = DateFormatter() // 年/月/日 時:分
    let dateFormatter = DateFormatter() // 年/月/日
    let dateFormatterMMdd = DateFormatter() // 月/日
    let dateFormatteryyyyMMddHHmmss = DateFormatter() // 年-月-日 時分秒
    let dateFormatteryyyyMMdd = DateFormatter() // 年-月-日
    let dateFormatterYYYY = DateFormatter() // 年
    let timezone = DateFormatter() // 月-日
    let dateFormatterHHmmss = DateFormatter() // 時分秒
    
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
        guard let fullTheDayOfReckoning = dateFormatter.date(from: String(fiscalYear + fiscalYearFixed) + "/" + theDayOfReckoning) else {
            return false
        }
        // 年度開始日　決算日の翌日に設定する
        guard let dayOfStartInPeriod = calendar.date(byAdding: .year, value: -1, to: fullTheDayOfReckoning), // 今年度の決算日 -１年
              let dayOfStartInPeriod = calendar.date(byAdding: .day, value: 1, to: dayOfStartInPeriod) else {
            return false
        } // 今年度の決算日 +１日
        // 形式を変換する　"yyyy/MM/dd"　→ "yyyy-MM-dd"
        guard let objectDate = dateFormatteryyyyMMdd.date(from: date) else {
            return false
        }
        // 形式を変換する　"yyyy/MM/dd"　→ "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        guard let journalEntryDate = dateFormatter.date(from: dateFormatter.string(from: objectDate)) else {
            return false
        }
        print("####開始日　", dayOfStartInPeriod)
        print("####仕訳日付", date)
        print("####変換前　", objectDate)
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
        guard let fullTheDayOfReckoning = dateFormatter.date(from: String(fiscalYear + fiscalYearFixed) + "/" + theDayOfReckoning) else {
            return ""
        }
        // 年度開始日　決算日の翌日に設定する
        guard let dayOfStartInPeriod = calendar.date(byAdding: .year, value: -1, to: fullTheDayOfReckoning), // 今年度の決算日 -１年
              let dayOfStartInPeriod = calendar.date(byAdding: .day, value: 1, to: dayOfStartInPeriod) else {
            return ""
        } // 今年度の決算日 +１日
        // 先頭を0埋めする
        return "\(dayOfStartInPeriod.year)" + "/" + "\(String(format: "%02d", dayOfStartInPeriod.month))" + "/" + "\(String(format: "%02d", dayOfStartInPeriod.day))"
    }
    
    // 期末：会計期間の最終日。決算日とも言います。
    func getEndingOfYearDate() -> String {
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear() // 年度
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning() // 決算日
        var fiscalYearFixed = 0 // 補正値
        if theDayOfReckoning == "12/31" {
            fiscalYearFixed = 0 // 年度と同じ年
        } else {
            fiscalYearFixed = 1 // 年度 + 1年
        }
        // 今年度の決算日　決算日 + 年度 + 時分秒
        guard let fullTheDayOfReckoning = dateFormatter.date(from: String(fiscalYear + fiscalYearFixed) + "/" + theDayOfReckoning) else {
            return ""
        }
        // 先頭を0埋めする
        return "\(fullTheDayOfReckoning.year)" + "/" + "\(String(format: "%02d", fullTheDayOfReckoning.month))" + "/" + "\(String(format: "%02d", fullTheDayOfReckoning.day))"
    }
    
    // 期首　月日
    func getTheDayOfBeginningOfYear() -> String {
        let fiscalYear = DataBaseManagerSettingsPeriod.shared.getSettingsPeriodYear() // 年度
        let theDayOfReckoning = DataBaseManagerSettingsPeriod.shared.getTheDayOfReckoning() // 決算日
        var fiscalYearFixed = 0 // 補正値
        if theDayOfReckoning == "12/31" {
            fiscalYearFixed = 0 // 年度と同じ年
        } else {
            fiscalYearFixed = 1 // 年度 + 1年
        }
        // 今年度の決算日　決算日 + 年度 + 時分秒
        guard let fullTheDayOfReckoning = dateFormatter.date(from: String(fiscalYear + fiscalYearFixed) + "/" + theDayOfReckoning) else {
            return ""
        }
        // 年度開始日　決算日の翌日に設定する
        guard let dayOfStartInPeriod = calendar.date(byAdding: .year, value: -1, to: fullTheDayOfReckoning), // 今年度の決算日 -１年
              let dayOfStartInPeriod = calendar.date(byAdding: .day, value: 1, to: dayOfStartInPeriod) else {
            return ""
        } // 今年度の決算日 +１日
        
        return dateFormatterMMdd.string(from: dayOfStartInPeriod)
    }
    
    // 現在日時
    func getDate() -> String {
        
        formatter.string(from: Date())
    }
}
