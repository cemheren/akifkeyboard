//
//  textTracker.swift
//  akifkeyboard
//
//  Created by Akif Heren on 8/19/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation
import UIKit

class TextTracker{
    
    var lastWord: String
    var currentWord: String
    var currentSentence: String
    var lastSentence: String
    
    var shiftKey: KeyButton?
    var textDocumentProxy: UITextDocumentProxy
    
    private var shiftPosArr = [0]
    private var numCharacters = 0
    private var spacePressed = false
    private var spaceTimer: Timer?
    
    private var selectedExtensions: [Extension]

    init(shiftKey: KeyButton!, textDocumentProxy: UITextDocumentProxy, selectedExtensions: [Extension]) {
        lastWord = ""
        currentWord = ""
        currentSentence = ""
        lastSentence = ""
        self.shiftKey = shiftKey!
        self.textDocumentProxy = textDocumentProxy
        
        self.selectedExtensions = selectedExtensions
    }
    
    func addCharacter(ch: String?, redrawButtons: () -> ()){
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        var insertText = ch ?? "";
        
        if spacePressed && ch == " " {
            proxy.deleteBackward()
            insertText = ". "
            proxy.insertText(insertText)
            spacePressed = false
            
            if (shiftKey!.isSelected == false) {
                self.shiftKey?.isSelected = true;
                redrawButtons()
            }
        }
        else {
            spacePressed = ch == " "
            let enterPressed = ch == "\n"
            
            if spacePressed || enterPressed{
                spaceTimer?.invalidate()
                spaceTimer = Timer.scheduledTimer(timeInterval: 1,
                                                  target: self,
                                                  selector: #selector(spaceTimeout),
                                                  userInfo: nil,
                                                  repeats: false)
                
                if(!enterPressed){
                    
                    let text = (proxy.documentContextBeforeInput ?? "")
                    currentWord = String(text.split(separator: " ", maxSplits: 1000, omittingEmptySubsequences: false).last ?? "")
                    
                    for e in self.selectedExtensions{
                        let corrrectedWord = e.OnWordAdded(lastWord: currentWord);
                        if(currentWord != corrrectedWord){
                            
                            self.replaceLastWordAtNewWordDetection(newLastWord: corrrectedWord)
                        }
                    }
                }
                
                lastWord = currentWord
                currentWord = ""
            }else{
                currentWord = currentWord + insertText;
            }
            
            proxy.insertText(insertText)
            
            if (self.shiftKey!.isSelected && self.shiftKey!.longSelected == false) {
                self.shiftKey?.isSelected = false
                redrawButtons()
            }
        }
        
        if(insertText == "." || insertText == ". " || insertText == "?" || insertText == "? " || insertText == "!" || insertText == "! "){
            lastSentence = currentSentence
            currentSentence = ""
        }else{
            currentSentence = currentSentence + insertText
        }
        
        numCharacters = numCharacters + 1;
        shiftPosArr[shiftPosArr.count - 1] = shiftPosArr[shiftPosArr.count - 1] + 1;
    }
    
    func deleteCharacter() -> String {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        proxy.deleteBackward()
        let text = (proxy.documentContextBeforeInput ?? "")
        
        currentSentence = text
        currentWord = String(text.split(separator: " ", maxSplits: 1000, omittingEmptySubsequences: false).last ?? "")
        
        if(currentWord == ""){
            lastWord = String(text.split(separator: " ").last ?? "")
        }
        
        self.spacePressed = false
        
        return ""
    }
	
    func replaceLastWordAtNewWordDetection(newLastWord: String){
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        let text = (proxy.documentContextBeforeInput ?? "")
        
        currentWord = String(text.split(separator: " ", maxSplits: 1000, omittingEmptySubsequences: false).last ?? "")
        
        for _ in self.currentWord{
            proxy.deleteBackward()
            currentSentence = String(currentSentence.dropLast())
            //print("del " + String(ch))
        }
        
        insertText(text: newLastWord)
    }
    
    func getLastWord() -> String{
        
        return lastWord
    }
    
    func getlastSentence() -> String{
        
        return lastSentence
    }
    
    func getCurrentSentence() -> String{
        
        return currentSentence
    }
    
    func deleteUntilLastSpace(){
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        let text = (proxy.documentContextBeforeInput ?? "")
        
        var split = text.split(separator: " ", maxSplits: 1000, omittingEmptySubsequences: true)
        var last = split.last ?? Substring()
        
        for ch in last{
            proxy.deleteBackward()
        }
        
        if text.last == " "{
            proxy.deleteBackward()
        }
        
        let remaining = split.prefix(upTo: split.count - 1)
        currentSentence = remaining.joined(separator: " ")
        currentWord = ""
        
        if(currentWord == ""){
            lastWord = String(remaining.last ?? "")
        }
        
        self.spacePressed = false
    }
    
    func deleteCurrentWord(){
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        
        for ch in self.currentWord{
            proxy.deleteBackward()
            currentSentence = String(currentSentence.dropLast())
            //print("del " + String(ch))
        }
        
        self.currentWord = ""
        self.spacePressed = false
    }
    
    func deleteLastWord(){
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        
        for ch in self.lastWord{
            proxy.deleteBackward()
            currentSentence = String(currentSentence.dropLast())
            //print("del " + String(ch))
        }
        
        // delete extra space...
        proxy.deleteBackward()
        currentSentence = String(currentSentence.dropLast())
        
        self.currentWord = ""
        self.lastWord = ""
        self.spacePressed = false
    }
    
    func signalSentenceEnd(){
        self.lastSentence = currentSentence
        self.currentSentence = ""
        self.lastWord = ""
        self.currentWord = ""
        self.spacePressed = false
    }
    
    func insertText(text: String?){
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        var insertText = text ?? "";

        if(self.shiftKey!.isSelected == true){
            insertText = insertText.capitalized
        }
        
        if(self.shiftKey?.longSelected == true){
            insertText = insertText.uppercased()
        }
        
        let substrings = insertText.split(separator: " ", maxSplits: 1000, omittingEmptySubsequences: false);
        
        var fixed = [String]()
        
        for substring in substrings{
            var s = String(substring)
            for e in self.selectedExtensions{
                s = e.OnWordAdded(lastWord: s);
            }
            fixed.append(s)
        }
        
        insertText = fixed.joined(separator: " ")
        
        proxy.insertText(insertText)
        
        if(insertText == "." || insertText == ". " || insertText == "?" || insertText == "? " || insertText == "!" || insertText == "! "){
            lastSentence = currentSentence
            currentSentence = ""
        }else{
            currentSentence = currentSentence + insertText
        }
        
        if(insertText.range(of:" ") != nil){ // " " exists
            self.lastWord = String(text!.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ").last ?? "")
            self.currentWord = ""
        }else{
            self.currentWord = insertText
        }
        
        if (shiftKey!.isSelected && self.shiftKey!.longSelected == false) {
            self.shiftKey!.isSelected = false
            // redraw buttons
        }
        
        self.spacePressed = false
    }
    
    func signalWordEnd(){
        self.lastWord = self.currentWord.trimmingCharacters(in: .whitespacesAndNewlines)
        self.currentWord = ""
    }
    
    @objc func spaceTimeout() {
        spaceTimer = nil
        spacePressed = false
    }
    
    func setShiftValue(shiftVal: KeyButton) {
        self.shiftKey = shiftVal
    }
}
