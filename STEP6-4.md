# Step 6.4 - Implementing PatientMedicationsViewController -  Loading and displaying all prescriptions for the logged-in user

The ViewController needs to display a list of `MedicationOrders`

Therefore the `View Controller` needs to store the list of medications somewhere.

A new property called `medicationOrders` is introduced.
Each time the `medicationOrders` are changed the tableView needs to be reloaded.
```swift

///medicationOrders to display in the list
var medicationOrders: [MedicationOrder] = [] {
  didSet {
    tableView.reloadData()
  }
}
```

### Creating the MedicationOrderTableViewCell
1. Create a new `Cocoa Touch Class` named `MedicationOrderTableViewCell` and make it a subclass of `UITableViewCell`
2. In the `Main.storyboard` select the `PatientMedicationsViewController`
>__Note:__ By default in a `UITableViewController` a single table-view-cell prototype is created.
4. Select the first cell
5. In the `Identity Inspector` change its class to `MedicationTableViewCell`
6. In the `Attributes Inspector` change its style to `Subtitle`
7. In the `Attributes Inspector` assign it the identifier `MedicationOrderTableViewCell`
>__Note:__ This identifier will be used later to instantiate a cell of this type


### Configuring the MedicationOrderTableViewCell
The `MedicationOrderTableViewCell` represents a single item in the list.

Each cell is configured for a single `MedicationOrder`. In the `MedicationOrderTableViewCell` implementation import the `SMART` framework and add the following method

```swift
func configure(medicationOrder: MedicationOrder) {
    self.textLabel?.text = medicationOrder.medicationName
    self.detailTextLabel?.text = medicationOrder.localizedInstructions
}
```

### Preparing the display of MedicationOrderTableViewCells

`PatientMedicationsViewController` is a subclass of `UITableViewController`

the `UITableViewController` conforms to the `UITableViewDataSource` protocol.

The tableView requires the dataSource to implement the following methods:

```swift
func numberOfSectionsInTableView(tableView: UITableView) -> Int

func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int

func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell

```

These methods should be implemented as follows:

```swift
override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
  //the tableView should display a single section
  return 1
}

override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  //in the section the number of items should be the number of medicationOrders
  return medicationOrders.count
}

override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  //dequeue cell with the identifier specified in the storyboard
  let cell = tableView.dequeueReusableCellWithIdentifier("MedicationOrderTableViewCell", forIndexPath: indexPath) as! MedicationOrderTableViewCell

  //find the medicationOrder at the index
  let medicationOrder = medicationOrders[indexPath.row]

  //configure the cell
  cell.configure(medicationOrder)

  return cell
}
```

Now the tableView is able to display the `medicationOrders`.

### Loading the results

When the sign-in finished the method `loadContent()` was called.
Now this function will be implemented.

```swift
func loadContent() {

    //transition to the loading state
    state = .LoadingResults

    //ensure a patient is logged in and it has an id
    guard let patient = SessionManager.shared.patient, patientId = patient.id else {
        //transition to the error state
        state = .Error
        return
    }

    //perform a query search all MedicationOrder prescribed for the logged in patient
    MedicationOrder.search(["patient": patientId]).perform(SessionManager.shared
        .server) { [weak self](bundle, error) in
            dispatch_async(dispatch_get_main_queue()) {

                //self was captured weakly
                //if the ViewController was deallocated while the search is in progress dont try to access self
                //doing so would crash the app
                guard let strongSelf = self else {
                    return
                }

                //if a error occurred reset the medicationOrders and transition to the error state
                guard error == nil else {
                    strongSelf.medicationOrders = []
                    strongSelf.state = .Error
                    return
                }

                //extract all medicationOrders from the result
                let meds = bundle?.entry?.flatMap { $0.resource as? MedicationOrder } ?? []

                //if no medicationOrders where found transition to the empty state
                strongSelf.state = meds.isEmpty ? .Empty : .Loaded

                strongSelf.medicationOrders = meds
            }
    }
}
```

[Continue with Step 7 of the Tutorial](STEP7.md)
