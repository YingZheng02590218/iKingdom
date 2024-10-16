//
//  UpgradeManager.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2021/01/09.
//  Copyright © 2021 Hisashi Ishihara. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit // アップグレード機能

// アップグレード
class UpgradeManager {
    
    static let shared = UpgradeManager()

    private init() {
    }

    // 定期購読のためのフラグ
    public var inAppPurchaseFlag = false
    // プロダクトID スタンダードプラン
    static let PRODUCTIDSTANDARDPLAN = "com.ikingdom.Accountant.autoRenewableSubscriptions.advertisingOff"

    // アプリ起動時にネットに繋いでAppStoreで購入済みか確認する（1件のみ有料アイテムを登録）
    func isPurchasedWhenAppStart() {
        UpgradeManager.shared.verifyPurchase(productId: UpgradeManager.PRODUCTIDSTANDARDPLAN) { isSuccess in
            if isSuccess {
                self.inAppPurchaseFlag = true
            } else {
                self.inAppPurchaseFlag = false
            }
        }
    }
    
    // プロダクト情報取得 価格
    func purchaseGetInfo(productId: Set<String>, completion: @escaping (Array<SKProduct>) -> Void) { // Set<>は、重複を許さない配列のようなもの
        
        SwiftyStoreKit.retrieveProductsInfo(productId) { result in // [weak self]
            
            let products = Array(result.retrievedProducts) //
//            products.sort(by: { (lh, rh) -> Bool in
//                return lh.localizedPrice! < rh.localizedPrice!
//            })

            if let product = result.retrievedProducts.first { // プロダクトは一種類なので、firstでよい
                print("valid", result.retrievedProducts)
                print("localizedTitle       : \(product.localizedTitle)")
                if let localizedPrice = product.localizedPrice { // 地域別の価格
                    print("price                : \(localizedPrice)")
                }
                print("priceLocale          : \(product.priceLocale)")
                print("Product              : \(product.localizedDescription)")
                print("subscriptionPeriod   : \(String(describing: product.subscriptionPeriod?.unit))")
                print("productIdentifier    : \(product.productIdentifier)")
            } else if let invalidProductId = result.invalidProductIDs.first {
                
                print("Invalid product identifier: \(invalidProductId)")
            } else {
                if let error = result.error {
                    print("Error: \(error)")
                }
            }
            
            completion(products)
        }
    }
    
    // 購入　更新型課金
    func purchase(productId: String, completion: @escaping (Bool) -> Void) {

        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                // 購入成功
                print("アップグレード購入 購入成功 \(purchase.productId)")
            case .error(let error):
                // 購入失敗
                print("アップグレード購入 購入失敗")
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                @unknown default: break
                }
                // Cancelの場合
            }
            // 購入の検証
            self.verifyPurchase(productId: productId, completion: { isSuccess in // OK、Manageの場合
                completion(isSuccess)
            })
        }
    }
    // 確認　更新型課金 自動更新型のレシート検証と継続中か期限切れかのチェック
    func verifyPurchase(productId: String, completion: @escaping (Bool) -> Void) {

        var isSuccess = false
        // 引数のserviceは.productionで常時OKです。サンドボックスへの分岐はSwiftyStoreKitがやってくれます。
        let appleValidator = AppleReceiptValidator(
            service: .production,
            sharedSecret: "267511abfdf6422ea0cf43cf14046d95"
        ) // 共有シークレット
        // Apple持ちのレシートを指定 ローカルレシートを指定する場合は、SwiftyStoreKit.verifyReceipt(using: appleValidator,forcerefresh:false)とします。
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                // 自動更新
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt
                )
                print("アップグレード確認", purchaseResult)
                switch purchaseResult {
                case let .purchased(expiryDate, receiptItems):
                    print("アップグレード確認 Product is valid until \(expiryDate) \(receiptItems)")
                    // リストアの成功
                    self.inAppPurchaseFlag = true
                    isSuccess = true
                case let .expired(expiryDate, receiptItems):
                    print("アップグレード確認 Product is expired since \(expiryDate) \(receiptItems)")
                    self.inAppPurchaseFlag = false
                case .notPurchased:
                    print("アップグレード確認 This product has never been purchased")
                    self.inAppPurchaseFlag = false
                    // リストアの失敗
                }
            case .error(let error):
                // 4G、Wi-FiをOFFにした場合　広告もロードできないので表示されない
                print("アップグレード確認　Receipt verification failed: \(error)")
                // Conformの場合 OK、Manageを押した場合エラーとなった
            }

            completion(isSuccess)
        }
    }
}
