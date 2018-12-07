//
//  myEventsTableViewController.swift
//  myStatus365
//
//  Created by Chris Tham on 6/12/18.
//  Copyright © 2018 Transport for NSW. All rights reserved.
//

import UIKit

class myEventsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        sharedGraphController?.getEvents(with: { (result) in
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
            return 1
        default:
            return (sharedGraphController?.myEvents.count)!
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "my Leave"
        case 1:
            return "my Calendar"
        default:
            return "unknown section"
        }
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        let isodf = ISO8601DateFormatter()
        isodf.formatOptions = .withInternetDateTime

        // Configure the cell...
        switch indexPath.section {
        case 0:
            cell.imageView?.image = #imageLiteral(resourceName: "Leave")
            cell.textLabel?.text = "Christmas closedown"
            cell.detailTextLabel?.text = "24/12/2018-4/1/2019"
        case 1:
            cell.imageView?.image = #imageLiteral(resourceName: "Meeting")
            let event = sharedGraphController?.myEvents[indexPath.row]
            if let subject = event?.subject {
                cell.textLabel?.text = subject
            }
            if let location = event?.location.displayName {
                cell.detailTextLabel?.text = location
            }
            if let start = event?.start.dateTime {
                if let date = isodf.date(from: start) {
                    cell.detailTextLabel?.text = (cell.detailTextLabel?.text ?? "no location") + " (\(df.string(from: date)))"
                }
                else {
                    cell.detailTextLabel?.text = (cell.detailTextLabel?.text ?? "no location") + " (\(start))"

                }
            }
        default:
            print("Unknown section")
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
