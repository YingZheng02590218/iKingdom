//
//  Network.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2022/06/16.
//  Copyright © 2022 Hisashi Ishihara. All rights reserved.
//

import Foundation
import Network

class Network {
    
    static let shared = Network()
    
    private let monitor = NWPathMonitor()
    
    func setUp() {
        // NWPathを引数に受け取るクロージャを設定することで、接続状態が変更したときに通知を受け取ることができます。
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Network satisfied")
            } else if path.status == .unsatisfied {
                print("Network unsatisfied")
            } else if path.status == .requiresConnection {
                print("Network requiresConnection")
            } else {
                print("Network else")
            }
        }
        let queue = DispatchQueue.global(qos: .background)
        // ネットワーク監視 開始
        monitor.start(queue: queue)
    }
    
    // ネットワーク接続を確認する
    func isOnline() -> Bool {
        // currentPathは startが呼ばれるまでnilです。
        return monitor.currentPath.status == .satisfied
    }
}
