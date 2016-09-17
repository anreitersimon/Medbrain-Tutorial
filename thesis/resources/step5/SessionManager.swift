//
//  SessionManager.swift
//  Medbrain
//
//  Created by Simon Anreiter on 13/08/16.
//  Copyright © 2016 Simon Anreiter. All rights reserved.
//

import Foundation
import SMART

///credentials should provide enough data to uniquely identifiy a patient
struct LogInCredentials {
    static var defaultCredentials: LogInCredentials {
        return LogInCredentials(queryParamters: ["_id": ["$exact": "f001"]])
    }

    var queryParamters: [NSObject:AnyObject] = [:]
}

//when performing a task which might fail result is always success or failure
enum Result<ExpectedResultType> {
    case Success(_: ExpectedResultType)
    case Error(_: ErrorType?)
}


//MARK: - Properties
class SessionManager {

    //singleton instance
    static let shared = SessionManager()

    private init() {
        //private initializer to avoid this class being instantiated anywhere else than the singleton instance
    }

    var server = Server(base: "http://fhir2.healthintersections.com.au/open/")

    ///The currently logged in patient
    var patient: SMART.Patient? {
        didSet {
            guard oldValue !== patient else { return }

            patientDidChange(oldValue, new: patient)
        }
    }

    ///convenience property is `true` if a patient is signed in
    var signedIn: Bool {
        return patient != nil
    }

}


//MARK: - Definitions
extension SessionManager {
    typealias LogInCompletionHandler = (result: Result<Patient>) -> Void

    ///Name of the notification sent to observers when the patient changes
    static let PatientChangedNotification = "SessionManager.PatientChangedNotification"

    ///User-info dictionary key for the old patient value
    static let PatientChangedNotificationOldKey = "SessionManager.PatientChangedNotification.Old"

    ///User-info dictionary key for the new patient value
    static let PatientChangedNotificationNewKey = "SessionManager.PatientChangedNotification.New"
}


//MARK: - Methods
extension SessionManager {


    ///When the patient changes notify all observers about this change
    func patientDidChange(old: Patient?, new: Patient?) {
        var info = [NSObject:AnyObject]()
        info[SessionManager.PatientChangedNotificationOldKey] = old
        info[SessionManager.PatientChangedNotificationNewKey] = new

        //Notify obvservers that the current patient did change
        NSNotificationCenter.defaultCenter().postNotificationName(SessionManager.PatientChangedNotification, object: self, userInfo: info)
    }

    ///attempts to log in the user whith the specified credentials asynchronously
    ///calls completion handler with the result (success/failure)
    func logIn(credentials: LogInCredentials, completion: LogInCompletionHandler) {

        //This executes a search against the specified server the SMART Framework
        Patient.search(credentials.queryParamters).perform(server) {(bundle, error) in

            let result: Result<Patient>

            if let patients = bundle?.entry?.flatMap({ $0.resource as? Patient }) where !patients.isEmpty {
                if patients.count > 1 {
                    print("warning: multiple patients found. using first")
                }

                self.patient = patients.first
                result = .Success(patients.first!)


            } else {
                result = .Error(error)
            }

            dispatch_async(dispatch_get_main_queue()) {
                completion(result: result)
            }
        }
    }

    func logout() {
        patient = nil
    }
}
