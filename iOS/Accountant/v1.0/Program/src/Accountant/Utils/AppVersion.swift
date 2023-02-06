//
//  AppVersion.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/19.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation

public struct AppVersion {
    
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
