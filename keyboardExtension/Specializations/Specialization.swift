//
//  Specialization.swift
//  akifkeyboard
//
//  Created by Akif Heren on 9/5/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import UIKit

protocol Specialization{
    
    var layout: [[String]] {get}
    var layout_prob: [[Double]] {get}
    var secondaryLayout: [[String]] {get}
    
    var spellCheckfilename: String {get}
    var autocompleteCutoffFrequency: Int {get}
    
    var keyboardBgColor: UIColor {get}
    
    var buttonBgColor: UIColor {get}
    var buttonBorderColor: UIColor{get}
    var textColor: UIColor {get}
    
    var spaceAfterAutoComplete: Bool {get}
}
