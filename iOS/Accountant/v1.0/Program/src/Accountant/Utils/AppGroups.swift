//
//  AppGroups.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/02/09.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation

public struct AppGroups {
    
    static var appGroupsId: String {
        let bundleIdentifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? "com.ikingdom.Accountant"
        if bundleIdentifier == "com.ikingdom.Accountant" {
            return "group.com.ikingdom.Accountant"
        } else {
            return "group.com.ikingdom.AccountantSTG"
        }
    }
}
