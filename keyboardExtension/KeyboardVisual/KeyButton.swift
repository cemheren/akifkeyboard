//
//  KeyButton.swift
//  akifkeyboard
//
//  Created by Akif Heren on 3/10/19.
//  Copyright © 2019 Akif Heren. All rights reserved.
//

import Foundation

import UIKit
import AudioToolbox

class KeyButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            //backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
        }
    }
    var marginX: CGFloat = 3
    var marginY: CGFloat = 3
    
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    var mode: String?;
    var secondaryTitle: String?;
    
    public var longSelected = false;
    
    init(frame: CGRect, settings: Specialization, noBackground: Bool = false)  {
        super.init(frame: frame)
        
        self.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 22.0)
        self.titleLabel?.textAlignment = .center
        let buttonTextColor = settings.textColor
        self.setTitleColor(buttonTextColor, for: [])
        self.titleLabel?.sizeToFit()
        
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 6
        
        if (noBackground){
            self.layer.borderColor = settings.keyboardBgColor.cgColor
            self.backgroundColor = settings.keyboardBgColor
        }else{
            self.layer.borderColor = settings.buttonBorderColor.cgColor
            self.backgroundColor = settings.buttonBgColor // UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        }
        
        self.contentVerticalAlignment = .center
        self.contentHorizontalAlignment = .center
        
        // this improves click performance: https://stackoverflow.com/questions/34324496/custom-ios-keyboard-keys-are-too-slow
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    func setMargin(marginX: CGFloat, marginY: CGFloat, offsetX: CGFloat, offsetY: CGFloat){
        self.marginX = marginX
        self.marginY = marginY
        self.offsetX = offsetX
        self.offsetY = offsetY
    }
    
    override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        var area = self.bounds.insetBy(dx: -marginX, dy: -marginY)
        area = area.offsetBy(dx: -offsetX, dy: -offsetY)
        return area.contains(point)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //UIDevice.current.playInputClick()
        AudioServicesPlaySystemSound(0x450)
        super.touchesBegan(touches, with: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
