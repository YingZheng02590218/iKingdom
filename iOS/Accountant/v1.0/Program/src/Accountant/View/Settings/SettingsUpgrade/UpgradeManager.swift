//
//  UpgradeManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/01/09.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import Foundation
import SwiftyStoreKit // アップグレード機能

//定期購読のためのフラグ
public var inAppPurchaseFlag = false

// アップグレード
class UpgradeManager {
    
    // 購入　更新型課金
    func purchase(PRODUCT_ID: String, completion: @escaping (Bool) -> Void) {

        SwiftyStoreKit.purchaseProduct(PRODUCT_ID, quantity: 1, atomically: true) { result in
            switch result {
            case .success(_):
                // 購入成功
                print("アップグレード購入 購入成功")
                break
            case .error(_):
                // 購入失敗
                print("アップグレード購入 購入失敗")
                break // Cancelの場合
            }
            // 購入の検証
            self.verifyPurchase(PRODUCT_ID: PRODUCT_ID, completion: { returning in // OK、Manageの場合
                completion(returning)
            })
        }
    }
    // 確認　更新型課金
    func verifyPurchase(PRODUCT_ID: String, completion: @escaping (Bool) -> Void) {
        
        var returning = false
        // 引数のserviceは.productionで常時OKです。サンドボックスへの分岐はSwiftyStoreKitがやってくれます。
        let appleValidator = AppleReceiptValidator(service: .production,
                                                   sharedSecret: "267511abfdf6422ea0cf43cf14046d95") // 共有シークレット
        // Apple持ちのレシートを指定 ローカルレシートを指定する場合は、SwiftyStoreKit.verifyReceipt(using: appleValidator,forcerefresh:false)とします。
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                // 自動更新
                let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable,
                                                                       productId: PRODUCT_ID,
                                                                       inReceipt: receipt)
                print("アップグレード確認", purchaseResult)
                switch purchaseResult {
                case .purchased(let expiryDate, let receiptItems):
                    print("アップグレード確認 Product is valid until \(expiryDate) \(receiptItems)")
                    //リストアの成功
                    UserDefaults.standard.set(1, forKey: "buy")
                    inAppPurchaseFlag = true
                    returning = true
                    break
                case .expired(let expiryDate, let receiptItems):
                    print("アップグレード確認 Product is expired since \(expiryDate) \(receiptItems)")
                    break
                case .notPurchased:
                    print("アップグレード確認 This product has never been purchased")
                    //リストアの失敗
                    break
                }
            case .error:
                //エラー
                print("アップグレード確認 エラー")
                break // Conformの場合 OK、Manageを押した場合エラーとなった
            }
            completion(returning)
        }
    }
    
}
