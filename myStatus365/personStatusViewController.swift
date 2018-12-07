//
//  personStatusViewController.swift
//  myStatus365
//
//  Created by Chris Tham on 7/12/18.
//  Copyright © 2018 Transport for NSW. All rights reserved.
//

import UIKit
import MessageUI

class personStatusViewController: UIViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    //MARK: - Properties
    
    var person : MSGraphDirectoryObject?
    var status : StatusType?
    
    //MARK: - Outlets
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var skypeCallButton: UIButton!
    @IBOutlet weak var skypeChatButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        status = StatusType.random()
        statusImageView.image = status?.getImage()
        statusLabel.text = status?.getLabel()
        statusLabel.textColor = status?.getForegroundColor()
        statusLabel.backgroundColor = status?.getBackgroundColor()
        locationLabel.text = "Current Location:\nBlah Blah Blah ..."
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Actions

    @IBAction func phoneButtonPressed(_ sender: UIButton) {
        guard let mobilePhone = person!.dictionaryFromItem()!["mobilePhone"]! as? String else {
            let alert = UIAlertController(title: "Phone Call", message: "No mobile number", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if let url = URL(string: "tel://\(mobilePhone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        guard let mobilePhone = person!.dictionaryFromItem()!["mobilePhone"]! as? String else {
            let alert = UIAlertController(title: "Send Message", message: "No mobile number", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard MFMessageComposeViewController.canSendText() else {
            return
        }
        
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Enter a message";
        messageVC.recipients = [mobilePhone]
        messageVC.messageComposeDelegate = self
        
        self.present(messageVC, animated: true, completion: nil)
    }
    
    @IBAction func mailButtonPressed(_ sender: Any) {
        guard let mail = person!.dictionaryFromItem()!["mail"]! as? String else {
            let alert = UIAlertController(title: "Send Mail", message: "No email address", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        let mailComposerVC = MFMailComposeViewController()
        
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([mail])
        mailComposerVC.setSubject("Need to contact you ...")
        mailComposerVC.setMessageBody("Please contact me!", isHTML: false)
        
        
        self.present(mailComposerVC, animated: true, completion: nil)
    }
    
    @IBAction func skypeCallButtonPressed(_ sender: Any) {
        guard let mail = person!.dictionaryFromItem()!["mail"]! as? String else {
            let alert = UIAlertController(title: "Skype Call", message: "No Skype user name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
        }

        if let url = URL(string: "ms-sfb://call?id=\(mail)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func skypeChatButtonPressed(_ sender: Any) {
        guard let mail = person!.dictionaryFromItem()!["mail"]! as? String else {
            let alert = UIAlertController(title: "Skype Call", message: "No Skype user name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if let url = URL(string: "ms-sfb://chat?id=\(mail)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //MARK: - delegate functions
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
