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
        fileNameDateformater.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        fileNameDateformater.locale = Locale(identifier: "en_US_POSIX")

        folderNameDateformater.dateFormat = "yyyyMMddHHmm"
        folderNameDateformater.locale = Locale(identifier: "en_US_POSIX")

        metadataQuery = NSMetadataQuery()
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
    /// iCloud Driveのパス
    private var documentsFolderUrl: URL {
        // iCloud Driveのパスは、ローカルと同じように、FileManagerでとれます。
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)!
            .appendingPathComponent("Documents")
    }
    /// バックアップファイル名（前部）
    private let mBackupFileNamePre = "default.realm_bk_"

    // MARK: バックアップ

    /// バックアップデータ作成処理
    /// RealmのデータをiCloudにコピー
    func backup(completion: @escaping () -> Void) {
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
            completion()
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
    /// バックアップフォルダ削除
    func deleteBackupFolder(folderName: String? = nil) {
        let (exists, files) = isBackupFileExists(folderName: folderName)
        if exists {
            do {
                if let folderName = folderName {
                    try FileManager.default.removeItem(at: documentsFolderUrl.appendingPathComponent(folderName))
                }
            } catch {
                print(error.localizedDescription)
            }
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
    private func isBackupFileExists(folderName: String? = nil) -> (Bool, [String]) {
        var exists = false
        var files: [String] = []
        var allFiles: [String] = []
        // バックアップフォルダのファイル取得
        do {
            if let folderName = folderName {
                // バックアップファイルの格納場所
                let folderUrl = documentsFolderUrl.appendingPathComponent(folderName)
                allFiles = try FileManager.default.contentsOfDirectory(atPath: folderUrl.path)
            } else {
                allFiles = try FileManager.default.contentsOfDirectory(atPath: backupFolderUrl.path)
            }
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

    // MARK: バックアップファイル取得
    private var metadataQuery: NSMetadataQuery // 参照を保持するため、メンバとして持っておく。load()内のローカル変数にするとうまく動かない。

    func load(completion: @escaping ([String]) -> Void) {
        metadataQuery = NSMetadataQuery()
        metadataQuery.predicate = NSPredicate(format: "%K like 'public.folder'", NSMetadataItemContentTypeKey)
        metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        metadataQuery.sortDescriptors = [
            NSSortDescriptor(key: NSMetadataItemFSContentChangeDateKey, ascending: false), // 効いていない
        ]

        NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidFinishGathering, object: metadataQuery, queue: nil) { notification in
            if let query = notification.object as? NSMetadataQuery {

                var displayName: [String] = []
                for result in query.results {
//                    print((result as AnyObject).values(forAttributes: [NSMetadataItemFSContentChangeDateKey, NSMetadataItemDisplayNameKey, NSMetadataItemContentTypeKey, NSMetadataItemFSSizeKey]))
                    // Optional(["kMDItemDisplayName": default, "kMDItemFSSize": 454832, "kMDItemContentType": dyn.ah62d46dzqm0gw23srf4gn5m4ge81e3pbrv0z82xpp63daqvxfy2dcpmwg60xarvrga5w4rm3, "kMDItemPath": /private/var/mobile/Library/Mobile Documents/iCloud~com~ikingdom778~AccountantSTG/Documents/202301270607/default.realm_bk_2023-01-27-06-07-59])
                    // Optional(["kMDItemDisplayName": 202301270608, "kMDItemContentType": public.folder, "kMDItemPath": /private/var/mobile/Library/Mobile Documents/iCloud~com~ikingdom778~AccountantSTG/Documents/202301270608])

                    let name = (result as AnyObject).value(forAttribute: NSMetadataItemDisplayNameKey) as! String
                    displayName.append(name)
                }
                // 並べ替え
                completion(displayName.sorted { $0 < $1 })
            }
        }

        metadataQuery.start()
    }
}
