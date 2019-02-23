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
        if lowercasedCurrentWord == "i'll"{
            return "I'll"
        }
        if lowercasedCurrentWord == "i've"{
            return "I've"
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
