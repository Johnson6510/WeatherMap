//
//  PoiManager.swift
//  WeatherMap
//
//  Created by 黃健偉 on 2017/12/30.
//  Copyright © 2017年 黃健偉. All rights reserved.
//

import UIKit
import CoreData

class PoiManager: UITableViewController {

    var totalEntries: Int = 0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let entityName = "StoredPlace"
    let entity = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredPlace")

    @IBOutlet var tblLog: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let results = try context.fetch(entity)
            totalEntries = results.count
            print ("Total Location in Core Data: \(totalEntries)")
        } catch {
            print("Failed")
        }
        entity.returnsObjectsAsFaults = false
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return totalEntries
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Default")
        
        do {
            cell.textLabel?.text = "..."
            cell.detailTextLabel?.text = "..."
            
            let results = try context.fetch(entity)
            let thisPlace = results[indexPath.row] as! StoredPlace
            if let name = thisPlace.title, let type = thisPlace.poiType {
                cell.textLabel?.text = name + ", " + type
            }
            if let latitude = thisPlace.latitude, let longitude = thisPlace.longitude {
                cell.detailTextLabel?.text = latitude + ", " + longitude
            }
        } catch {
            print("Failed")
        }

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        do {
            let results = try context.fetch(entity)
            context.delete(results[indexPath.row] as! NSManagedObject)
            try context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        totalEntries = totalEntries - 1
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

