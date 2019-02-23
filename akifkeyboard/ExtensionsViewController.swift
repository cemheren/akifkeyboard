//
//  ExtensionsViewController.swift
//  akifkeyboard
//
//  Created by Akif Heren on 2/13/19.
//  Copyright © 2019 Akif Heren. All rights reserved.
//

import Foundation
import UIKit

class ExtensionCell : UITableViewCell{
    @IBOutlet weak var cellDescription: UITextView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var purchaseButton: UIButton!
}

class ExtensionsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let extensions: [String] = ["EmojiExtension", "QuickFixTextExtension"]
    let descriptions: [String] = [
        "Uses advanced machine learning to come up with the most suitable emoji! Requires internet access to communicate to the model. Since it's backed by a server costs 1$ a year.",
        "Applies quick fixes to simple English structures such as i'll -> I'll or hes -> he's, im -> I'm. Useful for quick typing."]
    let prices: [String] = [
        "$0.99",
        "Free"
    ]
    
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "extensionCell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    var selectedExtensions : Set<String> = Set()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellReuseIdentifier)
    
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
    
    @IBAction func OnGithubClicked(_ sender: Any) {
        if let link = URL(string: "https://github.com/cemheren/akifkeyboard/tree/master/keyboardExtension/Extensions") {
            UIApplication.shared.open(link)
        }
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
        let c = self.tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier);
        let cell: ExtensionCell = c as! ExtensionCell
        
        // set the text from the data model
        //cell.textLabel?.text = self.extensions[indexPath.row]
        cell.cellTitle.text = self.extensions[indexPath.row]
        cell.cellDescription.text = self.descriptions[indexPath.row]
        
        cell.purchaseButton.setTitle(self.prices[indexPath.row], for: UIControlState.normal)
        cell.purchaseButton.layer.borderColor = self.view.tintColor.cgColor;
        cell.purchaseButton.layer.borderWidth = 1.0;
        cell.purchaseButton.layer.cornerRadius = 10;
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
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

