//
//  Word.swift
//  akifkeyboard
//
//  Created by Akif Heren on 8/26/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation

final class Word: Searchable {
    var word: String {
        if(_single) {
            return _word!
        }
        return _keywords![0]
    }
    var keywords: [String] {
        if(_single){
            return [_word!];
        }
        
        return _keywords!
    }
    
    // keep non-array Word objects separately. This helps save memory.
    private var _single: Bool
    private var _keywords: [String]?
    private var _word: String?
    
    let weight: Int
    
    init(word: String, weight: Int) {
        self.weight = weight
        self._word = word
        self._single = true;
    }
    
    init(word: String, weight: Int, keywords: [String]) {
        self.weight = weight
        self._keywords = keywords
        self._single = false
    }
}

extension Word : Hashable {
    var hashValue: Int { return self.word.hashValue }
    
    static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.word == rhs.word
    }
}

