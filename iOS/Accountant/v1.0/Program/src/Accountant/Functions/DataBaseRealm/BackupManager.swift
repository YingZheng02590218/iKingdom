//
//  BackupManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/27.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import RealmSwift

class BackupManager {

    static let shared = BackupManager()

    private init() {
        fileNameDateformater.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        fileNameDateformater.locale = Locale(identifier: "ja_JP")

        folderNameDateformater.dateFormat = "yyyyMMddhhmm"
        folderNameDateformater.locale = Locale(identifier: "ja_JP")
    }

    let fileNameDateformater = DateFormatter()
    let folderNameDateformater = DateFormatter()

    /// バックアップフォルダURL
    private var backupFolderUrl: URL {
        let folderName = folderNameDateformater.string(from: Date()) // 日付
        // iCloud Driveのパスは、ローカルと同じように、FileManagerでとれます。
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)!
            .appendingPathComponent("Documents")
            .appendingPathComponent(folderName)
    }
    /// バックアップファイル名（前部）
    private let mBackupFileNamePre = "default.realm_bk_"

    // MARK: バックアップ

    /// バックアップデータ作成処理
    /// RealmのデータをiCloudにコピー
    func backup() {
        do {
            /// iCloudにフォルダ作成
            if FileManager.default.fileExists(atPath: backupFolderUrl.path) {

            } else {
                try FileManager.default.createDirectory(atPath: backupFolderUrl.path, withIntermediateDirectories: false)
            }
            // 既存バックアップファイル（iCloud）の削除
            deleteBackup()
            // バックアップファイル名
            let fileName = "default.realm_bk_" + fileNameDateformater.string(from: Date()) // 日付
            // バックアップファイルの格納場所
            let fileUrl = backupFolderUrl.appendingPathComponent(fileName)
            // バックアップ作成
            try backupRealm(backupFileUrl: fileUrl)
        } catch {
            print(error.localizedDescription)
        }
    }
    /// Realmのデータファイルを指定ファイル名（フルパス）にコピー
    /// - Parameter backupFileUrl: 指定ファイル名（フルパス）URL
    private func backupRealm(backupFileUrl: URL) throws {
        do {
            let realm = try Realm()
            realm.beginWrite()
            try realm.writeCopy(toFile: backupFileUrl)
            realm.cancelWrite()
        } catch {
            throw error
        }
    }
    /// バックアップファイル削除
    func deleteBackup() {
        let (exists, files) = isBackupFileExists()
        if exists {
            do {
                for file in files {
                    try FileManager.default.removeItem(at: backupFolderUrl.appendingPathComponent(file))
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    /// バックアップフォルダにバックアップファイルがあるか、ある場合、そのファイル名を取得
    /// - Returns: バックアップファイルの有無、そのファイル名
    private func isBackupFileExists() -> (Bool, [String]) {
        var exists = false
        var files: [String] = []
        var allFiles: [String] = []
        // バックアップフォルダのファイル取得
        do {
            allFiles = try FileManager.default.contentsOfDirectory(atPath: backupFolderUrl.path)
        } catch {
            return (exists, files)
        }
        // バックアップファイル名を選別
        for file in allFiles where file.contains(mBackupFileNamePre) {
            exists = true
            files.append(file)
        }
        return (exists, files)
    }

}
