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
    
    init(textTracker: TextTracker, parentView: UIView) {
        self.textTracker = textTracker
        self.parentView = parentView;
    }
    
    func getSpecialRow(){
        
    }
    
    func updateSpecialRow(){
        let currentWord = self.textTracker?.currentWord ?? ""
        
        if(currentWord.count >= 3){
            self.spellCheckController.checkSpelling(currentWord: currentWord, completion: { result in
                let alternatives = result.alternatives
                self.drawSpecialRow(array: [alternatives])
            })
        }
    }
    
    func drawSpecialRow(array: Array<Array<String>>){
        DispatchQueue.main.async {
            var y: CGFloat = self.specialRowPadding
            let width = UIScreen.main.applicationFrame.size.width
            let dynamicWidth = width/3.0 - self.keySpacing
            
            for sb in self.specialButtons{
                sb.removeFromSuperview();
            }
            
            for row in array {
                var x: CGFloat = ceil((width - (CGFloat(row.count) - 1) * (self.keySpacing + dynamicWidth) - dynamicWidth) / 2.0)
                for label in row {
                    let button = KeyButton(frame: CGRect(x: x, y: y, width: dynamicWidth, height: self.specialKeyHeight))
                    button.setTitle(label, for: .normal)
                    button.addTarget(self, action:#selector(self.specialKeyPressed(sender:)), for: .touchUpInside)
                    //button.autoresizingMask = .FlexibleWidth | .FlexibleLeftMargin | .FlexibleRightMargin
                    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                    
                    self.parentView!.addSubview(button)
                    self.specialButtons.append(button)
                    x += dynamicWidth + self.keySpacing
                }
                
                y += self.specialKeyHeight + self.rowSpacing
            }
        }
    }
    
    @objc private func specialKeyPressed(sender: UIButton) {
        self.textTracker?.deleteCurrentWord()
        self.textTracker?.insertText(text: sender.titleLabel?.text)
    }
}
