# Step 7.2 - Implementing MedicationDetailViewController - Loading and displaying all administrations for a prescription


#### Defining properties

The administrations in this `View` are loaded for a specific `MedicationOrder`

Add a new property called `medicationOrder`
```swift
///medicationOrder for which details are shown
///NOTE: - This property has to be set before `viewDidLoad()` is called
var medicationOrder: MedicationOrder!
```

As before the results are loaded asynchronously.

The previously declared `State` enum as well as the `configure(forState state: State)` method will be added.

Add the `state` property and a initially empty implementation of `configure(forState state: State)`
```swift


var state: State = .Initial {
    didSet {
        configure(forState: state)
    }
}

func configure(forState state: State) {
  //will be implemented later
}
```

In this controller a list of `MedicationAdministrations` will be shown.

Add a property named `administrations`

```swift
var administrations: [MedicationAdministration] = [] {
    didSet {
        tableView.reloadData()
    }
}
```
#### Implementing `UITableViewDataSource` methods

This implementation will be very similar to the implementation done in [STEP-6](STEP6-4.md)

```swift
override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
  //the tableView should display a single section
  return 1
}

override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  //in the section the number of items should be the number of medicationOrders
  return administrations.count
}

override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  //dequeue cell with the identifier specified in the storyboard
  let cell = tableView.dequeueReusableCellWithIdentifier("MedicationAdministrationTableViewCell", forIndexPath: indexPath) as! MedicationAdministrationTableViewCell

  //find the medicationOrder at the index
  let medicationAdministration = administrations[indexPath.row]

  //Configuring the cell will be implemented later

  return cell
}
```

#### Configure the MedicationAdministrationTableViewCell
In the `MedicationAdministrationTableViewCell` implementation import the `SMART` framework
add a method called `configure(administration: MedicationAdministration)` with the following contents.

```swift

static let dateFormatter: NSDateFormatter = {

    let formatter = NSDateFormatter()
    formatter.dateStyle = .LongStyle

    return formatter
}()

func configure(administration: MedicationAdministration) {
  //set transparent color to the contentView
  contentView.backgroundColor = UIColor.clearColor()

  //try to get the date when the medication was administered / not administered
  if let date = administration.effectiveTimeDateTime?.date.nsDate ?? administration.effectiveTimePeriod?.start?.nsDate {
      detailTextLabel?.text = MedicationAdministrationTableViewCell.dateFormatter.stringFromDate(date)
  } else {
      detailTextLabel?.text = "-"
  }

  //if the medication was not taken set red backgroundColor
  if let wasNotGiven = administration.wasNotGiven where wasNotGiven {
      textLabel?.text = "not taken"

      backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2)
  } else {
      textLabel?.text = "taken"
      backgroundColor = UIColor.whiteColor()
  }
}
```

Now that the `configure(administration: MedicationAdministration)` method is implemented it needs to be called.

Navigate to the `MedicationDetailViewController` and add the call to configure the cell.

```swift
override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  //dequeue cell with the identifier specified in the storyboard
  let cell = tableView.dequeueReusableCellWithIdentifier("MedicationAdministrationTableViewCell", forIndexPath: indexPath) as! MedicationAdministrationTableViewCell

  //find the medicationOrder at the index
  let medicationAdministration = administrations[indexPath.row]

  cell.configure(medicationAdministration)

  return cell
}
```

### Implement loading of administrations

A user can only reach this screen if he has signed in already.
So the content can be loaded immediately when the screen has appeared.

Next the `loadContent()` method will be implemented and called from `viewDidAppear(animated: Bool)`:
```swift

override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    loadContent()
}

func loadContent() {

    //ensure the medicationOrder has an id (this should always be the case)
    guard let id = medicationOrder.id else {
        state = .Error
        return
    }

    //transition to the loading state
    state = .LoadingResults


    //Perform a search of MedicationAdministrations for the medicationOrder
    MedicationAdministration.search(["prescription": id]).perform(SessionManager.shared.server) { [weak self](bundle, error) in

        dispatch_async(dispatch_get_main_queue()) {
            guard let strongSelf = self else {
                return
            }

            //if a error occurred reset the administrations and transition to the error state
            guard error == nil else {
                strongSelf.administrations = []
                strongSelf.state = .Error
                return
            }


            let administrations = bundle?.entry?.flatMap { $0.resource as? MedicationAdministration} ?? []

            strongSelf.administrations = administrations
            strongSelf.state = administrations.isEmpty ? .Empty : .Loaded

        }
    }
}

```
