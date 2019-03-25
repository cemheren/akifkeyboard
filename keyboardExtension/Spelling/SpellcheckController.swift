//
//  SpellcheckController.swift
//  keyboardExtension
//
//  Created by Akif Heren on 8/18/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation

class SpellCheckModel{
    
    let isCorrect: Bool
    let alternatives: [String]
    
    let autoReplaceable : Word?
    
//    let middle: String
//    let left: String
//    let right: String
    
    init(isCorrect: Bool, alternatives: [Word], autoReplaceable: Word?) {
        self.isCorrect = isCorrect
        // Ensure the best prediction is on the most right.
        let setOfAlternatives = Array(Set(Array(alternatives.prefix(4))).sorted(by: { $0.weight < $1.weight }).map{value in value.word});
        self.alternatives = setOfAlternatives
        self.autoReplaceable = autoReplaceable
    }
}

class SpellCheckController{
    var autoComplete = AutoComplete<Word>()
    var correctSpelling = CorrectSpelling()
    var nextWordPredictor = NextWordPredictor()
    
    var filename = ""
    var autocompleteCutoffFrequency = 3;
    
    init(specialization: Specialization) {
        self.filename = specialization.spellCheckfilename;
        self.autocompleteCutoffFrequency = specialization.autocompleteCutoffFrequency;
        
        DispatchQueue.global(qos: .background).async {
            self.loadData()
        }
    }
    
    func loadData(){
        do {
            let path = Bundle.main.path(forResource: self.filename, ofType: "csv")
            
//            if let streamReader = StreamReader(path: path!) {
//                while let line = streamReader.nextLine() {
//                    let lineItems  = line.components(separatedBy: ",")
//                    if(lineItems.count == 2){
//                        let frequency = Int(lineItems[1]) ?? 1;
//                        let word = String(lineItems[0]);
//
//                        if(frequency > self.autocompleteCutoffFrequency){
//                            self.autoComplete.insert(Word(word: word, weight: frequency))
//                        }
//
//                        self.correctSpelling.insertWord(word: Word(word: word, weight: frequency))
//                    }
//                }
//            }
            
            var data:String? = try String(contentsOfFile: (path)!, encoding: .utf8)
            data?.components(separatedBy: .newlines).forEach({
                let lineItems  = $0.split(separator: ",")
                if(lineItems.count == 2){
                    let frequency = Int(lineItems[1]) ?? 1;
                    let wordString = String(lineItems[0]);
                    
                    let wordObject = Word(word: wordString, weight: frequency);
                    if(frequency > self.autocompleteCutoffFrequency){
                        self.autoComplete.insert(wordObject)
                    }
                    self.correctSpelling.insertWord(word: wordObject)
                }
                if(lineItems.count == 3){
                    let frequency = Int(lineItems[1]) ?? 1;
                    let word = String(lineItems[0]);
                    let keywords = lineItems[2].replacingOccurrences(of: "[", with: "")
                        .replacingOccurrences(of: "]", with: "")
                        .replacingOccurrences(of: "\'", with: "")
                        .folding(options: .diacriticInsensitive, locale: nil)
                        .components(separatedBy: ",")
                    
                    let wordObject = Word(word: word, weight: frequency, keywords: keywords, single: false)
                    if(frequency > self.autocompleteCutoffFrequency){
                        self.autoComplete.insert(wordObject)
                    }
                    self.correctSpelling.insertWord(word: wordObject)
                }
            })
            data = nil
            self.correctSpelling.isCompleted = true;
            
            let bipath = Bundle.main.path(forResource: "english_bigrams", ofType: "csv")
            var bigramdata:String? = try String(contentsOfFile: (bipath)!, encoding: .utf8)
            bigramdata?.components(separatedBy: .newlines).forEach({
                let lineItems  = $0.split(separator: ",")
                if(lineItems.count == 2){
                    let frequency = Int(lineItems[1]) ?? 1;
                    let word = String(lineItems[0]);
                    
                    self.correctSpelling.insertWord(word: Word(word: word, weight: frequency))
                }
            })
            bigramdata = nil
            
            let nextwordpath = Bundle.main.path(forResource: "english_bigram_probabilities", ofType: "csv")
            var nextwordpathdata:String? = try String(contentsOfFile: (nextwordpath)!, encoding: .utf8)
            try nextwordpathdata?.components(separatedBy: .newlines).forEach({
                let data = $0.data(using: .utf8)!
                do{
                    let parsed = try JSONDecoder().decode(NextWord.self, from: data)
                    nextWordPredictor.insertWord(word: parsed)
                }
                catch {
                    print($0)
                }
            })
            nextwordpathdata = nil
            
        } catch {
            print(error)
        }
    }
    
