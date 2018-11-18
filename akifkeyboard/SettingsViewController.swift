//
//  SettingsViewController.swift
//  akifkeyboard
//
//  Created by Akif Heren on 9/4/18.
//  Copyright © 2018 Akif Heren. All rights reserved.
//

import UIKit
import LionheartExtensions
import QuickTableView

class SettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let flavors: [String] = ["English", "Dvorak", "Turkish", "EnglishWithTurkishChars", "Chinese"]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var tipJarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tipjarClicked(_ sender: Any) {
        let tc = TipJarViewController<ExampleTipJarOptions>();
        
        self.navigationController?.pushViewController(tc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.flavors.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = self.flavors[indexPath.row]
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell \(self.flavors[indexPath.row]).")
        
        if let userDefaults = UserDefaults(suiteName: "group.heren.kifboard") {
            userDefaults.set(self.flavors[indexPath.row], forKey: "flavor")
        }
    }
}

struct ExampleTipJarOptions: TipJarConfiguration {
    static var topHeader = "Hi there"
    
    static var topDescription = """
If you've been enjoying this keyboard and would like to show your support, please consider a tip. They go such a long way, and every little bit helps. Thanks! :)
Don't forget to leave feedback or feature requests!
"""
    
    static func subscriptionProductIdentifier(for row: SubscriptionRow) -> String {
        switch row {
        case .monthly: return "tip.monthly"
        case .yearly: return "tip.yearly"
        }
    }
    
    static func oneTimeProductIdentifier(for row: OneTimeRow) -> String {
        switch row {
        case .small: return "small.tip"
        case .medium: return "medium.tip"
        case .large: return "large.tip"
//        case .huge:
//            return "huge.tip"
//        case .massive:
//            return "massive.tip"
        }
    }
    
    static var termsOfUseURLString = "https://github.com/cemheren/akifkeyboard"
    static var privacyPolicyURLString = "https://github.com/cemheren/akifkeyboard/blob/master/privacyPolicy.md"
}

extension ExampleTipJarOptions: TipJarOptionalConfiguration {
    static var title = "Tip Jar"
    static var oneTimeTipsTitle = "One-Time Tips"
    static var subscriptionTipsTitle = "Ongoing Tips ❤️"
    static var receiptVerifierURLString = ""
}
