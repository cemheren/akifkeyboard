//
//  CorrectSpelling.swift
//  akifkeyboard
//
//  Created by Akif Heren on 8/22/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation

class CorrectSpelling{
    
    var knownWords = Set<String>(minimumCapacity: 1)
    
    /// Given a word, produce a set of possible alternatives with
    /// letters transposed, deleted, replaced or rogue characters inserted
    func edits(word: String) -> Set<String> {
        if word.isEmpty { return [] }
        
        let splits = word.indices.map {
            (word[word.startIndex..<$0], word[$0..<word.endIndex])
            } as [(Substring, Substring)]
        
        let deletes = splits.map { $0.0 + ($0.1).dropFirst() }.map {String($0)} as [String]
        
        let transposes: [String] = splits.map { left, right in
            if let fst = (right).first {
                let drop1 = (right).dropFirst()
                if let snd = (drop1).first {
                    let drop2 = (drop1).dropFirst()
                    return "\(left)\(snd)\(fst)\(drop2)"
                }
            }
            return ""
            }.filter { !$0.isEmpty } as [String]
        
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        
        let replaces = splits.flatMap { left, right in
            alphabet.map { "\(left)\($0)\(right.dropFirst())" }
            } as [String]
        
        let inserts = splits.flatMap { left, right in
            alphabet.map { "\(left)\($0)\(right)" }
            } as [String]
        
        return Set(deletes + transposes + replaces + inserts)
    }
    
    func insertWord(word: String){
        self.knownWords.insert(word);
    }
    
    init(){
        
    }
    
    func known<S: Sequence>(words: S) -> Set<String>? where S.Iterator.Element == String {
        let s = Set(words.filter { self.knownWords.contains($0) == true })
        return s.isEmpty ? nil : s
    }
    
    func getCorrection(word: String) -> [String]{
        let candidates = known(words: [word]) ?? known(words: edits(word: word)) ?? []
     
        return Array(known(words: candidates) ?? [])
    }
}