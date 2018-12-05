//
//  MSGraphController.swift
//  my iOS Swift App
//
//  Created by Chris Tham on 3/12/18.
//  Copyright © 2018 Hello Tham. All rights reserved.
//

import Foundation

class MSGraphController {
    static let clientId = "e810233c-a57b-4300-8c12-633a14c4dc26"
    static let scopes   = ["User.Read.All", "Mail.Read", "Calendars.Read", "Contacts.Read", "Directory.AccessAsUser.All", "People.Read", "Group.Read.All"]
    lazy var graphClient: MSGraphClient = {
        
        let client = MSGraphClient.defaultClient()
        return client!
    }()
    var me : MSGraphUser?
    var myImage : UIImage?
    var allUsers : [MSGraphUser]
    var myGroups : [MSGraphDirectoryObject]
    var myEvents : [MSGraphEvent]

    init (with authentication: Authentication) {
        MSGraphClient.setAuthenticationProvider(authentication.authenticationProvider)
        me = nil
        myImage = nil
        allUsers = []
        myGroups = []
        myEvents = []
    }
    
    // Returns select information about the signed-in user from Azure Active Directory. Applies to personal or work accounts
    func getMe(with completion: @escaping (_ result: Result) -> Void) {
        graphClient.me().request().getWithCompletion {
            (user: MSGraphUser?, error: Error?) in
            
            if let error = error {
                completion(.Failure(error: MSGraphError.ErrorType(error: error)))
            }
            else {
                if let me = user {
                    self.me = me
                    let displayString = "Retrieval of user account information succeeded for \(String(user!.displayName!))"
                    completion(.Success(displayText: displayString))
                }
                else {
                    completion(.Failure(error: error!))
                }

            }
        }
    }
    
    // Returns all of the users in your tenant's directory.
    // Applies to personal or work accounts.
    // nextRequest is a subsequent request if there are more users to be loaded.
    func getUsers(with completion: @escaping (_ result: Result) -> Void) {
        graphClient.users().request().getWithCompletion {
            (userCollection: MSCollection?, nextRequest: MSGraphUsersCollectionRequest?, error: Error?) in
            
            if let error = error {
                completion(.Failure(error: MSGraphError.ErrorType(error: error)))
            }
            else {
                var displayString = "List of users:\n"
                if let users = userCollection {
                    self.allUsers = []
                    
                    for user: MSGraphUser in users.value as! [MSGraphUser] {
                        displayString += user.displayName + "\n"
                        self.allUsers.append(user)
                    }
                }
                
                if let _ = nextRequest {
                    displayString += "Next request available for more users"
                }
                completion(.Success(displayText: displayString))
            }
        }
    }
    
    // Get user's direct reports
    // Applies to work accounts only
    func getDirects(with completion: @escaping (_ result: Result) -> Void) {
        graphClient.me().directReports().request().getWithCompletion {
            (directCollection: MSCollection?, nextRequest: MSGraphUserDirectReportsCollectionWithReferencesRequest?, error: Error?) in
            
            if let error = error {
                completion(.Failure(error: MSGraphError.ErrorType(error: error)))
            }
            else {
                var displayString = "List of directs: \n"
                if let directs = directCollection {
                    
                    for direct: MSGraphDirectoryObject in directs.value as! [MSGraphDirectoryObject] {
                        guard let name = direct.dictionaryFromItem()["displayName"] else {
                            completion(.Failure(error: MSGraphError.UnexpectecError(errorString: "Display name not found")))
                            return
                        }
                        displayString += "\(name)\n"
                    }
                }
                
                if let _ = nextRequest {
                    displayString += "Next request available for more users"
                }
                
                completion(.Success(displayText: "\(displayString)"))
            }
        }
    }
    
