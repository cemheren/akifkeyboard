//
//  SpecialRowController.swift
//  akifkeyboard
//
//  Created by Akif Heren on 8/20/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import Foundation
import UIKit

class UndoItem{
    
    let prev: String
    let next: String
    
    init(prev: String, next:String) {
        self.prev = prev
        self.next = next
    }
}

class UndoController{
    
    private var stack: [UndoItem] = [UndoItem]()
    
    public func Add(previous: String, next: String){
        
        let undoItem = UndoItem(prev: previous, next: next)
        
        stack.append(undoItem)
    }
    
    public func GetLast() -> UndoItem?{
        
        return stack.popLast()
    }
    
    public func Invalidate(){
        
        stack = [UndoItem]()
    }
}
