### Implementing PatientMedicationsViewController - PatientMedicationsViewController Interface


Similar to creating  the `PatientSignInViewController` interface:
- Create a `UITableViewController` subclass named `PatientMedicationsViewController`
- In the `Main.storyboard` select the `PatientMedicationsViewController` and set its class to `PatientMedicationsViewController`

#### Creating the StatusView
This ViewController loads data from a remote source.
While performing such a task its common practice to do this asynchronously. (While performing this task the user can still interact with the app.)

To inform the user that the app is fetching data it displays a StatusView.

This StatusView has responsibility for displaying:
- loading states
- error states
- empty states


##### Define the outlets in the implementation.
The StatusView consists of two elements:
- loading-indicator
- title-label

for these and the StatusView itself outlets are declared.

Add the following to the `PatientMedicationsViewController`

```swift
@IBOutlet var statusView: UIView!
@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
@IBOutlet weak var statusTitleLabel: UILabel!
```

drag a view object from the object-library onto the `PatientMedicationsViewController`

![](resources/step6/add_statusview.gif)

Again the implementation of the design will not be explained in depth.
The important part is that all elements are added.

The end-result can look like this:

![](resources/step6/statusview.png)

Connect the storyboard-elements to the outlets.

![](resources/step6/connect_status_outlets.gif)


[Continue with Part 2 of this Step](STEP6-2.md)
