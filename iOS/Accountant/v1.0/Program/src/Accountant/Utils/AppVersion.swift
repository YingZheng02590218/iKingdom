//
//  AppVersion.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/19.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation

struct AppVersion {
    
    let versionString: String // アプリバージョン文字列
    let majorVersion: Int // メジャーバージョン
    let minorVersion: Int // マイナーバージョン
    let patchVersion: Int // パッチバージョン
    
    init?(_ version: String) {
        let versionNumbers = version.components(separatedBy: ".").compactMap { Int($0) }
        if versionNumbers.count == 3 {
            versionString = version
            majorVersion = versionNumbers[0]
            minorVersion = versionNumbers[1]
            patchVersion = versionNumbers[2]
        } else {
            print("Does not meet the conditions of Semantic Versioning. App Version: \(version)")
            return nil
        }
    }

    static var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
    
    static var currentBuildVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1.0.0"
    }

    static var identifier: String {
#if DEBUG
        // STG環境で動作確認するため
        "com.ikingdom.Accountant"
#else
        Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "com.ikingdom.Accountant"
#endif
    }

    //    static func convertVersionValue(string: String) -> Int {
    //        let versionList = string.components(separatedBy: ".")
    //        guard versionList.count == 3 else { return 10_000 }
    //        let major = versionList[0]
    //        let minor = String(format: "%02d", Int(versionList[1]) ?? 0)
    //        let revision = String(format: "%02d", Int(versionList[2]) ?? 0)
    //        return Int(major + minor + revision) ?? 10_000
    //    }
}

// MARK: - AppVersion Comparable Functions
extension AppVersion: Comparable {

    // 左辺と右辺は等しい
    static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {

        if lhs.majorVersion == rhs.majorVersion,
           lhs.minorVersion == rhs.minorVersion,
           lhs.patchVersion == rhs.patchVersion {
            return true
        }

        return false
    }

    // 左辺は右辺より小さい
    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {

        if lhs.majorVersion != rhs.majorVersion {
            return lhs.majorVersion < rhs.majorVersion
        }
        if lhs.minorVersion != rhs.minorVersion {
            return lhs.minorVersion < rhs.minorVersion
        }
        if lhs.patchVersion != rhs.patchVersion {
            return lhs.patchVersion < rhs.patchVersion
        }

        return false
    }

    // 左辺は右辺より大きい
    static func > (lhs: AppVersion, rhs: AppVersion) -> Bool {

        if lhs.majorVersion != rhs.majorVersion {
            return lhs.majorVersion > rhs.majorVersion
        }
        if lhs.minorVersion != rhs.minorVersion {
            return lhs.minorVersion > rhs.minorVersion
        }
        if lhs.patchVersion != rhs.patchVersion {
            return lhs.patchVersion > rhs.patchVersion
        }

        return false
    }

    // 左辺は右辺以下
    static func <= (lhs: AppVersion, rhs: AppVersion) -> Bool {

        if lhs == rhs {
            return true
        }

        return lhs < rhs
    }

    // 左辺は右辺以上
    static func >= (lhs: AppVersion, rhs: AppVersion) -> Bool {

        if lhs == rhs {
            return true
        }

        return lhs > rhs
    }
}
