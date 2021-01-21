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
    func purchase(PRODUCT_ID:String){
        SwiftyStoreKit.purchaseProduct(PRODUCT_ID, quantity: 1, atomically: true) { result in
            switch result {
            case .success(_):
                //購入成功
                UserDefaults.standard.set(1, forKey: "buy")
                inAppPurchaseFlag = true
                //購入の検証
                self.verifyPurchase(PRODUCT_ID: PRODUCT_ID) // OK、Manageの場合
                break
            case .error(_):
                //購入失敗
                print("購入失敗errorです")
                break//Cancelの場合
            }
        }
    }
    // 確認　更新型課金
    func verifyPurchase(PRODUCT_ID:String){
        print(UserDefaults.standard.string(forKey: "buy"))
        // 引数のserviceは.productionで常時OKです。サンドボックスへの分岐はSwiftyStoreKitがやってくれます。
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "267511abfdf6422ea0cf43cf14046d95") // 共有シークレット
        // Apple持ちのレシートを指定 ローカルレシートを指定する場合は、SwiftyStoreKit.verifyReceipt(using: appleValidator,forcerefresh:false)とします。
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            print(result)
            switch result {
            case .success(let receipt):
                //自動更新
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: PRODUCT_ID,
                    inReceipt: receipt)
                print(purchaseResult)
                switch purchaseResult {
                case .purchased(let expiryDate, let receiptItems):
                    print("Product is valid until \(expiryDate)")
                    //リストアの成功
                    UserDefaults.standard.set(1, forKey: "buy")
                    inAppPurchaseFlag = true
                    break
                case .expired(let expiryDate, let receiptItems):
                    print("Product is expired since \(expiryDate)")
                    break
                case .notPurchased:
                    print("This product has never been purchased")
                    //リストアの失敗
                    break
                default:
                    break
                }
            case .error:
                //エラー
                break// Conformの場合 OK、Manageを押した場合エラーとなった
            }
        }
    }
    
}
