//
//  SpecialRowController.swift
//  akifkeyboard
//
//  Created by Akif Heren on 8/20/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation
import UIKit

class SpecialRowController: CompletionFunction{
    
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
    
    private var lastarray: Array<Array<SpecialRowKeyPlaceHolder>>? = nil
    
    private var settings: Specialization
    
    private var selectedExtensions: [Extension]
    
    init(textTracker: TextTracker, parentView: UIView, spellCheckController: SpellCheckController, specialization: Specialization) {
        self.textTracker = textTracker
        self.parentView = parentView;
        self.spellCheckController = spellCheckController
        self.spaceAfterAutoComplete = specialization.spaceAfterAutoComplete
        
        self.settings = specialization
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;
        self.selectedExtensions = [Extension]()
        
        if let userDefaults = UserDefaults(suiteName: "group.heren.kifboard") {
            let arr = userDefaults.stringArray(forKey: "extensions") ?? []

            for e in arr {
                var extensionClass: AnyClass = (NSClassFromString("\(namespace).\(e)") as! AnyClass) ;
                let extensionClass1 = extensionClass as! Extension.Type
                
                self.selectedExtensions.append(extensionClass1.init())
            }
        }
    }
    
    func getSpecialRow(){
        
    }
    
    func updateSpecialRow(){
        DispatchQueue.global(qos: .background).async {
            let currentWord = self.textTracker?.currentWord ?? ""
            var alternatives = Array<SpecialRowKeyPlaceHolder>()
            
            let lowercased = self.textTracker?.currentSentence.lowercased().components(separatedBy: " ");
            let s = NSMutableSet()
            s.addObjects(from: lowercased!)
            
            if(s.contains("how") || s.contains("what") || s.contains("who") || s.contains("where") || s.contains("why") || s.contains("which") || s.contains("when")){
                alternatives.append(SpecialRowKeyPlaceHolder(text: "?", operationMode: SpecialKeyOperationMode.append)) //? as an append
                self.drawSpecialRow(array: [alternatives])
            }
            
            for e in self.selectedExtensions{
                if(e.implementsAsync){
                    e.OnSentenceCompletedAsync(sentence: self.textTracker?.currentSentence ?? "",
                                               completionFunction: self)
                }
            }
            
            if(currentWord.count >= 1){
                let checkSpellingInitiateTime = Date();
                
                self.spellCheckController.checkSpelling(lastWord: self.textTracker?.lastWord ?? "", currentWord: currentWord, completion: { result in
                    if checkSpellingInitiateTime > self.lastUpdated {
                        
                        if(self.spaceAfterAutoComplete == false){
                            alternatives.append(contentsOf: result.alternatives.map({SpecialRowKeyPlaceHolder(text: $0, operationMode: SpecialKeyOperationMode.appendNoSpace)}))
                        }else{
                            alternatives.append(contentsOf: result.alternatives.map({SpecialRowKeyPlaceHolder(text: $0)}))
                        }
                        
                        self.drawSpecialRow(array: [alternatives])
                        
                        self.lastUpdated = Date()
                    }
                })
            }else{
                let result = self.spellCheckController.getNextWordPredictions(lastWord: (self.textTracker?.lastWord)!)
                self.drawSpecialRow(array: [result.alternatives.map{SpecialRowKeyPlaceHolder(text: $0, operationMode: SpecialKeyOperationMode.append)}])
            }
        }
    }
    
    func OnComplete(result: String) {
        self.appendToSpecialRow(text: result)
    }
    
    func appendToSpecialRow(text: String){
        
        if self.lastarray == nil {return}
        
        self.lastarray?[0].append(SpecialRowKeyPlaceHolder(text: text))
        self.drawSpecialRow(array: self.lastarray!)
    }
    
    func drawSpecialRow(array: Array<Array<SpecialRowKeyPlaceHolder>>){
        DispatchQueue.main.async {
            var y: CGFloat = self.specialRowPadding
            let width = UIScreen.main.applicationFrame.size.width
            let count = CGFloat(array[0].count);
            var effectiveCount = count;
            
            //if self.lastemoji != nil && self.lastemoji != "" { effectiveCount = effectiveCount + 1 }
            
            let dynamicWidth = width/effectiveCount - self.keySpacing
            
            self.lastarray = array;
            
            for sb in self.specialButtons{
                sb.removeFromSuperview();
            }
            
            self.specialButtons.removeAll()
            
            for row in array {
                var x: CGFloat = ceil((width - (CGFloat(effectiveCount) - 1) * (self.keySpacing + dynamicWidth) - dynamicWidth) / 2.0)
                for var placeholder in row {
                    
                    let button = SpecialRowKeyButton(
                        frame: CGRect(x: x, y: y, width: dynamicWidth, height: self.specialKeyHeight),
                        operationMode: placeholder.operationMode,
                        settings: self.settings)
                    
                    button.titleLabel?.adjustsFontSizeToFitWidth = true
                    button.setTitle(placeholder.text, for: .normal)
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
    
    @objc private func specialKeyPressed(sender: SpecialRowKeyButton) {
        if sender.titleLabel?.text == nil{
            return
        }
        
        if sender.operationMode == SpecialKeyOperationMode.replace{
            if self.textTracker?.currentWord == ""{
                self.textTracker?.deleteLastWord()
            }else{
                self.textTracker?.deleteCurrentWord()
            }
        }
        
        if sender.operationMode == SpecialKeyOperationMode.replace || sender.operationMode == SpecialKeyOperationMode.append{
            self.textTracker?.insertText(text: (sender.titleLabel?.text)! + " ")
            self.clearSpecialKeys()
        }
        
        if sender.operationMode == SpecialKeyOperationMode.appendNoSpace{
            if self.textTracker?.currentWord == ""{
                self.textTracker?.deleteLastWord()
            }else{
                self.textTracker?.deleteCurrentWord()
            }
            self.textTracker?.insertText(text: (sender.titleLabel?.text)!)
            self.clearSpecialKeys()
            self.textTracker?.signalWordEnd()
        }
        
        if sender.operationMode == SpecialKeyOperationMode.number{
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
