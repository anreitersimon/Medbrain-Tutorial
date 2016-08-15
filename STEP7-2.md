### Implementing `MedicationDetailViewController` - Loading results


#### Defining properties

The administrations in this view are loaded for a specific `MedicationOrder`

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
in the `MedicationAdministrationTableViewCell` implementation import the `SMART` framework
add a method called `configure(administration: MedicationAdministration)` with the following contents.

```swift
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
