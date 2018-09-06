//
//  Word.swift
//  akifkeyboard
//
//  Created by Akif Heren on 8/26/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation

final class Word: Searchable {
    var word: String
    var keywords: [String] { return _keywords }
    private var _keywords: [String]
    
    var weight: Int
    
    init(word: String, weight: Int) {
        self.word = word
        self.weight = weight;
        
        self._keywords = [word]
    }
    
    init(word: String, weight: Int, keywords: [String]) {
        self.word = word
        self.weight = weight;
        self._keywords = keywords
    }
}

extension Word : Hashable {
    var hashValue: Int { return word.hashValue }
    
    static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.word == rhs.word
    }
}

