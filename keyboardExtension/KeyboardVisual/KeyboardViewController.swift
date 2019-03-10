//
//  KeyboardViewController.swift
//  keyboardExtension
//
//  Created by Akif Heren on 8/15/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation

import UIKit
import AudioToolbox

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    
    
    let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    var settings: Specialization = EnglishQ()
    
    var selectedRows = [[""]]
    var keyProbabilities = [[1.0]]
    
    let poundKeyStates = ["off", "numeric"]
    var poundKeyCurrentState = 0
    
    let topPadding: CGFloat = 46
    let keyHeight: CGFloat = 48
    var keyWidth: CGFloat = 33
    let keySpacing: CGFloat = 4
    let rowSpacing: CGFloat = 9
    let shiftWidth: CGFloat = 45
    let shiftHeight: CGFloat = 48
    
    var spaceWidth: CGFloat = 170
    
    let spaceHeight: CGFloat = 45
    let nextWidth: CGFloat = 50
    let returnWidth: CGFloat = 90
    let keyboardHeight: CGFloat = 260
    
    var buttons: Array<UIButton> = []
    var shiftKey: KeyButton?
    var deleteKey: KeyButton?
    var spaceKey: UIButton?
    var poundKey: KeyButton?
    //var nextKeyboardButton: KeyButton?
    var returnButton: KeyButton?
    
    var shiftPosArr = [0]
    var numCharacters = 0
    var spacePressed = false
    var spaceTimer: Timer?
    var currentWord = ""
    
    var textTracker: TextTracker?
    var specialRowController: SpecialRowController?
    
    private weak var heightConstraint: NSLayoutConstraint?
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
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
        
        // Load settings
        if let userDefaults = UserDefaults(suiteName: "group.heren.kifboard") {
            if let flavor = userDefaults.string(forKey: "flavor"){
                print(flavor)
                if(flavor == "English"){
                    self.settings = EnglishQ()
                }else if(flavor == "EnglishWithTurkishChars"){
                    self.settings = EnglishQTurkishExtended()
                }else if(flavor == "EnglishQDark"){
                    self.settings = EnglishQDark()
                }else if(flavor == "Turkish"){
                    self.settings = TurkishQ()
                }else if(flavor == "Dvorak"){
                    self.settings = EnglishDvorak()
                }else if(flavor == "Chinese"){
                    self.settings = Chinese()
                }
            }
        }
        
        // Perform custom UI setup here
        self.view.backgroundColor = self.settings.keyboardBgColor;
        
        let border = UIView(frame: CGRect(x:CGFloat(0.0), y:CGFloat(0.0), width:self.view.frame.size.width, height:CGFloat(0.5)))
        border.autoresizingMask = UIViewAutoresizing.flexibleWidth
        border.backgroundColor = UIColor(red: 210.0/255, green: 205.0/255, blue: 193.0/255, alpha: 1)
        self.view.addSubview(border)
        
        self.setupThirdRow()
        self.setupBottomRow()
        
        self.selectedRows = self.settings.layout;
        self.keyProbabilities = self.settings.layout_prob;
        
        self.setupKeys()
        
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;
        var selectedExtensions = [Extension]()
        if let userDefaults = UserDefaults(suiteName: "group.heren.kifboard") {
            let arr = userDefaults.stringArray(forKey: "extensions") ?? []
            
            for e in arr {
                var extensionClass: AnyClass = (NSClassFromString("\(namespace).\(e)") as! AnyClass) ;
                let extensionClass1 = extensionClass as! Extension.Type
                
                selectedExtensions.append(extensionClass1.init())
            }
        }
        
        self.textTracker = TextTracker(
            shiftKey: self.shiftKey,
            textDocumentProxy: self.textDocumentProxy,
            selectedExtensions: selectedExtensions)
        
        self.specialRowController = SpecialRowController(
            textTracker: self.textTracker!,
            parentView: self.view,
            spellCheckController: SpellCheckController(specialization: self.settings),
            specialization: self.settings,
            selectedExtensions: selectedExtensions)
        
        self.specialRowController?.drawSpecialRow(array: [
            [SpecialRowKeyPlaceHolder(text: ""), SpecialRowKeyPlaceHolder(text: ""), SpecialRowKeyPlaceHolder(text: "")]
            ])
    }
    
    func setupThirdRow(){
        let thirdRowTopPadding: CGFloat = topPadding + (keyHeight + rowSpacing) * 2
        self.shiftKey = KeyButton(
            frame: CGRect(x: 2.0, y: thirdRowTopPadding, width:shiftWidth, height:shiftHeight),
            settings: self.settings)
        
        self.shiftKey!.setMargin(marginX: 10, marginY: 4, offsetX: 0, offsetY: 0)
        
        self.shiftKey!.addTarget(self, action:#selector(shiftKeyPressed(sender:)), for: .touchUpInside)
        self.shiftKey!.isSelected = true
        self.shiftKey!.setTitle("^", for: .normal)
        self.shiftKey!.setTitle("^^", for: .selected)
        self.view.addSubview(shiftKey!)
        let longShiftGesture = UILongPressGestureRecognizer(target: self, action: #selector(shiftKeyLongPressed(sender: )))
        self.shiftKey!.addGestureRecognizer(longShiftGesture)
        self.shiftKey!.addTarget(self, action:#selector(shiftKeyLongPressed(sender:)), for: .touchDragExit)
        
        let viewWidth = UIScreen.main.applicationFrame.size.width
        deleteKey = KeyButton(
            frame: CGRect(x:viewWidth - shiftWidth - 2.0, y: thirdRowTopPadding, width:shiftWidth, height:shiftHeight),
            settings: self.settings)
        
        deleteKey!.setMargin(marginX: 10, marginY: 4, offsetX: 0, offsetY: 0)
        deleteKey!.addTarget(self, action:#selector(deleteKeyPressed(sender:)), for: .touchUpInside)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteKeyLongPressed(sender: )))
        deleteKey!.addGestureRecognizer(longGesture)
        
        deleteKey!.setTitle("<-", for: .normal)
        //deleteKey!.setTitle("*", for: .highlighted)
        self.view.addSubview(deleteKey!)
    }
    
    func setupBottomRow(){
        
        let viewWidth = UIScreen.main.applicationFrame.size.width
        let bottomRowTopPadding = topPadding + keyHeight * 3 + rowSpacing * 2 + 8
        self.spaceWidth = viewWidth - 2 - returnWidth - 2 - nextWidth - 2 - nextWidth;
        
        spaceKey = KeyButton(
            frame: CGRect(x:(viewWidth - returnWidth - 2  - spaceWidth), y: bottomRowTopPadding, width:spaceWidth, height:spaceHeight),
            settings: self.settings)
        
        spaceKey!.setTitle(" ", for: .normal)
        spaceKey!.addTarget(self, action:#selector(keyPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(spaceKey!)
        
        self.nextKeyboardButton = KeyButton(
            frame:CGRect(x: 4 + nextWidth, y: bottomRowTopPadding, width:nextWidth, height:spaceHeight),
            settings: self.settings)
        
        nextKeyboardButton!.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size:18)
        nextKeyboardButton!.setTitle("N", for: .normal)
        nextKeyboardButton!.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        view.addSubview(self.nextKeyboardButton!)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        //self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        poundKey = KeyButton(
            frame: CGRect(x: 2, y: bottomRowTopPadding, width:nextWidth, height:spaceHeight),
            settings: self.settings)
        
        poundKey!.setTitle("#", for: .normal)
        poundKey!.addTarget(self, action:#selector(poundKeyPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(poundKey!)
        
        returnButton = KeyButton(
            frame: CGRect(x:viewWidth - returnWidth - 2, y: bottomRowTopPadding, width:self.returnWidth, height:spaceHeight),
            settings: self.settings)
        
        returnButton!.setTitle(NSLocalizedString("Ret", comment: "Title for 'Return Key' button"), for: .normal)
        returnButton!.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size:18)
        returnButton!.addTarget(self, action:#selector(returnKeyPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(returnButton!)
    }
    
    func setupKeys(){
        var y: CGFloat = topPadding
        var width = UIScreen.main.applicationFrame.size.width
        keyWidth = (width / 10.0) - keySpacing
        
        for button in self.buttons{
            button.removeFromSuperview()
        }
        self.buttons.removeAll()
        
        for (i, row) in self.selectedRows.enumerated() {
            var x: CGFloat = ceil((width - (CGFloat(row.count) - 1) * (keySpacing + keyWidth) - keyWidth) / 2.0)
            for var (k, label) in row.enumerated() {
                
                let keyProb = self.keyProbabilities[i][k]
                
                let labelArr = label.components(separatedBy: "||")
                var secondTitle = "";
                if labelArr.count == 2{
                    label = labelArr[0]
                    secondTitle = labelArr[1]
                }else{
                    label = labelArr[0]
                }
                
                let button = KeyButton(
                    frame: CGRect(x: x, y: y, width: keyWidth, height: keyHeight),
                    settings: self.settings)
                
                button.setTitle(self.shiftKey?.isSelected ?? false ? label.uppercased() : label.lowercased(), for: .normal)
                button.addTarget(self, action:#selector(keyPressed(sender:)), for: .touchUpInside)
                
                let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(keyLongPressed(sender: )))
                button.addGestureRecognizer(longGesture)
                button.addTarget(self, action:#selector(keySlideOut(sender:)), for: .touchDragExit)
                
                button.secondaryTitle = secondTitle;
                
                //button.autoresizingMask = .FlexibleWidth | .FlexibleLeftMargin | .FlexibleRightMargin
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                
                let xRange: [CGFloat] = [3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
                let yRange: [CGFloat] = [3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
                var effective: CGFloat = CGFloat(keyProb - 100.0/26.0)
                if(effective > 8) { effective = 8; }
                
                let marginX = xRange.first(where: { $0 >= effective })!
                let marginY = yRange.first(where: { $0 >= effective })!
                
                button.setMargin(
                    marginX: marginX,
                    marginY: marginY,
                    offsetX: 0,
                    offsetY: 0)

                // Hack for A and L mimicking IOS keyboard. We need to make these adaptive later.
                if(label.uppercased() == "A"){
                    button.setMargin(marginX: 15, marginY: 4, offsetX: 0, offsetY: 0)
                }
                if(label.uppercased() == "L"){
                    button.setMargin(marginX: 15, marginY: 4, offsetX: -15, offsetY: 0)
                }
                
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
        
        // something cleared the view.
        if self.textDocumentProxy.documentContextAfterInput == nil && self.textDocumentProxy.documentContextBeforeInput == nil{
            self.textTracker?.signalSentenceEnd()
        }
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        //self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }

    @objc func returnKeyPressed(sender: UIButton) {
        
        lightImpactFeedbackGenerator.impactOccurred();
        
        self.textTracker?.addCharacter(ch: "\n", redrawButtons: {
            redrawButtonsForShift()
        })

        numCharacters = numCharacters + 1;
        shiftPosArr[shiftPosArr.count - 1] = shiftPosArr[shiftPosArr.count - 1] + 1;
        if shiftKey!.isSelected {
            shiftPosArr.append(0)
            self.shiftKey?.isSelected = false
            self.textTracker?.setShiftValue(shiftVal: self.shiftKey!)
        }
        
        spacePressed = false
    }
    
    @objc func deleteKeyPressed(sender: UIButton) {
        self.textTracker?.deleteCharacter()
        self.specialRowController?.updateSpecialRow()
        spacePressed = false
    }
    
    var timer: Timer?
    @objc func deleteKeyLongPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleTimer(timer:)), userInfo: nil, repeats: true)
            lightImpactFeedbackGenerator.impactOccurred();
            
        } else if sender.state == .ended || sender.state == .cancelled {
            timer?.invalidate()
            timer = nil
            }
        spacePressed = false
    }
    
    @objc private func handleTimer(timer: Timer) {
        AudioServicesPlaySystemSound(0x450)
        self.textTracker?.deleteCharacter()
    }
    
    @objc func shiftKeyPressed(sender: UIButton) {
        if (self.shiftKey?.longSelected == true){
            self.shiftKey!.isSelected = false
            self.shiftKey!.longSelected = false;
        }else{
            self.shiftKey!.isSelected = !self.shiftKey!.isSelected
            self.shiftKey!.longSelected = false;
        }
        
        self.textTracker?.setShiftValue(shiftVal: self.shiftKey!)
        self.shiftKey?.backgroundColor = self.settings.buttonBgColor
        
        if shiftKey!.isSelected {
            shiftPosArr.append(0)
        }
        else if shiftPosArr[shiftPosArr.count - 1] == 0 {
            shiftPosArr.removeLast()
        }
        
        spacePressed = false
        
        redrawButtonsForShift()
    }
    
    @objc func shiftKeyLongPressed(sender: UIButton) {
        
        if(self.shiftKey!.longSelected == true){
            self.shiftKey!.longSelected = false
            self.shiftKey!.isSelected = false;
            self.shiftKey?.backgroundColor = self.settings.buttonBgColor
        }else{
            self.shiftKey!.longSelected = true
            self.shiftKey!.isSelected = true;
            self.shiftKey?.backgroundColor = UIColor.red
        }
        
        self.textTracker?.setShiftValue(shiftVal: self.shiftKey!)
        
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
        sender.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        
        //sender.transform = CGAffineTransform(translationX: 0, y: -65)
        
        UIView.animate(
            withDuration: 0.14,
            delay: 0,
            options: UIViewAnimationOptions.allowUserInteraction,
            animations: {
                sender.transform = CGAffineTransform.identity
            },
            completion: { Void in()  }
        )
        
        self.textTracker?.addCharacter(ch: sender.titleLabel?.text, redrawButtons: {
            redrawButtonsForShift()
        })
        self.specialRowController?.updateSpecialRow()
    }
    
    @objc func keySlideOut(sender: KeyButton) {
        self.secondaryButtonAction(button: sender)
    }
    
    @objc func keyLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended{
            let button = sender.view as! KeyButton
            
            lightImpactFeedbackGenerator.impactOccurred();
            
            self.secondaryButtonAction(button: button)
        }
    }
    
    private func secondaryButtonAction(button: KeyButton){
        
        let temp = button.titleLabel?.text
        button.setTitle(button.secondaryTitle, for: .normal)
        
        textTracker?.addCharacter(ch: button.secondaryTitle, redrawButtons: {
            redrawButtonsForShift()
        })
        self.specialRowController?.updateSpecialRow()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 1 to desired number of seconds
            button.setTitle(temp?.lowercased(), for: .normal)
        }
    }
    
    @objc func poundKeyPressed(sender: UIButton) {
        if self.poundKeyCurrentState < poundKeyStates.count - 1{
            self.poundKeyCurrentState = self.poundKeyCurrentState + 1;
        }else{
            self.poundKeyCurrentState = 0;
        }
        let nextState = self.poundKeyStates[self.poundKeyCurrentState]
        
        lightImpactFeedbackGenerator.impactOccurred();
        
        if nextState == "numeric"{
            self.selectedRows = self.settings.secondaryLayout;
            self.setupKeys()
            self.specialRowController?.drawSpecialRow(array: [
                [SpecialRowKeyPlaceHolder(text: "😂", operationMode: SpecialKeyOperationMode.number),
                 SpecialRowKeyPlaceHolder(text: "😘", operationMode: SpecialKeyOperationMode.number),
                 SpecialRowKeyPlaceHolder(text: "💕", operationMode: SpecialKeyOperationMode.number),
                 SpecialRowKeyPlaceHolder(text: "❤️", operationMode: SpecialKeyOperationMode.number),
                 SpecialRowKeyPlaceHolder(text: "👍", operationMode: SpecialKeyOperationMode.number),
                 SpecialRowKeyPlaceHolder(text: "😅", operationMode: SpecialKeyOperationMode.number),
                 SpecialRowKeyPlaceHolder(text: "😥", operationMode: SpecialKeyOperationMode.number),
                 SpecialRowKeyPlaceHolder(text: "😎", operationMode: SpecialKeyOperationMode.number),
                 SpecialRowKeyPlaceHolder(text: "☺️", operationMode: SpecialKeyOperationMode.number),
                 SpecialRowKeyPlaceHolder(text: "🙃", operationMode: SpecialKeyOperationMode.number)]
                ])
        }else{
            self.selectedRows = self.settings.layout;
            self.setupKeys()
        }
        if nextState == "off"{
            self.specialRowController?.clearSpecialKeys()
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
