//
//  AddOnInterface.swift
//  akifkeyboard
//
//  Created by Akif Heren on 2/16/19.
//  Copyright © 2019 Akif Heren. All rights reserved.
//

import Foundation
protocol Extension{
    init()
    
    func OnWordAdded(lastWord: String) -> String
    
    func OnSentenceCompleted(sentence: String) -> String

    func OnTextChanged(currentText: String) -> String
    
    var implementsAsync : Bool {get}
    
//    func OnWordAddedAsync(lastWord: String, completionFunction: CompletionFunction) -> Void
//    func OnWordAddedAsyncCompletion(result: String) -> String
//
    func OnSentenceCompletedAsync(sentence: String, placeholderId: Int, completionFunction: CompletionFunction) -> Void
    
//    var OnTextChangedAsyncCompletion : CompletionFunction {get}
//    func OnTextChangedAsync(currentText: String, completionFunction: CompletionFunction) -> Void
}

protocol CompletionFunction{
    
    func OnComplete(result: String, placeholderId: Int) -> Void
}
