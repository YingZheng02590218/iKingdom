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
            .appendingPathComponent("Documents", isDirectory: true)
            .appendingPathComponent(folderName, isDirectory: true)
    }
    /// iCloud Driveのパス
    private var documentsFolderUrl: URL {
        // iCloud Driveのパスは、ローカルと同じように、FileManagerでとれます。
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)!
            .appendingPathComponent("Documents", isDirectory: true)
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
                // ダウンロードする前にiCloudとの同期を行う
                try FileManager.default.startDownloadingUbiquitousItem(at: folderUrl)
                allFiles = try FileManager.default.contentsOfDirectory(atPath: folderUrl.path)
            } else {
                allFiles = try FileManager.default.contentsOfDirectory(atPath: backupFolderUrl.path)
                // fileName    String    ".default.realm_bk_2023-02-02-10-30-00.icloud"
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

    /// バックアップファイル
    func getBackup(folderName: String) -> String {
        let (exists, files) = isBackupFileExists(folderName: folderName)
        if exists {
            if let file = files.first {
                return file
            }
        }
        return ""
    }

    func load(completion: @escaping ([(String, NSNumber?)]) -> Void) {
        metadataQuery = NSMetadataQuery()
        // フォルダとファイルを取得して、ファイルのサイズを取得するため、絞り込まない
        // metadataQuery.predicate = NSPredicate(format: "%K like 'public.folder'", NSMetadataItemContentTypeKey)
        metadataQuery.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        metadataQuery.sortDescriptors = [
            NSSortDescriptor(key: NSMetadataItemFSContentChangeDateKey, ascending: false) // 効いていない
        ]

        NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidFinishGathering, object: metadataQuery, queue: nil) { notification in
            if let query = notification.object as? NSMetadataQuery {

                var backupFiles: [(String, NSNumber?)] = []
                // Documents内のフォルダとファイルにアクセス
                for result in query.results {
                    // print((result as AnyObject).values(forAttributes: [NSMetadataItemFSContentChangeDateKey, NSMetadataItemDisplayNameKey, NSMetadataItemFSNameKey, NSMetadataItemContentTypeKey, NSMetadataItemFSSizeKey, NSMetadataItemPathKey]))
                    // フォルダの場合
                    let contentType = (result as AnyObject).value(forAttribute: NSMetadataItemContentTypeKey) as! String
                    if contentType == "public.folder" {
                        // フォルダ名
                        let dysplayName = (result as AnyObject).value(forAttribute: NSMetadataItemDisplayNameKey) as! String
                        // フォルダ内のファイルのファイル名
                        let fileName = self.getBackup(folderName: dysplayName)
                        // fileName    String    ".default.realm_bk_2023-02-02-10-30-00.icloud"
                        // Documents内のフォルダとファイルにアクセス
                        for result in query.results {
                            // 同名のファイルからサイズを取得
                            let name = (result as AnyObject).value(forAttribute: NSMetadataItemFSNameKey) as! String
                            // name    String    "default.realm_bk_2023-02-02-10-30-00"
                            if fileName == name {
                                let size = (result as AnyObject).value(forAttribute: NSMetadataItemFSSizeKey) as? NSNumber
                                // フォルダ名、ファイルサイズ
                                backupFiles.append((dysplayName, size))
                            }
                            // デバイス間の共有　iCloud経由の場合、ファイル名が変わる！！！復元する際に、ダウンロードをしないと復元できない。
                            if fileName == "." + name + ".icloud" {
                                print("." + name + ".icloud", "加工した　.icloud　です。")
                                let size = (result as AnyObject).value(forAttribute: NSMetadataItemFSSizeKey) as? NSNumber
                                // フォルダ名、ファイルサイズ
                                backupFiles.append((dysplayName, size))
                            }
                        }
                    }
                }
                // 並べ替え
                completion(backupFiles.sorted { $0.0 < $1.0 })
            }
        }

        metadataQuery.start()
    }

    /// Realmのデータを復元
    func restore(folderName: String, completion: @escaping () -> Void) {
        guard let realmURL = Realm.Configuration.defaultConfiguration.fileURL else {
            print("Realmのファイルパスが取得できませんでした。")
            return
        }
        // バックアップファイルの格納場所
        let folderUrl = documentsFolderUrl.appendingPathComponent(folderName)
        // ダウンロードする前にiCloudとの同期を行う
        // This simple code launch the download
        do {
            let urls = try? FileManager.default.contentsOfDirectory(at: folderUrl, includingPropertiesForKeys: nil, options: [])
            if let url = urls?.first {
                try FileManager.default.startDownloadingUbiquitousItem(at: url)
            }
        } catch {
            print("Unexpected error: \(error).")
        }
        // iCloudからファイルをダウンロード
        downloadFileFromiCloud(folderName: folderName, completion: {
            // バックアップファイルの有無チェック
            let (exists, files) = self.isBackupFileExists(folderName: folderName)
            if exists {
                do {
                    let config = Realm.Configuration()
                    // 既存Realmファイル削除
                    let realmURLs = [
                        realmURL,
                        realmURL.appendingPathExtension("lock"), // 排他アクセス等に使われていて、実行中以外は、削除等しても構いませんと説明されています。
                        realmURL.appendingPathExtension("note"), // 排他アクセス等に使われていて、実行中以外は、削除等しても構いませんと説明されています。
                        realmURL.appendingPathExtension("management")
                    ]
                    for URL in realmURLs {
                        do {
                            try FileManager.default.removeItem(at: URL)
                            // URL"file:///var/mobile/Containers/Data/Application/C7E1E626-E114-4402-83EC-834AE43292F9/Documents/default.realm"
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    // バックアップファイルをRealmの位置にコピー
                    print(files[files.count - 1])
                    try FileManager.default.copyItem(
                        at: folderUrl.appendingPathComponent(files[files.count - 1]),
                        to: realmURL
                    )
                    Realm.Configuration.defaultConfiguration = config
                    print(config) // schemaVersion を確認できる
                    Thread.sleep(forTimeInterval: 3.0)
                    completion()
                    //　abort()   // 既存のRealmを開放させるため
                } catch {
                    print(error.localizedDescription)
                }
            }
        })
    }
    // iCloudからファイルをダウンロード
    func downloadFileFromiCloud(folderName: String, completion: @escaping () -> Void) {
        // If it’s a background function, I advise you to put this function in another DispatchQueue than the main one.
        DispatchQueue.global(qos: .utility).async {

            let fileManager = FileManager.default
            // Browse your icloud container to find the file you want
            if let icloudFolderURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(folderName),
               let urls = try? fileManager.contentsOfDirectory(at: icloudFolderURL, includingPropertiesForKeys: nil, options: []) {
                // Here select the file url you are interested in (for the exemple we take the first)
                if let myURL = urls.first {
                    // We have our url
                    var lastPathComponent = myURL.lastPathComponent
                    if lastPathComponent.contains(".icloud") {
                        // Delete the "." which is at the beginning of the file name
                        lastPathComponent.removeFirst()
                        let folderPath = myURL.deletingLastPathComponent().path
                        let downloadedFilePath = folderPath + "/" + lastPathComponent.replacingOccurrences(of: ".icloud", with: "")
                        var isDownloaded = false
                        while !isDownloaded {
                            if fileManager.fileExists(atPath: downloadedFilePath) {
                                isDownloaded = true
                            }
                        }
                        // Do what you want with your downloaded file at path contains in variable "downloadedFilePath"
                        completion()
                    } else {
                        // ダウンロード済みの場合
                        completion()
                    }
                }
            }
        }
    }
}

// ■キューの作り方による種類
// 既存のキューを使うか、新規でキューを作るかの作り方
//　　｜ーー＞既存のディスパッチキュー
//　　｜　　　　｜ーー＞メインキュー（main queue）・・・直列（同期型）
//　　｜　　　　｜ーー＞グローバルキュー（global queue）・・・並列（非同期型）
//　　｜
//　　｜ーー＞新規のディスパッチキュー
//　　　　　　　｜ーー＞DispatchQueue型のイニシャライザ
