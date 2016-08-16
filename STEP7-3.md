# Step 7.3 - Implementing MedicationDetailViewController - Rendering a chart visualizing a timeline of administrations

#### Configuring the view
In a previous step [Step 7.1](STEP7-1.md) the UI-elements were added in the storyboard and connected to the corresponding outlets. But the view was never configured for the corresponding content/state.


#### Configuring the view for state
Start of by implementing the `configure(forState state: State)` method.
```swift
func configure(forState state: State) {
    //only show the chart if data has loaded successfully
    chartView.hidden = state != .Loaded

    //start/stop the activityIndicator if needed
    if state.showsLoadingIndicator && !activityIndicator.isAnimating() {
        activityIndicator.startAnimating()
    } else if !state.showsLoadingIndicator && activityIndicator.isAnimating() {
        activityIndicator.stopAnimating()
    }
}
```

#### Configuring the view for the prescription
The view is correctly showing a list of all administrations for a given prescription. But the `MedicationDetailViewController` should also show for which `Medication` data is shown.
A new function named `configure(forMedicationOrder medicationOrder: MedicationOrder)` is implemented. This function uses the previously declared properties defined in `MedicationOrder+Instructions.swift`.

```swift
func configure(forMedicationOrder medicationOrder: MedicationOrder) {
    navigationItem.title = medicationOrder.medicationName

    titleLabel.text = medicationOrder.medicationName
    subtitleLabel.text = medicationOrder.localizedInstructions
}
```

Additionally some setup has to be performed in the `MedicationDetailViewControllers` `viewDidLoad()` method.

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    //`MedicationDetailViewController` will provide chart data
    chartView.dataSource = self

    configure(forState: state)
    configure(forMedicationOrder: medicationOrder)
}
```
#### Implementing the `SegmentedControl` functionality

In the storyboard a `SegmentedControl` was added which allows the user to modify how the chart renders its data.
The user can select to group medications by:
- Year
- Month
- Week
- Day

To express this in code a new `enum` named `DateGroupingMode` is introduced.

```swift
enum DateGroupingMode: Int {
    case Year = 0
    case Month = 1
    case Week = 2
    case Day = 3
}
```

>__Note:__ This enum was specified as a `Int` `enum` this is helpful when used in combination with `SegmentedControl` which exposes its current selection via the `selectedSegmentIndex` property.
>The `selectedSegmentIndex` corresponds to the `DateGroupingMode` rawValue.

Add a property named `groupingMode` to the `MedicationDetailViewController`. Each time this property changes the charts data needs to be updated.

Additionally every time the `administrations` change the chartData has to be updated as well.

```swift
var groupingMode: DateGroupingMode = .Month {
    didSet {
        updateChartData()
    }
}

var administrations: [MedicationAdministration] = [] {
    didSet {
        tableView.reloadData()
        updateChartData()
    }
}


