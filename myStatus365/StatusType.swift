//
//  StatusType.swift
//  myStatus365
//
//  Created by Chris Tham on 6/12/18.
//  Copyright © 2018 Transport for NSW. All rights reserved.
//

import Foundation

enum StatusType : Int, CaseIterable {
    case AtDesk = 0
    case InMeeting
    case Event
    case Travel
    case Home
    case Leave
    case DoNotDisturb
    case OutOfOffice
    case Other
    
    func getLabel() -> String {
        switch self {
        case .AtDesk:
            return "At Desk"
        case .InMeeting:
            return "In Meeting"
        case .Event:
            return "At Event"
        case .Travel:
            return "Travel"
        case .Home:
            return "At Home"
        case .Leave:
            return "On Leave"
        case .DoNotDisturb:
            return "Do Not Disturb"
        case .OutOfOffice:
            return "Out of Office"
        case .Other:
            return "Other"
        }
    }
    
    func getImage() -> UIImage {
        switch self {
        case .AtDesk:
            return #imageLiteral(resourceName: "AtDesk")
        case .InMeeting:
            return #imageLiteral(resourceName: "Meeting")
        case .Event:
            return #imageLiteral(resourceName: "Event")
        case .Travel:
            return #imageLiteral(resourceName: "Travel")
        case .Home:
            return #imageLiteral(resourceName: "Home")
        case .Leave:
            return #imageLiteral(resourceName: "Leave")
        case .DoNotDisturb:
            return #imageLiteral(resourceName: "DoNotDisturb")
        case .OutOfOffice:
            return #imageLiteral(resourceName: "OutOfOffice")
        case .Other:
            return #imageLiteral(resourceName: "Other")
        }
    }
    
    func getForegroundColor() -> UIColor {
        switch self {
        case .AtDesk:
            return #colorLiteral(red: 0.07797776908, green: 0.2222562134, blue: 0.4960105419, alpha: 1)
        case .InMeeting:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .Event:
            return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case .Travel:
            return #colorLiteral(red: 0.07797776908, green: 0.2222562134, blue: 0.4960105419, alpha: 1)
        case .Home:
            return #colorLiteral(red: 0.07797776908, green: 0.2222562134, blue: 0.4960105419, alpha: 1)
        case .Leave:
            return #colorLiteral(red: 0.07797776908, green: 0.2222562134, blue: 0.4960105419, alpha: 1)
        case .DoNotDisturb:
            return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        case .OutOfOffice:
            return #colorLiteral(red: 0.07797776908, green: 0.2222562134, blue: 0.4960105419, alpha: 1)
        case .Other:
            return #colorLiteral(red: 0.07797776908, green: 0.2222562134, blue: 0.4960105419, alpha: 1)
        }
    }
    
    func getBackgroundColor() -> UIColor {
        switch self {
        case .AtDesk:
            return #colorLiteral(red: 0.6913105845, green: 0.7106819749, blue: 0.2170348763, alpha: 1)
        case .InMeeting:
            return #colorLiteral(red: 0.5067401528, green: 0.5137251019, blue: 0.526117146, alpha: 1)
        case .Event:
            return #colorLiteral(red: 0.5067401528, green: 0.5137251019, blue: 0.526117146, alpha: 1)
        case .Travel:
            return #colorLiteral(red: 0.4175251126, green: 0.8115726113, blue: 0.9541099668, alpha: 1)
        case .Home:
            return #colorLiteral(red: 0.4175251126, green: 0.8115726113, blue: 0.9541099668, alpha: 1)
        case .Leave:
            return #colorLiteral(red: 0.4175251126, green: 0.8115726113, blue: 0.9541099668, alpha: 1)
        case .DoNotDisturb:
            return #colorLiteral(red: 0.8876586556, green: 0.08936477453, blue: 0.2413475513, alpha: 1)
        case .OutOfOffice:
            return #colorLiteral(red: 0.4175251126, green: 0.8115726113, blue: 0.9541099668, alpha: 1)
        case .Other:
            return #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        }
    }
    
    static func random() -> StatusType {
        // Random status rawvalue except omit last (.Other)
        let random = Int(arc4random_uniform(UInt32(StatusType.allCases.count - 1)))
        return StatusType(rawValue: random)!
    }
}

struct CurrentStatus {
    var user : String
    var status : StatusType
    var start, end : Date
    var location : String
    var description : String
}
