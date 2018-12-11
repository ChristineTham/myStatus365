//
//  myTeamTableViewController.swift
//  myStatus365
//
//  Created by Chris Tham on 5/12/18.
//  Copyright © 2018 Transport for NSW. All rights reserved.
//

import UIKit

class myTeamTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        sharedGraphController?.getManager(with: { (result) in
            switch result
            {
            case .Success(let displayText):
                print(displayText!)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            default:
                print("Error")
            }
        })
        sharedGraphController?.getDirects(with: { (result) in
            switch result
            {
            case .Success(let displayText):
                print(displayText!)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            default:
                print("Error")
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if (sharedGraphController?.myManager == nil) {
                return 0
            }
            else {
                return 1
            }
        case 1:
            return (sharedGraphController?.myReports.count)!
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "my Manager"
        case 1:
            return "my Team"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCell", for: indexPath)

        // Configure the cell...
        switch indexPath.section {
        case 0:
            if (sharedGraphController?.myManager == nil) {
                cell.textLabel?.text = "n/a"
                return cell
            }
            
            if let displayName = sharedGraphController?.myManager!.dictionaryFromItem()!["displayName"]! as? String {
                cell.textLabel?.text = displayName
            }
        case 1:
            let person = sharedGraphController?.myReports[indexPath.row]
            if let displayName = person!.dictionaryFromItem()!["displayName"]! as? String {
                cell.textLabel?.text = displayName
            }
        default:
            cell.textLabel?.text = "n/a"
            cell.detailTextLabel?.text = ""
        }
        
        let status = StatusType.random()
        cell.detailTextLabel?.backgroundColor = status.getBackgroundColor()
        cell.detailTextLabel?.textColor = status.getForegroundColor()
        cell.detailTextLabel?.text = status.getLabel()
        cell.imageView?.image = status.getImage()

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

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedPerson = sharedGraphController?.myReports.remove(at: fromIndexPath.row)
        sharedGraphController?.myReports.insert(movedPerson!, at: to.row)
        tableView.reloadData()
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        guard let destination = segue.destination as? personStatusViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectedPersonCell = sender as? UITableViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedPersonCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        switch indexPath.section {
        case 0:
            destination.person = sharedGraphController?.myManager
        case 1:
            destination.person = sharedGraphController?.myReports[indexPath.row]
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
}
