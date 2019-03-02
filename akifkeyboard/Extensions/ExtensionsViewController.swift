//
//  ExtensionsViewController.swift
//  akifkeyboard
//
//  Created by Akif Heren on 2/13/19.
//  Copyright © 2019 Akif Heren. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class ExtensionCell : UITableViewCell{
    @IBOutlet weak var cellDescription: UITextView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var purchaseButton: UIButton!
}

class ExtensionsController: UIViewController, UITableViewDelegate, UITableViewDataSource, StoreKitItemRequestFetchCompleteDelegate {
    
    let extensions: [ExtensionConfiguration] = ExtensionConfigurations.Instance
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "extensionCell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    var selectedExtensions : Set<String> = Set()
    
    var storeKit : StoreKitItemDelegate?
    
    var selectedCell: ExtensionCell?
    var selectedExtension: ExtensionConfiguration?
    
    override func viewDidLoad() {
        self.storeKit = StoreKitItemDelegate(extensionRequestFetchCompleteDelegate: self)
        self.storeKit?.fetchProducts(extensionConfigurations: self.extensions)
        
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
    
    @IBAction func OnRestoreClicked(_ sender: Any) {
        self.storeKit?.restorePurchases()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(self.selectedExtensions.contains(self.extensions[indexPath.row].identifier)){
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            //self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: indexPath)
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
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        
        // set the text from the data model
        //cell.textLabel?.text = self.extensions[indexPath.row]
        cell.cellTitle.text = self.extensions[indexPath.row].identifier
        cell.cellDescription.text = self.extensions[indexPath.row].description
        
        cell.purchaseButton.setTitle(self.extensions[indexPath.row].price, for: UIControlState.normal)
        
        if(cell.isSelected ||
            self.selectedExtensions.contains(self.extensions[indexPath.row].identifier))
        {
            cell.purchaseButton.setTitle("Enabled", for: UIControlState.normal)
        }
        
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
        
        var selectedCell = self.tableView.cellForRow(at: indexPath) as! ExtensionCell
        selectedCell.purchaseButton.setTitle("Removed", for: UIControlState.normal)
        
        self.selectedExtensions.remove(self.extensions[indexPath.row].identifier)
        
        if let userDefaults = UserDefaults(suiteName: "group.heren.kifboard") {
            userDefaults.set(Array(self.selectedExtensions), forKey: "extensions")
        }
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell \(self.extensions[indexPath.row]).")
    
        self.storeKit?.purchase(productID: self.extensions[indexPath.row].sku)
        
        let selectedCell = self.tableView.cellForRow(at: indexPath) as! ExtensionCell
        selectedCell.purchaseButton.setTitle("Waiting", for: UIControlState.normal)
        
        self.selectedCell = selectedCell
        self.selectedExtension = self.extensions[indexPath.row]
        
        if(self.selectedExtension!.isFree){
            self.AddSelectedExtension()
        }
    }
    
    func OnFetchProductsComplete(products: [SKProduct]) {
        
        // make eligible
        self.extensions.forEach{ ext in
            
        }
    }
    
    func OnPurchaseProductComplete(Sku: String) {
        print("purchase complete")
        
        if(self.selectedExtension == nil || self.selectedCell == nil){
            return
        }
        
        self.AddSelectedExtension()
    }
    
    func OnRestoreProductComplete(Sku: String) {
        print("purchase complete")
        
        var i = 0;
        self.extensions.forEach{ e in
            if(e.sku == Sku){
                self.selectedExtension = e;
                self.selectedCell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! ExtensionCell
                
                self.tableView.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.none)
                
                return
            }
            
            i = i + 1;
        }
        
        self.AddSelectedExtension()
    }
    
    func AddSelectedExtension(){
        self.selectedExtensions.insert(self.selectedExtension!.identifier)
        
        self.selectedCell!.purchaseButton.setTitle("Enabled", for: UIControlState.normal)
        
        if let userDefaults = UserDefaults(suiteName: "group.heren.kifboard") {
            userDefaults.set(Array(self.selectedExtensions), forKey: "extensions")
        }
    }
    
    func OnTransactionError(error: NSError) {
        let alert = UIAlertController(title: "Error", message: "There was an error with your transaction. Please try restoring your purchases.", preferredStyle: .actionSheet)
        
        self.selectedCell!.purchaseButton.setTitle("Error", for: UIControlState.normal)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }}))
        self.present(alert, animated: true, completion: nil)
    }
}
