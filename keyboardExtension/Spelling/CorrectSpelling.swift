//
//  CorrectSpelling.swift
//  akifkeyboard
//
//  Created by Akif Heren on 8/22/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation

class CorrectSpelling{
    
    var knownWords = Set<Word>(minimumCapacity: 1)
    
    var isCompleted = false;
    
    /// Given a word, produce a set of possible alternatives with
    /// letters transposed, deleted, replaced or rogue characters inserted
    private func edits(word: String) -> Set<String> {
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
        
        let alphabet = "abcdefghijklmnopqrstuvwxyz' "
        
        let replaces = splits.flatMap { left, right in
            alphabet.map { "\(left)\($0)\(right.dropFirst())" }
            } as [String]
        
        let inserts = splits.flatMap { left, right in
            alphabet.map { "\(left)\($0)\(right)" }
            } as [String]
        
        return Set(deletes + transposes + replaces + inserts)
    }
    
    func insertWord(word: Word){
        self.knownWords.insert(word);
    }
    
    init(){
        
    }
    
    func knownEdits2(edits: Set<String>) -> Set<Word>? {
        var known_edits: Set<Word> = []
        for edit in edits {
            let currentEdits = self.edits(word: edit)
            let edit1s = known(words: currentEdits)
            if let k = edit1s {
                known_edits.formUnion(k)
            }
        }
        return known_edits.isEmpty ? nil : known_edits
    }
    
    private func known<S: Sequence>(words: S) -> Set<Word>? where S.Iterator.Element == String {
        var s = Set<Word>();
        
        for word in words{
            if self.knownWords.contains(Word(word: word, weight: 0)) == true{
                let indexOf = self.knownWords.index(of: Word(word: word, weight: 0));
                s.insert(self.knownWords[indexOf!])
            }
        }
        
        return s.isEmpty ? nil : s;
    }
    
    func isKnowWord(word: Word) -> Bool{
        return self.knownWords.contains(word)
    }
    
    func getWord(str: String) -> Word?{
        let temp = Word(word: str, weight: 0);
        if(self.isKnowWord(word: temp) == false){
            return nil
        }
        
        let indexOf = self.knownWords.index(of: temp)
        return self.knownWords[indexOf!]
    }
    
    func getCorrection(word: String) -> [Word]{
        let edits = self.edits(word: word);
        let candidates = known(words: edits) ?? []
     
        return Array(candidates)
    }
}
