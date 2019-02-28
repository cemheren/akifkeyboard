//
//  ExtensionsStoreKitDelegate.swift
//  akifkeyboard
//
//  Created by Akif Heren on 2/26/19.
//  Copyright © 2019 Akif Heren. All rights reserved.
//

import Foundation
import StoreKit

protocol StoreKitItemConfiguration {
    var sku : String {get set}
    var isFree: Bool {get set}
}

protocol StoreKitItemRequestFetchCompleteDelegate{
    func OnFetchProductsComplete(products: [SKProduct])
    func OnPurchaseProductComplete(Sku: String)
}

class StoreKitItemDelegate: NSObject {
    
    var products: [String: SKProduct] = [:]
    var requestFetchCompleteDelegate: StoreKitItemRequestFetchCompleteDelegate
    
    init(extensionRequestFetchCompleteDelegate: StoreKitItemRequestFetchCompleteDelegate) {
        self.requestFetchCompleteDelegate = extensionRequestFetchCompleteDelegate
        
        super.init();
        
        SKPaymentQueue.default().add(self)
    }
    
    func fetchProducts(extensionConfigurations: [StoreKitItemConfiguration]) {
        var productIDs = Set<String>()
        extensionConfigurations.forEach { extensionConfiguration in
            if(extensionConfiguration.isFree == false){
                productIDs.insert(extensionConfiguration.sku)
            }
        }
        
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

extension StoreKitItemDelegate: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.invalidProductIdentifiers.forEach { product in
            print("Invalid: \(product)")
        }
        
        response.products.forEach { product in
            print("Valid: \(product)")
            products[product.productIdentifier] = product
        }
        
        self.requestFetchCompleteDelegate.OnFetchProductsComplete(products: response.products)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error for request: \(error.localizedDescription)")
    }
    
}

extension StoreKitItemDelegate: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue,
                             updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restore... \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        
        self.requestFetchCompleteDelegate.OnPurchaseProductComplete(Sku: identifier)
    }
}
