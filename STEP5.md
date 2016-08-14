# Step 5 - Implementing SignIn

## Prerequisites
Finished [Step 4](STEP4.md) of this Tutorial.

If you want to start here you just run `git checkout step5`.

The Project is located at `project/` of the git repository root.

## Goals
The data displayed in this app is very specific to the currently signed in patient.

So before building the rest of the app it is the first priority to implement the sign-in.

## Getting started

For the implementation we will introduce following classes:

- `SessionManager`
- `PatientSignInViewController`


##### SessionManager
- Implemented as a singleton.
- Its responsibility is to manage the currently signed in patient.
- handle log-in and log-out

##### PatientSignInViewController
- displays a screen in which the user can enter his credentials. (i.e. username and password)
- displays loading indicator while the log-in is in progress
- displays a message if a error occurred


### Implementing the SessionManager

1. create a new file named `SessionManager.swift` (File->New->File)
2. When prompted for the template for the file select `Swift File`

3. Create a singleton class and import the `SMART` framework
```swift

import Foundation
import SMART


class SessionManager {
    ///singleton instance
    static let shared = SessionManager()

    private init() {
        //private initializer to avoid this class being instantiated anywhere else than the singleton instance
    }

    ///The server against which requests are executed
    var server = Server(base: "http://fhir2.healthintersections.com.au/open/")

    ///The currently logged in patient (defaults to nil)
    var patient: Patient?

    ///convenience property is `true` if a patient is signed in
    var signedIn: Bool {
        return patient != nil
    }
}
```
4. Create an accompanying object `LogInCredentials`. This object is passed to the `SessionManger` when initiating the login.

```swift
///credentials should provide enough data to uniquely identify a patient
struct LogInCredentials {

    ///credentials which identify a test_user on the server
    static var defaultCredentials: LogInCredentials {
        return LogInCredentials(queryParamters: ["_id": ["$exact": "f001"]])
    }

    var queryParamters: [NSObject:AnyObject] = [:]
}
```

4. Create an accompanying enum `Result`.
This object represents the result of a task which might fail.

```swift
//when performing a task which might fail the result of this task can be modelled like this.
enum Result<ExpectedResultType> {
    //the task completed successfully and produced a result
    //if no actual result is produced use Void as ExpectedResultType
    case Success(_: ExpectedResultType)

    //the task failed and optionally provides an error which contains more information what went wrong.
    case Error(_: ErrorType?)
}
```

```swift

//MARK: - Definitions
extension SessionManager {
    //closure called after the log-in completes
    //Note: completing the log-in does NOT mean it was successful
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

        Patient.search(credentials.queryParamters).perform(server) {(bundle, error) in

            let result: Result<Patient>

            if let patients = bundle?.entry?.flatMap({ $0.resource as? Patient }) where !patients.isEmpty {
                if patients.count > 1 {
                    print("warning: multiple patients found. using first")
                }

                let oldPatient = self.patient
                self.patient = patients.first
                self.patientDidChange(oldPatient, new: self.patient)

                result = .Success(patients.first!)

            } else {
                result = .Error(error)
            }

            completion(result: result)
        }
    }

    func logout() {
        let oldPatient = self.patient
        patient = nil
        patientDidChange(oldPatient, new: nil)
    }
}
```

The finished `SessionManager` implementation can be found [here](resources/step5/SessionManager.swift)


[Continue with Step5 of the Tutorial](STEP5-2.md)
