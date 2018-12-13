//
//  newLeaveRequestTableViewController.swift
//  myStatus365
//
//  Created by Chris Tham on 12/12/18.
//  Copyright © 2018 Transport for NSW. All rights reserved.
//

import UIKit

class newLeaveRequestTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var sap : SAPController?
    var sapuser : String?
    var leaveTypes = [LeaveType]()
    var leaveTypeTextArray = [String]()
    var leaveTypeCodeArray = [String]()
    var leaveCreate : LeaveCreateRecord?
    var CSRFToken : String?
    var isLeaveTypePickerHidden = true
    var isStartDatePickerHidden = true
    var isEndDatePickerHidden = true
    
    //MARK: - Properties
    
    //MARK: - Outlets
    @IBOutlet weak var managerTextField: UITextField!
    @IBOutlet weak var leaveTypePickerView: UIPickerView!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDatePickerView: UIDatePicker!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDatePickerView: UIDatePicker!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        sap?.getLeaveTypeList() { data, response, error in
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
                    if let leaveTypeList = try? jsonDecoder.decode(LeaveTypeList.self, from: data) {
                        self.leaveTypes = leaveTypeList.d.results
                        for leaveType in leaveTypeList.d.results {
                            self.leaveTypeTextArray.append(leaveType.Subtytext)
                            self.leaveTypeCodeArray.append(leaveType.Subty)
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.leaveTypePickerView.dataSource = self
                        self.leaveTypePickerView.delegate = self
                        if let leaveCreate = self.leaveCreate,
                            let row = self.leaveTypeCodeArray.index(where: {$0 == leaveCreate.d.SUBTY}) {
                            self.leaveTypePickerView.selectRow(row, inComponent: 0, animated: false)
                        }
                    })
                }
            }
        }
        
        sap?.prepopulateLeaveRequest(sapuser!) { data, response, error in
            guard let data = data, error == nil else {
                print("\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {
                // check status code returned by the http server
                print("status code = \(httpStatus.statusCode)")
                // process result
                if (httpStatus.statusCode == 200) {
                    self.CSRFToken = httpStatus.allHeaderFields["x-csrf-token"] as? String
                    let jsonDecoder = JSONDecoder()
                    if let leaveCreateRecord = try? jsonDecoder.decode(LeaveCreateRecord.self, from: data) {
                        self.leaveCreate = leaveCreateRecord
                    }
                    DispatchQueue.main.async(execute: {
                        self.managerTextField.text = self.leaveCreate?.d.MANAGER
                        if let row = self.leaveTypeCodeArray.index(where: {$0 == self.leaveCreate?.d.SUBTY}) {
                            self.leaveTypePickerView.selectRow(row, inComponent: 0, animated: false)
                        }
                        let df = DateFormatter()
                        df.dateFormat = "yyyyMMdd"
                        let startDate = df.date(from: (self.leaveCreate?.d.BEGDA)!)
                        let endDate = df.date(from: (self.leaveCreate?.d.ENDDA)!)
                        df.dateStyle = .short
                        df.timeStyle = .none
                        df.locale = Locale(identifier: "en_AU")
                        self.startDateLabel.text = df.string(from: startDate!)
                        self.startDatePickerView.date = startDate!
                        self.endDateLabel.text = df.string(from: endDate!)
                        self.endDatePickerView.date = endDate!
                    })
                }
            }
        }
    }
    
    //MARK: - leaveTypePicker delegate functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.leaveTypeTextArray.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.leaveTypeTextArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if leaveCreate != nil {
            leaveCreate!.d.SUBTY = leaveTypeCodeArray[row]
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let normalCellHeight = CGFloat(44)
        let largeCellHeight = CGFloat(200)
        
        switch(indexPath) {
        case [1,0]: // Leave Type Picker Cell
//            return isLeaveTypePickerHidden ? normalCellHeight : largeCellHeight
            return CGFloat(216)
        case [2,0]: // Start Date Cell
            return isStartDatePickerHidden ? normalCellHeight : largeCellHeight
        case [3,0]: // End Date Cell
            return isEndDatePickerHidden ? normalCellHeight : largeCellHeight
        default: return normalCellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath) {
        case [1,0]:
            isLeaveTypePickerHidden = !isLeaveTypePickerHidden
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
        case [2,0]:
            isStartDatePickerHidden = !isStartDatePickerHidden
            
            startDateLabel.textColor =
                isStartDatePickerHidden ? .black : tableView.tintColor
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
        case [3,0]:
            isEndDatePickerHidden = !isEndDatePickerHidden
            
            endDateLabel.textColor =
                isEndDatePickerHidden ? .black : tableView.tintColor
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
        default: break
        }
    }
    
    //MARK: - Actions
    @IBAction func startDatePickerChanged(_ sender: UIDatePicker) {
        let df = DateFormatter()
        
        df.locale = Locale(identifier: "en_AU")
        df.dateStyle = .short
        df.timeStyle = .none
        startDateLabel.text = df.string(from: startDatePickerView.date)
        
        df.dateFormat = "yyyyMMdd"
        leaveCreate?.d.BEGDA = df.string(from: startDatePickerView.date)
        
    }
    
    @IBAction func endDatePickerChanged(_ sender: UIDatePicker) {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_AU")
        df.dateStyle = .short
        df.timeStyle = .none
        endDateLabel.text = df.string(from: endDatePickerView.date)
        
        df.dateFormat = "yyyyMMdd"
        leaveCreate?.d.ENDDA = df.string(from: endDatePickerView.date)
    }

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
