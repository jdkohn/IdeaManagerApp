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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ideas = populateCoreDataArray("Idea")
        subideas = populateCoreDataArray("SubIdea")
        
        print(subidea)
        
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
            
            cameraButton.frame = CGRectMake(self.view.frame.size.width / 2 + 45, self.view.frame.size.height - 53, 45, 45)
            cameraButton.addTarget(self, action: "camera:", forControlEvents: .TouchUpInside)
            cameraButton.setImage(camera, forState: .Normal)
            cameraButton.tintColor = purple
            self.view.addSubview(cameraButton)
        
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
    
    func back(sender: UIBarButtonItem) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - subVC], animated: true);
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