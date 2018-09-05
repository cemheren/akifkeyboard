//
//  EnglishQ.swift
//  akifkeyboard
//
//  Created by Akif Heren on 9/4/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation

class EnglishQ : Specialization{
    
    public let layout = [["q||1", "w||2", "e||3", "r||4", "t||5", "y||6", "u||7", "i||8", "o||9", "p||0"],
                  ["a||-", "s||/", "d||;", "f||(", "g||)", "h||$", "j||&", "k||@", "l||\""],
                  ["z||.", "x||,", "c||?", "v||!", "b||:", "n||!", "m||'"]];
    
    public let secondaryLayout = [["1||1", "2||2", "3||3", "4||4", "5||5", "6||6", "7||7", "8||8", "9||9", "0||0"],
                           ["-||-", "/||/", ";||;", "(||(", ")||)", "$||$", "&||&", "@||@", "\"||\""],
                           [".||.", ",||,", "?||?", "!||!", ":||:", "!||!", "'||'"]]
    
    let spellCheckfilename = "english"
    let autocompleteCutoffFrequency = 3;
}

class EnglishQTurkishExtended : Specialization{
    
    public let layout = [["q||1", "w||2", "e||3", "r||4", "t||5", "y||6", "u||7", "i||ı", "o||ö", "p||0"],
                         ["a||-", "s||ş", "d||;", "f||(", "g||ğ", "h||$", "j||&", "k||@", "l||\""],
                         ["z||.", "x||,", "c||ç", "v||?", "b||:", "n||!", "m||'"]];
    
    public let secondaryLayout = [["1||1", "2||2", "3||3", "4||4", "5||5", "6||6", "7||7", "8||8", "9||9", "0||0"],
                                  ["-||-", "/||/", ";||;", "(||(", ")||)", "$||$", "&||&", "@||@", "\"||\""],
                                  [".||.", ",||,", "?||?", "!||!", ":||:", "!||!", "'||'"]]
    
    let spellCheckfilename = "english" // for now
    let autocompleteCutoffFrequency = 3;
}

class EnglishDvorak : Specialization{
    
    public let layout = [["q||.", "p||1", "y||2", "f||3", "g||4", "c||5", "r||6", "l||7", "z||9"],
                         ["a||-", "o||/", "e||;", "u||(", "i||)", "d", "h||$", "t||&", "n||@", "s||\""],
                         ["j||,", "k||?", "x||!", "b||:", "m||!", "w||'", "v||8"]];
    
    public let secondaryLayout = [["1||1", "2||2", "3||3", "4||4", "5||5", "6||6", "7||7", "8||8", "9||9", "0||0"],
                                  ["-||-", "/||/", ";||;", "(||(", ")||)", "$||$", "&||&", "@||@", "\"||\""],
                                  [".||.", ",||,", "?||?", "!||!", ":||:", "!||!", "'||'"]]
    
    let spellCheckfilename = "english"
    let autocompleteCutoffFrequency = 3;
}
