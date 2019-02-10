//
//  EnglishQ.swift
//  akifkeyboard
//
//  Created by Akif Heren on 9/4/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation
import UIKit

class EnglishQ : Specialization{
    public let keyboardBgColor = UIColor(red: 227/255.0, green: 228/255.0, blue: 229/255.0, alpha: 1)
    
    public let buttonBgColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
    
    public let textColor = UIColor(white: 20.0/255, alpha: 1)
    
    public let buttonBorderColor = UIColor(red: 216.0/255, green: 211.0/255, blue: 199.0/255, alpha: 1)
    
    public let layout = [["q||1", "w||2", "e||3", "r||4", "t||5", "y||6", "u||7", "i||8", "o||9", "p||0"],
                  ["a||-", "s||/", "d||;", "f||(", "g||)", "h||$", "j||&", "k||@", "l||\""],
                  ["z||.", "x||,", "c||?", "v||!", "b||:", "n||=", "m||'"]];
    
    public let layout_prob = [[0.12, 1.68, 12.49, 6.28, 9.28, 1.66, 2.73, 7.57, 7.64, 2.14],
                               [8.04, 6.51, 3.82, 2.40, 1.87, 5.05, 0.16, 0.54, 4.07],
                               [0.09, 0.23, 3.34, 1.05, 1.48, 7.23, 2.51]]
    
    public let secondaryLayout = [["1||1", "2||2", "3||3", "4||4", "5||5", "6||6", "7||7", "8||8", "9||9", "0||0"],
                           ["-||-", "/||/", ";||;", "(||(", ")||)", "$||$", "&||&", "@||@", "\"||\""],
                           [".||.", ",||,", "?||?", "!||!", ":||:", "=||=", "'||'"]]
    
    let spellCheckfilename = "english"
    let autocompleteCutoffFrequency = 3;
    let spaceAfterAutoComplete = true;
    
}

class EnglishQDark : Specialization{
    public let keyboardBgColor = UIColor(red: 9/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1)
    
    public let buttonBgColor =  UIColor(red: 60/255.0, green: 60/255.0, blue: 60/255.0, alpha: 1)
    
    public let textColor = UIColor(white: 220/255.0, alpha: 1)
    
    public let buttonBorderColor = UIColor(red: 40/255.0, green: 40/255.0, blue: 40/255.0, alpha: 1)
    
    public let layout = [["q||1", "w||2", "e||3", "r||4", "t||5", "y||6", "u||7", "i||8", "o||9", "p||0"],
                         ["a||-", "s||/", "d||;", "f||(", "g||)", "h||$", "j||&", "k||@", "l||\""],
                         ["z||.", "x||,", "c||?", "v||!", "b||:", "n||=", "m||'"]];
    
    public let layout_prob = [[0.12, 1.68, 12.49, 6.28, 9.28, 1.66, 2.73, 7.57, 7.64, 2.14],
                              [8.04, 6.51, 3.82, 2.40, 1.87, 5.05, 0.16, 0.54, 4.07],
                              [0.09, 0.23, 3.34, 1.05, 1.48, 7.23, 2.51]]
    
    public let secondaryLayout = [["1||1", "2||2", "3||3", "4||4", "5||5", "6||6", "7||7", "8||8", "9||9", "0||0"],
                                  ["-||-", "/||/", ";||;", "(||(", ")||)", "$||$", "&||&", "@||@", "\"||\""],
                                  [".||.", ",||,", "?||?", "!||!", ":||:", "=||=", "'||'"]]
    
    let spellCheckfilename = "english"
    let autocompleteCutoffFrequency = 3;
    let spaceAfterAutoComplete = true;
    
}

class EnglishQTurkishExtended : Specialization{
    public let keyboardBgColor = UIColor(red: 227/255.0, green: 228/255.0, blue: 229/255.0, alpha: 1)
    
    public let buttonBgColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
    
    public let textColor = UIColor(white: 20.0/255, alpha: 1)
    
    public let buttonBorderColor = UIColor(red: 216.0/255, green: 211.0/255, blue: 199.0/255, alpha: 1)
    
    public let layout = [["q||1", "w||2", "e||3", "r||4", "t||5", "y||6", "u||7", "i||ı", "o||ö", "p||0"],
                         ["a||-", "s||ş", "d||;", "f||(", "g||ğ", "h||$", "j||&", "k||@", "l||\""],
                         ["z||.", "x||,", "c||ç", "v||?", "b||:", "n||!", "m||'"]];
    
    public let layout_prob = [[0.12, 1.68, 12.49, 6.28, 9.28, 1.66, 2.73, 7.57, 7.64, 2.14],
                              [8.04, 6.51, 3.82, 2.40, 1.87, 5.05, 0.16, 0.54, 4.07],
                              [0.09, 0.23, 3.34, 1.05, 1.48, 7.23, 2.51]]
    
    public let secondaryLayout = [["1||1", "2||2", "3||3", "4||4", "5||5", "6||6", "7||7", "8||8", "9||9", "0||0"],
                                  ["-||-", "/||/", ";||;", "(||(", ")||)", "$||$", "&||&", "@||@", "\"||\""],
                                  [".||.", ",||,", "?||?", "!||!", ":||:", "!||!", "'||'"]]
    
    let spellCheckfilename = "english" // for now
    let autocompleteCutoffFrequency = 3;
    
    let spaceAfterAutoComplete = true;
}

class EnglishDvorak : Specialization{
    public let keyboardBgColor = UIColor(red: 227/255.0, green: 228/255.0, blue: 229/255.0, alpha: 1)
    
    public let buttonBgColor =  UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
    
    public let textColor = UIColor(white: 20.0/255, alpha: 1)
    
    public let buttonBorderColor = UIColor(red: 216.0/255, green: 211.0/255, blue: 199.0/255, alpha: 1)
    
    public let layout = [["q||.", "p||1", "y||2", "f||3", "g||4", "c||5", "r||6", "l||7", "z||9"],
                         ["a||-", "o||/", "e||;", "u||(", "i||)", "d", "h||$", "t||&", "n||@", "s||\""],
                         ["j||,", "k||?", "x||!", "b||:", "m||=", "w||'", "v||8"]];
    
    public let layout_prob = [[0.12, 2.14, 1.66, 2.40, 1.87, 3.34, 6.28, 4.07, 0.09, ],
                              [8.04, 7.64, 12.49, 2.73, 7.57, 3.58, 5.05, 9.28, 7.23, 6.51],
                              [0.16, 0.54, 0.23, 1.48, 2.51, 1.68, 1.05]]
    
    public let secondaryLayout = [["1||1", "2||2", "3||3", "4||4", "5||5", "6||6", "7||7", "8||8", "9||9", "0||0"],
                                  ["-||-", "/||/", ";||;", "(||(", ")||)", "$||$", "&||&", "@||@", "\"||\""],
                                  [".||.", ",||,", "?||?", "!||!", ":||:", "=||=", "'||'"]]
    
    let spellCheckfilename = "english"
    let autocompleteCutoffFrequency = 3;
    let spaceAfterAutoComplete = true;
}
