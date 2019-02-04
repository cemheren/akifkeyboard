//
//  Specialization.swift
//  akifkeyboard
//
//  Created by Akif Heren on 9/5/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

protocol Specialization{
    
    var layout: [[String]] {get}
    var layout_prob: [[Double]] {get}
    var secondaryLayout: [[String]] {get}
    
    var spellCheckfilename: String {get}
    var autocompleteCutoffFrequency: Int {get}
    
    var spaceAfterAutoComplete: Bool {get}
}
