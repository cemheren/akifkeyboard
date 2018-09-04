//
//  SettingsViewController.swift
//  akifkeyboard
//
//  Created by Akif Heren on 9/4/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func BackButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeController
        self.present(newViewController, animated: false, completion: nil)
    }
    
    @IBAction func PickEnglish(_ sender: Any) {
        if let userDefaults = UserDefaults(suiteName: "group.heren.kifboard") {
            userDefaults.set("English", forKey: "flavor")
        }
    }
    
    @IBAction func PickTurkish(_ sender: Any) {
        if let userDefaults = UserDefaults(suiteName: "group.heren.kifboard") {
            userDefaults.set("Turkish", forKey: "flavor")
        }
    }
}
