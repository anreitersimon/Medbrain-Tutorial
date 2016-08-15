# Step 6.1 Implementing PatientMedicationsViewController - PatientMedicationsViewController Interface

Creating the `PatientMedicationsViewController` is very similar to creating  the `PatientSignInViewController` interface:
- Create a `UITableViewController` subclass named `PatientMedicationsViewController`
- In the `Main.storyboard` select the `PatientMedicationsViewController` and set its class to `PatientMedicationsViewController`

#### Creating the StatusView
This `View Controller` loads data from a remote source.
While performing such a task its common practice to do this asynchronously. (While performing this task the user can still interact with the app.)

To inform the user that the app is fetching data it displays a StatusView.

The StatusView has responsibility for displaying:
- loading states
- error states
- empty states


##### Define the outlets in the implementation.
The StatusView consists of two elements:
- loading-indicator
- title-label

For these and the StatusView itself outlets are declared.

Add the following to the `PatientMedicationsViewController`

```swift
@IBOutlet var statusView: UIView!
@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
@IBOutlet weak var statusTitleLabel: UILabel!
```

drag a view object from the `object-library` onto the `PatientMedicationsViewController`

![](resources/step6/add_statusview.gif)

Again the implementation of the design will not be explained in depth.
The important part is that all elements are added.

The end-result can look like this:

![](resources/step6/statusview.png)

Connect the storyboard-elements to the outlets.

![](resources/step6/connect_status_outlets.gif)

To actually show the statusView this has to be set to be the tableViews backgroundView. In order to accomplish this the `viewDidLoad()` method is overridden. Once the `ViewControllers`view is created the `viewDidLoad()` method gets called. At this point all storyboard-elements have been linked up.

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    tableView.backgroundView = statusView
}
```
To keep track of the state a `State` enum and a corresponding property are introduced:
```swift
enum State {
    //Starting state show nothing
    case Initial

    //Fetching medications from the server
    case LoadingResults

    //Fetching medications failed
    case Error

    //Fetching medications succeeded but list was empty
    case Empty

    //Fetching medications succeeded
    case Loaded
}

var state: State = .Initial
```

Additionally 3 convenience accessors are added to the `State` enum:

```swift
///does the statusView need to be shown
var showsStatusView: Bool {
    switch self {
    case .Initial, .LoadingResults, .Error, .Empty:
        return true
    case .Loaded:
        return false
    }
}

///when the statusView is show should the loading-indicator be displayed
var showsLoadingIndicator: Bool {
    switch self {
    case .LoadingResults:
        return true
    case .Initial, .Error, .Empty, .Loaded:
        return false
    }
}

///The text displayed in the statusView
var title: String? {
    switch self {
    case .Initial:
        return nil
    case .LoadingResults:
        return "Loading..."
    case .Error:
        return "Error"
    case .Empty:
        return "No Prescriptions"
    case .Loaded:
        return nil
    }
}
```


The `View Controller` has to be able to display every state which is why a new method `configure(forState state: State)` is added:

```swift
func configure(forState state: State) {
    //Hide/show the statusView
    statusView.hidden = !state.showsStatusView

    //Hide show the titleLable
    statusTitleLabel.hidden = state.title?.isEmpty ?? true
    statusTitleLabel.text = state.title ?? " "


    //Start/Stop Animating the activityIndicator
    if activityIndicator.isAnimating() && !state.showsLoadingIndicator {
        activityIndicator.stopAnimating()
    } else if !activityIndicator.isAnimating() && state.showsLoadingIndicator {
        activityIndicator.startAnimating()
    }
}
```
The above mentioned method should be executed every time the controllers `state` changes. This can be achieved by adding a `property observer` to the `state` property.

```swift
var state: State = .Initial {
    didSet {
        configure(forState: state)
    }
}
```

To initially configure the `statusView` the `viewDidLoad()` has to be modified as follows:

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    tableView.backgroundView = statusView

    //configure the statusView for the current state
    configure(forState: state)
}
```

[Continue with Step 6.2 of the Tutorial](STEP6-2.md)
