//
//  ExtensionsViewController.swift
//  akifkeyboard
//
//  Created by Akif Heren on 2/13/19.
//  Copyright © 2019 Akif Heren. All rights reserved.
//

import Foundation
import UIKit

class ExtensionsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let extensions: [String] = ["EmojiExtension"]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "extension"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    var selectedExtensions : Set<String> = Set()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    
        self.tableView.allowsMultipleSelection = true;
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()
        
        if let userDefaults = UserDefaults(suiteName: "group.heren.kifboard") {
            let arr = userDefaults.stringArray(forKey: "extensions") ?? []
            self.selectedExtensions = Set(arr)
        }
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(self.selectedExtensions.contains(self.extensions[indexPath.row])){
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.extensions.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = self.extensions[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("You de-selected cell \(self.extensions[indexPath.row]).")
        
        self.selectedExtensions.remove(self.extensions[indexPath.row])
        
        if let userDefaults = UserDefaults(suiteName: "group.heren.kifboard") {
            userDefaults.set(Array(self.selectedExtensions), forKey: "extensions")
        }
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell \(self.extensions[indexPath.row]).")
        
        self.selectedExtensions.insert(self.extensions[indexPath.row])
        
        if let userDefaults = UserDefaults(suiteName: "group.heren.kifboard") {
            userDefaults.set(Array(self.selectedExtensions), forKey: "extensions")
        }
    }
}

