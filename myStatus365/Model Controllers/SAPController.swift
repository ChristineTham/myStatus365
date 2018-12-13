//
//  SAPLeaveController.swift
//  myStatus365
//
//  Created by Chris Tham on 10/12/18.
//  Copyright © 2018 Transport for NSW. All rights reserved.
//

import Foundation

struct LeaveCreateRecord : Codable {
    var d : LeaveCreate
}

struct LeaveCreate : Codable {
    var __metadata : MetaData
    var USERID : String
    var SUBTY: String
    var BEGDA : String
    var ENDDA : String
    var MSG: String
    var MANAGER : String
}

struct LeaveTypeList : Codable {
    var d : LeaveTypeResults
}

struct LeaveTypeResults : Codable {
    var results : [LeaveType]
}

struct LeaveType : Codable {
    var __metadata : MetaData
    var Subty: String
    var Subtytext: String
}

struct LeaveRequestList : Codable {
    var d : LeaveResults
}

struct LeaveResults : Codable {
    var results : [LeaveRequest]
}

struct LeaveRequest : Codable {
    var __metadata : MetaData
    var Status : String
    var StatusText : String
    var Employee : String
    var Subty: String
    var Endda : String
    var Begda : String
    var SubtypeDescription: String
}

struct MetaData : Codable {
    var id: String
    var uri : URL
    var type: String
}

extension Date {
    init?(jsonDate: String) {
        
        let prefix = "/Date("
        let suffix = ")/"
        // Check for correct format:
        if jsonDate.hasPrefix(prefix) && jsonDate.hasSuffix(suffix) {
            // Extract the number as a string:
            let from = jsonDate.index(jsonDate.startIndex, offsetBy: prefix.count)
            let to = jsonDate.index(jsonDate.endIndex, offsetBy: -suffix.count)
            // Convert milliseconds to double
            guard let milliSeconds = Double(jsonDate[from ..< to]) else {
                return nil
            }
            // Create NSDate with this UNIX timestamp
            self.init(timeIntervalSince1970: milliSeconds/1000.0)
        } else {
            return nil
        }
    }
}

class SAPController {
    let baseURL = URL(string: "https://tfnswpoc.apimanagement.ap1.hana.ondemand.com:443/ZPOC_ESS_LEAVE_SRV")!
    let leaveRequestListset = "/LEAVE_REQUESTLIST"
    let leaveTypeList = "/LEAVE_TYPES"
    let leaveCreate = "/LEAVE_CREATE"
    let userName = "POCUSER1"
    let password = "Welcome@123"
    
    func getLeaveRequestList(_ user : String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let loginString = String(format: "%@:%@", userName, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        // create the request
        let url = baseURL.appendingPathComponent(leaveRequestListset)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "sap-client", value: "110")
        ]
        let myURL = components.url!
        
        var request = URLRequest(url: myURL)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Fetch", forHTTPHeaderField: "X-CSRF-Token")
        
        //making the request
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func getLeaveTypeList(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let loginString = String(format: "%@:%@", userName, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        // create the request
        let url = baseURL.appendingPathComponent(leaveTypeList)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "sap-client", value: "110")
        ]
        let myURL = components.url!
        
        var request = URLRequest(url: myURL)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //making the request
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func prepopulateLeaveRequest(_ user : String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let loginString = String(format: "%@:%@", userName, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        // create the request
        let url = baseURL.appendingPathComponent(leaveCreate + "('\(user)')")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "sap-client", value: "110")
        ]
        let myURL = components.url!
        
        var request = URLRequest(url: myURL)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Fetch", forHTTPHeaderField: "X-CSRF-Token")

        //making the request
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func createLeaveRequest(with leaveRequest : LeaveCreateRecord, CSRFToken : String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let loginString = String(format: "%@:%@", userName, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        // create the request
        let url = baseURL.appendingPathComponent(leaveCreate)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "sap-client", value: "110")
        ]
        let myURL = components.url!
        
        var request = URLRequest(url: myURL)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(CSRFToken, forHTTPHeaderField: "X-CSRF-Token")
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        if let jsonData = try? jsonEncoder.encode(leaveRequest) {
            request.httpBody = jsonData
            print(String(data: jsonData, encoding: .utf8)!)
        }
        
        //making the request
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
}
