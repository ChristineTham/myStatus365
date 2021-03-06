//
//  myStatusViewController.swift
//  myStatus365
//
//  Created by Chris Tham on 5/12/18.
//  Copyright © 2018 Transport for NSW. All rights reserved.
//

import UIKit

class myStatusViewController: UIViewController {
    
    //MARK: - Properties
    
    let authentication = Authentication()
    var graph : MSGraphController?
    
    //MARK: - Outlets
    @IBOutlet weak var connectButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    
    //MARK: - Controller overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        connectButton.title = "Log In"
    }

    @IBAction func connectButtonPressed(_ sender: UIBarButtonItem) {
        let clientId = MSGraphController.clientId
        let scopes = MSGraphController.scopes
        
        if (connectButton.title == "Log In") {
            authentication.connectToGraph(withClientId: clientId, scopes: scopes) {
                (error) in
                
                if let graphError = error {
                    switch graphError {
                    case .ErrorType(let error):
                        print(NSLocalizedString("ERROR", comment: ""), error.localizedDescription)
                    default:
                        print("Unexpected error")
                    }
                }
                else {
                    self.graph = MSGraphController(with: self.authentication)
                    sharedGraphController = self.graph
                    self.graph?.getMe(with: { (result) in
                        switch (result) {
                        case .Success:
                            self.updateUserInfo((self.graph?.me)!)
                        default:
                            print("An error occured")
                        }
                    })
                }
                self.graph?.getPhoto(with: { (result) in
                    switch (result) {
                    case .SuccessDownloadImage(let displayImage):
                        DispatchQueue.main.async(execute: {
                            self.photoImageView.image = displayImage
                        })
                    default:
                        print("An error occured")
                    }
                })
            }
            
            connectButton.title = "Log Out"
        }
        else {
            authentication.disconnect()
            connectButton.title = "Log In"
        }
        
        
    }
    
    @IBAction func unwindToMyStatus(sender: UIStoryboardSegue) {
        updateLocation()
    }
    
    func updateUserInfo(_ user: MSGraphUser) {
        DispatchQueue.main.async(execute: {
            self.nameLabel.text = user.displayName
            let status = sharedGraphController?.myStatus
            self.statusImageView.image = status!.getImage()
            self.statusLabel.text = status!.getLabel()
            self.statusLabel.textColor = status!.getForegroundColor()
            self.statusLabel.backgroundColor = status!.getBackgroundColor()
            self.locationLabel.text = sharedGraphController?.currLocation
            self.locationImageView.image = #imageLiteral(resourceName: "L25Pitt")
        })
    }
    
    func updateLocation() {
        let status = StatusType.AtDesk
        sharedGraphController?.myStatus = status
        self.statusImageView.image = status.getImage()
        self.statusLabel.text = status.getLabel()
        self.statusLabel.textColor = status.getForegroundColor()
        self.statusLabel.backgroundColor = status.getBackgroundColor()
        
        let location = sharedGraphController?.currLocation
        self.locationLabel.text = location
        if location!.contains("Pitt") {
            self.locationImageView.image = #imageLiteral(resourceName: "ABW25Pitt")
        } else if location!.contains("Macquarie") {
            self.locationImageView.image = #imageLiteral(resourceName: "ABWMacq")
        }
    }
}

