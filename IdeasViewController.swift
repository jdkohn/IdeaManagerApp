//
//  IdeasViewController.swift
//  FileCabinet
//
//  Created by Jacob Kohn on 1/5/16.
//  Copyright © 2016 Jacob Kohn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class IdeasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UINavigationControllerDelegate {
    
    var bundle = NSBundle.mainBundle()
    
    //outlets
    @IBOutlet weak var toggle: UISegmentedControl!
    @IBOutlet weak var ideasTable: UITableView!
    
    let searchButton = UIButton()
    let settingsButton = UIButton()
    
    //arrays
    var ideas = [NSManagedObject]()
    var completed = [NSManagedObject]()
    var inProgress = [NSManagedObject]()
    
    //conditionals
    var inProgressSide = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        
        addButtons()
        
        inProgressSide = true
        configureActions()
        
        //get ideas
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
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
        
        //separate ideas into completed or in progress
        
//        for(var i=0; i<ideas.count; i++) {
//            if(ideas[i].valueForKey("completed") as! Bool == true) {
//                completed.append(ideas[i])
//            } else {
//                inProgress.append(ideas[i])
//            }
//        }
//        
        ideasTable.dataSource = self
        
        ideasTable.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //separate ideas into completed or in progress
        
        inProgress = [NSManagedObject]()
        completed = [NSManagedObject]()
        
        for(var i=0; i<ideas.count; i++) {
            if(ideas[i].valueForKey("completed") as! Bool == true) {
                completed.append(ideas[i])
            } else {
                inProgress.append(ideas[i])
            }
        }
        
        ideasTable.reloadData()
    }
    
    func addButtons() {
        let purple = UIColor(red: 0.23137, green: 0.0, blue: 0.79215, alpha: 1.0)
        
        let search = UIImage(named:"search@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let settings = UIImage(named: "settings@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        searchButton.frame = CGRectMake(self.view.frame.size.width / 2 - 60, self.view.frame.size.height - 53, 45, 45)
        searchButton.addTarget(self, action: "search:", forControlEvents: .TouchUpInside)
        searchButton.setImage(search, forState: .Normal)
        searchButton.imageView!.image? = (searchButton.imageView!.image?.imageWithRenderingMode(.AlwaysTemplate))!
        searchButton.tintColor = purple
        self.view.addSubview(searchButton)
        
        settingsButton.frame = CGRectMake(self.view.frame.size.width / 2 + 15, self.view.frame.size.height - 53, 45, 45)
        settingsButton.addTarget(self, action: "settings:", forControlEvents: .TouchUpInside)
        settingsButton.setImage(settings, forState: .Normal)
        settingsButton.setImage(settings, forState: .Normal)
        settingsButton.tintColor = purple
        self.view.addSubview(settingsButton)
        
    }
    
    func search(sender: UIButton) {
        print("search")
    }
    
    func settings(sender: UIButton) {
        print("settings")
    }
    
    func configureNavBar() {
        let purple = UIColor(red: 0.23137, green: 0.0, blue: 0.79215, alpha: 1.0)
        
        self.navigationController?.navigationBar.barTintColor = purple
        self.navigationController?.navigationBar.topItem!.title = "My Ideas"
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newIdea:")
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as! [String : AnyObject]
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func newIdea(sender: UIBarButtonItem) {
        performSegueWithIdentifier("addNewIdea", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureActions() {
        toggle.addTarget(self, action: "changeSide:", forControlEvents: .ValueChanged)
    }
    
    func changeSide(sender: UISegmentedControl) {
        print(toggle.selectedSegmentIndex)
        if(toggle.selectedSegmentIndex == 0) {
            inProgressSide = true
        } else {
            inProgressSide = false
        }
        ideasTable.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ideaCell", forIndexPath: indexPath) as! IdeaCell
        
        if(inProgressSide) {
            cell.nameLabel.text = inProgress[indexPath.row].valueForKey("name") as! String
            cell.summaryLabel.text = inProgress[indexPath.row].valueForKey("summary") as! String
            cell.checkedButton.tag = indexPath.row
            cell.checkedButton.addTarget(self, action: "complete:", forControlEvents: .TouchUpInside)
            let image = UIImage(named: "purpCicle@1x.png") as UIImage?
            cell.checkedButton.setImage(image, forState: .Normal)
            
        } else {
            cell.nameLabel.text = completed[indexPath.row].valueForKey("name") as! String
            cell.summaryLabel.text = completed[indexPath.row].valueForKey("summary") as! String
            cell.checkedButton.tag = indexPath.row
            cell.checkedButton.addTarget(self, action: "complete:", forControlEvents: .TouchUpInside)
            let image = UIImage(named: "checkCircle@1x.png") as UIImage?
            cell.checkedButton.setImage(image, forState: .Normal)
        }
        return cell
    }
    
    //set completed/not completed methods
    
    func complete(sender: UIButton) {
        
        if(inProgressSide) {
            let index = matchIdeas(inProgress[sender.tag])
            ideas[index].setValue(true, forKey: "completed")
        } else {
            let index = matchIdeas(completed[sender.tag])
            ideas[index].setValue(false, forKey: "completed")
        }
        
        //repopulates completed and inProgress arrays
        completed = [NSManagedObject]()
        inProgress = [NSManagedObject]()
        
        for(var i=0; i<ideas.count; i++) {
            print(ideas[i].valueForKey("id") as! Int)
            if(ideas[i].valueForKey("completed") as! Bool == true) {
                completed.append(ideas[i])
            } else {
                inProgress.append(ideas[i])
            }
        }
        
        ideasTable.reloadData()
        
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
        for(var i=0; i<ideas.count; i++) {
            if(idea == ideas[i]) {
                return i
            }
        }
        return -1
    }
    
    //segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showIdeaDetails") {
            if let indexPath = self.ideasTable.indexPathForSelectedRow {
                let controller = segue.destinationViewController as! SubIdeasViewController
                if(inProgressSide) {
                    controller.idea = matchIdeas(inProgress[indexPath.row])
                } else {
                    controller.idea = matchIdeas(completed[indexPath.row])
                }
                controller.ideaVC = 2
            }
        }
    }
    
    
    //test methods
    
    func printIdea(idea: NSManagedObject) {
        print(idea.valueForKey("name") as! String)
        print(idea.valueForKey("summary") as! String)
    }
    
    
}
