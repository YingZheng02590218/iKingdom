//
//  DataBaseSettingsOperating.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/10.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 設定操作
class DataBaseSettingsOperating: RObject {
    convenience init(
        EnglishFromOfClosingTheLedger0: Bool,
        EnglishFromOfClosingTheLedger1: Bool,
        EnglishFromOfClosingTheLedger2: Bool
    ) {
        self.init()

        self.EnglishFromOfClosingTheLedger0 = EnglishFromOfClosingTheLedger0
        self.EnglishFromOfClosingTheLedger1 = EnglishFromOfClosingTheLedger1
        self.EnglishFromOfClosingTheLedger2 = EnglishFromOfClosingTheLedger2
    }

    @objc dynamic var EnglishFromOfClosingTheLedger0: Bool = true // 損益振替仕訳 初期値はON
    @objc dynamic var EnglishFromOfClosingTheLedger1: Bool = true // 資本振替仕訳 初期値はON
    @objc dynamic var EnglishFromOfClosingTheLedger2: Bool = true // 残高振替仕訳 初期値はON
}
