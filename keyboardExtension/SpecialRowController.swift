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
    
    private var lastemoji: String? = nil;
    private var lastarray: Array<Array<String>>? = nil
    
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
            
            let lowercased = self.textTracker?.currentSentence.lowercased().components(separatedBy: " ");
            let s = NSMutableSet()
            s.addObjects(from: lowercased!)
            
            if(s.contains("how") || s.contains("what") || s.contains("who") || s.contains("where") || s.contains("why") || s.contains("which") || s.contains("when")){
                alternatives.append("?:a") //? as an append
                self.drawSpecialRow(array: [alternatives])
            }
            
            self.emojiSetter(text: self.textTracker?.currentSentence ?? "")
            
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
    
    func updateSpecialRow(text: String){
        
        if self.lastarray == nil {return}
        
        self.lastarray?[0].append(text)
        self.drawSpecialRow(array: self.lastarray!)
    }
    
    func drawSpecialRow(array: Array<Array<String>>){
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
    
    func emojiSetter(text: String){
        if text.count < 5 {
            self.lastemoji = nil
            return
        }
        
        if text.last != " "{
            return
        }
        
        func getURI(url: String, completion: @escaping (_ result: String)->()){
            
            let uri = URL(string: url)
            
            if uri == nil { completion(""); print("not a uri: " + url); return }
            
            var request = URLRequest(url: uri!)
            request.httpMethod = "GET"
            //request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                if(response == nil){
                    return;
                }
                
                print(response!)
                print(data!)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Array<String>
                    completion(json[0])
                    
                } catch {
                    print("error")
                }
            })
            
            task.resume()
        }
        
        var k = text ?? ""
        k = k.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        k = k.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        getURI(url: "http://104.42.124.221:5000/" + k) { (result) in
            DispatchQueue.main.async {
                self.lastemoji = result
                self.updateSpecialRow(text: result + ":a")
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
