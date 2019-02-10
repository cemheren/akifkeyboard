//
//  TurkishQ.swift
//  akifkeyboard
//
//  Created by Akif Heren on 9/5/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation
import UIKit

class TurkishQ : Specialization{
    public let keyboardBgColor = UIColor(red: 227/255.0, green: 228/255.0, blue: 229/255.0, alpha: 1)
    
    public let buttonBgColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
    
    public let textColor = UIColor(white: 20.0/255, alpha: 1)
    
    public let buttonBorderColor = UIColor(red: 216.0/255, green: 211.0/255, blue: 199.0/255, alpha: 1)
    
    public let layout = [["q||1", "w||2", "e||3", "r||4", "t||5", "y||6", "u||ü", "i||ı", "o||ö", "p||0" ],
                         ["a||-", "s||ş", "d||;", "f||(", "g||ğ", "h||$", "j||&", "k||@", "l||\""],
                         ["z||.", "x||,", "c||ç", "v||,", "b||:", "n||!", "m||'"]];
    
    public let layout_prob = [[0.12, 1.68, 12.49, 6.28, 9.28, 1.66, 2.73, 7.57, 7.64, 2.14],
                              [8.04, 6.51, 3.82, 2.40, 1.87, 5.05, 0.16, 0.54, 4.07],
                              [0.09, 0.23, 3.34, 1.05, 1.48, 7.23, 2.51]]
    
    public let secondaryLayout = [["1||1", "2||2", "3||3", "4||4", "5||5", "6||6", "7||7", "8||8", "9||9", "0||0"],
                                  ["-||-", "/||/", ";||;", "(||(", ")||)", "$||$", "&||&", "@||@", "\"||\""],
                                  [".||.", ",||,", "?||?", "!||!", ":||:", "!||!", "'||'"]]
    
    let spellCheckfilename = "turkish"
    let autocompleteCutoffFrequency = 100;
    
    let spaceAfterAutoComplete = false
}
