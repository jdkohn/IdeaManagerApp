//
//  SubIdeaDetailViewController.swift
//  FileCabinet
//
//  Created by Jacob Kohn on 1/7/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SubIdeaDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    var subidea = Int()
    var idea = Int()
    
    var ideas = [NSManagedObject]()
    var subideas = [NSManagedObject]()
    
    var subVC = Int()
    
    let checkButton = UIButton()
    let editButton = UIButton()
    let cameraButton = UIButton()
    let deleteButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ideas = populateCoreDataArray("Idea")
        subideas = populateCoreDataArray("SubIdea")
        
        idea = subideas[subidea].valueForKey("idea") as! Int
        
        setLabels()
        
        addButtons()
    }
    
    func addButtons() {
            let purple = UIColor(red: 0.23137, green: 0.0, blue: 0.79215, alpha: 1.0)
            
            var check = UIImage()
            if(subideas[subidea].valueForKey("completed") as! Bool) {
                check = (UIImage(named:"checkCircle@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
            } else {
                check = (UIImage(named:"purpCicle@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
            }
            let edit = UIImage(named: "edit@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            let camera = UIImage(named: "camera@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            let trashCan = UIImage(named: "TrashCan@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
            checkButton.frame = CGRectMake(self.view.frame.size.width / 2 - 90, self.view.frame.size.height - 53, 45, 45)
            checkButton.addTarget(self, action: "check:", forControlEvents: .TouchUpInside)
            checkButton.setImage(check, forState: .Normal)
            checkButton.tintColor = purple
            self.view.addSubview(checkButton)
            
            editButton.frame = CGRectMake(self.view.frame.size.width / 2 - 22.5, self.view.frame.size.height - 53, 45, 45)
            editButton.addTarget(self, action: "edit:", forControlEvents: .TouchUpInside)
            editButton.setImage(edit, forState: .Normal)
            editButton.tintColor = purple
            self.view.addSubview(editButton)
            
//            cameraButton.frame = CGRectMake(self.view.frame.size.width / 2 + 45, self.view.frame.size.height - 53, 45, 45)
//            cameraButton.addTarget(self, action: "camera:", forControlEvents: .TouchUpInside)
//            cameraButton.setImage(camera, forState: .Normal)
//            cameraButton.tintColor = purple
//            self.view.addSubview(cameraButton)
      
            deleteButton.frame = CGRectMake(self.view.frame.size.width / 2 + 45, self.view.frame.size.height - 53, 45, 45)
            deleteButton.addTarget(self, action: "deleteSub:", forControlEvents: .TouchUpInside)
            deleteButton.setImage(trashCan, forState: .Normal)
            deleteButton.tintColor = purple
            self.view.addSubview(deleteButton)
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton.png"), style: .Plain, target: self,action: "back:")
        
        
    }
    
    func check(sender: UIButton) {
        var check = UIImage()
        if(subideas[subidea].valueForKey("completed") as! Bool) {
            check = (UIImage(named:"purpCicle@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
            subideas[subidea].setValue(false, forKey: "completed")
        } else {
            check = (UIImage(named:"checkCircle@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
            subideas[subidea].setValue(true, forKey: "completed")
        }
        
        //saves change made
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
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
        
        
        checkButton.setImage(check, forState: .Normal)
    }
    
    func deleteSub(sender: AnyObject?) {
        
        let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete?", preferredStyle:UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action) -> Void in
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext
            
            for(var i=0; i<self.subideas.count; i++) {
                if((self.subideas[i].valueForKey("id") as! Int) == self.subidea) {
                    
                    
                    context.deleteObject(self.subideas[i])
                    self.subideas.removeAtIndex(i)
                    
                    i--
                    do {
                        try context.save()
                    } catch _ {
                    }
                } else {
                    if((self.subideas[i].valueForKey("id") as! Int) > self.subidea) {
                        self.subideas[i].setValue((self.subideas[i].valueForKey("id") as! Int) - 1, forKey: "id")
                    }
                }
            }
            
            var error: NSError?
            do {
                try context.save()
            } catch var error1 as NSError {
                error = error1
                print("Could not save \(error), \(error?.userInfo)")
            }
            
            do {
                try context.save()
            } catch _ {
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    func back(sender: UIBarButtonItem) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
    }
    
    func edit(sender: UIButton) {
        performSegueWithIdentifier("editSubIdea", sender: nil)
    }
    
    func camera(sender: UIButton) {
        print("camera")
    }
    
    func setLabels() {
        nameLabel.text = subideas[subidea].valueForKey("name") as! String
        summaryLabel.text = subideas[subidea].valueForKey("summary") as! String
        self.title = "New Note"
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
    
    //segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "returnToSubIdeas") {
                let controller = segue.destinationViewController as! SubIdeasViewController
                        controller.idea = idea
                controller.ideaVC = 2
        }
        if(segue.identifier == "editSubIdea") {
            let controller = segue.destinationViewController as! EditSubIdeaViewController
            controller.idea = idea
            controller.subidea = subidea
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}