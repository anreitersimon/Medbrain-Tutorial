//
//  PatientMedicationsViewController.swift
//  Medbrain
//
//  Created by Simon Anreiter on 16/08/16.
//  Copyright © 2016 Simon Anreiter. All rights reserved.
//

import UIKit
import SMART

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


    var showsStatusView: Bool {
        switch self {
        case .Initial, .LoadingResults, .Error, .Empty:
            return true
        case .Loaded:
            return false
        }
    }

    var showsLoadingIndicator: Bool {
        switch self {
        case .LoadingResults:
            return true
        case .Initial, .Error, .Empty, .Loaded:
            return false
        }
    }

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
}

class PatientMedicationsViewController: UITableViewController {

    @IBOutlet var statusView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusTitleLabel: UILabel!

    var isSigninIn: Bool = false

    var medicationOrders: [MedicationOrder] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var state: State = .Initial {
        didSet {
            configure(forState: state)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundView = statusView
        tableView.tableFooterView = UIView(frame: .zero)

        //configure the statusView for the current state
        configure(forState: state)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if SessionManager.shared.patient == nil && !isSigninIn {
            performSegueWithIdentifier("showSignIn", sender: nil)
            return
        }
    }

    func configure(forState state: State) {
        statusView.hidden = !state.showsStatusView

        statusTitleLabel.hidden = state.title?.isEmpty ?? true
        statusTitleLabel.text = state.title ?? " "


        if activityIndicator.isAnimating() && !state.showsLoadingIndicator {
            activityIndicator.stopAnimating()
        } else if !activityIndicator.isAnimating() && state.showsLoadingIndicator {
            activityIndicator.startAnimating()
        }

        statusView.setNeedsLayout()
        statusView.layoutIfNeeded()
    }

    func loadContent() {
        state = .LoadingResults

        guard let patient = SessionManager.shared.patient, patientId = patient.id else {
            state = .Error
            return
        }

        MedicationOrder.search(["patient": patientId]).perform(SessionManager.shared
            .server) { [weak self](bundle, error) in

                dispatch_async(dispatch_get_main_queue()) {

                    guard let strongSelf = self else {
                        return
                    }
                    guard error == nil else {
                        strongSelf.medicationOrders = []
                        strongSelf.state = .Error
                        return
                    }

                    let meds = bundle?.entry?.flatMap { $0.resource as? MedicationOrder } ?? []

                    strongSelf.refreshControl?.endRefreshing()
                    strongSelf.state = meds.isEmpty ? .Empty : .Loaded

                    strongSelf.medicationOrders = meds
                }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicationOrders.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MedicationOrderTableViewCell", forIndexPath: indexPath) as! MedicationOrderTableViewCell

        let medicationOrder = medicationOrders[indexPath.row]

        cell.configure(medicationOrder)

        return cell
    }

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
}
