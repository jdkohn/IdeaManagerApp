//
//  EditIdeaVC.swift
//  FileCabinet
//
//  Created by Jacob Kohn on 1/10/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import SwiftForms
import CoreData

class EditIdeaVC: FormViewController {
    
    var ideas = [NSManagedObject]()
    var idea = Int()
    
    override func viewDidLoad() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName:"Idea")
        let error: NSError?
        var fetchedResults = [NSManagedObject]()
        do {
            fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        ideas = fetchedResults
        
        let form = FormDescriptor()
        
        form.title = "Edit Idea"
        
        // Define first section
        let section1 = FormSectionDescriptor()
        
        var row: FormRowDescriptor! = FormRowDescriptor(tag: "name", rowType: .Name, title: "Title")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "e.g. Twitter", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        row.value = ideas[idea].valueForKey("name") as! String
        section1.addRow(row)
        
        let section2 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: "summary", rowType: .MultilineText, title: "Summary")
        row.value = ideas[idea].valueForKey("summary") as! String
        section2.addRow(row)
        
        form.sections = [section1, section2]
        
        self.form = form
        
        configureActions()
    }
    
    
    func configureActions() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: "submit:")
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel:")
        
        self.title = "Edit Idea"
    }
    
    
    func submit(sender: UIBarButtonItem) {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Idea",
            inManagedObjectContext:
            managedContext)
        
        
        ideas[idea].setValue(self.form.formValues().valueForKey("name") as! String, forKey: "name")
        
        ideas[idea].setValue(self.form.formValues().valueForKey("summary") as! String, forKey: "summary")
        
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
        
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
    }
    
    func cancel(sender: UIBarButtonItem) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "doneEditingIdea") {
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