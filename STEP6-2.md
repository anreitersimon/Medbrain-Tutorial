### Implementing PatientMedicationsViewController - Ensuring the user is logged in

When the user navigates to the `PatientMedicationsViewController` it is possible that the user hasnt logged in yet.


`UIViewController` (and its subclasses) have methods that are invoked by the framework for specific lifecycle events.

of particular interest is the `viewDidAppear(animated: Bool)` method.

This method gets called after the view-controller has appeared.


Before overriding this method the `PatientMedicationsViewController` needs a way to show the `PatientSignInViewController`

This is done via a `StoryboardSegue`.

In a previous step we set up a segue from `PatientMedicationsViewController` to the `PatientSignInViewController`
But to invoke this segue it hast to be assigned an identifier.

- In the `Main.storyboard` select the `PatientMedicationsViewController` and in the `Attributes Inspector` assign `showSignIn` as identifier.

#### overriding viewDidAppear

Add the following to the `PatientMedicationsViewController` implementation.
```swift
    var isSigninIn: Bool = false

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        ///if the user is not signed in show the PatientSignInViewController
        if SessionManager.shared.patient == nil && !isSigninIn {
            performSegueWithIdentifier("showSignIn", sender: nil)
            return
        }
    }
```

Now the `PatientSignInViewController` is shown but after the user signs-in successfully the `PatientSignInViewController` never is dismissed.

for this purpose the `completionHandler` property on the `PatientSignInViewController` was introduced.

To set this property we need a reference to the signInController.

This can be achieved by overriding `prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)`

This method gets called before a segue is executed.
```swift
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    if segue.identifier == "showSignIn" {
         //Get a reference to the signInController
         let signInController = segue.destinationViewController as! PatientSignInViewController

        //set isSigninIn flag to true
        isSigninIn = true

        //Set the completionHandler
        signInController.completionHandler = { (patient) in
            //Dismiss the signInController and wait for the animation to finish
            self.dismissViewControllerAnimated(true) {
                self.isSigninIn = false

                //Now that the patient is signed in it the prescriptions can be loaded
                self.loadContent() //NOTE: This function will be implemented later
            }
        }
    }
}
```


[Continue with Step 6.3 of the Tutorial](STEP6-3.md)
