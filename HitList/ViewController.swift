//
//  ViewController.swift
//  HitList
//
//  Created by neal on 2017/9/6.
//  Copyright © 2017年 neal. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var people:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupNavigationTitle()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        self.fetchCoreData(managedContext)
    }

    func setupNavigationTitle() {
        title = "the list"
    }
    
    func fetchCoreData(_ managedContext: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            people = results as! [NSManagedObject]
        } catch let error as NSError {
            print("clould not fetch \(error),\(error.userInfo)")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var addName: UIBarButtonItem!
    
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "save", style: .default) { (action) in
            let textField = alert.textFields!.first
            self.saveName(textField!.text!)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .default) { (action) in
            
        }
        
        alert.addTextField { (textField) in
            
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    

    // MARK: - CoreData func
    
    func saveName(_ name: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)
        
        let person = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        person.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}


extension ViewController: UITableViewDataSource {
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        let person = people[indexPath.row]
        
        cell.textLabel?.text = person.value(forKey: "name") as? String
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            managedContext.delete(people[indexPath.row] as NSManagedObject)
            
            do {
                try managedContext.save()
                people.remove(at: indexPath.row)
            } catch let error as NSError {
                print("cloud not save \(error),\(error.userInfo)")
            }
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            return
        }
    }
}
