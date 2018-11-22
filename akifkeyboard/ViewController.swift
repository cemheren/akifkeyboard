//
//  ViewController.swift
//  akifkeyboard
//
//  Created by Akif Heren on 8/15/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import UIKit

class HomeController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var maintview: UITextView!
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       maintview.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func OpenSettings(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "Settings") as! SettingsController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if self.maintview.text.length < 5 {
            return
        }
        
        if self.maintview.text.last != " "{
            return
        }
        
        func getURI(url: String, completion: @escaping (_ result: String)->()){
            
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
                    completion(json[0] + ", " + json[1] + ", " + json[2] + ", " + json[3] + ", " + json[4])
                    
                } catch {
                    print("error")
                }
            })
            
            task.resume()
        }
        
        var k = self.maintview.text ?? ""
        k = k.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        k = k.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        getURI(url: "http://104.42.124.221:5000/" + k) { (result) in
            DispatchQueue.main.async {
                self.label.text = result;
            }
        }
        
    }
}

