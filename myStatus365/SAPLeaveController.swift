//
//  SAPLeaveController.swift
//  myStatus365
//
//  Created by Chris Tham on 10/12/18.
//  Copyright © 2018 Transport for NSW. All rights reserved.
//

import Foundation

struct LeaveRequestList : Codable {
    var d : Results
}

struct Results : Codable {
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

class SAPLeaveController {
    let baseURL = URL(string: "https://tfnswpoc.apimanagement.ap1.hana.ondemand.com:443/ZPOC_ESS_LEAVE_SRV")!
    let leaveRequestListset = "/ETY_LEAVE_REQUESTLISTSET"
    let leaveCreateGet = "/ETS_LEAVE_CREATESET('ESSTEST14')"
    let leaveCreatePost = "/ETS_LEAVE_CREATESET"
    let userName = "POCUSER1"
    let password = "Welcome@123"
    
    func getLeaveEntitlements(_ user : String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let loginString = String(format: "%@:%@", userName, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        // create the request
        let url = baseURL.appendingPathComponent(leaveRequestListset)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "$filter", value: "Status eq '\(user)'"),
            URLQueryItem(name: "sap-client", value: "110")
        ]
        let menuURL = components.url!
//        let menuURL = URL(string: "https://tfnswpoc.apimanagement.ap1.hana.ondemand.com:443/ZPOC_ESS_LEAVE_SRV/ETY_LEAVE_REQUESTLISTSET?$filter=Status%20eq%20'ESSTEST14'&sap-client=110")!
        
        var request = URLRequest(url: menuURL)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //making the request
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
        
        return task
    }
}
