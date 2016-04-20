//
//  SettingsViewController.swift
//  FileCabinet
//
//  Created by Jacob Kohn on 4/6/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    var categories = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = populateCoreDataArray("Category")
        
        table.delegate = self
        table.dataSource = self
        
        navBar.topItem?.title = "Categories"
        navBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "add:")
        navBar.topItem?.rightBarButtonItem?.tintColor = UIColor.whiteColor()
    }
    
    func add(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Category", message: "Add a new caterogoy?", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in })
        
        alert.addAction(UIAlertAction(title: "Add Category", style: .Default, handler: { (action) -> Void in
            
            if(alert.textFields![0].text != "") {
                
                let appDelegate =
                UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                
                let entity =  NSEntityDescription.entityForName("Category", inManagedObjectContext: managedContext)
                
                //creates new password object
                let categoryObject = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext:managedContext)
                
                categoryObject.setValue(alert.textFields![0].text, forKey: "name")
                
                var error: NSError?
                do {
                    try managedContext.save()
                } catch var error1 as NSError {
                    error = error1
                    print("Could not save \(error), \(error?.userInfo)")
                }
                
                self.categories.insert(categoryObject, atIndex: self.categories.count)
                
                do {
                    try managedContext.save()
                } catch _ {
                }
                
                self.table.reloadData()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func populateCoreDataArray(entity: String) -> [NSManagedObject] {
        //get ideas
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName:entity)
        let error: NSError?
        var fetchedResults = [NSManagedObject]()
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            
            print("Fetch failed: \(error.localizedDescription)")
        }
        return fetchedResults
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell") as! CategoryCell
        
        cell.nameLabel.text = (categories[indexPath.row].valueForKey("name") as! String)
        
        //print(cell.nameLabel.text!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(categories.count)
        return categories.count
    }
}