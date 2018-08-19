//
//  KeyboardViewController.swift
//  keyboardExtension
//
//  Created by Akif Heren on 8/15/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import UIKit

class KeyButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
        }
    }
    
    override init(frame: CGRect)  {
        super.init(frame: frame)
        
        self.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 22.0)
        self.titleLabel?.textAlignment = .center
        self.setTitleColor(UIColor(white: 68.0/255, alpha: 1), for: [])
        self.titleLabel?.sizeToFit()
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red: 216.0/255, green: 211.0/255, blue: 199.0/255, alpha: 1).cgColor
        self.layer.cornerRadius = 3
        
        self.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
        self.contentVerticalAlignment = .center
        self.contentHorizontalAlignment = .center
        
        // this improves click performance: https://stackoverflow.com/questions/34324496/custom-ios-keyboard-keys-are-too-slow
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    
    let rows = [["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
                ["z", "x", "c", "v", "b", "n", "m"]]
    let specialRowPadding: CGFloat = 1
    let specialKeyHeight: CGFloat = 40
    
    let topPadding: CGFloat = 46
    let keyHeight: CGFloat = 48
    let keyWidth: CGFloat = 33
    let keySpacing: CGFloat = 4
    let rowSpacing: CGFloat = 9
    let shiftWidth: CGFloat = 40
    let shiftHeight: CGFloat = 40
    let spaceWidth: CGFloat = 200
    let spaceHeight: CGFloat = 45
    let nextWidth: CGFloat = 70
    let returnWidth: CGFloat = 100
    let keyboardHeight: CGFloat = 260
    
    var buttons: Array<UIButton> = []
    var shiftKey: UIButton?
    var deleteKey: UIButton?
    var spaceKey: UIButton?
    //var nextKeyboardButton: KeyButton?
    var returnButton: KeyButton?
    
    var specialButtons: Array<UIButton> = []
    
    var shiftPosArr = [0]
    var numCharacters = 0
    var spacePressed = false
    var spaceTimer: Timer?
    var currentWord = ""
    
    var spellcheckController : SpellCheckController = SpellCheckController()
    var textTracker: TextTracker?
    
    private weak var heightConstraint: NSLayoutConstraint?
    override func updateViewConstraints() {
        super.updateViewConstraints()
        guard nil == self.heightConstraint else { return }
        
        // We must add a subview with an `instrinsicContentSize` that uses autolayout to force the height constraint to be recognized.
        //
        let emptyView = UILabel(frame: .zero)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView);
        
        let heightConstraint = NSLayoutConstraint(item: view,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 0.0,
                                                  constant: self.keyboardHeight)
        heightConstraint.priority = .required - 1
        view.addConstraint(heightConstraint)
        self.heightConstraint = heightConstraint
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform custom UI setup here
        self.view.backgroundColor = UIColor(red: 227/255.0, green: 228/255.0, blue: 229/255.0, alpha: 1)
        
        let border = UIView(frame: CGRect(x:CGFloat(0.0), y:CGFloat(0.0), width:self.view.frame.size.width, height:CGFloat(0.5)))
        border.autoresizingMask = UIViewAutoresizing.flexibleWidth
        border.backgroundColor = UIColor(red: 210.0/255, green: 205.0/255, blue: 193.0/255, alpha: 1)
        self.view.addSubview(border)
        
        self.setupSpecialRow(array: [["b1", "b2", "b3"]])
        
        self.setupThirdRow()
        self.setupBottomRow()
        
        self.setupKeys()
        
        self.textTracker = TextTracker(shiftKey: self.shiftKey, textDocumentProxy: self.textDocumentProxy)
    }
    
    func setupSpecialRow(array: Array<Array<String>>){
        
        var y: CGFloat = specialRowPadding
        let width = UIScreen.main.applicationFrame.size.width
        let dynamicWidth = width/3.0 - keySpacing
        
        for sb in self.specialButtons{
            sb.removeFromSuperview();
        }
        
        for row in array {
            var x: CGFloat = ceil((width - (CGFloat(row.count) - 1) * (keySpacing + dynamicWidth) - dynamicWidth) / 2.0)
            for label in row {
                let button = KeyButton(frame: CGRect(x: x, y: y, width: dynamicWidth, height: self.specialKeyHeight))
                button.setTitle(label, for: .normal)
                button.addTarget(self, action:#selector(specialKeyPressed(sender:)), for: .touchUpInside)
                //button.autoresizingMask = .FlexibleWidth | .FlexibleLeftMargin | .FlexibleRightMargin
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                
                self.view.addSubview(button)
                specialButtons.append(button)
                x += dynamicWidth + keySpacing
            }
            
            y += specialKeyHeight + rowSpacing
        }
    }
    
    func setupThirdRow(){
        let thirdRowTopPadding: CGFloat = topPadding + (keyHeight + rowSpacing) * 2
        shiftKey = KeyButton(frame: CGRect(x: 2.0, y: thirdRowTopPadding, width:shiftWidth, height:shiftHeight))
        shiftKey!.addTarget(self, action:#selector(shiftKeyPressed(sender:)), for: .touchUpInside)
        shiftKey!.isSelected = true
        shiftKey!.setTitle("^", for: .normal)
        shiftKey!.setTitle("^^", for: .selected)
        self.view.addSubview(shiftKey!)
        
        deleteKey = KeyButton(frame: CGRect(x:380 - shiftWidth - 2.0, y: thirdRowTopPadding, width:shiftWidth, height:shiftHeight))
        deleteKey!.addTarget(self, action:#selector(deleteKeyPressed(sender:)), for: .touchUpInside)
        deleteKey!.setTitle("<-", for: .normal)
        //deleteKey!.setTitle("*", for: .highlighted)
        self.view.addSubview(deleteKey!)
    }
    
    func setupBottomRow(){
        
        let bottomRowTopPadding = topPadding + keyHeight * 3 + rowSpacing * 2 + 10
        spaceKey = KeyButton(frame: CGRect(x:(345.0 - spaceWidth) / 2, y: bottomRowTopPadding, width:spaceWidth, height:spaceHeight))
        spaceKey!.setTitle(" ", for: .normal)
        spaceKey!.addTarget(self, action:#selector(keyPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(spaceKey!)
        
        self.nextKeyboardButton = KeyButton(frame:CGRect(x:2, y: topPadding + keyHeight * 3 + rowSpacing * 2 + 10, width:nextWidth, height:spaceHeight))
        
        nextKeyboardButton!.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size:18)
        nextKeyboardButton!.setTitle(NSLocalizedString("N", comment: "Title for 'Next Keyboard' button"), for: .normal)
        nextKeyboardButton!.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        view.addSubview(self.nextKeyboardButton!)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        
        returnButton = KeyButton(frame: CGRect(x:380 - returnWidth - 2, y: bottomRowTopPadding, width:self.returnWidth, height:spaceHeight))
        returnButton!.setTitle(NSLocalizedString("Ret", comment: "Title for 'Return Key' button"), for: .normal)
        returnButton!.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size:18)
        returnButton!.addTarget(self, action:#selector(returnKeyPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(returnButton!)
    }
    
    func setupKeys(){
        var y: CGFloat = topPadding
        var width = UIScreen.main.applicationFrame.size.width
        for row in rows {
            var x: CGFloat = ceil((width - (CGFloat(row.count) - 1) * (keySpacing + keyWidth) - keyWidth) / 2.0)
            for label in row {
                let button = KeyButton(frame: CGRect(x: x, y: y, width: keyWidth, height: keyHeight))
                button.setTitle(label.uppercased(), for: .normal)
                button.addTarget(self, action:#selector(keyPressed(sender:)), for: .touchUpInside)
                //button.autoresizingMask = .FlexibleWidth | .FlexibleLeftMargin | .FlexibleRightMargin
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                
                self.view.addSubview(button)
                buttons.append(button)
                x += keyWidth + keySpacing
            }
            
            y += keyHeight + rowSpacing
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }

    @objc func returnKeyPressed(sender: UIButton) {
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        proxy.insertText("\n")
        numCharacters = numCharacters + 1;
        shiftPosArr[shiftPosArr.count - 1] = shiftPosArr[shiftPosArr.count - 1] + 1;
        if shiftKey!.isSelected {
            shiftPosArr.append(0)
            self.textTracker?.setShiftValue(shiftVal: true)
        }
        
        spacePressed = false
    }
    
    @objc func deleteKeyPressed(sender: UIButton) {
        if numCharacters > 0 {
            let proxy = self.textDocumentProxy as UITextDocumentProxy
            proxy.deleteBackward()
            numCharacters = numCharacters - 1;
            var charactersSinceShift = shiftPosArr[shiftPosArr.count - 1]
            if charactersSinceShift > 0 {
                charactersSinceShift = charactersSinceShift - 1;
            }
            
            self.textTracker?.setShiftValue(shiftVal: charactersSinceShift == 0)
            if charactersSinceShift == 0 && shiftPosArr.count > 1 {
                shiftPosArr.removeLast()
            }
            else {
                shiftPosArr[shiftPosArr.count - 1] = charactersSinceShift
            }
        }else{
            
            // careful with this part.
            let proxy = self.textDocumentProxy as UITextDocumentProxy
            proxy.deleteBackward()
            numCharacters = 0;
        }
        
        spacePressed = false
    }
    
    @objc func shiftKeyPressed(sender: UIButton) {
        self.textTracker?.setShiftValue(shiftVal: !shiftKey!.isSelected)
        if shiftKey!.isSelected {
            shiftPosArr.append(0)
        }
        else if shiftPosArr[shiftPosArr.count - 1] == 0 {
            shiftPosArr.removeLast()
        }
        
        spacePressed = false
        
        redrawButtonsForShift()
    }
    
    @objc func keyPressed(sender: UIButton) {
        
        textTracker?.addCharacter(ch: sender.titleLabel?.text, redrawButtons: {
            redrawButtonsForShift()
        })
        currentWord = textTracker?.currentWord ?? ""
        
        if(currentWord.count >= 3){
            self.spellcheckController.checkSpelling(currentWord: currentWord, completion: { result in
                let alternatives = result.alternatives
                DispatchQueue.main.async {
                    self.setupSpecialRow(array: [alternatives])
                }
            })
        }
    }
    
    @objc func specialKeyPressed(sender: UIButton) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        
        for ch in self.currentWord{
            proxy.deleteBackward()
            print("del " + String(ch))
        }
        
        let charCount = sender.titleLabel?.text?.count ?? 0
        proxy.insertText(sender.titleLabel?.text ?? "")
        
        let charDiff = charCount - currentWord.count
        
        numCharacters = numCharacters + charDiff;
        shiftPosArr[shiftPosArr.count - 1] = shiftPosArr[shiftPosArr.count - 1] + charDiff;
        if (shiftKey!.isSelected) {
            self.textTracker?.setShiftValue(shiftVal: false)
        }
    }
    
    func redrawButtonsForShift() {
        for button in buttons {
            var text = button.titleLabel?.text
            if shiftKey!.isSelected {
                text = text?.uppercased()
            } else {
                text = text?.lowercased()
            }

            button.setTitle(text, for: UIControlState.normal)
            button.titleLabel?.sizeToFit()
        }
    }
}
