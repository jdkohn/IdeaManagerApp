//
//  AddSubIdeaViewController.swift
//  FileCabinet
//
//  Created by Jacob Kohn on 1/6/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import SwiftForms
import CoreData

class AddSubIdeaViewController: FormViewController {
    
    var ideas = [NSManagedObject]()
    var subideas = [NSManagedObject]()
    var idea = Int()
    
    override func viewDidLoad() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName:"SubIdea")
        let error: NSError?
        var fetchedResults = [NSManagedObject]()
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        subideas = fetchedResults
        
        
        let fetchR = NSFetchRequest(entityName:"Idea")
        let e: NSError?
        var fetchedR = [NSManagedObject]()
        do {
            fetchedR = try managedContext.executeFetchRequest(fetchR) as! [NSManagedObject]
        } catch let e as NSError {
            print("Fetch failed: \(e.localizedDescription)")
        }
        ideas = fetchedR
        
        
        
        
        let form = FormDescriptor()
        
        form.title = "New SubIdea"
        
        // Define first section
        let section1 = FormSectionDescriptor()
        
        var row: FormRowDescriptor! = FormRowDescriptor(tag: "name", rowType: .Name, title: "Title")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "e.g. Twitter", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section1.addRow(row)
        
        let section2 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: "summary", rowType: .MultilineText, title: "Summary")
        
        section2.addRow(row)
        
        form.sections = [section1, section2]
        
        self.form = form
        
        configureActions()
    }
    
    
    func configureActions() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: "submit:")
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel:")
        
        self.title = "New Note"
    }
    
    
    func submit(sender: UIBarButtonItem) {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("SubIdea",
            inManagedObjectContext:
            managedContext)
        
        
        //creates new password object
        let ideaObject = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        ideaObject.setValue(self.form.formValues().valueForKey("name") as! String, forKey: "name")
        
        ideaObject.setValue(self.form.formValues().valueForKey("summary") as! String, forKey: "summary")
        ideaObject.setValue(false, forKey: "completed")
        ideaObject.setValue(idea, forKey: "idea")
        ideaObject.setValue(self.subideas.count, forKey: "id")
        if(ideas[idea].valueForKey("order") as! String == "") {
            ideas[idea].setValue(String(subideas.count), forKey: "order")
        } else {
            ideas[idea].setValue(ideas[idea].valueForKey("order") as! String + "-" + String(subideas.count), forKey: "order")
        }
        
        var error: NSError?
        do {
            try managedContext.save()
        } catch var error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
        
        self.subideas.insert(ideaObject, atIndex: self.subideas.count)
        
        do {
            try managedContext.save()
        } catch _ {
        }
        
        performSegueWithIdentifier("newToSubIdeas", sender: nil)
    }
    
    func cancel(sender: UIBarButtonItem) {
        performSegueWithIdentifier("newToSubIdeas", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "newToSubIdeas") {
            let controller = segue.destinationViewController as! SubIdeasViewController
            controller.idea = idea
            controller.ideaVC = 4
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
