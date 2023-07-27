//
//  DataBaseSettingsOperatingJournalEntryGroup.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/07/15.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 設定仕訳画面 よく使う仕訳のグループ
class DataBaseSettingsOperatingJournalEntryGroup: RObject {
    convenience init(
        groupName: String
    ) {
        self.init()

        self.groupName = groupName
    }

    @objc dynamic var groupName: String = "" // グループ名
}
