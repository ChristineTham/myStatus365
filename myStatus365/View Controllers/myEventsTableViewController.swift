//
//  myEventsTableViewController.swift
//  myStatus365
//
//  Created by Chris Tham on 6/12/18.
//  Copyright © 2018 Transport for NSW. All rights reserved.
//

import UIKit

class myEventsTableViewController: UITableViewController {
    let sapLeave = SAPLeaveController()
    let sapuser = "ESSTEST14"
    var leaveRequests = [LeaveRequest]()

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        refreshData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return leaveRequests.count
        default:
            return (sharedGraphController?.myEvents.count)!
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "my Leave Requests"
        case 1:
            return "my Calendar"
        default:
            return "unknown section"
        }
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_AU")
        let isodf = ISO8601DateFormatter()
        isodf.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Configure the cell...
        switch indexPath.section {
        case 0:
            let leaveRequest = leaveRequests[indexPath.row]
            df.dateStyle = .short
            df.timeStyle = .none
            cell.imageView?.image = #imageLiteral(resourceName: "Leave")
            cell.textLabel?.text = leaveRequest.SubtypeDescription
            if let beginDate = Date(jsonDate: leaveRequest.Begda),
                let endDate = Date(jsonDate: leaveRequest.Endda) {
                cell.detailTextLabel?.text = leaveRequest.StatusText + " (" + df.string(from: beginDate) + "-" + df.string(from: endDate) + ")"
            }
        case 1:
            df.dateStyle = .short
            df.timeStyle = .short
//            df.timeZone = TimeZone(identifier: "Australia/Sydney")
            cell.imageView?.image = #imageLiteral(resourceName: "Meeting")
            let event = sharedGraphController?.myEvents[indexPath.row]
            if let subject = event?.subject {
                cell.textLabel?.text = subject
            }
            if let location = event?.location.displayName {
                cell.detailTextLabel?.text = location
            }
            if (event?.isAllDay)! {
                df.timeStyle = .none
                df.timeZone = TimeZone(identifier: "GMT")
            }
            if let isoStartDate = event?.start.dateTime,
                let startTimeZone = event?.start.timeZone,
                let isoEndDate = event?.end.dateTime,
                let endTimeZone = event?.end.timeZone,
                let startDate = isodf.date(from: isoStartDate + startTimeZone),
                let endDate = isodf.date(from: isoEndDate + endTimeZone) {
                    cell.detailTextLabel?.text = (cell.detailTextLabel?.text ?? "no location") + " (\(df.string(from: startDate))-\(df.string(from: endDate)))"
            }
            else {
                cell.detailTextLabel?.text = (cell.detailTextLabel?.text ?? "no location")
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func unwindToMyEvents(segue: UIStoryboardSegue) {
        
    }

    //MARK: - Actions
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func requestLeaveButtonPressed(_ sender: UIBarButtonItem) {
        refreshData()
    }
    
    //MARK - Private Functions
    func refreshData() {
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
        
        let _ = sapLeave.getLeaveRequestList(sapuser) { data, response, error in
            guard let data = data, error == nil else {
                print("\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {
                // check status code returned by the http server
                print("status code = \(httpStatus.statusCode)")
                // process result
                if (httpStatus.statusCode == 200) {
                    let jsonDecoder = JSONDecoder()
                    if let leaveRequestList = try? jsonDecoder.decode(LeaveRequestList.self, from: data) {
                        self.leaveRequests = leaveRequestList.d.results
                    }
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
}