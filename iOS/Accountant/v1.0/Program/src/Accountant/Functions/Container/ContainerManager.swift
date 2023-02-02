//
//  ContainerManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2023/01/27.
//  Copyright © 2023 Hisashi Ishihara. All rights reserved.
//

import Foundation
import UIKit

class ContainerManager {
    private var metadata: NSMetadataQuery! // 参照を保持するため、メンバとして持っておく。load()内のローカル変数にするとうまく動かない。
    private var url: URL {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)!
            .appendingPathComponent("Documents")
            .appendingPathComponent("test.txt")
    }

    func load(completion: @escaping (String?) -> Void) {
        metadata = NSMetadataQuery()
        metadata.predicate = NSPredicate(format: "%K like 'test.txt'", NSMetadataItemFSNameKey)
        metadata.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]

        NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidFinishGathering, object: metadata, queue: nil) { notification in
            let query = notification.object as! NSMetadataQuery

            if query.resultCount == 0 {
                print("ファイルが見つからなかったので新規作成")
                let document = Document(fileURL: self.url)
                document.save(to: self.url, for: .forCreating) { success in
                    print(success ? "作成成功" : "作成失敗")
                    completion(nil)
                }
                return
            }

            let url = (query.results[0] as AnyObject).value(forAttribute: NSMetadataItemURLKey) as! URL
            let document = Document(fileURL: url)
            document.open { success in
                if success {
                    print("ファイル読み込み: \(document.text ?? "nil")")
                    completion(document.text)
                } else {
                    print("ファイル読み込み失敗")
                    completion(nil)
                }
            }
        }

        metadata.start()
    }

    func save(_ text: String) {
        let document = Document(fileURL: url)
        document.text = text
        document.save(to: url, for: .forOverwriting) { success in
            print("ファイル保存\(success ? "成功" : "失敗")")
        }
    }
}
// UIDocumentを継承しないと書けないっぽい
class Document: UIDocument {
    var text: String? = ""

    override func contents(forType typeName: String) throws -> Any {
        text?.data(using: .utf8) ?? Data()
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let contents = contents as? Data else { return }
        text = String(data: contents, encoding: .utf8)
    }
}
