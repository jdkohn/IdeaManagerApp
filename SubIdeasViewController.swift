//
//  SubIdeasViewController.swift
//  FileCabinet
//
//  Created by Jacob Kohn on 1/6/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SubIdeasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var subIdeasTable: UITableView!
    @IBOutlet weak var toggle: UISegmentedControl!
    @IBOutlet weak var summaryLabel: UILabel!
    
    let checkButton = UIButton()
    let editButton = UIButton()
    let stepsButton = UIButton()
    
    var idea = Int()
    
    var ideaVC = Int()
    
    var ideas = [NSManagedObject]()
    var subideas = [NSManagedObject]()
    var inProgress = [NSManagedObject]()
    var completed = [NSManagedObject]()
    
    var inProgressSide = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ideas = populateCoreDataArray("Idea")
        subideas = populateCoreDataArray("SubIdea")
        sortSubIdeas()
        configureActions()
        
        addButtons()
        
        inProgressSide = true
        
        subIdeasTable.dataSource = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sortSubIdeas()
    }
    
    func newSubIdea(sender: UIBarButtonItem) {
        performSegueWithIdentifier("newSubIdea", sender: nil)
    }
    
    func editIdea(sender: UIButton) {
        print("edit")
    }
    
    func addButtons() {
        let purple = UIColor(red: 0.23137, green: 0.0, blue: 0.79215, alpha: 1.0)
        
        var check = UIImage()
        if(ideas[idea].valueForKey("completed") as! Bool) {
            check = (UIImage(named:"checkCircle@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        } else {
            check = (UIImage(named:"purpCicle@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
        }
        let edit = UIImage(named: "edit@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let steps = UIImage(named: "steps@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
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
        
        stepsButton.frame = CGRectMake(self.view.frame.size.width / 2 + 45, self.view.frame.size.height - 53, 45, 45)
        stepsButton.addTarget(self, action: "steps:", forControlEvents: .TouchUpInside)
        stepsButton.setImage(steps, forState: .Normal)
        stepsButton.tintColor = purple
        self.view.addSubview(stepsButton)
    }
    
    func check(sender: UIButton) {
        var check = UIImage()
        if(ideas[idea].valueForKey("completed") as! Bool) {
            check = (UIImage(named:"purpCicle@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
            ideas[idea].setValue(false, forKey: "completed")
        } else {
            check = (UIImage(named:"checkCircle@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))!
            ideas[idea].setValue(true, forKey: "completed")
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
    
    func edit(sender: UIButton) {
        performSegueWithIdentifier("editIdea", sender: nil)
    }
    
    func steps(sender: UIButton) {
        print("steps")
    }
    
    func configureActions() {
        print(ideas[idea].valueForKey("name") as! String)
        
        self.title = ideas[idea].valueForKey("name") as! String

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "home.png"), style: .Plain, target: self,action: "home:")
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newSubIdea:")
        
        summaryLabel.text = ideas[idea].valueForKey("summary") as! String
        
        toggle.addTarget(self, action: "changeSide:", forControlEvents: .ValueChanged)
    }
    
    func home(sender: UIBarButtonItem) {
        //performSegueWithIdentifier("ideaToHome", sender: nil)
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - ideaVC], animated: true);
    }
    
    func changeSide(sender: UISegmentedControl) {
        print(toggle.selectedSegmentIndex)
        if(toggle.selectedSegmentIndex == 0) {
            inProgressSide = true
        } else {
            inProgressSide = false
        }
        subIdeasTable.reloadData()
    }
    
    func sortSubIdeas() {
        completed = [NSManagedObject]()
        inProgress = [NSManagedObject]()
        var temp = [NSManagedObject]()
        
        for(var i=0; i<subideas.count; i++) {
            if(subideas[i].valueForKey("idea") as! Int == idea) {
                if(subideas[i].valueForKey("completed") as! Bool == true) {
                    completed.append(subideas[i])
                } else {
                    inProgress.append(subideas[i])
                }
                temp.append(subideas[i])
            }
        }
        subideas = temp
        
        subIdeasTable.reloadData()
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
    
    
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(inProgressSide) {
            return inProgress.count
        } else {
            return completed.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("subIdeaCell", forIndexPath: indexPath) as! SubIdeaCell
        
        if(inProgressSide) {
            cell.nameLabel.text = inProgress[indexPath.row].valueForKey("name") as! String
            cell.button.tag = indexPath.row
            cell.button.addTarget(self, action: "complete:", forControlEvents: .TouchUpInside)
            let image = UIImage(named: "purpCicle@1x.png") as UIImage?
            cell.button.setImage(image, forState: .Normal)
            
        } else {
            cell.nameLabel.text = completed[indexPath.row].valueForKey("name") as! String
            cell.button.tag = indexPath.row
            cell.button.addTarget(self, action: "complete:", forControlEvents: .TouchUpInside)
            let image = UIImage(named: "checkCircle@1x.png") as UIImage?
            cell.button.setImage(image, forState: .Normal)
        }
        return cell
    }
    
    //set completed/not completed methods
    
    func complete(sender: UIButton) {
        
        if(inProgressSide) {
            let index = matchIdeas(inProgress[sender.tag])
            subideas[index].setValue(true, forKey: "completed")
        } else {
            let index = matchIdeas(completed[sender.tag])
            subideas[index].setValue(false, forKey: "completed")
        }
        
        //repopulates completed and inProgress arrays
        sortSubIdeas()
        
        subIdeasTable.reloadData()
        
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
    }
    
    
    //takes 'Idea' as paramater and returns index in ideas array
    func matchIdeas(idea: NSManagedObject) -> Int {
        var tempSubs = populateCoreDataArray("SubIdea")
        for(var i=0; i<tempSubs.count; i++) {
            if(idea == tempSubs[i]) {
                return i
            }
        }
        return -1
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "newSubIdea") {
            let controller = segue.destinationViewController as! AddSubIdeaViewController
            controller.idea = idea
        }
        if(segue.identifier == "showSubIdeaDetails") {
            if let indexPath = self.subIdeasTable.indexPathForSelectedRow {
                let controller = segue.destinationViewController as! SubIdeaDetailViewController
                controller.subVC = 2
                if(inProgressSide) {
                    controller.subidea = matchIdeas(inProgress[indexPath.row])
                    print(matchIdeas(inProgress[indexPath.row]))
                } else {
                    controller.subidea = matchIdeas(completed[indexPath.row])
                    print(matchIdeas(completed[indexPath.row]))
                }
            }
        }
        if(segue.identifier == "editIdea") {
            let controller = segue.destinationViewController as! EditIdeaVC
            controller.idea = idea
        }
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}