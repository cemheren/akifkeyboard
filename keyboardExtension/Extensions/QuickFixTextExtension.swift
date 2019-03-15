//
//  QuickFixTextExtension.swift
//  akifkeyboard
//
//  Created by Akif Heren on 2/17/19.
//  Copyright © 2019 Akif Heren. All rights reserved.
//

import Foundation
class QuickFixTextExtension : Extension{
    required init(){
        
    }
    
    func OnWordAdded(lastWord: String) -> String {
        if lastWord == "i" {
            return "I"
        }
        let lowercasedCurrentWord = lastWord.lowercased();
        if lowercasedCurrentWord == "im" || lowercasedCurrentWord == "i'm" {
            return "I'm"
        }
        if lowercasedCurrentWord == "i'll" || lowercasedCurrentWord == "illl"{
            return "I'll"
        }
        if lowercasedCurrentWord == "i'd"{
            return "I'd"
        }
        if lowercasedCurrentWord == "i've"{
            return "I've"
        }
        if lowercasedCurrentWord == "lets"{
            return "let's"
        }
        if lowercasedCurrentWord == "weare"{
            return "we're"
        }
        if lowercasedCurrentWord == "theyre" || lowercasedCurrentWord == "theyare"{
            return "they're"
        }
        if lowercasedCurrentWord == "theyll"{
            return "they'll"
        }
        if lowercasedCurrentWord == "theyve"{
            return "they've"
        }
        if lowercasedCurrentWord == "youre" || lowercasedCurrentWord == "youare"{
            return "you're"
        }
        if lowercasedCurrentWord == "youve"{
            return "you've"
        }
        if lowercasedCurrentWord == "youre" || lowercasedCurrentWord == "youare"{
            return "you're"
        }
        if lowercasedCurrentWord == "shes"{
            return "she's"
        }
        if lowercasedCurrentWord == "hes"{
            return "he's"
        }
        if lowercasedCurrentWord == "theres"{
            return "there's"
        }
        if lowercasedCurrentWord == "cant"{
            return "can't"
        }
        if lowercasedCurrentWord == "doesnt"{
            return "doesn't"
        }
        if lowercasedCurrentWord == "dont"{
            return "don't"
        }
        if lowercasedCurrentWord == "wont"{
            return "won't"
        }
        if lowercasedCurrentWord == "shes"{
            return "she's"
        }
        if lowercasedCurrentWord == "couldnt"{
            return "couldn't"
        }
        if lowercasedCurrentWord == "wouldnt"{
            return "wouldn't"
        }
        if lowercasedCurrentWord == "shouldnt"{
            return "shouldn't"
        }
        if lowercasedCurrentWord == "isnt"{
            return "isn't"
        }
        if lowercasedCurrentWord == "hadnt"{
            return "hadn't"
        }
        if lowercasedCurrentWord == "hasnt"{
            return "hasn't"
        }
        if lowercasedCurrentWord == "havent"{
            return "haven't"
        }
        if lowercasedCurrentWord == "thats"{
            return "that's"
        }
        if lowercasedCurrentWord == "whatll"{
            return "what'll"
        }
        if lowercasedCurrentWord == "whats"{
            return "what's"
        }
        if lowercasedCurrentWord == "whos"{
            return "who's"
        }
        
        return String(lastWord)
    }
    
    func OnSentenceCompleted(sentence: String) -> String {
        return sentence
    }
    
    func OnTextChanged(currentText: String) -> String {
        return currentText
    }
    
    var implementsAsync = false
    
    func ShouldTriggerAsync(sentence: String) -> Bool {
        return false
    }
    
    func OnSentenceCompletedAsync(sentence: String, placeholderId: Int, completionFunction: CompletionFunction) {
        
    }
}