    // Get user's manager if they have one.
    // Applies to work accounts only
    func getManager(with completion: @escaping (_ result: Result) -> Void) {
        graphClient.me().manager().request().getWithCompletion {
            (directoryObject: MSGraphDirectoryObject?, error: Error?) in
            
            if let error = error {
                completion(.Failure(error: MSGraphError.ErrorType(error: error)))
            }
            else {
                var displayString: String = "Manager information: \n"
                
                if let manager = directoryObject {
                    if let managerName = manager.dictionaryFromItem()["displayName"] {
                        displayString += "Manager is \(managerName)\n\n"
                    }
                    else {
                        displayString += "No manager"
                    }
                    displayString += "Full object is\n\(manager)"
                }
                completion(.Success(displayText: "\(displayString)"))
            }
        }
    }
        
    // Gets the signed-in user's photo data if they have a photo.
    // Applies to work accounts only
    func getPhoto(with completion: @escaping (_ result: Result) -> Void) {
            
        graphClient.me().photoValue().download {
            (url: URL?, response: URLResponse?, error: Error?) in
                
            if let error = error {
                completion(.Failure(error: MSGraphError.ErrorType(error: error)))
                return
            }
            
            guard let picUrl = url else {
                completion(.Failure(error: MSGraphError.UnexpectecError(errorString: "No downloaded URL")))
                return
            }
            
            let picData = try? Data(contentsOf: picUrl)
            self.myImage = UIImage(data: picData!)
            
            completion(.SuccessDownloadImage(displayImage: self.myImage))
        }
    }

    // Gets the signed-in user's events.
    // Applies to personal or work accounts
    func getEvents(with completion: @escaping (_ result: Result) -> Void) {
        graphClient.me().events().request().getWithCompletion {
            (eventCollection: MSCollection?, nextRequest: MSGraphUserEventsCollectionRequest?, error: Error?) in
            if let error = error {
                completion(.Failure(error: MSGraphError.ErrorType(error: error)))
            }
            else {
                var displayString = "List of events (subjects):\n"
                if let events = eventCollection {
                    self.myEvents = []
                    
                    for event: MSGraphEvent in events.value as! [MSGraphEvent] {
                        displayString += event.subject + "\n\n"
                        self.myEvents.append(event)
                    }
                }
                
                if let _ = nextRequest {
                    displayString += "Next request available for more users"
                }
                
                completion(.Success(displayText: displayString))
            }
        }
    }
    
    // Create an event in the signed in user's calendar.
    // Applies to personal or work accounts
    func createEvent(with completion: @escaping (_ result: Result) -> Void) {
        
        let event = createEventObject(isSeries: false)
        
        graphClient.me().calendar().events().request().add(event) {
            (event: MSGraphEvent?, error: Error?) in
            if let error = error {
                completion(.Failure(error: MSGraphError.ErrorType(error: error)))
            }
            else {
                let displayString = "Event created with id \(event!.entityId!)"
                completion(.Success(displayText: displayString))
            }
        }
    }
    
    // Updates an event in the signed in user's calendar.
    // Applies to personal or work accounts
    func updateEvent(with completion: @escaping (_ result: Result) -> Void) {
        
        // Enter a valid event id
        let eventId = "ENTER_VALID_EVENT_ID"
        
        // Get an event and then update
        graphClient.me().events(eventId).request().getWithCompletion {
            (event: MSGraphEvent?, error: Error?) in
            
            if let error = error {
                completion(.Failure(error: MSGraphError.ErrorType(error: error)))
            }
            else {
                guard let validEvent = event else {
                    completion(.Failure(error: MSGraphError.UnexpectecError(errorString: "Event ID not returned")))
                    return
                }
                validEvent.subject = "New Name"
                self.graphClient.me().events(validEvent.entityId).request().update(validEvent, withCompletion: {
                    (updatedEvent: MSGraphEvent?, error: Error?) in
                    if let error = error {
                        completion(.Failure(error: MSGraphError.ErrorType(error: error)))
                    }
                    else {
                        let displayString = "Event updated with a new subject"
                        completion(.Success(displayText: displayString))
                    }
                })
            }
        }
    }
    
