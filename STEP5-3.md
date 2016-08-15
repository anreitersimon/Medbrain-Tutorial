### Implementing SignIn -  PatientSignInViewController functionality

------------

### Import `SMART` framework
add `import SMART` statement to the top of the `PatientSignInViewController`


### Add a completionHandler
First define a typealias for the `completionHandler`

```swift
typealias SignInCompletionHandler = (patient: Patient) -> Void
```
This will be called after the user has successfully signed in

Add a optional property named `completionHandler` of type `SignInCompletionHandler`

```swift
///Will be called after the Sign-In successfully finished
///Note: user cannot leave screen without successfully signing in
var completionHandler: SignInCompletionHandler?
```

### Implement `submitButtonPressed` action
This method gets called when the `submitButton` is pressed and will perform 3 steps:
- generate `LogInCredentials` from the entered information
- log-in using `SessionManager`
- Verify result and if successful call `completionHandler` if failed show error

```swift
@IBAction func submitButtonPressed(sender: AnyObject?) {
    //1. generate `LogInCredentials` from the entered information
    //2. log-in using `SessionManager`
    //3. Verify result and if successful call `completionHandler` if failed show error
  }
```

##### 1. Generating and verifying credentials
Two helper-methods are introduced
```swift
///generate `LogInCredentials` from the information entered
///- returns: nil if the entered credentials are incomplete or invalid
func generateCredentials() -> LogInCredentials? {
    //when sign-in is implemented properly this has to be adjusted

    //Always return the default credentials for the test-user
    return LogInCredentials.defaultCredentials
}
```
```swift
///displays an alert with the specified message
func showError(message message: String) {
    let alertController = UIAlertController(title: message, message: nil, preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))

    presentViewController(alertController, animated: true, completion: nil)
}
```

In the `submitButtonPressed` method these methods will be used
```swift
@IBAction func submitButtonPressed(sender: AnyObject?) {
    //verify that the entered information is valid
    guard let credentials = generateCredentials() else {
        showError(message: "Entered Information is incomplete or invalid")
        return
    }

    //2. log-in using `SessionManager`
    //3. Verify result and if successful call `completionHandler` if failed show error
}
```

##### 2. Performing the log-in
```swift
@IBAction func submitButtonPressed(sender: AnyObject?) {
    //verify that the entered information is valid
    guard let credentials = generateCredentials() else {
        showError(message: "Entered Information is incomplete or invalid")
        return
    }

    //disable textFields so user cannot edit information while it is being submitted
    emailTextfield.userInteractionEnabled = false
    passwordTextfield.userInteractionEnabled = false
    submitButton.enabled = false

    //attempt sign-in using the verified credentials
    SessionManager.shared.logIn(credentials) { (result) in
      //3. Verify result and if successful call `completionHandler` if failed show error
    }
}
```

##### 3. Handling the result
```swift
@IBAction func submitButtonPressed(sender: AnyObject?) {
    //verify that the entered information is valid
    guard let credentials = generateCredentials() else {
        showError(message: "Entered Information is incomplete or invalid")
        return
    }

    //disable controls so user cannot edit information while it is being submitted
    emailTextfield.userInteractionEnabled = false
    passwordTextfield.userInteractionEnabled = false
    submitButton.enabled = false
    activityIndicator.startAnimating()

    //attempt sign-in using the verified credentials
    SessionManager.shared.logIn(credentials) { (result) in

      //reenable controls
      self.emailTextfield.userInteractionEnabled = true
      self.passwordTextfield.userInteractionEnabled = true
      self.submitButton.enabled = true
      self.activityIndicator.stopAnimating()

      //check result
      switch result {
      case .Success(let patient):
          //Was successful call completionHandler
          self.completionHandler?(patient: patient)
      case .Error(_):
          //Failed show Error Message
          self.showError(message: "Something went wrong")
      }
    }
}
```

The finished `PatientSignInViewController` implementation can be found [here](resources/step5/PatientSignInViewController.swift)

## Conclusion
You built a Log-In Interface and functionality and implemented the SessionManager.

Next-Up is building the `PatientMedicationsViewController`

[Continue with Step6 of the Tutorial](STEP6.md)
