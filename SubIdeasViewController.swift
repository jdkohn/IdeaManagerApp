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

class SubIdeasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var subIdeasTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var toggle: UISegmentedControl!
    @IBOutlet weak var summaryLabel: UILabel!
    
    let checkButton = UIButton()
    let editButton = UIButton()
    let stepsButton = UIButton()
    let searchButton = UIButton()
    let deleteButton = UIButton()
    
    var idea = Int()
    
    var ideaVC = Int()
    
    var ideas = [NSManagedObject]()
    var subideas = [NSManagedObject]()
    var inProgress = [NSManagedObject]()
    var completed = [NSManagedObject]()
    var all = [NSManagedObject]()
    
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
        
        searchBar.delegate = self
    }
    
    func deleteIdea(sender: UIButton) {
        
        let alert = UIAlertController(title: "Delete?", message: "Are you sure you want to delete?", preferredStyle:UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action) -> Void in
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext
            
            for(var i=0; i<self.ideas.count; i++) {
                if((self.ideas[i].valueForKey("id") as! Int) == self.idea) {
                    context.deleteObject(self.ideas[i])
                    self.ideas.removeAtIndex(i)
                    i--
                } else if((self.ideas[i].valueForKey("id") as! Int) > self.idea) {
                    self.ideas[i].setValue((self.ideas[i].valueForKey("id") as! Int) - 1, forKey: "id")
                }
            }
            
            for(var l=0; l<self.subideas.count; l++) {
                if((self.subideas[l].valueForKey("idea") as! Int) == self.idea) {
                    
                    
                    context.deleteObject(self.subideas[l])
                    self.subideas.removeAtIndex(l)
                    
                    l--
                } else {
                    if((self.subideas[l].valueForKey("idea") as! Int) > self.idea) {
                        self.subideas[l].setValue((self.subideas[l].valueForKey("idea") as! Int) - 1, forKey: "idea")
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
    
    
    
    var searchActive : Bool = false
    var filtered:[NSManagedObject] = []
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = all.filter({ (text) -> Bool in
            let tmp: NSString = text.valueForKey("name") as! NSString
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.subIdeasTable.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subideas = populateCoreDataArray("SubIdea")
        sortSubIdeas()
        
        subIdeasTable.reloadData()
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
        let search = UIImage(named: "search@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let edit = UIImage(named: "edit@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let steps = UIImage(named: "steps@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let trash = UIImage(named: "TrashCan@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        checkButton.frame = CGRectMake(self.view.frame.size.width / 2 - 122.5, self.view.frame.size.height - 53, 45, 45)
        checkButton.addTarget(self, action: "check:", forControlEvents: .TouchUpInside)
        checkButton.setImage(check, forState: .Normal)
        checkButton.tintColor = purple
        self.view.addSubview(checkButton)
        
        searchButton.frame = CGRectMake(self.view.frame.size.width / 2 - 22.5, self.view.frame.size.height - 53, 45, 45)
        searchButton.addTarget(self, action: "search:", forControlEvents: .TouchUpInside)
        searchButton.setImage(search, forState: .Normal)
        searchButton.tintColor = purple
        self.view.addSubview(searchButton)
        
        editButton.frame = CGRectMake(self.view.frame.size.width / 2 - 72.5, self.view.frame.size.height - 53, 45, 45)
        editButton.addTarget(self, action: "edit:", forControlEvents: .TouchUpInside)
        editButton.setImage(edit, forState: .Normal)
        editButton.tintColor = purple
        self.view.addSubview(editButton)
        
        stepsButton.frame = CGRectMake(self.view.frame.size.width / 2 + 32.5, self.view.frame.size.height - 53, 45, 45)
        stepsButton.addTarget(self, action: "steps:", forControlEvents: .TouchUpInside)
        stepsButton.setImage(steps, forState: .Normal)
        stepsButton.tintColor = purple
        self.view.addSubview(stepsButton)
        
        deleteButton.frame = CGRectMake(self.view.frame.size.width / 2 + 82.5, self.view.frame.size.height - 53, 45, 45)
        deleteButton.addTarget(self, action: "deleteIdea:", forControlEvents: .TouchUpInside)
        deleteButton.setImage(trash, forState: .Normal)
        deleteButton.tintColor = purple
        self.view.addSubview(deleteButton)
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
    
    func search(sender: UIButton) {
        if(searchBar.hidden) {
            searchActive = true
            searchBar.hidden = false
            filtered = all
            searchBar.text = ""
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "doneSearching:")
            subIdeasTable.reloadData()
        } else {
            searchActive = false
            searchBar.hidden = true
            //inProgressSide = true
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "home.png"), style: .Plain, target: self,action: "home:")
            subIdeasTable.reloadData()
        }
    }
    
    func doneSearching(sender: UIBarButtonItem) {
        searchActive = false
        searchBar.hidden = true
        self.view.endEditing(true)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "home.png"), style: .Plain, target: self,action: "home:")
        subIdeasTable.reloadData()
    }
    
    func edit(sender: UIButton) {
        performSegueWithIdentifier("editIdea", sender: nil)
    }
    
    func steps(sender: UIButton) {
        performSegueWithIdentifier("viewSteps", sender: nil)
    }
    
    func configureActions() {
        
        self.title = ideas[idea].valueForKey("name") as! String

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "home.png"), style: .Plain, target: self,action: "home:")
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newSubIdea:")
        
        summaryLabel.text = ideas[idea].valueForKey("summary") as! String
        
        toggle.addTarget(self, action: "changeSide:", forControlEvents: .ValueChanged)
    }
    
    func home(sender: UIBarButtonItem) {
        //performSegueWithIdentifier("ideaToHome", sender: nil)
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        
        if(ideaVC == 0) {
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
        } else {
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - ideaVC], animated: true);
        }
    }
    
    func changeSide(sender: UISegmentedControl) {
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
        var temp2 = [NSManagedObject]()
        
        for(var i=0; i<subideas.count; i++) {
            if(subideas[i].valueForKey("idea") as! Int == idea) {
                if(subideas[i].valueForKey("completed") as! Bool == true) {
                    completed.append(subideas[i])
                } else {
                    inProgress.append(subideas[i])
                }
                temp2.append(subideas[i])
            }
            temp.append(subideas[i])
        }
        subideas = temp
        all = temp2
        
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
        if(searchActive) {
            return filtered.count
        }
        if(inProgressSide) {
            return inProgress.count
        } else {
            return completed.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("subIdeaCell", forIndexPath: indexPath) as! SubIdeaCell
        
        
        
        if(searchActive) {
            cell.nameLabel.text = filtered[indexPath.row].valueForKey("name") as! String
            cell.button.tag = indexPath.row
            cell.button.addTarget(self, action: "complete:", forControlEvents: .TouchUpInside)
            var image = UIImage()
            if(filtered[indexPath.row].valueForKey("completed") as! Bool) {
                image = (UIImage(named: "checkCircle@1x.png") as UIImage?)!
            } else {
                image = (UIImage(named: "purpCicle@1x.png") as UIImage?)!
            }
            cell.button.setImage(image, forState: .Normal)
            return cell
        } else if(inProgressSide) {
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
        
        if(searchActive) {
            let index = matchIdeas(filtered[sender.tag])
            if(subideas[index].valueForKey("completed") as! Bool) {
                subideas[index].setValue(true, forKey: "completed")
                filtered[sender.tag].setValue(false, forKey: "completed")
            } else {
                subideas[index].setValue(false, forKey: "completed")
                filtered[sender.tag].setValue(true, forKey: "completed")
            }
        } else if(inProgressSide) {
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
                if(searchActive) {
                    controller.subidea = matchIdeas(filtered[indexPath.row])
                } else if(inProgressSide) {
                    controller.subidea = matchIdeas(inProgress[indexPath.row])
                } else {
                    controller.subidea = matchIdeas(completed[indexPath.row])
                }
            }
        }
        if(segue.identifier == "editIdea") {
            let controller = segue.destinationViewController as! EditIdeaVC
            controller.idea = idea
        }
        if(segue.identifier == "viewSteps") {
            let controller = segue.destinationViewController as! StepViewController
            controller.idea = idea
            if(ideaVC == 4) {
                controller.justEdited = true
            }
            
        }
        
        searchActive = false
        searchBar.hidden = true
        inProgressSide = true
        searchBar.text = ""
        toggle.selectedSegmentIndex = 0
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}