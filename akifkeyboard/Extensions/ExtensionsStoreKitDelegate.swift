//
//  ExtensionsStoreKitDelegate.swift
//  akifkeyboard
//
//  Created by Akif Heren on 2/26/19.
//  Copyright © 2019 Akif Heren. All rights reserved.
//

import Foundation
import StoreKit

class ExtensionsStoreKitDelegate: NSObject {
    
    let monthlySubID = "large.tip"
    let yearlySubID = "small.tip"
    var products: [String: SKProduct] = [:]
    
    func fetchProducts() {
        let productIDs = Set([monthlySubID, yearlySubID])
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func purchase(productID: String) {
        if let product = products[productID] {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension ExtensionsStoreKitDelegate: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.invalidProductIdentifiers.forEach { product in
            print("Invalid: \(product)")
        }
        
        response.products.forEach { product in
            print("Valid: \(product)")
            products[product.productIdentifier] = product
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error for request: \(error.localizedDescription)")
    }
    
}
