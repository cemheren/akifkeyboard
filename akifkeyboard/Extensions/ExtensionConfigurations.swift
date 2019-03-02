//
//  ExtensionConfigurations.swift
//  akifkeyboard
//
//  Created by Akif Heren on 2/26/19.
//  Copyright © 2019 Akif Heren. All rights reserved.
//

import Foundation

class ExtensionConfiguration : StoreKitItemConfiguration{
    var title : String
    var description: String
    var sku : String
    var isFree: Bool
    var identifier : String
    var price: String
    
    init(identifier: String, title: String, description: String, sku: String, isFree: Bool, priceText: String) {
        self.title = title
        self.description = description
        self.sku = sku
        self.isFree = isFree
        self.identifier = identifier
        self.price = priceText
    }
}

class ExtensionConfigurations : NSObject{
    static let Instance : [ExtensionConfiguration] = [
        ExtensionConfiguration(
            identifier: "EmojiExtension",
            title: "Emoji extension",
            description: "Uses advanced machine learning to come up with the most suitable emoji! Requires internet access to communicate to the model. Since it's backed by a server costs 1$ a month.",
            sku: "emoji.extension",
            isFree: false,
            priceText: "$0.99"
        ),
        ExtensionConfiguration(
            identifier: "QuickFixTextExtension",
            title: "Quick fix text",
            description: "Applies quick fixes to simple English structures such as i'll -> I'll or hes -> he's, im -> I'm. Useful for quick typing.",
            sku: "",
            isFree: true,
            priceText: "Free")
    ]
}
