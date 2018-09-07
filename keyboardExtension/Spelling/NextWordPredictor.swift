//
//  NextWordPredictor.swift
//  akifkeyboard
//
//  Created by Akif Heren on 9/6/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation
class NextWordPredictor{
    
    var knownWords = [String: NextWord](minimumCapacity: 1)
    
    func insertWord(word: NextWord){
        self.knownWords[word.w] = word;
    }
}
