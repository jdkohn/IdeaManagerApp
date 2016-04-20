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

class IdeasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UINavigationControllerDelegate, UISearchBarDelegate, UIPopoverPresentationControllerDelegate {
    
    var bundle = NSBundle.mainBundle()
    
    //outlets
    @IBOutlet weak var toggle: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var ideasTable: UITableView!
    
    let searchButton = UIButton()
    let settingsButton = UIButton()
    
    //arrays
    var ideas = [NSManagedObject]()
    var completed = [NSManagedObject]()
    var inProgress = [NSManagedObject]()
    var subideas = [NSManagedObject]()
    var categories = [NSManagedObject]()
    
    //dictionaries
    var ipDict = [[NSManagedObject]]()
    var doneDict = [[NSManagedObject]]()
    
    
    //conditionals
    var inProgressSide = Bool()
    
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
        filtered = ideas.filter({ (text) -> Bool in
            let tmp: NSString = text.valueForKey("name") as! NSString
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.ideasTable.reloadData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        
        addButtons()
        
        inProgressSide = true
        configureActions()
        
        ideas = populateCoreDataArray("Idea")
        
        searchBar.delegate = self

        
        ideasTable.dataSource = self
        
        
        print("LOAD")
        
        ideasTable.reloadData()
    }
    
    func sortIntoSections() {
        
        ipDict = [[NSManagedObject]]()
        
        for(var l=0; l<categories.count; l++) {
            var temp = [NSManagedObject]()
            for(var i=0; i<inProgress.count; i++) {
                print("!")
                if let category = (inProgress[i].valueForKey("category") as? String) {
                    if(category == (categories[l].valueForKey("name") as! String)) {
                        temp.append(inProgress[i])
                        print("!!")
                    }
                }
            }
            ipDict.append(temp)
        }
        
        
        doneDict = [[NSManagedObject]]()
        
        for(var l=0; l<categories.count; l++) {
            var temp = [NSManagedObject]()
            for(var i=0; i<completed.count; i++) {
                if let category = completed[i].valueForKey("category") as? String {
                    if(category == (categories[l].valueForKey("name") as! String)) {
                        temp.append(completed[i])
                    }
                }
            }
            doneDict.append(temp)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("WillAppear")
        
        //separate ideas into completed or in progress
        
        searchActive = false
        
        ideas = populateCoreDataArray("Idea")
        categories = populateCoreDataArray("Category")
        
        inProgress = [NSManagedObject]()
        completed = [NSManagedObject]()
        
        for(var i=0; i<ideas.count; i++) {
            if(ideas[i].valueForKey("completed") as! Bool == true) {
                completed.append(ideas[i])
            } else {
                inProgress.append(ideas[i])
            }
        }
        
        sortIntoSections()
        
        ideasTable.reloadData()
        
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
        settingsButton.tintColor = purple
        self.view.addSubview(settingsButton)
        
    }
    
    func search(sender: UIButton) {
        let search = UIImage(named:"search@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let searching = UIImage(named:"search@1x.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        if(searchBar.hidden) {
            searchActive = true
            searchBar.hidden = false
            searchButton.setImage(searching, forState: .Normal)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "doneSearching:")
            filtered = ideas
            ideasTable.reloadData()
        } else {
            searchActive = false
            searchBar.hidden = true
            searchButton.setImage(search, forState: .Normal)
            //inProgressSide = true
            self.navigationItem.leftBarButtonItem = nil
            ideasTable.reloadData()
        }
    }
    
    func doneSearching(sender: UIBarButtonItem) {
        searchActive = false
        searchBar.hidden = true
        self.view.endEditing(true)
        self.navigationItem.leftBarButtonItem = nil
        ideasTable.reloadData()
    }
    
    func settings(sender: UIButton) {
        self.performSegueWithIdentifier("editCategories", sender: nil)
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
        if(toggle.selectedSegmentIndex == 0) {
            inProgressSide = true
        } else {
            inProgressSide = false
        }
        ideasTable.reloadData()
    }
    
    
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        if(inProgressSide) {
            print("IP#: " + String(ipDict[section].count))
            return ipDict[section].count
        } else {
            print("DONE#: " + String(ipDict[section].count))
            return doneDict[section].count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ideaCell", forIndexPath: indexPath) as! IdeaCell
        if(searchActive) {
            cell.nameLabel.text = (filtered[indexPath.row].valueForKey("name") as! String)
            cell.summaryLabel.text = (filtered[indexPath.row].valueForKey("summary") as! String)
            cell.checkedButton.tag = indexPath.row
            cell.checkedButton.addTarget(self, action: "complete:", forControlEvents: .TouchUpInside)
            var image = UIImage()
            if(filtered[indexPath.row].valueForKey("completed") as! Bool) {
                image = (UIImage(named: "checkCircle@1x.png") as UIImage?)!
            } else {
                image = (UIImage(named: "purpCicle@1x.png") as UIImage?)!
            }
            cell.checkedButton.setImage(image, forState: .Normal)
            return cell
        } else if(inProgressSide) {
            cell.nameLabel.text = (ipDict[indexPath.section][indexPath.row].valueForKey("name") as! String)
            cell.summaryLabel.text = (ipDict[indexPath.section][indexPath.row].valueForKey("summary") as! String)
            cell.checkedButton.tag = (ipDict[indexPath.section][indexPath.row].valueForKey("id") as! Int)
            cell.checkedButton.addTarget(self, action: "complete:", forControlEvents: .TouchUpInside)
            let image = UIImage(named: "purpCicle@1x.png") as UIImage?
            cell.checkedButton.setImage(image, forState: .Normal)
            
        } else {
            cell.nameLabel.text = (doneDict[indexPath.section][indexPath.row].valueForKey("name") as! String)
            cell.summaryLabel.text = (doneDict[indexPath.section][indexPath.row].valueForKey("summary") as! String)
            cell.checkedButton.tag = (doneDict[indexPath.section][indexPath.row].valueForKey("id") as! Int)
            cell.checkedButton.addTarget(self, action: "complete:", forControlEvents: .TouchUpInside)
            let image = UIImage(named: "checkCircle@1x.png") as UIImage?
            cell.checkedButton.setImage(image, forState: .Normal)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(searchActive) {
            return "Results:"
        }
        return (self.categories[section].valueForKey("name") as! String)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(searchActive) {
            return 1
        }
        
        return self.categories.count
    }
    
    func matchID(id: Int) -> Int {
        for(var i=0; i<ideas.count; i++) {
            if(id == (ideas[i].valueForKey("id") as! Int)) {
                return i
            }
        }
        return -1
    }
    
    //set completed/not completed methods
    
    func complete(sender: UIButton) {
        
        if(searchActive) {
            let index = matchIdeas(filtered[sender.tag])
            if(ideas[index].valueForKey("completed") as! Bool) {
                ideas[index].setValue(true, forKey: "completed")
                filtered[sender.tag].setValue(false, forKey: "completed")
            } else {
                ideas[index].setValue(false, forKey: "completed")
                filtered[sender.tag].setValue(true, forKey: "completed")
            }
        } else if(inProgressSide) {
            let index = matchID(sender.tag)
            ideas[index].setValue(true, forKey: "completed")
        } else {
            let index = matchID(sender.tag)
            ideas[index].setValue(false, forKey: "completed")
        }
        
        //repopulates completed and inProgress arrays
        completed = [NSManagedObject]()
        inProgress = [NSManagedObject]()
        
        for(var i=0; i<ideas.count; i++) {
            if(ideas[i].valueForKey("completed") as! Bool == true) {
                completed.append(ideas[i])
            } else {
                inProgress.append(ideas[i])
            }
        }
        
        sortIntoSections()
        
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    //segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showIdeaDetails") {
            if let indexPath = self.ideasTable.indexPathForSelectedRow {
                let controller = segue.destinationViewController as! SubIdeasViewController
                if(searchActive) {
                    controller.idea = matchIdeas(filtered[indexPath.row])
                    
                    searchActive = false
                    searchBar.hidden = true
                    inProgressSide = true
                    searchBar.text = ""
                    toggle.selectedSegmentIndex = 0
                    //hide cancel button
                    
                } else if(inProgressSide) {
                    controller.idea = matchID(ipDict[indexPath.section][indexPath.row].valueForKey("id") as! Int)
                } else {
                    controller.idea = matchID(doneDict[indexPath.section][indexPath.row].valueForKey("id") as! Int)
                }
                controller.ideaVC = 2
            }
        }
        if(segue.identifier == "editCategories") {
            let popoverViewController = segue.destinationViewController as! SettingsViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }
}
