//
//  RealmManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/12/28.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {

    static let shared = RealmManager()

    // MARK: - CRUD

    // MARK: Create

    // MARK: Read

    /**
     * 指定キーのレコードを取得
     */
    func findFirst<T: Object>(type: T.Type, key: Int) -> T? {
        DataBaseManager.realm.object(ofType: T.self, forPrimaryKey: key)
    }

    // MARK: Update


    // MARK: Delete

}
