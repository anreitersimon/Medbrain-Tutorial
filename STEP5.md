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
- displays a message if a error occured



### Implementing the SessionManager

1. create a new file named `SessionManager.swift` (File->New->File)
2. When prompted for the template for the file select `Swift File`

3. Create a singleton class and import the `SMART` framework:
```swift

import Foundation
import SMART

class SessionManager {
  //singleton instance
  static let shared = SessionManager()

  private init() {
    //private initializer to avoid this class being instantiated anywhere else than the singleton instance
  }

  ///The server to which request are sent
  var server = Server(base: "http://fhir2.healthintersections.com.au/open/")

  ///The currently logged in patient
  var patient: SMART.Patient?

}
```
4.