func updateChartData() {
  //will be implemented later
}
```

Add the following to the `segmentedControlChanged(sender: AnyObject?)` implementation:
```swift
@IBAction func segmentedControlChanged(sender: AnyObject?) {
    groupingMode = DateGroupingMode(rawValue: segmentedControl.selectedSegmentIndex)!
}
```

#### Implementing the Chart
The charts data is dependent on the `MedicationDetailViewControllers` `administrations` and `groupingMode` and has to perform some processing to group the administrations.
Two helper-functions which extend `NSDate` are introduced.

The first helper-function generates a `identifier` from a `NSDate` object using a specified `DateGroupingMode`.
Each administration generates a identifier and all administrations with the same identifier fall into the same group.

Consider the following example:
- `Adminstration1` was administered on (Monday - 15.08.2016)
- `Adminstration2` was administered on (Tuesday - 16.08.2016)
- `Adminstration3` was administered on (Friday - 20.02.2015)

The following identifiers will be generated for these administration-dates:

|                  | Year   | Month      | Week      | Day          |
| :--------------- | :----- | :--------- | :-------- | :----------- |
| Administration1  | `2016` | `2016-08`  | `2016-34` | `2016-08-15` |
| Administration2  | `2016` | `2016-08`  | `2016-34` | `2016-08-16` |
| Administration3  | `2016` | `2016-02`  | `2016-08` | `2016-02-20` |


When grouping by `Year` all administration dates generate the same identifier and are therefore in the same group.
But when grouping by `Month` only `Administration1` and `Administration2` fall into the same group.

#### Generating identifiers
Create a new File named `NSDate+DateGrouping.swift`

In it add the following implementation:
```swift
extension NSDate {
  func identifier(groupingMode mode: DateGroupingMode) -> String {

    //specify which calendar-units to use
    let units: NSCalendarUnit

    switch mode {
    case .Day:
        units = [ .Year, .Month, .Day ]
    case .Week:
        units = [ .Year, .WeekOfYear ]
    case .Month:
        units = [ .Year, .Month]
    case .Year:
        units = [ .Year]
    }

    let calendar = NSCalendar.currentCalendar()

    let components = calendar.components(units, fromDate: self)

    switch mode {
    case .Day:
        return String(format: "%04d-%02d-%02d", components.year, components.month, components.day)
    case .Week:
        return String(format: "%04d-%02d", components.year, components.weekOfYear)
    case .Month:
        return String(format: "%04d-%02d", components.year, components.month)
    case .Year:
        return String(format: "%04d", components.year)
    }
  }
}

```


A second convenience function called `predecessor(groupingMode mode: DateGroupingMode)->NSDate` is added. This method returns a date which lies in the group directly before the current dates group.

```swift
  ///returns: - a date which lies in the group directly before this dates group
  func predecessor(groupingMode mode: DateGroupingMode)->NSDate {
    let calendar = NSCalendar.currentCalendar()

    let components = NSDateComponents()

    switch mode {
    case .Day:
        components.day = -1
    case .Week:
        components.weekOfYear = -1
    case .Month:
        components.month = -1
    case .Year:
        components.year = -1
    }

    return calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions.MatchStrictly)!
  }
```

#### Creating the Charts Data-Model
The charts Data-Model will be created in a new `struct` called `GraphData`

```swift
struct GraphData {

    //Represents a group in the graph
    struct GroupData {
        let identifier: String

        ///count of medications which where administered
        let countTaken: Int
        ///count of medications which were not administered
        let countNotTaken: Int
    }

    //each item represents a group the values represent the count of administrations
    let content: [GroupData]


    init(_ administrations: [MedicationAdministration], groupingMode mode: DateGroupingMode, maxGroups: Int = 7) {
        var takenIdentifierToCounts = [String:Int]()
        var missedIdentifierToCounts = [String:Int]()

        //Start with the current date
        var current = NSDate()

        var identifiers = [String]()

        for _ in 0...maxGroups {
            let identifier = current.identifier(groupingMode: mode)

            identifiers.append(identifier)

            current = current.predecessor(groupingMode: mode)
        }

        for administration in administrations {
            guard let date = administration.effectiveTimeDateTime?.date.nsDate ?? administration.effectiveTimePeriod?.start?.nsDate else { continue }

            let identifier = date.identifier(groupingMode: mode)

            if !(administration.wasNotGiven ?? false) {

                takenIdentifierToCounts[identifier] = (takenIdentifierToCounts[identifier] ?? 0) + 1
            } else {

                missedIdentifierToCounts[identifier] = (missedIdentifierToCounts[identifier] ?? 0) + 1
            }

        }


        content = identifiers.map { GroupData(identifier: $0, countTaken: takenIdentifierToCounts[$0] ?? 0, countNotTaken:  missedIdentifierToCounts[$0] ?? 0) }.reverse()
    }
}
```


Add a property called `graphData` to the `MedicationDetailViewController`. Each time the graphData changes the `chartView` should be reloaded.

```swift
var graphData: GraphData =  GraphData([], groupingMode: DateGroupingMode.Day) {
    didSet {
        //WORKAROUND: - ORKLineGraphChartView has no explicit reloadData() method. Setting its dataSource property triggers a reload
        chartView.dataSource = self

        //animated the change
        chartView.animateWithDuration(0.2)
    }
}
```


#### Implementing the `updateChartData()` function
Above the `updateChartData()` method was defined which gets called every time the `administrations` or the `groupingMode` changes. In this method the `graphData` should be recomputed.

```swift
func updateChartData() {
    graphData = GraphData(administrations, groupingMode: groupingMode)
}
```

#### Implementing the `ORKGraphChartViewDataSource` protocol methods
The `chartView` expects the data to be rendered to be provided by a object conforming to the `ORKGraphChartViewDataSource`.

The `MedicationDetailViewController` will implement these methods in a extension:

```swift
extension MedicationDetailViewController: ORKGraphChartViewDataSource {

