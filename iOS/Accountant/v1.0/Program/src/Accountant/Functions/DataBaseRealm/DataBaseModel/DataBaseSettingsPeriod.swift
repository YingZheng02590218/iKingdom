//
//  DataBaseSettingsPeriod.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2020/12/13.
//  Copyright © 2020 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

// 会計期間クラス
class DataBaseSettingsPeriod: RObject {
    convenience init(
        theDayOfReckoning: String
    ) {
        self.init()

        self.theDayOfReckoning = theDayOfReckoning
    }

    @objc dynamic var theDayOfReckoning: String = TheDayOfReckoning.soloProprietor.rawValue // a settlement day / the day of reckoning
}