    // Deletes an event in the signed in user's calendar.
    // Applies to personal or work accounts
    func deleteEvent(with completion: @escaping (_ result: Result) -> Void) {
        
        // Enter a valid event id
        let eventId = "ENTER_VALID_EVENT_ID"
        
        graphClient.me().events(eventId).request().delete(completion: {
            (error: Error?) in
            if let error = error {
                completion(.Failure(error: MSGraphError.ErrorType(error: error)))
            }
            else {
                completion(.Success(displayText: "Deleted calendar event id: \(eventId)"))
            }
        })
    }
    // Helper for creating a event object.
    // Set series to true to create a recurring event.
    func createEventObject(isSeries series: Bool) -> MSGraphEvent {
        
        let event = MSGraphEvent()
        event.subject = "Event Subject"
        event.body = MSGraphItemBody()
        event.body.contentType = MSGraphBodyType.text()
        event.body.content = "Sample event body"
        event.importance = MSGraphImportance.normal()
        
        let startDate: Date = Date(timeInterval: 30 * 60, since: Date())
        let endDate: Date = Date(timeInterval: 30 * 60, since: startDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        
        event.start = MSGraphDateTimeTimeZone()
        event.start.dateTime = dateFormatter.string(from: startDate)
        
        // For more timezone settings, visit this link
        // http://graph.microsoft.io/en-us/docs/api-reference/v1.0/resources/datetimetimezone
        event.start.timeZone = "Pacific/Honolulu"
        
        event.end = MSGraphDateTimeTimeZone()
        event.end.dateTime = dateFormatter.string(from: endDate)
        event.end.timeZone = "Pacific/Honolulu"
        
        if !series {
            event.type = MSGraphEventType.singleInstance()
        }
        else {
            event.type = MSGraphEventType.seriesMaster()
            
            event.recurrence = MSGraphPatternedRecurrence()
            event.recurrence.pattern = MSGraphRecurrencePattern()
            event.recurrence.pattern.interval = 1
            event.recurrence.pattern.type = MSGraphRecurrencePatternType.weekly()
            event.recurrence.pattern.daysOfWeek = [MSGraphDayOfWeek.friday()]
            event.recurrence.range = MSGraphRecurrenceRange()
            event.recurrence.range.type = MSGraphRecurrenceRangeType.noEnd()
            event.recurrence.range.startDate = MSDate(nsDate: startDate)
        }
        return event
    }

    // Gets a collection of groups that the signed-in user is a member of.
    func getGroups(with completion: @escaping (_ result: Result) -> Void) {
        
        graphClient.me().memberOf().request().getWithCompletion {
            (userGroupCollection: MSCollection?,
            nextRequest: MSGraphUserMemberOfCollectionWithReferencesRequest?,
            error: Error?) in
            
            if let error = error {
                completion(.Failure(error: MSGraphError.ErrorType(error: error)))
                return
            }
            
            var displayString = "List of groups: \n"
            
            if let userGroups = userGroupCollection {
                self.myGroups = []
                for userGroup: MSGraphDirectoryObject in userGroups.value as! [MSGraphDirectoryObject] {
                    guard let name = userGroup.dictionaryFromItem()["displayName"] else {
                        completion(.Failure(error: MSGraphError.UnexpectecError(errorString: "Display name not found")))
                        return
                    }
                    displayString += "\(name)\n"
                    self.myGroups.append(userGroup)
                }
            }
            if let _ = nextRequest {
                displayString += "Next request available for more groups"
            }
            
            completion(.Success(displayText: displayString))
        }
    }
}

// MARK: - Enum Result
enum Result {
    case Success(displayText: String?)
    case SuccessDownloadImage(displayImage: UIImage?)
    case Failure(error: Error)
}

enum MSGraphError: Error {
    case ErrorType(error: Error)
    case UnexpectecError(errorString: String)
}
