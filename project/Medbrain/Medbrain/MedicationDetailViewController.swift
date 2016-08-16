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

    }



}
