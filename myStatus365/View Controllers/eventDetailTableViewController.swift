//
//  eventDetailTableViewController.swift
//  myStatus365
//
//  Created by Chris Tham on 11/12/18.
//  Copyright © 2018 Transport for NSW. All rights reserved.
//

import UIKit

class eventDetailTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    var event = ""
    var location = ""
    var type = ""
    var status = ""
    var start = Date()
    var end = Date()
    
    //MARK: - Outlets
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        eventLabel.text = event
        locationLabel.text = location
        typeLabel.text = type
        statusLabel.text = status
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_AU")
        df.dateStyle = .short
        df.timeStyle = .short
        if type == "All Day Event" {
            df.timeStyle = .none
        }
        startLabel.text = df.string(from: start)
        endLabel.text = df.string(from: end)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
