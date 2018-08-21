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
        let insertText = ch ?? "";
        
        if spacePressed && ch == " " {
            proxy.deleteBackward()
            proxy.insertText(". ")
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
                currentWord = ""
            }else{
                currentWord = currentWord + insertText;
            }
            
            if (shiftKey!.isSelected) {
                self.setShiftValue(shiftVal: false)
                redrawButtons()
            }
        }
        
        numCharacters = numCharacters + 1;
        shiftPosArr[shiftPosArr.count - 1] = shiftPosArr[shiftPosArr.count - 1] + 1;
    }
    
    func deleteCharacter() -> String {
        
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
    
    func deleteCurrentWord(){
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        
        for ch in self.currentWord{
            proxy.deleteBackward()
            print("del " + String(ch))
        }
    }
    
    func insertText(text: String?){
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        let charCount = text?.count ?? 0
        
        proxy.insertText(text ?? "")
        
        let charDiff = charCount - currentWord.count
        
        numCharacters = numCharacters + charDiff;
        if (shiftKey!.isSelected) {
            self.setShiftValue(shiftVal: false)
            //redrawButtons()
        }
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