    func checkSpelling(lastWord: String, currentWord: String, completion: @escaping (_ result: SpellCheckModel)->()){
        DispatchQueue.global(qos: .background).async {
        
            let nextWordPredictions = Set(self.nextWordPredictor.knownWords[lastWord.lowercased()]?.p.map({ (p: Prediction) -> Word in
                Word(word: p.w, weight: p.c)
            }) ?? [Word]())
            
            let results = self.autoComplete.search(currentWord)
        
            var corrections: [Word] = [];
            if results.count < 4{
                corrections = self.correctSpelling.getCorrection(word: currentWord.lowercased());
            }

            let keyDist1 = self.getAlternatives(word: currentWord.lowercased())
            var keyDist1KnownStrings = keyDist1.filter({ (s: String) -> Bool in
                return self.correctSpelling.isKnowWord(word: Word(word: s, weight: 1000))
            })
            
            let keyDist1KnownWords = keyDist1KnownStrings.flatMap{Word(word: $0, weight: 50000)}
            
            var keyDist1Results: [Word] = [];
            if(keyDist1KnownWords.count < 4){
                keyDist1Results = keyDist1.flatMap {self.autoComplete.search($0)}.map{Word(word: $0.word, weight: Int(Double($0.weight) / 4.0))}
            }
            
            var alternatives = keyDist1KnownWords
                + results
                + keyDist1Results
                + corrections
            
            alternatives = alternatives.map({ (word : Word) -> Word in
                var w2:Word;
                if(nextWordPredictions.contains(word)){
                    w2 = Word(word: word.word, weight: Int(word.weight) * 5);
                    return w2;
                }
                return word;
            })

            var autoReplaceable: Word? = nil;
            if (self.correctSpelling.isCompleted){
                if (keyDist1KnownWords.count == 1){
                    autoReplaceable = keyDist1KnownWords.first
                }
                if (keyDist1KnownWords.count > 1){
                    autoReplaceable = keyDist1KnownWords.map{ self.correctSpelling.getWord(str: $0.word) }.sorted(by: { $0!.weight > $1!.weight }).first!
                }
                
                let cw = Word(word: currentWord.lowercased(), weight: 1000);
                if (self.correctSpelling.isKnowWord(word: cw)){
                    autoReplaceable = cw
                }
                
                if autoReplaceable != nil{
                    alternatives = alternatives.filter{ $0.word != autoReplaceable?.word }
                }
            }
            
            DispatchQueue.main.async {
                completion(SpellCheckModel(
                    isCorrect: false,
                    alternatives: alternatives.sorted(by: { $0.weight > $1.weight }),
                    autoReplaceable: autoReplaceable
                ))
            }
        }
    }
    
    func getNextWordPredictions(lastWord: String) -> SpellCheckModel{
        let predictions = self.nextWordPredictor.knownWords[lastWord.lowercased()]?.p.map({ (p: Prediction) -> Word in
            Word(word: p.w, weight: p.c)
        }) ?? [Word]()
        
        let scm = SpellCheckModel(
            isCorrect: false,
            alternatives: predictions.sorted(by: { $0.weight > $1.weight }),
            autoReplaceable: nil)
        
        return scm
    }
    
    func getAlternatives(word: String) -> [String]{
        var characterMapping = ["a" : "s",
                                "b" : "vn",
                                "c" : "xv",
                                "d" : "sf",
                                "e" : "wr",
                                "f" : "dg",
                                "g" : "fh",
                                "h" : "gj",
                                "i" : "uo",
                                "j" : "hk",
                                "k" : "jl",
                                "l" : "k",
                                "m" : "n",
                                "n" : "bm",
                                "o" : "ip",
                                "p" : "o",
                                "q" : "w",
                                "r" : "et",
                                "s" : "ad",
                                "t" : "ry",
                                "u" : "yi",
                                "v" : "cb",
                                "w" : "qe",
                                "x" : "zc",
                                "y" : "tu",
                                "z" : "x"];
        
        let splits = word.indices.map {
            (word[word.startIndex..<$0], word[$0..<word.endIndex])
            } as [(Substring, Substring)]
        
        func abc(left: Substring, right: Substring) -> [String]{
            let char = String(right.first!).lowercased()
            let exists = characterMapping[char] != nil
            if exists == false{
                return [];
            }
            
            let alphabet : String = String(characterMapping[char]!)
            return alphabet == nil ? [] : alphabet.map { "\(left)\($0)\(right.dropFirst())" }
        }
        
        let replaces = splits.flatMap { left, right in
            abc(left: left, right: right)
        } as [String]
        
        return Array(Set(replaces));
    }
}

