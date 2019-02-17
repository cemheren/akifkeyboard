//
//  SpecialRowKeyButton.swift
//  akifkeyboard
//
//  Created by Akif Heren on 2/16/19.
//  Copyright © 2019 Akif Heren. All rights reserved.
//

import Foundation
import UIKit

enum SpecialKeyOperationMode{
    case append
    case appendNoSpace
    case replace
    case number
}

class SpecialRowKeyPlaceHolder{
    var operationMode: SpecialKeyOperationMode!
    var text: String?
    
    init(text: String, operationMode: SpecialKeyOperationMode){
        self.operationMode = operationMode
        self.text = text;
    }
    
    init(text: String){
        self.text = text
        self.operationMode = SpecialKeyOperationMode.replace
    }
}

class SpecialRowKeyButton : KeyButton{
    
    var operationMode: SpecialKeyOperationMode?
    
    init(frame: CGRect, operationMode: SpecialKeyOperationMode, settings: Specialization) {
        super.init(frame: frame, settings: settings)
        self.operationMode = operationMode
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
