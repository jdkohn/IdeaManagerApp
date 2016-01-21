//
//  StepViewController.swift
//  
//
//  Created by Jacob Kohn on 1/13/16.
//
//

import Foundation
import UIKit
import CoreData

class StepViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var toggle: UISegmentedControl!
    
    var order = [Int]()
    var subideas = [NSManagedObject]()
    var ideas = [NSManagedObject]()
    var subidea = Int()
    var idea = Int()
    
    var justEdited = Bool()
    
    var all = [NSManagedObject]()
    var toDo = [NSManagedObject]()
    
    var toDoSide = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ideas = populateCoreDataArray("Idea")
        subideas = populateCoreDataArray("SubIdea")
        order = getOrder(ideas[idea].valueForKey("order") as! String)
        toggle.selectedSegmentIndex = 0
        toDoSide = true
        sortSubIdeas()
        table.delegate = self
        table.dataSource = self
        
        configureActions()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureActions() {
        self.title = ideas[idea].valueForKey("name") as! String
        self.summaryLabel.text = ideas[idea].valueForKey("summary") as! String
        toggle.addTarget(self, action: "changeSide:", forControlEvents: .ValueChanged)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton.png"), style: .Plain, target: self,action: "back:")
    }
    
    func back(sender: UIBarButtonItem) {
        ideas[idea].setValue(setIdeaOrder(order), forKey: "order")
        
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
        
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true);
    }
    
    
    func changeSide(sender: UISegmentedControl) {
        if(toggle.selectedSegmentIndex == 0) {
            toDoSide = true
        } else {
            toDoSide = false
        }
        table.reloadData()
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(toDoSide) {
            return toDo.count
        } else {
            return all.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stepCell", forIndexPath: indexPath) as! StepCell
        
        let purple = UIColor(red: 0.23137, green: 0.0, blue: 0.79215, alpha: 1.0)
        
        let upImage = UIImage(named: "upArrow.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let downImage = UIImage(named: "downArrow.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        if(indexPath.row != 0) {
            cell.up.tag = indexPath.row
            cell.up.addTarget(self, action: "up:", forControlEvents: .TouchUpInside)
            cell.up.tintColor = purple
            cell.up.setImage(upImage, forState: .Normal)
        }
        
        if(toDoSide && indexPath.row != toDo.count - 1) {
            cell.down.tag = indexPath.row
            cell.down.addTarget(self, action: "down:", forControlEvents: .TouchUpInside)
            cell.down.setImage(downImage, forState: .Normal)
            cell.down.tintColor = purple
        } else if(indexPath.row != all.count - 1) {
            cell.down.tag = indexPath.row
            cell.down.addTarget(self, action: "down:", forControlEvents: .TouchUpInside)
            cell.down.setImage(downImage, forState: .Normal)
            cell.down.tintColor = purple
        }
        
        if(toDoSide) {
            cell.nameLabel.text = toDo[indexPath.row].valueForKey("name") as! String
            cell.checkButton.tag = indexPath.row
            cell.checkButton.addTarget(self, action: "complete:", forControlEvents: .TouchUpInside)
            let image = UIImage(named: "purpCicle@1x.png") as UIImage?
            cell.checkButton.setImage(image, forState: .Normal)
        } else {
            cell.nameLabel.text = all[indexPath.row].valueForKey("name") as! String
            cell.checkButton.tag = indexPath.row
            cell.checkButton.addTarget(self, action: "complete:", forControlEvents: .TouchUpInside)
            var image = UIImage()
            if(all[indexPath.row].valueForKey("completed") as! Bool) {
                image = (UIImage(named: "checkCircle@1x.png") as UIImage?)!
            } else {
                image = (UIImage(named: "purpCicle@1x.png") as UIImage?)!
            }
            cell.checkButton.setImage(image, forState: .Normal)
        }
        
        return cell
    }
    
    func complete(sender: UIButton) {
        if(toDoSide) {
            let index = matchSubIdeas(toDo[sender.tag])
            subideas[index].setValue(true, forKey: "completed")
        } else {
            let index = matchSubIdeas(all[sender.tag])
            if(subideas[index].valueForKey("completed") as! Bool) {
                subideas[index].setValue(false, forKey: "completed")
            } else {
                subideas[index].setValue(true, forKey: "completed")
            }
        }
        
        //repopulates completed and inProgress arrays
        sortSubIdeas()
        
        table.reloadData()
        
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
    
    
    /*MARK: Segues*/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "stepsToSubs") {
            let controller = segue.destinationViewController as! SubIdeasViewController
            controller.idea = idea
            if(justEdited) {
                controller.ideaVC = 4
            } else {
                controller.ideaVC = 2
            }
            
            ideas[idea].setValue(setIdeaOrder(order), forKey: "order")
            
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
    }
    
    func up(sender: UIButton) {
        changeOrder(sender.tag, up: true)
    }
    
    func down(sender: UIButton) {
        changeOrder(sender.tag, up: false)
    }
    
    /*MARK: Convenience Methods*/
    
    //takes "SubIdea" as paramater and returns index in subideas array
    func matchSubIdeas(subidea: NSManagedObject) -> Int {
        for(var i=0; i<subideas.count; i++) {
            if(subidea == subideas[i]) {
                return i
            }
        }
        return -1
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
    
    func sortSubIdeas() {
        toDo = [NSManagedObject]()
        all = [NSManagedObject]()
        var temp = [NSManagedObject]()
        
        for(var i=0; i<subideas.count; i++) {
            if(subideas[i].valueForKey("idea") as! Int == idea) {
                temp.append(subideas[i])
            }
        }
        subideas = temp
        
        
        /////// ORDER LISTS ////////
        
        for(var i=0; i<order.count; i++) {
            for(var l=0; l<subideas.count; l++) {
                if(subideas[l].valueForKey("id") as! Int == order[i]) {
                    if(subideas[l].valueForKey("completed") as! Bool == false) {
                        toDo.append(subideas[l])
                        all.append(subideas[l])
                    } else {
                        all.append(subideas[l])
                    }
                }
            }
        }
        table.reloadData()
    }
    
    func getOrder(str: String) -> [Int] {
        let arr = str.characters.split("-").map(String.init)
        var temp = [Int]()
        for(var i=0; i<arr.count; i++) {
            var t = arr[i]
            temp.append(Int(t)!)
        }
        return temp
    }
    
    func setIdeaOrder(arr: [Int]) -> String {
        var str = ""
        for(var i=0; i<order.count; i++) {
            if(i==0) {
                str = String(order[i])
            } else {
                str = str + "-" + String(order[i])
            }
        }
        return str
    }
    
    func changeOrder(elementIndex: Int, up: Bool) {
        let element = order[elementIndex]
        
        var first = [Int]()
        var second = [Int]()
        
        if(up) {
            
            //if moving up
            
            if(elementIndex == 1) {
                for(var l=elementIndex-1; l<order.count; l++) {
                    if(l != elementIndex) {
                        second.append(order[l])
                    }
                }
            } else {
            
                for(var i=0; i<=elementIndex - 2; i++) {
                    first.append(order[i])
                }
                for(var l=elementIndex-1; l<order.count; l++) {
                    if(l != elementIndex) {
                        second.append(order[l])
                    }
                }
                
            }
        } else {
            
            //if moving down
            
            if(elementIndex == order.count - 2) {
                for(var i=0; i<order.count; i++) {
                    if(i != elementIndex) {
                        first.append(order[i])
                    }
                }
            } else {
            
                
                for(var i=0; i<=elementIndex + 1; i++) {
                    if(i != elementIndex) {
                        first.append(order[i])
                    }
                }
                for(var l=elementIndex + 2; l<order.count; l++) {
                    second.append(order[l])
                }
            }
        }
        
        //reconstruct order
        var temp = [Int]()
        for(var q=0; q<first.count; q++) {
            temp.append(first[q])
        }
        temp.append(element)
        for(var p=0; p<second.count; p++) {
            temp.append(second[p])
        }
        
        order = [Int]()
        order = temp
        
        sortSubIdeas()
        table.reloadData()
    }
    
    func printIntArray(arr: [Int]) {
        for(var i=0; i<arr.count; i++) {
            print(arr[i])
        }
    }
}
