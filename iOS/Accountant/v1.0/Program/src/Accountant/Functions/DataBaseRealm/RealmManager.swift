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
     * データベース
     * 指定されたモデルオブジェクトのテーブルから検索条件に合ったレコードを取得する
     * @param type モデルオブジェクトタイプ
     * @param predicates クエリ(検索条件)
     */
    func readWithPredicate<T: Object>(type: T.Type, predicates: [NSPredicate]) -> Results<T> {
        // NSPredicateオブジェクトを配列に格納してから「NSCompoundPredicate」クラスを利用してそれぞれの条件を結合します。
        // AND条件なので「andPredicateWithSubpredicates」を指定します。
        // 比較したい文字列が１つしかなくてもこのコードで問題ありません。
        let compoundedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let result = DataBaseManager.realm.objects(type.self).filter(compoundedPredicate)
        return result
    }

    /**
     * 指定キーのレコードを取得
     */
    func findFirst<T: Object>(type: T.Type, key: Int) -> T? {
        DataBaseManager.realm.object(ofType: T.self, forPrimaryKey: key)
    }

    // MARK: Update


    // MARK: Delete

}
