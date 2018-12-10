//
//  SAPLeaveController.swift
//  myStatus365
//
//  Created by Chris Tham on 10/12/18.
//  Copyright © 2018 Transport for NSW. All rights reserved.
//

import Foundation

class SAPLeaveController {
    let baseURL = URL(string: "https://tfnswpoc.apimanagement.ap1.hana.ondemand.com:443/ZPOC_ESS_LEAVE_SRV/")!
    let leaveRequestList = "/ETY_LEAVE_REQUESTLISTSET"
    let leaveCreateGet = "/ETS_LEAVE_CREATESET('ESSTEST14')"
    let leaveCreatePost = "/ETS_LEAVE_CREATESET"
    let userName = "POCUSER1"
    let password = "Welcome@123"
    
    func getRequest() {
        let loginString = String(format: "%@:%@", userName, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        // create the request
        let url = baseURL.appendingPathComponent(leaveRequestList)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "$filter",
                                              value: "Status eq 'ESSTEST14'")]
        let menuURL = components.url!
        var request = URLRequest(url: menuURL)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        //making the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {
                // check status code returned by the http server
                print("status code = \(httpStatus.statusCode)")
                // process result
                if (httpStatus.statusCode == 200) {
                    print(data)
                }
            }
        }
        task.resume()
    }
}
