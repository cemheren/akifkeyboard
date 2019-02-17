//
//  EmojiExtension.swift
//  akifkeyboard
//
//  Created by Akif Heren on 2/16/19.
//  Copyright © 2019 Akif Heren. All rights reserved.
//

import Foundation
class EmojiExtension: Extension{
    required init() {
        
    }
    
    private var lastemoji: String? = nil;
    
    func OnSentenceCompletedAsyncCompletion(result: String) -> String {
        return result
    }
    
    private func getURI(url: String, completion: @escaping (_ result: String)->()){
        let uri = URL(string: url)
        
        if uri == nil { completion(""); print("not a uri: " + url); return }
        
        var request = URLRequest(url: uri!)
        request.httpMethod = "GET"
        //request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if(response == nil){
                return;
            }
            
            print(response!)
            print(data!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Array<String>
                completion(json[0])
                
            } catch {
                print("error")
            }
        })
        
        task.resume()
    }
    
    func OnSentenceCompletedAsync(sentence: String, placeholderId: Int, completionFunction: CompletionFunction) {
        if sentence.count < 5 {
            self.lastemoji = nil
            return
        }
        
        if sentence.last != " "{
            return
        }
        
        var k = sentence ?? ""
        k = k.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        k = k.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        self.getURI(url: "http://104.42.255.66:5000/" + k) { (result) in
            DispatchQueue.main.async {
                self.lastemoji = result
                
                completionFunction.OnComplete(result: result, placeholderId: placeholderId)
            }
        }
    }
    
    let implementsAsync = true;
    
    func OnWordAdded(lastWord: String) -> String {
        return lastWord
    }
    
    func OnSentenceCompleted(sentence: String) -> String {
        return sentence
    }
    
    func OnTextChanged(currentText: String) -> String {
        return currentText
    }
}