    ///Display two lines one for the medications which were taken, one for the medications which were not taken
    func numberOfPlotsInGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 2
    }


    func graphChartView(graphChartView: ORKGraphChartView, numberOfPointsForPlotIndex plotIndex: Int) -> Int {
        return graphData.content.count
    }

    //The line representing medications which were not taken should be red
    //The other line should use the views tintColor
    func graphChartView(graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
        if plotIndex == 1 {
            return view.tintColor
        } else {
            return UIColor.redColor()
        }
    }


    func graphChartView(graphChartView: ORKGraphChartView, pointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKRangedPoint {

        if plotIndex == 1 {
            return ORKRangedPoint(value: CGFloat(graphData.content[pointIndex].countTaken))
        } else {
            return ORKRangedPoint(value: CGFloat(graphData.content[pointIndex].countNotTaken))
        }

    }
}
```

Now the `MedicationDetailViewController` is able to fully display the administrations for the `medicationOrder` thats is set.

But the link from the `PatientMedicationsViewController` is not yet established.


#### Connecting MedicationDetailViewController and PatientMedicationsViewController

Navigate to the `Main.storyboard` and select the `Segue` going from the `PatientMedicationsViewController` to the `MedicationDetailViewController`. In the `Attributes Inspector` assign it the identifier `showMedication`.

Go to the `PatientMedicationsViewController`.

The `MedicationDetailViewController` should be shown when the user selects a item in the list.
The item that should be shown is the one the user tapped on.

`UITableView` can be assigned a `delegate` which must conform to the `UITableViewDelegate` protocol.
The delegate can be used to modify certain aspects of how the `tableView` displays its content. (for instance: the height of cells).
Additionally the delegate is informed when a cell is selected.

To receive these notifications the `func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)` method must be implemented.

When a cell is selected the previously added segue with identifier `showMedication` is executed.

```swift
override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("showMedication", sender: nil)
}
```

Before performing the `Segue` the `prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)` function is invoked. In this function the selected `medicationOrder` is passed to the `MedicationDetailViewController`

```swift

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showSignIn" {
             let signInController = segue.destinationViewController as! PatientSignInViewController

            isSigninIn = true

            signInController.completionHandler = { (patient) in
                self.dismissViewControllerAnimated(true) {
                    self.isSigninIn = false

                    self.loadContent()
                }
            }
        } else if segue.identifier == "showMedication" {
            let detailController = segue.destinationViewController as! MedicationDetailViewController

            let selectedMedication = medicationOrders[tableView.indexPathForSelectedRow!.row]

            detailController.medicationOrder = selectedMedication
        }
    }
```

## Conclusion
You:
- added a new dependency (`ResearchKit`)
- implemented a list showing all `MedicationAdministrations`
- loaded all `MedicationAdministrations` for a specific prescription from a remote server
- implemented a graph visualizing the timeline of administrations

Next-up is Creating a `MedicationAdministration`

[Continue with Step 8 of the Tutorial](STEP8.md)
