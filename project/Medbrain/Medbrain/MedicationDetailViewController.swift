//
//  MedicationDetailViewController.swift
//  Medbrain
//
//  Created by Simon Anreiter on 15/08/16.
//  Copyright © 2016 Simon Anreiter. All rights reserved.
//

import UIKit
import ResearchKit
import SMART

enum DateGroupingMode: Int {

    case Year = 0
    case Month = 1
    case Week = 2
    case Day = 3

}


extension MedicationAdministration {
    var _date: NSDate? {
        return  effectiveTimeDateTime?.date.nsDate ?? effectiveTimePeriod?.start?.nsDate
    }
}

struct GraphData {

    struct GroupData {
        let identifier: String

        let countTaken: Int
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
            guard let date = administration._date else { continue }

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

class MedicationDetailViewController: UITableViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var chartView: ORKLineGraphChartView!

    var medicationOrder: MedicationOrder!

    var administrations: [MedicationAdministration] = [] {
        didSet {
            tableView.reloadData()
            updateGraphData()
        }
    }

    var groupingMode: DateGroupingMode = .Month {
        didSet {
            updateGraphData()
        }
    }

    func updateGraphData() {
        graphData = GraphData(administrations, groupingMode: groupingMode)
    }

    var graphData: GraphData =  GraphData([], groupingMode: DateGroupingMode.Day) {
        didSet {
            //WORKAROUND: - ORKLineGraphChartView has no explicit reloadData() method setting its dataSource property triggers a reload
            chartView.dataSource = self

            //animated the change
            chartView.animateWithDuration(0.4)
        }
    }

    var state: State = .Initial {
        didSet {
            configure(forState: state)
        }
    }

    func configure(forState state: State) {
        //will be implemented later

        chartView.hidden = state != .Loaded
        if state.showsLoadingIndicator && !activityIndicator.isAnimating() {
            activityIndicator.startAnimating()
        } else if !state.showsLoadingIndicator && activityIndicator.isAnimating() {
            activityIndicator.stopAnimating()
        }
    }

    func configure(forMedicationOrder medicationOrder: MedicationOrder) {
        navigationItem.title = medicationOrder.medicationName

        titleLabel.text = medicationOrder.medicationName
        subtitleLabel.text = medicationOrder.localizedInstructions
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        chartView.dataSource = self
        configure(forState: state)
        configure(forMedicationOrder: medicationOrder)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        loadContent()
    }

    @IBAction func segmentedControlChanged(sender: AnyObject?) {
        groupingMode = DateGroupingMode(rawValue: segmentedControl.selectedSegmentIndex)!
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

    // MARK: - Table view data source

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


        cell.configure(medicationAdministration)

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Administrations"
    }

}

extension MedicationDetailViewController: ORKGraphChartViewDataSource {

    func graphChartView(graphChartView: ORKGraphChartView, numberOfPointsForPlotIndex plotIndex: Int) -> Int {
        return graphData.content.count
    }

    func numberOfPlotsInGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 2
    }

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
