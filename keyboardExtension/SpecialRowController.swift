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
    private var spellCheckController : SpellCheckController = SpellCheckController()
    
    private let specialRowPadding: CGFloat = 1
    private let specialKeyHeight: CGFloat = 40
    private let keySpacing: CGFloat = 4
    private let rowSpacing: CGFloat = 9
    
    private var lastUpdated : Date = Date()
    
    init(textTracker: TextTracker, parentView: UIView) {
        self.textTracker = textTracker
        self.parentView = parentView;
    }
    
    func getSpecialRow(){
        
    }
    
    func updateSpecialRow(){
        let currentWord = self.textTracker?.currentWord ?? ""
        var alternatives = Array<String>()
        
        if(self.handlePronouns(currentWord)){
            return; // already handled
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
            
            self.spellCheckController.checkSpelling(currentWord: currentWord, completion: { result in
                if checkSpellingInitiateTime > self.lastUpdated {
                    alternatives.append(contentsOf: result.alternatives)
                    self.drawSpecialRow(array: [alternatives])
                    self.lastUpdated = Date()
                }
            })
        }
    }
    
    // returns is handled
    private func handlePronouns(_ currentWord: String) -> Bool{
        if currentWord == "i" {
            self.drawSpecialRow(array:[["I"]])
            return true;
        }
        let lowercased = currentWord.lowercased();
        
        if lowercased == "im" {
            self.drawSpecialRow(array:[["I'm"]])
            return true;
        }
        
        if lowercased == "hes"{
            self.drawSpecialRow(array:[["he's"]])
            return true;
        }
        
        if lowercased == "its"{
            self.drawSpecialRow(array:[["it's"]])
            return true;
        }
        
        if lowercased == "ill"{
            self.drawSpecialRow(array:[["I'll"]])
            return true;
        }
        
        return false;
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
    
    // modes:
    // r : replace
    // a : append
    // n : number
    @objc private func specialKeyPressed(sender: KeyButton) {
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
        
        if sender.mode == "n"{
            self.textTracker?.insertText(text: (sender.titleLabel?.text)!)
        }
    }
    
    func clearSpecialKeys(){
        for sb in self.specialButtons{
            sb.removeFromSuperview();
        }
    }
}
