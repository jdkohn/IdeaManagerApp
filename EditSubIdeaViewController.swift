//
//  EditSubIdeaViewController.swift
//  FileCabinet
//
//  Created by Jacob Kohn on 1/10/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import SwiftForms
import CoreData

class EditSubIdeaViewController: FormViewController {
    
    var subideas = [NSManagedObject]()
    var subidea = Int()
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
        
        let form = FormDescriptor()
        
        form.title = "Edit SubIdea"
        
        // Define first section
        let section1 = FormSectionDescriptor()
        
        var row: FormRowDescriptor! = FormRowDescriptor(tag: "name", rowType: .Name, title: "Title")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "e.g. Twitter", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        row.value = subideas[subidea].valueForKey("name") as! String
        section1.addRow(row)
        
        let section2 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: "summary", rowType: .MultilineText, title: "Summary")
        row.value = subideas[subidea].valueForKey("summary") as! String
        section2.addRow(row)
        
        form.sections = [section1, section2]
        
        self.form = form
        
        configureActions()
    }
    
    
    func configureActions() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: "submit:")
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel:")
        
        self.title = "Edit Note"
    }
    
    
    func submit(sender: UIBarButtonItem) {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("SubIdea",
            inManagedObjectContext:
            managedContext)
        
        
        subideas[subidea].setValue(self.form.formValues().valueForKey("name") as! String, forKey: "name")
        
        subideas[subidea].setValue(self.form.formValues().valueForKey("summary") as! String, forKey: "summary")
        
        var error: NSError?
        do {
            try managedContext.save()
        } catch var error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
        
        do {
            try managedContext.save()
        } catch _ {
        }
        
        performSegueWithIdentifier("doneEditingSubIdea", sender: nil)
    }
    
    func cancel(sender: UIBarButtonItem) {
        performSegueWithIdentifier("doneEditingSubIdea", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "doneEditingSubIdea") {
            let controller = segue.destinationViewController as! SubIdeaDetailViewController
            controller.idea = idea
            controller.subidea = subidea
            controller.subVC = 4
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
