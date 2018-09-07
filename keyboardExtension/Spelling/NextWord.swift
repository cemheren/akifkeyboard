//
//  NextWord.swift
//  akifkeyboard
//
//  Created by Akif Heren on 9/7/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation
struct NextWord : Codable{
    
    let w: String
    let p: [Prediction]
}

public struct Prediction : Codable{
    public let w: String
    let c: Int
}
