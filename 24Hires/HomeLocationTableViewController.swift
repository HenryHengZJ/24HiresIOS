//
//  HomeLocationTableViewController.swift
//  JobIn24
//
//  Created by MacUser on 06/12/2017.
//  Copyright © 2017 Jonin24 Official Team. All rights reserved.
//

import UIKit

class HomeLocationTableViewController: UITableViewController {
    
    var fromviewcontroller = ""
    
    @IBOutlet var stateTableView: UITableView!
    
    var location = [
        "Johor Bahru",
        "Kedah",
        "Kelantan",
        "Kuala Lumpur",
        "Melaka",
        "Negeri Sembilan",
        "Pahang",
        "Penang",
        "Perak",
        "Perlis",
        "Sabah",
        "Sarawak",
        "Selangor",
        "Terrenganu"
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select Location"
//        tableView.register(StateTableViewCell.self, forCellReuseIdentifier: "stateTableViewCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return location.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let locationDict: [String: String] = ["location": location[indexPath.row ]]
        
        if (fromviewcontroller == "Home") {
            NotificationCenter.default.post(name: Notification.Name("updateHomeLocation"), object: nil, userInfo: locationDict)
            
            self.navigationController?.popViewController(animated: true)
        }else{
            NotificationCenter.default.post(name: Notification.Name(rawValue: AppConstant.notification_selectLocationToSearchMenu ), object: locationDict)
            
            self.navigationController?.popViewController(animated: true)
        }
        

//        if (fromviewcontroller == "2") {
//            NotificationCenter.default.post(name: Notification.Name("updateProfileLocation"), object: nil, userInfo: locationDict)
//
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "stateTableViewCell", for: indexPath)as? StateTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TableViewCell.")
        }
       
        let selectedLocation = location[indexPath.row]
        if selectedLocation.isEmpty{
            cell.stateLabel.text = "Select Your Location"
        }else{
            cell.stateLabel.text = selectedLocation
        }
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
