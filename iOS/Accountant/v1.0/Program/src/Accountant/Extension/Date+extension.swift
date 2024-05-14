//
//  Date+extension.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/03/16.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation

extension Date {
    
    public init?(year: Int?, month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        guard let date = Calendar(identifier: .gregorian).date(from: components) else {
            return nil
        }
        self = date
    }
    
    public var year: Int {
        Calendar(identifier: .gregorian).component(.year, from: self)
    }
    
    public var month: Int {
        Calendar(identifier: .gregorian).component(.month, from: self)
    }
    
    public var day: Int {
        Calendar(identifier: .gregorian).component(.day, from: self)
    }
    
    public var hour: Int {
        Calendar(identifier: .gregorian).component(.hour, from: self)
    }
    
    public var minute: Int {
        Calendar(identifier: .gregorian).component(.minute, from: self)
    }
    
    public var second: Int {
        Calendar(identifier: .gregorian).component(.second, from: self)
    }
    
    public func toString(format: String, timeZone: TimeZone = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: format, options: 0, locale: Locale(identifier: "en_US_POSIX"))
        return dateFormatter.string(from: self)
    }
    
    public static func convertDate(from dateString: String, format: String, timeZone: TimeZone = .current) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        // dateFormatter.locale = Locale(identifier: "en_US_POSIX") この書き方は誤り
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: format, options: 0, locale: Locale(identifier: "en_US_POSIX"))
        return dateFormatter.date(from: dateString)
    }

    public static func iso8601String(date: Date, timeZone: TimeZone = .current) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: date)
    }
    
    public static func iso8601Date(from dateString: String, timeZone: TimeZone = .current) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = timeZone
        return dateFormatter.date(from: dateString)
    }
}
