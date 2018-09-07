//
//  SpecialRowController.swift
//  akifkeyboard
//
//  Created by Akif Heren on 8/20/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation
import UIKit

class SpecialRowController{
    
    private var textTracker: TextTracker?
    private var parentView: UIView?
    
    private var specialButtons: Array<UIButton> = []
    private var spellCheckController : SpellCheckController
    
    private let specialRowPadding: CGFloat = 1
    private let specialKeyHeight: CGFloat = 40
    private let keySpacing: CGFloat = 4
    private let rowSpacing: CGFloat = 9
    
    private var lastUpdated : Date = Date()
    private var spaceAfterAutoComplete = false;
    
    init(textTracker: TextTracker, parentView: UIView, spellCheckController: SpellCheckController, specialization: Specialization) {
        self.textTracker = textTracker
        self.parentView = parentView;
        self.spellCheckController = spellCheckController
        self.spaceAfterAutoComplete = specialization.spaceAfterAutoComplete
    }
    
    func getSpecialRow(){
        
    }
    
    func updateSpecialRow(){
        DispatchQueue.global(qos: .background).async {
            let currentWord = self.textTracker?.currentWord ?? ""
            var alternatives = Array<String>()
            
            if currentWord == "i" {
                alternatives.append("I")
                self.drawSpecialRow(array: [alternatives])
            }
            let lowercasedCurrentWord = currentWord.lowercased();
            
            if lowercasedCurrentWord == "im" {
                alternatives.append("I'm")
                self.drawSpecialRow(array: [alternatives])
            }
            
            if lowercasedCurrentWord == "ill"{
                alternatives.append("I'll")
                self.drawSpecialRow(array: [alternatives])
            }
            
            let lowercased = self.textTracker?.currentSentence.lowercased().components(separatedBy: " ");
            let s = NSMutableSet()
            s.addObjects(from: lowercased!)
            
            if(s.contains("how") || s.contains("what") || s.contains("who") || s.contains("where") || s.contains("why") || s.contains("which") || s.contains("when")){
                alternatives.append("?:a") //? as an append
                self.drawSpecialRow(array: [alternatives])
            }
            
            if(currentWord.count >= 1){
                let checkSpellingInitiateTime = Date();
                
                self.spellCheckController.checkSpelling(lastWord: self.textTracker?.lastWord ?? "", currentWord: currentWord, completion: { result in
                    if checkSpellingInitiateTime > self.lastUpdated {
                        
                        if(self.spaceAfterAutoComplete == false){
                            alternatives.append(contentsOf: result.alternatives.map({$0 + ":s"}))
                        }else{
                            alternatives.append(contentsOf: result.alternatives)
                        }
                        self.drawSpecialRow(array: [alternatives])
                        self.lastUpdated = Date()
                    }
                })
            }else{
                let result = self.spellCheckController.getNextWordPredictions(lastWord: (self.textTracker?.lastWord)!)
                self.drawSpecialRow(array: [result.alternatives.map{$0 + ":a"}])
            }
        }
    }
    
    func drawSpecialRow(array: Array<Array<String>>){
        DispatchQueue.main.async {
            var y: CGFloat = self.specialRowPadding
            let width = UIScreen.main.applicationFrame.size.width
            let count = CGFloat(array[0].count);
            let dynamicWidth = width/count - self.keySpacing
            
            for sb in self.specialButtons{
                sb.removeFromSuperview();
            }
            
            self.specialButtons.removeAll()
            
            for row in array {
                var x: CGFloat = ceil((width - (CGFloat(row.count) - 1) * (self.keySpacing + dynamicWidth) - dynamicWidth) / 2.0)
                for var label in row {
                    
                    let labelArr = label.components(separatedBy: ":")
                    var mode = "r";
                    if labelArr.count == 2{
                        label = labelArr[0]
                        mode = labelArr[1]
                    }
                    
                    let button = KeyButton(frame: CGRect(x: x, y: y, width: dynamicWidth, height: self.specialKeyHeight))
                    button.titleLabel?.adjustsFontSizeToFitWidth = true
                    button.mode = mode
                    button.setTitle(label, for: .normal)
                    button.addTarget(self, action:#selector(self.specialKeyPressed(sender:)), for: .touchUpInside)
                    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                    
                    self.parentView!.addSubview(button)
                    self.specialButtons.append(button)
                    x += dynamicWidth + self.keySpacing
                }
                
                y += self.specialKeyHeight + self.rowSpacing
            }
        }
    }
    
    // probably we should look at these at some point.
    // modes:
    // r : replace
    // a : append
    // n : number
    // s : no space after append
    @objc private func specialKeyPressed(sender: KeyButton) {
        if sender.titleLabel?.text == nil{
            return
        }
        
        if sender.mode == "r"{
            if self.textTracker?.currentWord == ""{
                self.textTracker?.deleteLastWord()
            }else{
                self.textTracker?.deleteCurrentWord()
            }
        }
        
        if sender.mode == "r" || sender.mode == "a"{
            self.textTracker?.insertText(text: (sender.titleLabel?.text)! + " ")
            self.clearSpecialKeys()
        }
        
        if sender.mode == "s"{
            if self.textTracker?.currentWord == ""{
                self.textTracker?.deleteLastWord()
            }else{
                self.textTracker?.deleteCurrentWord()
            }
            self.textTracker?.insertText(text: (sender.titleLabel?.text)!)
            self.clearSpecialKeys()
            self.textTracker?.signalWordEnd()
        }
        
        if sender.mode == "n"{
            self.textTracker?.insertText(text: (sender.titleLabel?.text)!)
        }
        
        self.updateSpecialRow()
    }
    
    func clearSpecialKeys(){
        for sb in self.specialButtons{
            sb.removeFromSuperview();
        }
        
        self.specialButtons.removeAll()
    }
}
