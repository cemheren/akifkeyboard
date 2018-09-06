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
    
    var shiftKey: UIButton?
    var textDocumentProxy: UITextDocumentProxy
    
    private var shiftPosArr = [0]
    private var numCharacters = 0
    private var spacePressed = false
    private var spaceTimer: Timer?

    init(shiftKey: UIButton?, textDocumentProxy: UITextDocumentProxy) {
        lastWord = ""
        currentWord = ""
        currentSentence = ""
        lastSentence = ""
        self.shiftKey = shiftKey
        self.textDocumentProxy = textDocumentProxy
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
                self.setShiftValue(shiftVal: true)
                redrawButtons()
            }
        }
        else {
            proxy.insertText(insertText)
            spacePressed = ch == " "
            
            if spacePressed {
                spaceTimer?.invalidate()
                spaceTimer = Timer.scheduledTimer(timeInterval: 1,
                                                  target: self,
                                                  selector: #selector(spaceTimeout),
                                                  userInfo: nil,
                                                  repeats: false)
                lastWord = currentWord
                currentWord = ""
            }else{
                currentWord = currentWord + insertText;
            }
            
            if (shiftKey!.isSelected) {
                self.setShiftValue(shiftVal: false)
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
        currentSentence = String(currentSentence.dropLast())
        currentWord = String(currentWord.dropLast())
        
        return ""
    }

    func replaceLastWord(newWord: String){
        
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
    
    func deleteCurrentWord(){
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        
        for ch in self.currentWord{
            proxy.deleteBackward()
            currentSentence = String(currentSentence.dropLast())
            //print("del " + String(ch))
        }
        
        self.currentWord = ""
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
    }
    
    func signalSentenceEnd(){
        self.lastSentence = currentSentence
        self.currentSentence = ""
        self.lastWord = ""
        self.currentWord = ""
    }
    
    func insertText(text: String?){
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        let insertText = text ?? "";
        
        proxy.insertText(insertText)
        
        if(insertText == "." || insertText == ". " || insertText == "?" || insertText == "? " || insertText == "!" || insertText == "! "){
            lastSentence = currentSentence
            currentSentence = ""
        }else{
            currentSentence = currentSentence + insertText
        }
        
        if(insertText.range(of:" ") != nil){ // " " exists
            self.lastWord = text!
            self.currentWord = ""
        }else{
            self.currentWord = text!
        }
        
        if (shiftKey!.isSelected) {
            self.setShiftValue(shiftVal: false)
            //redrawButtons()
        }
    }
    
    func signalWordEnd(){
        self.lastWord = self.currentWord
        self.currentWord = ""
    }
    
    @objc func spaceTimeout() {
        spaceTimer = nil
        spacePressed = false
    }
    
    func setShiftValue(shiftVal: Bool) {
        if shiftKey?.isSelected != shiftVal {
            shiftKey!.isSelected = shiftVal
        }
    }
}
