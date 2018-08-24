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
    
    init(isCorrect: Bool, alternatives: [String]) {
        self.isCorrect = isCorrect
        self.alternatives = Array(alternatives.prefix(4));
    }
}

class SpellCheckController{
    var autoComplete = AutoComplete<Word>()
    var correctSpelling = CorrectSpelling()
    
    let endpoint: String = "https://2hwrmsajo2.execute-api.eu-central-1.amazonaws.com/Prod/spellcheck?prompt="

    init() {
        DispatchQueue.main.async {
            self.loadData()
        }
    }
    
    func loadData(){
        do {
            let path = Bundle.main.path(forResource: "wordslonglist", ofType: "csv")
            let data = try String(contentsOfFile: (path)!, encoding: .utf8)
            data.components(separatedBy: .newlines).forEach({
                let lineItems  = $0.split(separator: ",")
                if(lineItems.count == 2){
                    let frequency = Int(lineItems[1]);
                    let word = String(lineItems[0]);
                    
                    if(frequency ?? 0 > 15){
                        self.autoComplete.insert(Word(word: word))
                    }
                    self.correctSpelling.insertWord(word: word)
                }
            })
        } catch {
            print(error)
        }
    }
    
    func checkSpelling(currentWord: String, completion: @escaping (_ result: SpellCheckModel)->()){
        
        let corrections = self.correctSpelling.getCorrection(word: currentWord.lowercased());
        
        let results = self.autoComplete.search(currentWord)
        let alternatives = results.map{value in value.word} + corrections
        completion(SpellCheckModel(isCorrect: false, alternatives: alternatives))
        
        //getURI(url: self.endpoint + currentWord, completion: completion)
    }
    
    func getURI(url: String, completion: @escaping (_ result: SpellCheckModel)->()){
        var url = URL(string: url) ?? nil
        
        if(url == nil){ return }
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        //request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if(response == nil){
                return;
            }
            
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json["isCorrect"])
                print(json["suggested"])
                
                completion(SpellCheckModel(isCorrect: (json["isCorrect"] != nil), alternatives: json["suggested"] as! [String]))
                
            } catch {
                print("error")
            }
        })
        
        task.resume()
    }
}

